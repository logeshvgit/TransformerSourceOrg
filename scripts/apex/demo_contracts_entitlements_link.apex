/**
 * Creates several Service Contracts + Entitlements, then sets Case.EntitlementId
 * for Cases whose Account matches each Entitlement’s Account.
 *
 * Expects Accounts named "PrintCo Customer%" (e.g. from scripts/apex/demo_cases_20.apex).
 * If Case.EntitlementId is not available, SC + Entitlements are still created; enable
 * Entitlement Management in Setup, then re-run to link Cases.
 * Each run inserts new contracts (duplicate names possible) — delete old demo data if needed.
 *
 * Run: sf apex run --file scripts/apex/demo_contracts_entitlements_link.apex --target-org <alias>
 */

if (!Schema.getGlobalDescribe().containsKey('ServiceContract') || !Schema.getGlobalDescribe().containsKey('Entitlement')) {
    System.debug('ServiceContract or Entitlement not available in this org.');
    return;
}

Boolean caseCanLinkEntitlement = Schema.SObjectType.Case.fields.getMap().containsKey('EntitlementId');

List<Account> labAccounts = [
    SELECT Id, Name
    FROM Account
    WHERE Name LIKE 'PrintCo Customer%'
    ORDER BY Name
    LIMIT 20
];

if (labAccounts.isEmpty()) {
    System.debug('No accounts named PrintCo Customer%. Run scripts/apex/demo_cases_20.apex first or create Accounts.');
    return;
}

Date startD = Date.today().addMonths(-12);
Date endD = Date.today().addMonths(12);

List<ServiceContract> scToInsert = new List<ServiceContract>();

// One standard maintenance contract per PrintCo customer account (up to 5)
Integer cap = Math.min(5, labAccounts.size());
for (Integer i = 0; i < cap; i++) {
    Account a = labAccounts[i];
    String an = a.Name == null ? 'Account' : a.Name;
    if (an.length() > 40) {
        an = an.substring(0, 40);
    }
    scToInsert.add(
        new ServiceContract(
            AccountId = a.Id,
            Name = 'Standard Maintenance – ' + an,
            StartDate = startD,
            EndDate = endD,
            Term = 12
        )
    );
}

// Second contract on Enterprise Stable (if present) — managed print / production suite add-on
Id enterpriseStableId;
for (Account a : labAccounts) {
    if (a.Name != null && a.Name.contains('Enterprise Stable')) {
        enterpriseStableId = a.Id;
        break;
    }
}
if (enterpriseStableId != null) {
    scToInsert.add(
        new ServiceContract(
            AccountId = enterpriseStableId,
            Name = 'Managed Print Production Suite – Enterprise Stable',
            StartDate = startD,
            EndDate = endD,
            Term = 12
        )
    );
}

insert scToInsert;

Set<Id> scIds = new Set<Id>();
for (ServiceContract s : scToInsert) {
    scIds.add(s.Id);
}

// Reload SCs with AccountId
List<ServiceContract> insertedSc = [
    SELECT Id, AccountId, Name
    FROM ServiceContract
    WHERE Id IN :scIds
    ORDER BY Name
];

List<Entitlement> entToInsert = new List<Entitlement>();
for (ServiceContract sc : insertedSc) {
    entToInsert.add(
        new Entitlement(
            Name = 'Ent: ' + (sc.Name != null && sc.Name.length() > 75 ? sc.Name.substring(0, 75) : sc.Name),
            AccountId = sc.AccountId,
            ServiceContractId = sc.Id,
            StartDate = startD,
            EndDate = endD
        )
    );
}
insert entToInsert;

Set<Id> entIds = new Set<Id>();
for (Entitlement e : entToInsert) {
    entIds.add(e.Id);
}

List<Entitlement> insertedEnt = [
    SELECT Id, AccountId, Name, ServiceContractId
    FROM Entitlement
    WHERE Id IN :entIds
];

// Map AccountId -> list of Entitlement Ids (Enterprise Stable may have 2)
Map<Id, List<Id>> accountToEntIds = new Map<Id, List<Id>>();
for (Entitlement e : insertedEnt) {
    if (!accountToEntIds.containsKey(e.AccountId)) {
        accountToEntIds.put(e.AccountId, new List<Id>());
    }
    accountToEntIds.get(e.AccountId).add(e.Id);
}

List<Case> casesToFix = new List<Case>();
if (caseCanLinkEntitlement) {
    casesToFix = [
        SELECT Id, AccountId
        FROM Case
        WHERE AccountId IN :accountToEntIds.keySet()
        ORDER BY CaseNumber
    ];
    Integer rr = 0;
    for (Case c : casesToFix) {
        List<Id> ents = accountToEntIds.get(c.AccountId);
        if (ents == null || ents.isEmpty()) {
            continue;
        }
        Id chosen = ents.size() == 1 ? ents[0] : ents[Math.mod(rr, ents.size())];
        rr++;
        c.put('EntitlementId', chosen);
    }
    if (!casesToFix.isEmpty()) {
        update casesToFix;
    }
} else {
    System.debug(
        'Case.EntitlementId not available — enable Entitlement Management in Setup to link Cases. Service Contracts and Entitlements were still created.'
    );
}

System.debug('Service Contracts created: ' + insertedSc.size());
for (ServiceContract sc : insertedSc) {
    System.debug('  SC: ' + sc.Name + ' (' + sc.Id + ')');
}
System.debug('Entitlements created: ' + insertedEnt.size());
System.debug(
    caseCanLinkEntitlement ? ('Cases linked to Entitlement: ' + casesToFix.size()) : 'Cases not linked (enable Entitlement Management on Case)'
);

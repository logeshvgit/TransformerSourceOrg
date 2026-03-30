/**
 * Execute Anonymous — creates ~20 Cases with mixed subjects, origins, statuses, and accounts.
 * Priority comes from Case_Priority_Handler + Account_Size_Tier__c / Account_Customer_Status__c.
 * Deploy force-app first: sf project deploy start --source-dir force-app --target-org <alias>
 * Run: sf apex run --file scripts/apex/demo_cases_20.apex --target-org <alias>
 */

// --- Valid picklist values for this org ---
List<String> statusValues = new List<String>();
for (Schema.PicklistEntry pe : Case.Status.getDescribe().getPicklistValues()) {
    if (pe.isActive()) {
        statusValues.add(pe.getValue());
    }
}
List<String> originValues = new List<String>();
for (Schema.PicklistEntry pe : Case.Origin.getDescribe().getPicklistValues()) {
    if (pe.isActive()) {
        originValues.add(pe.getValue());
    }
}
if (originValues.isEmpty()) {
    originValues.add('Web');
}

// Prefer common progression for storytelling (falls back to describe order)
String statusNew = statusValues.contains('New') ? 'New' : statusValues[0];
String statusWorking =
    statusValues.contains('Working')
        ? 'Working'
        : (statusValues.size() > 1 ? statusValues[1] : statusValues[0]);
String statusEscalated =
    statusValues.contains('Escalated')
        ? 'Escalated'
        : (statusValues.size() > 2 ? statusValues[2] : statusValues[0]);
String statusClosed = statusValues.contains('Closed') ? 'Closed' : statusValues[statusValues.size() - 1];
String statusOnHold =
    statusValues.contains('On Hold') ? 'On Hold' : (statusValues.size() > 3 ? statusValues[3] : statusNew);

// Five accounts → Case_Priority_Handler sets Priority from tier/status when those fields exist (deploy Transformer package).
Map<String, Schema.SObjectField> accFields = Schema.SObjectType.Account.fields.getMap();
List<Account> labs = new List<Account>();
Account a1 = new Account(Name = 'PrintCo Customer – SMB Healthy');
if (accFields.containsKey('Account_Size_Tier__c')) {
    a1.put('Account_Size_Tier__c', 'SMB');
}
if (accFields.containsKey('Account_Customer_Status__c')) {
    a1.put('Account_Customer_Status__c', 'Healthy');
}
labs.add(a1);
Account a2 = new Account(Name = 'PrintCo Customer – Mid Market');
if (accFields.containsKey('Account_Size_Tier__c')) {
    a2.put('Account_Size_Tier__c', 'Mid_Market');
}
if (accFields.containsKey('Account_Customer_Status__c')) {
    a2.put('Account_Customer_Status__c', 'Healthy');
}
labs.add(a2);
Account a3 = new Account(Name = 'PrintCo Customer – Enterprise Stable');
if (accFields.containsKey('Account_Size_Tier__c')) {
    a3.put('Account_Size_Tier__c', 'Enterprise');
}
if (accFields.containsKey('Account_Customer_Status__c')) {
    a3.put('Account_Customer_Status__c', 'Healthy');
}
labs.add(a3);
Account a4 = new Account(Name = 'PrintCo Customer – Enterprise At Risk');
if (accFields.containsKey('Account_Size_Tier__c')) {
    a4.put('Account_Size_Tier__c', 'Enterprise');
}
if (accFields.containsKey('Account_Customer_Status__c')) {
    a4.put('Account_Customer_Status__c', 'At_Risk');
}
labs.add(a4);
Account a5 = new Account(Name = 'PrintCo Customer – Churning');
if (accFields.containsKey('Account_Size_Tier__c')) {
    a5.put('Account_Size_Tier__c', 'Mid_Market');
}
if (accFields.containsKey('Account_Customer_Status__c')) {
    a5.put('Account_Customer_Status__c', 'Churning');
}
labs.add(a5);
insert labs;

// Optional: contract + entitlement when Service Contracts / Entitlements are available
Id entitlementId;
Boolean caseHasEntitlementField = Schema.SObjectType.Case.fields.getMap().containsKey('EntitlementId');
if (
    Schema.getGlobalDescribe().get('ServiceContract').getDescribe().isCreateable() &&
    Schema.getGlobalDescribe().get('Entitlement').getDescribe().isCreateable() &&
    caseHasEntitlementField
) {
    ServiceContract sc = new ServiceContract(
        AccountId = labs[2].Id,
        Name = 'Standard Maintenance – Enterprise Stable',
        StartDate = Date.today().addMonths(-12),
        EndDate = Date.today().addMonths(12),
        Term = 24
    );
    insert sc;
    Entitlement ent = new Entitlement(
        Name = 'Depot & Field Service – Enterprise Stable',
        AccountId = labs[2].Id,
        ServiceContractId = sc.Id,
        StartDate = Date.today().addMonths(-12),
        EndDate = Date.today().addMonths(12)
    );
    insert ent;
    entitlementId = ent.Id;
}

List<String> flavors = new List<String>{
    'Billing – lease charge vs meter mismatch',
    'Print driver – Fiery queue dropping jobs',
    'Firmware – remote update to printer failing',
    'Mobile print – job stuck in release queue',
    'Color – RIP calibration drift on production press',
    'Finisher – booklet maker misalignment',
    'Dealer portal – toner reorder blocked',
    'Usage report – meter vs contract page count',
    'Email-to-case – duplicate toner tickets',
    'Knowledge – media compatibility for wide-format',
    'SLA – four-hour onsite response overdue',
    'Feature request – default duplex on fleet policy',
    'MIS integration – job status not updating',
    'Throughput – press below rated ppm',
    'Security – admin access to print controller',
    'Training – operator panel for new press',
    'Contract – page overage on quarterly true-up',
    'Warranty – extended coverage on fuser',
    'Supply chain – staple cartridge backorder',
    'VIP – production line stopped – press fault'
};

List<Id> accountCycle = new List<Id>{
    labs[0].Id,
    labs[1].Id,
    labs[2].Id,
    labs[3].Id,
    labs[4].Id,
    labs[0].Id,
    labs[1].Id,
    labs[2].Id,
    labs[3].Id,
    labs[4].Id,
    labs[0].Id,
    labs[1].Id,
    labs[2].Id,
    labs[3].Id,
    labs[4].Id,
    labs[0].Id,
    labs[1].Id,
    labs[2].Id,
    labs[3].Id,
    labs[4].Id
};

List<Case> toInsert = new List<Case>();
List<Integer> statusPattern = new List<Integer>{
    0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 0, 1, 2, 3, 4, 0, 1, 2, 3, 4
};
// 0=New, 1=Working, 2=Escalated, 3=OnHold, 4=Closed (mapped to org values below)

for (Integer i = 0; i < 20; i++) {
    String st;
    Integer pat = statusPattern[i];
    if (pat == 0) {
        st = statusNew;
    } else if (pat == 1) {
        st = statusWorking;
    } else if (pat == 2) {
        st = statusEscalated;
    } else if (pat == 3) {
        st = statusOnHold;
    } else {
        st = statusClosed;
    }

    Case c = new Case(
        AccountId = accountCycle[i],
        Subject = '(' + String.valueOf(i + 1) + ') ' + flavors[i],
        Status = st,
        Origin = originValues[Math.mod(i, originValues.size())],
        Description = 'PrintCo commercial printer support — seeded demo case #' + String.valueOf(i + 1) + '.'
    );
    // Entitlement must match Case.Account (entitlement is on labs[2])
    if (entitlementId != null && accountCycle[i] == labs[2].Id && Math.mod(i, 2) == 0) {
        c.put('EntitlementId', entitlementId);
    }
    toInsert.add(c);
}

insert toInsert;

List<Case> created = [
    SELECT CaseNumber, Subject, Status, Priority, Origin, Account.Name
    FROM Case
    WHERE Id IN :toInsert
    ORDER BY CaseNumber
];
System.debug('Created ' + created.size() + ' cases.');
for (Case c : created) {
    System.debug(
        c.CaseNumber +
            ' | ' +
            c.Subject +
            ' | ' +
            c.Status +
            ' | ' +
            c.Priority +
            ' | ' +
            c.Origin +
            ' | ' +
            c.Account.Name
    );
}

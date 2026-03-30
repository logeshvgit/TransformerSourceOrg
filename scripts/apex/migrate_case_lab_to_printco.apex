/**
 * One-time data migration: renames Accounts "Case Lab …" → "PrintCo Customer …"
 * and updates Service Contracts, Entitlements, and Cases whose text still contains "Case Lab".
 *
 * Safe to run multiple times (no-op when nothing matches).
 *
 * Run: sf apex run --file scripts/apex/migrate_case_lab_to_printco.apex --target-org <alias>
 */

final String OLD_TOKEN = 'Case Lab';
final String NEW_TOKEN = 'PrintCo Customer';

List<Account> accs = [
    SELECT Id, Name
    FROM Account
    WHERE Name LIKE 'Case Lab%'
];
for (Account a : accs) {
    if (a.Name != null) {
        a.Name = a.Name.replace(OLD_TOKEN, NEW_TOKEN);
    }
}
Set<Id> renamedAccountIds = new Map<Id, Account>(accs).keySet();
if (!accs.isEmpty()) {
    update accs;
    System.debug('Accounts updated: ' + accs.size());
} else {
    System.debug('No accounts with Name LIKE Case Lab%.');
}

List<ServiceContract> scs = [
    SELECT Id, Name
    FROM ServiceContract
    WHERE Name LIKE '%Case Lab%'
];
for (ServiceContract sc : scs) {
    if (sc.Name != null) {
        sc.Name = sc.Name.replace(OLD_TOKEN, NEW_TOKEN);
    }
}
if (!scs.isEmpty()) {
    update scs;
    System.debug('Service Contracts updated: ' + scs.size());
}

List<Entitlement> ents = [
    SELECT Id, Name
    FROM Entitlement
    WHERE Name LIKE '%Case Lab%'
];
for (Entitlement e : ents) {
    if (e.Name != null) {
        e.Name = e.Name.replace(OLD_TOKEN, NEW_TOKEN);
    }
}
if (!ents.isEmpty()) {
    update ents;
    System.debug('Entitlements updated: ' + ents.size());
}

// Case.Description is not filterable in SOQL — use Subject LIKE, then scan cases on renamed accounts.
Map<Id, Case> casesToSave = new Map<Id, Case>();

for (Case c : [SELECT Id, Subject, Description FROM Case WHERE Subject LIKE '%Case Lab%']) {
    if (c.Subject != null && c.Subject.contains(OLD_TOKEN)) {
        c.Subject = c.Subject.replace(OLD_TOKEN, NEW_TOKEN);
    }
    if (c.Description != null && c.Description.contains(OLD_TOKEN)) {
        c.Description = c.Description.replace(OLD_TOKEN, NEW_TOKEN);
    }
    casesToSave.put(c.Id, c);
}

if (!renamedAccountIds.isEmpty()) {
    for (Case c : [SELECT Id, Subject, Description FROM Case WHERE AccountId IN :renamedAccountIds]) {
        if (casesToSave.containsKey(c.Id)) {
            continue;
        }
        Boolean changed = false;
        if (c.Subject != null && c.Subject.contains(OLD_TOKEN)) {
            c.Subject = c.Subject.replace(OLD_TOKEN, NEW_TOKEN);
            changed = true;
        }
        if (c.Description != null && c.Description.contains(OLD_TOKEN)) {
            c.Description = c.Description.replace(OLD_TOKEN, NEW_TOKEN);
            changed = true;
        }
        if (changed) {
            casesToSave.put(c.Id, c);
        }
    }
}

if (!casesToSave.isEmpty()) {
    update casesToSave.values();
    System.debug('Cases updated (Subject/Description): ' + casesToSave.size());
}

System.debug('Migration complete.');

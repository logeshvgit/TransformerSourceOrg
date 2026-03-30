/**
 * When Run_Period_Summary__c is checked on Service Contract, summarizes entitled Cases for the contract window.
 * (ServiceContract.Status is not user-updateable in many orgs; this checkbox drives the demo.)
 */
public with sharing class ServiceContractTriggerHandler {
    public static void handleAfterUpdate(List<ServiceContract> newRows, Map<Id, ServiceContract> oldMap) {
        List<ServiceContract> toSummarize = new List<ServiceContract>();
        for (ServiceContract sc : newRows) {
            ServiceContract old = oldMap.get(sc.Id);
            if (old == null) {
                continue;
            }
            if (sc.Run_Period_Summary__c && !old.Run_Period_Summary__c) {
                toSummarize.add(sc);
            }
        }
        if (toSummarize.isEmpty()) {
            return;
        }
        Set<Id> contractIds = new Map<Id, ServiceContract>(toSummarize).keySet();
        Map<Id, List<Id>> contractToEntitlementIds = new Map<Id, List<Id>>();
        for (Entitlement e : [
            SELECT Id, ServiceContractId
            FROM Entitlement
            WHERE ServiceContractId IN :contractIds
        ]) {
            if (!contractToEntitlementIds.containsKey(e.ServiceContractId)) {
                contractToEntitlementIds.put(e.ServiceContractId, new List<Id>());
            }
            contractToEntitlementIds.get(e.ServiceContractId).add(e.Id);
        }
        List<ServiceContract> toSave = new List<ServiceContract>();
        for (ServiceContract sc : toSummarize) {
            List<Id> entIds = contractToEntitlementIds.get(sc.Id);
            if (entIds == null || entIds.isEmpty()) {
                toSave.add(
                    new ServiceContract(
                        Id = sc.Id,
                        Contract_Period_Summary__c = buildEmptySummary(),
                        Run_Period_Summary__c = false
                    )
                );
                continue;
            }
            Datetime windowStart = sc.StartDate == null
                ? Datetime.newInstance(2000, 1, 1, 0, 0, 0)
                : Datetime.newInstance(sc.StartDate, Time.newInstance(0, 0, 0, 0));
            Datetime windowEnd = sc.EndDate == null
                ? System.now()
                : Datetime.newInstance(sc.EndDate, Time.newInstance(23, 59, 59, 0));
            List<Case> cases = [
                SELECT Id, CaseNumber, Subject, Status, Priority, IsClosed, CreatedDate, ClosedDate
                FROM Case
                WHERE EntitlementId IN :entIds AND CreatedDate >= :windowStart AND CreatedDate <= :windowEnd
                ORDER BY CreatedDate ASC
                LIMIT 500
            ];
            toSave.add(
                new ServiceContract(
                    Id = sc.Id,
                    Contract_Period_Summary__c = buildSummary(sc, cases),
                    Run_Period_Summary__c = false
                )
            );
        }
        if (!toSave.isEmpty()) {
            update toSave;
        }
    }

    private static String buildEmptySummary() {
        return 'No entitlements linked to this service contract — nothing to summarize.';
    }

    private static String buildSummary(ServiceContract sc, List<Case> cases) {
        if (cases.isEmpty()) {
            return 'No entitled support cases in the contract window (by Created Date).';
        }
        Integer closedCt = 0;
        Map<String, Integer> statusCounts = new Map<String, Integer>();
        Map<String, Integer> priorityCounts = new Map<String, Integer>();
        List<String> lines = new List<String>();
        lines.add('Commercial printer service contract — period summary (Cases via Entitlement)');
        lines.add('Window: ' + String.valueOf(sc.StartDate) + ' – ' + String.valueOf(sc.EndDate));
        lines.add('Total Cases: ' + cases.size());
        Integer maxLines = 25;
        Integer n = 0;
        for (Case c : cases) {
            if (c.IsClosed) {
                closedCt++;
            }
            String st = c.Status == null ? 'Unknown' : c.Status;
            statusCounts.put(st, (statusCounts.containsKey(st) ? statusCounts.get(st) : 0) + 1);
            String pr = c.Priority == null ? 'Unknown' : c.Priority;
            priorityCounts.put(pr, (priorityCounts.containsKey(pr) ? priorityCounts.get(pr) : 0) + 1);
            if (n < maxLines) {
                lines.add('- ' + c.CaseNumber + ' | ' + st + ' | ' + pr);
                n++;
            }
        }
        if (cases.size() > maxLines) {
            lines.add('... (' + String.valueOf(cases.size() - maxLines) + ' more not listed)');
        }
        lines.add('Closed Cases: ' + closedCt);
        lines.add('By Status: ' + JSON.serialize(statusCounts));
        lines.add('By Priority: ' + JSON.serialize(priorityCounts));
        return String.join(lines, '\n');
    }
}

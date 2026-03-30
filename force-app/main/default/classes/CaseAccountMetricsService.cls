/**
 * Updates Account service metrics when Cases close.
 */
public with sharing class CaseAccountMetricsService {
    public static void handleCaseAfter(List<Case> newCases, Map<Id, Case> oldMap) {
        Map<Id, Integer> accountIdToCloseCount = new Map<Id, Integer>();
        for (Case c : newCases) {
            if (c.AccountId == null) {
                continue;
            }
            Case prior = oldMap == null ? null : oldMap.get(c.Id);
            Boolean becameClosed = c.IsClosed && (prior == null || !prior.IsClosed);
            if (becameClosed) {
                Integer n = accountIdToCloseCount.containsKey(c.AccountId)
                    ? accountIdToCloseCount.get(c.AccountId)
                    : 0;
                accountIdToCloseCount.put(c.AccountId, n + 1);
            }
        }
        if (accountIdToCloseCount.isEmpty()) {
            return;
        }
        List<Account> accounts = [
            SELECT Id, Closed_Support_Cases__c, Last_Service_Date__c
            FROM Account
            WHERE Id IN :accountIdToCloseCount.keySet()
            FOR UPDATE
        ];
        Date today = Date.today();
        for (Account a : accounts) {
            Integer add = accountIdToCloseCount.get(a.Id);
            Decimal current = a.Closed_Support_Cases__c == null ? 0 : a.Closed_Support_Cases__c;
            a.Closed_Support_Cases__c = current + add;
            a.Last_Service_Date__c = today;
        }
        update accounts;
    }
}

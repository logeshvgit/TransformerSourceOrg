@IsTest
private class CaseAccountMetricsServiceTest {
    @IsTest
    static void closedCaseIncrementsAccount() {
        Account a = new Account(Name = 'Metrics Account');
        insert a;
        Case c = new Case(AccountId = a.Id, Subject = 'Test case', Status = 'New', Origin = 'Web');
        insert c;
        c.Status = 'Closed';
        Test.startTest();
        update c;
        Test.stopTest();
        Account updated = [SELECT Closed_Support_Cases__c, Last_Service_Date__c FROM Account WHERE Id = :a.Id];
        System.assertEquals(1, updated.Closed_Support_Cases__c);
        System.assertEquals(Date.today(), updated.Last_Service_Date__c);
    }
}

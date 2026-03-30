@IsTest
private class ServiceContractTriggerHandlerTest {
    @IsTest
    static void runSummaryCheckboxWritesSummary() {
        Account a = new Account(Name = 'PrintCo Test Customer');
        insert a;
        ServiceContract sc = new ServiceContract(
            AccountId = a.Id,
            Name = 'Standard Maintenance – Test',
            StartDate = Date.today().addYears(-1),
            EndDate = Date.today().addMonths(6),
            Term = 18,
            Run_Period_Summary__c = false
        );
        insert sc;
        Entitlement e = new Entitlement(
            Name = 'Depot & Field Service – Test',
            AccountId = a.Id,
            ServiceContractId = sc.Id,
            StartDate = Date.today().addYears(-1),
            EndDate = Date.today().addMonths(6)
        );
        insert e;
        Case k = new Case(
            AccountId = a.Id,
            EntitlementId = e.Id,
            Subject = 'Entitled case – driver install',
            Status = 'New',
            Origin = 'Web'
        );
        insert k;
        Test.startTest();
        sc.Run_Period_Summary__c = true;
        update sc;
        Test.stopTest();
        ServiceContract out = [
            SELECT Contract_Period_Summary__c, Run_Period_Summary__c
            FROM ServiceContract
            WHERE Id = :sc.Id
        ];
        System.assertEquals(false, out.Run_Period_Summary__c);
        System.assertNotEquals(null, out.Contract_Period_Summary__c);
        System.assert(out.Contract_Period_Summary__c.contains('Commercial printer service contract'));
        System.assert(out.Contract_Period_Summary__c.contains('Total Cases'));
    }
}

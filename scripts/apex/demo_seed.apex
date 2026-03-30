// Demo seed (Execute Anonymous). Order: Account → ServiceContract → Entitlement → Case(s).
// CSM defaults to running user so Case CSM Closure Flow can assign the Task.

Id userId = UserInfo.getUserId();

Account a = new Account(
    Name = 'PrintCo Regional Print – Demo Site',
    Account_Size_Tier__c = 'Enterprise',
    Account_Customer_Status__c = 'At_Risk',
    CSM__c = userId
);
insert a;

ServiceContract sc = new ServiceContract(
    AccountId = a.Id,
    Name = 'Standard Maintenance & Parts – Demo Site',
    StartDate = Date.today().addMonths(-6),
    EndDate = Date.today().addMonths(6),
    Term = 12
);
insert sc;

Entitlement e = new Entitlement(
    Name = 'Depot & Field Service – Demo Site',
    AccountId = a.Id,
    ServiceContractId = sc.Id,
    StartDate = Date.today().addMonths(-6),
    EndDate = Date.today().addMonths(6)
);
insert e;

Case c1 = new Case(
    AccountId = a.Id,
    EntitlementId = e.Id,
    Subject = 'Demo – fleet toner delivery routing',
    Status = 'New',
    Origin = 'Web'
);
insert c1;

Case c1b = [SELECT Id, CaseNumber, Priority, OwnerId FROM Case WHERE Id = :c1.Id];
System.debug('Case after insert: ' + c1b);

System.debug('To generate contract period summary: edit the Service Contract and check Run_Period_Summary__c.');

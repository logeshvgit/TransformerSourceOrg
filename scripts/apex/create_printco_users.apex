/**
 * Creates internal PrintCo support users and assigns profile + permission set group.
 * REQUIRES: "Manage Users", Email deliverability, and unique emails in your org.
 * Edit emails, alias, and lastName before running.
 *
 * Profile API name: Print_Co_Support_Group
 * Permission Set Group: Print_Co_Support_Group (assign after users exist)
 *
 * Run: sf apex run --file scripts/apex/create_printco_users.apex --target-org <alias>
 */
Id profileId = [
    SELECT Id
    FROM Profile
    WHERE Name IN ('Print_Co_Support_Group', 'Print Co Support Group')
    LIMIT 1
]
.Id;

List<PermissionSet> psets = [
    SELECT Id
    FROM PermissionSet
    WHERE Name IN ('Contract_Manager', 'Channel_Supervisor')
];

List<User> users = new List<User>{
    new User(
        FirstName = 'Alex',
        LastName = 'Tier1 Agent',
        Alias = 'atier1',
        Email = 'alex.tier1.printco@example.com',
        Username = 'alex.tier1.printco+' + UserInfo.getOrganizationId().substring(0, 8) + '@example.com',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        ProfileId = profileId
    ),
    new User(
        FirstName = 'Jordan',
        LastName = 'Tier2 Agent',
        Alias = 'jtier2',
        Email = 'jordan.tier2.printco@example.com',
        Username = 'jordan.tier2.printco+' + UserInfo.getOrganizationId().substring(0, 8) + '@example.com',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        ProfileId = profileId
    ),
    new User(
        FirstName = 'Sam',
        LastName = 'Supervisor',
        Alias = 'ssuper',
        Email = 'sam.super.printco@example.com',
        Username = 'sam.super.printco+' + UserInfo.getOrganizationId().substring(0, 8) + '@example.com',
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        ProfileId = profileId
    )
};
insert users;

List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
for (User u : users) {
    for (PermissionSet ps : psets) {
        psa.add(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id));
    }
}
insert psa;

System.debug('Created users with profile + Contract_Manager & Channel_Supervisor: ' + users.size());

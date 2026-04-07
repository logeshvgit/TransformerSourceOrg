/**
 * Seed 4 PrintCo Knowledge articles using the REST API and publish them.
 *
 * Run: sf apex run --file scripts/apex/seed_knowledge_articles.apex --target-org <alias>
 */

List<Map<String, Object>> articleDefs = new List<Map<String, Object>>();

Map<String, Object> a1 = new Map<String, Object>();
a1.put('Title',       'How to clear a paper jam on the PrintCo Press 5000');
a1.put('UrlName',     'printco-press-5000-paper-jam');
a1.put('Summary',     'Step-by-step guide to safely clear paper jams on production press models.');
a1.put('Question__c', 'My PrintCo Press 5000 shows a paper jam error. How do I clear it?');
a1.put('Content__c',  'Step 1 — Open the front access panel by lifting the green lever.\nStep 2 — Gently pull the jammed sheet in the direction of paper travel. Do NOT pull backwards.\nStep 3 — Check the fuser area (Tray F) for any remaining fragments.\nStep 4 — Close the panel and press Resume on the operator display.\nStep 5 — If the jam recurs, power-cycle the device and run the built-in diagnostic (Menu > Service > Paper Path Test).\n\nIf the issue persists after three attempts, open a support case referencing error code E-2041.');
a1.put('Language',    'en_US');
articleDefs.add(a1);

Map<String, Object> a2 = new Map<String, Object>();
a2.put('Title',       'Replacing toner cartridges on PrintCo color devices');
a2.put('UrlName',     'printco-toner-replacement');
a2.put('Summary',     'Instructions for replacing CMYK toner cartridges across PrintCo color models.');
a2.put('Question__c', 'How do I replace the toner cartridge on my PrintCo Color Production A3?');
a2.put('Content__c',  'Compatible models: Color Production A3, Press 5000 (color variant), Wide Format 36\".\n\nStep 1 — Open the toner access door on the right side.\nStep 2 — Rotate the cartridge handle 90 degrees counter-clockwise and pull out.\nStep 3 — Unbox the new cartridge and shake gently 5-6 times.\nStep 4 — Slide the new cartridge in until it clicks, rotate the handle clockwise to lock.\nStep 5 — Close the door. The device auto-calibrates color density (~60 seconds).\n\nTip: Order replacement sets (SKU PC-TONER-CMYK) at least 2 weeks before the Low Toner alert.');
a2.put('Language',    'en_US');
articleDefs.add(a2);

Map<String, Object> a3 = new Map<String, Object>();
a3.put('Title',       'Configuring the Fiery RIP Module for color-accurate proofing');
a3.put('UrlName',     'fiery-rip-color-proofing');
a3.put('Summary',     'Set up the Fiery RIP for ICC-profile-based color matching and soft proofing.');
a3.put('Question__c', 'How do I configure the Fiery RIP to match Pantone spot colors for press proofs?');
a3.put('Content__c',  'Prerequisites: Fiery RIP Module (SKU PC-FIERY-RIP) firmware v4.2+, connected via Ethernet.\n\n1. Open Fiery Command WorkStation on the operator PC.\n2. Navigate to Color Setup > Color Management.\n3. Select CMYK Source Profile and choose the ICC profile for your paper stock.\n4. Enable Spot Color Matching and import the Pantone Plus library.\n5. Print a test target (Fiery > Calibration > Print Calibration Page) and measure with a spectrophotometer.\n6. Apply the calibration set and save as a preset.\n\nFor Delta-E values above 3.0, contact PrintCo Support with your calibration report.');
a3.put('Language',    'en_US');
articleDefs.add(a3);

Map<String, Object> a4 = new Map<String, Object>();
a4.put('Title',       'PrintCo Gold SLA — coverage and response times');
a4.put('UrlName',     'printco-gold-sla-coverage');
a4.put('Summary',     'Overview of coverage, response times, and included services under the Gold SLA add-on.');
a4.put('Question__c', 'What does the PrintCo Gold SLA include and how fast is the response?');
a4.put('Content__c',  'The Gold SLA Add-on (SKU PC-SLA-GOLD, $2,400/yr per device) includes:\n\n4-hour onsite response for Severity 1 (production down)\nNext-business-day response for Severity 2 (degraded output quality)\nPriority parts — overnight shipping at no cost\nQuarterly preventive maintenance visits\nAnnual firmware upgrade performed onsite\nUnlimited remote diagnostics via PrintCo Connect\n\nExcluded: consumables (toner, media), physical damage from misuse, third-party accessory failures.\n\nTo activate, open a case with subject Gold SLA Activation — [Device Serial].');
a4.put('Language',    'en_US');
articleDefs.add(a4);

List<Id> knowledgeArticleIds = new List<Id>();
String baseUrl = Url.getOrgDomainUrl().toExternalForm();
String token = UserInfo.getSessionId();

for (Map<String, Object> def : articleDefs) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint(baseUrl + '/services/data/v66.0/sobjects/Knowledge__kav');
    req.setMethod('POST');
    req.setHeader('Authorization', 'Bearer ' + token);
    req.setHeader('Content-Type', 'application/json');
    req.setBody(JSON.serialize(def));

    HttpResponse res = new Http().send(req);
    if (res.getStatusCode() == 201) {
        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        Id kavId = (Id) body.get('id');
        Knowledge__kav kav = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :kavId LIMIT 1];
        knowledgeArticleIds.add(kav.KnowledgeArticleId);
        System.debug('Created: ' + def.get('Title'));
    } else {
        System.debug('FAILED (' + res.getStatusCode() + '): ' + res.getBody());
    }
}

for (Id kaId : knowledgeArticleIds) {
    KbManagement.PublishingService.publishArticle(kaId, true);
}
System.debug('Published ' + knowledgeArticleIds.size() + ' articles.');

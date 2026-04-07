# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

## Service Cloud MVP (Transformer demo)

This demo models **PrintCo**, a company that sells **commercial printers** and supports customers with **service contracts**, **entitlements** (depot, field service, managed print), and **Service Cloud cases** (fleet issues, firmware, finishing, billing, and SLA).

**Flows**

- `Case_Priority_Handler` — Before-save on Case: sets **Priority** from **Account** `Account_Size_Tier__c` and `Account_Customer_Status__c` (Churning → High; Enterprise + At Risk → High; SMB → Low; default Medium).
- `Case_CSM_Closure` — After-save when **Case** is closed: **Task** for **Account.CSM__c** (or **Created By** if CSM empty) and **email** to **Created By** user’s email via `emailSimple`.

**Lightning Web Component**

- `printCoAccountHealth` — **PrintCo Account Health** on **Account** record pages: shows tier, customer status, last service date, closed case count, CSM (link to user), and **expected case priority** using the same rules as `Case_Priority_Handler`. Add it in **Lightning App Builder** to the Account Lightning page.
- **Field-level security:** Read/edit on `Account_Size_Tier__c`, `Account_Customer_Status__c`, `Last_Service_Date__c`, `Closed_Support_Cases__c`, and `CSM__c` is granted on **Print Co Support Group** profile and on **Contract Manager** / **Channel Supervisor** permission sets. Users on other profiles need the same FLS (or assign one of those permission sets). `Account.Name` and `User.Name` cannot be set via metadata on permission sets; standard access to Account/User usually covers them.

**Apex**

- `CaseAccountMetricsService` — On Case close, updates **Account** `Last_Service_Date__c` and increments `Closed_Support_Cases__c`.
- `ServiceContractTriggerHandler` — When **Service Contract** `Run_Period_Summary__c` is checked, summarizes entitled **Cases** (commercial printer support) for that contract (date window), writes `Contract_Period_Summary__c`, clears the checkbox. *(Standard `ServiceContract.Status` is not user-updateable in many orgs, so the demo uses this checkbox.)*

**Routing**

- Queues: `Tier1_Support`, `Tier2_Support`, `Escalation_Support`.
- Assignment rule: **High** → Tier 1; **Medium**/**Low** → Tier 2.

**Seed data**

Run `scripts/apex/demo_seed.apex` in **Execute Anonymous** (VS Code / Developer Console), then close a Case to exercise metrics + CSM Flow; check **Run_Period_Summary__c** on the Service Contract to build the entitled-case summary.

**Bulk demo cases (~20)**

Run `sf apex run --file scripts/apex/demo_cases_20.apex --target-org <alias>` after deploying this project so **Account** tier/status fields exist and **Case_Priority_Handler** can vary **Priority**. The script creates five **PrintCo Customer …** accounts (different tiers), optional **Service Contract** + **Entitlement**, and twenty cases with printer-focused subjects (drivers, firmware, finishing, meters, SLA, and so on), plus varied **Status** and **Origin**.

**Service contracts, entitlements, and cases**

Run `sf apex run --file scripts/apex/demo_contracts_entitlements_link.apex --target-org <alias>` after you have **PrintCo Customer …** accounts (from the bulk demo script). It creates:

- One **Service Contract** per customer account (up to five), named `Standard Maintenance – …` (parts, depot, and field service for installed printers)
- A second contract on **PrintCo Customer – Enterprise Stable**: **Managed Print Production Suite – Enterprise Stable** (higher-touch production workflow and reporting)
- One **Entitlement** per contract (six total when Enterprise Stable is present), named from each contract (prefix `Ent: …`)

It then sets **Case.EntitlementId** for Cases on those accounts so each Case ties to an Entitlement on the same Account. For Enterprise Stable, Cases alternate between **Standard Maintenance** and **Managed Print Production Suite** when both exist.

**Linking Cases requires Entitlement Management.** If the org does not expose `Case.EntitlementId`, turn on **Entitlement Management** in Setup (e.g. **Entitlement Management** → **Entitlement Settings**), then run the script again to create contracts/entitlements and link Cases—or link cases manually from the Case page.

**Legacy “Case Lab” data**

If older demo rows still use **Case Lab** in Account or related names, run:

`sf apex run --file scripts/apex/migrate_case_lab_to_printco.apex --target-org <alias>`

It renames matching **Accounts** to **PrintCo Customer …**, and updates **Service Contract**, **Entitlement**, and **Case** Subject/Description text that still contains `Case Lab`.

**Deploy**

`sf project deploy start --source-dir force-app --target-org <alias>`

Full metadata list: `manifest/package.xml` (retrieve/deploy with `--manifest manifest/package.xml`).

## PrintCo users, permissions, Omni-Channel, guest site

**Profile & permission sets (in source)**

- **Profile** `Print_Co_Support_Group` — internal Salesforce license baseline (console + Lightning + API + reports).
- **Permission sets** `Contract_Manager` (contracts, entitlements, accounts) and `Channel_Supervisor` (cases, transfer, Omni Supervisor tab, Lightning Service app).
- **Permission set group** `Print_Co_Support_Group` — bundles both sets (assign in Setup or use individual PS).

**Users**

- Script: `scripts/apex/create_printco_users.apex` — creates three sample agents with the PrintCo profile and assigns **Contract_Manager** and **Channel_Supervisor**. Edit emails before running; requires **Manage Users** and valid Email Encoding. Usernames are made unique with a short org id suffix.

**Omni-Channel (deployed metadata)**

- **Service channel** `PrintCo_Case` — **Case** work items.
- **Presence statuses** `PrintCo_Available`, `PrintCo_Busy` — tied to `PrintCo_Case`.
- **Presence configuration** `PrintCo_Agent` — capacity 5 (adjust in Setup if needed).
- **Queue routing** `PrintCo_Tier1_Routing`, `PrintCo_Tier2_Routing` — `LEAST_ACTIVE` model; **Tier1_Support** and **Tier2_Support** queues reference these configs.

After deploy, complete in **Setup** (exact labels vary by release): turn on **Omni-Channel**, assign **PrintCo Agent** presence to the **Print Co Support Group** profile (or users), add agents to **Tier1/Tier2** queues, and under **Omni-Channel** settings associate **Case** routing with the **PrintCo_Case** channel and your messaging deployment when you add Messaging. Chat buttons routed purely through Omni sometimes need extra org configuration that is not fully metadata-driven.

**Unauthenticated guest page & products**

- **Static resource** `PrintCo_GuestSite` — single HTML page with a **10-product** catalog (JavaScript), a **Web-to-Case** form stub (`ACTION_URL` / `ORG_ID` placeholders), and a placeholder for **Embedded Messaging** JavaScript from your **Embedded Service Deployment**. Host it on an **Experience Cloud** site (recommended) or a **Site**; set the static resource URL or copy the markup into an **HTML Editor** component on an **unauthenticated** LWR page.
- **Products**: `scripts/apex/seed_printco_products.apex` inserts **10 Product2** rows (same SKUs as the page). Run after deploy.

**Digital Experience site (PrintCo Support)**

This org includes an LWR site **PrintCo Support** created with the CLI (async job, then publish):

```text
sf community create --name "PrintCo Support" --template-name "Build Your Own (LWR)" \
  --url-path-prefix printco --description "PrintCo commercial printers" -o <alias> \
  templateParams.AuthenticationType=AUTHENTICATED_WITH_PUBLIC_ACCESS_ENABLED
sf community publish -o <alias> -n "PrintCo Support"
```

- **LWR note:** `templateParams.AuthenticationType=UNAUTHENTICATED` is **not** accepted for LWR; use **`AUTHENTICATED_WITH_PUBLIC_ACCESS_ENABLED`** so guests can use public pages while login remains available.
- **URL path:** Salesforce may assign a path different from `--url-path-prefix` (check **Digital Experiences → All Sites** or the publish output). Example publish URL shape: `https://<my-domain>.my.site.com/<pathPrefix>`.
- **In source:** `networks/PrintCo Support.network-meta.xml` and `digitalExperiences/site/PrintCo_Support1/` (bundle). Retrieve updates with `sf project retrieve start --metadata Network --metadata DigitalExperienceBundle --target-org <alias>` when you change the site in Builder.
- The **Home** page includes sections: hero banner, **Why PrintCo?**, **Product Catalog** (10 products), **Knowledge Base** (4 articles), and **Need help?** support callout.
- **Web-to-Case** / **Embedded Messaging:** fill `PrintCo_GuestSite.resource` and route Messaging in Omni-Channel; configure **Guest User** profile for Case/Web-to-Case as needed.

**Knowledge articles**

- Script: `scripts/apex/seed_knowledge_articles.apex` — creates **4 published articles** (uses REST API internally as `Knowledge__kav.Title` is not DML-writable, then publishes via `KbManagement.PublishingService`). Run after enabling the **Knowledge User** checkbox on the executing user (`UserPermissionsKnowledgeUser = true`).
- Articles (visible in Internal App, Customer, and Public KB):
  1. **How to clear a paper jam on the PrintCo Press 5000** — paper jam troubleshooting steps
  2. **Replacing toner cartridges on PrintCo color devices** — CMYK cartridge replacement procedure
  3. **Configuring the Fiery RIP Module for color-accurate proofing** — ICC profile and Pantone setup
  4. **PrintCo Gold SLA — coverage and response times** — SLA scope, response SLAs, exclusions
- **Permission sets** `Contract_Manager` and `Channel_Supervisor` grant read access to `Knowledge__kav` and the **Knowledge** tab. `Contract_Manager` also allows create/edit for article authoring.

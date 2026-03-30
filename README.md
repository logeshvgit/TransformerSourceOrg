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

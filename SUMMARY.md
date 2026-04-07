# PrintCo Service Cloud Implementation — Feature Summary

**Org:** PrintCo Commercial Printers | **Platform:** Salesforce Service Cloud | **Built:** April 2026

---

## 1. Case Automation & Priority Routing

A before-save Flow (`Case_Priority_Handler`) automatically sets Case priority based on the customer's account tier and status. Enterprise accounts flagged as "At Risk" or any account marked "Churning" are escalated to High priority; SMB accounts default to Low. An assignment rule then routes High-priority cases to the Tier 1 queue and Medium/Low cases to Tier 2, ensuring urgent issues reach senior agents first.

## 2. Case Closure Workflow

When a case is closed, an after-save Flow (`Case_CSM_Closure`) creates a follow-up Task assigned to the account's Customer Success Manager and sends an email notification to the case creator. An Apex service (`CaseAccountMetricsService`) simultaneously updates the account's Last Service Date and increments the lifetime closed-case counter, giving CSMs real-time visibility into account health.

## 3. Service Contracts & Entitlement Management

Each PrintCo customer account is linked to one or more Service Contracts (Standard Maintenance, Managed Print Production Suite) with corresponding Entitlements. An Apex trigger handler (`ServiceContractTriggerHandler`) generates on-demand period summaries of all entitled cases within a contract's date window, written to a long-text field on the Service Contract for quick review without running reports.

## 4. Omni-Channel Routing

A full Omni-Channel configuration routes incoming Case work items through a dedicated service channel (`PrintCo_Case`). Two queue routing configs use the Least Active model — Tier 1 with priority 1 and Tier 2 with priority 2. Agent presence statuses (Available, Busy) and a presence user config (capacity 5) control workload distribution across the support team.

## 5. User Management & Security Model

A custom profile (`Print_Co_Support_Group`) provides the baseline for internal support agents with console, Lightning, and API access. Two permission sets — `Contract_Manager` (contract/entitlement CRUD, Knowledge authoring) and `Channel_Supervisor` (case management, Omni Supervisor, transfer any case) — are bundled in a Permission Set Group. Field-level security on five custom Account fields is granted across all three metadata components.

## 6. Lightning Web Component — Account Health Dashboard

The `printCoAccountHealth` LWC displays a real-time health snapshot on Account record pages: account tier, customer status, last service date, closed case count, assigned CSM (with a clickable link to the User record), and the expected case priority using the same logic as the priority Flow. It uses two `@wire` adapters — one for Account fields and a second to resolve the CSM's display name.

## 7. Knowledge Base (4 Articles)

Four Knowledge articles were created, published, and made visible across all channels (Internal App, Customer Portal, Public Knowledge Base):

- **Paper Jam Troubleshooting** — step-by-step instructions for clearing jams on the Press 5000, including fuser checks and the built-in diagnostic tool.
- **Toner Cartridge Replacement** — CMYK cartridge swap procedure for all color models, with a reorder timing tip tied to SKU PC-TONER-CMYK.
- **Fiery RIP Color Proofing** — ICC profile setup, Pantone Plus import, spectrophotometer calibration, and Delta-E thresholds for escalation.
- **Gold SLA Coverage Guide** — full breakdown of 4-hour onsite response, priority parts, quarterly PM visits, annual firmware upgrades, and exclusions.

## 8. Digital Experience Site (PrintCo Support)

An LWR Experience Cloud site provides a public-facing portal with guest access (`AUTHENTICATED_WITH_PUBLIC_ACCESS_ENABLED`). The Home page includes a branded hero banner, a "Why PrintCo?" value-prop section (Gold SLA, Managed Print, Depot & Field Service), a 10-product catalog grid with SKUs and pricing, the 4 Knowledge Base article cards, and a support call-to-action section. The site is deployed and published from source-controlled metadata.

## 9. Product Catalog (10 SKUs)

Ten `Product2` records represent PrintCo's commercial printer lineup and are displayed on both the Experience site and the static resource guest page. The catalog spans production presses (Press 5000), wide-format printers, color/mono fleet devices, a booklet finisher, Fiery RIP module, CMYK toner sets, fuser maintenance kits, gloss media rolls, and the Gold SLA service add-on — each with a product code and price point.

## 10. Demo Data & Migration Scripts

A suite of Apex scripts seeds the org with realistic data: 5 customer accounts across different tiers, 20 printer-themed support cases with varied status/origin/priority, service contracts with entitlements linked to cases, 3 sample support users with profile and permission set assignments, and 10 products. A separate migration script renames any legacy "Case Lab" records to the PrintCo naming convention across Accounts, Service Contracts, Entitlements, and Cases.

---

*All metadata is source-controlled, deployable via `sf project deploy start --source-dir force-app`, and documented in `manifest/package.xml`.*

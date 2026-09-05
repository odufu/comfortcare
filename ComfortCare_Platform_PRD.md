# ComfortCare Digital Health & Pharmacy Platform

## Product Requirements Document (PRD)

**Version:** 1.0\
**Date:** September 2026\
**Country:** Nigeria\
**Owner:** ComfortCare Pharmaceuticals Ltd.\
**Currency:** Nigerian Naira (₦)

------------------------------------------------------------------------

## 1. Product Vision

ComfortCare will operate a connected digital pharmacy and
health-commerce ecosystem connecting customers, ComfortCare branches,
partner pharmacies, sales staff, riders, finance teams and
administrators.

The platform will allow customers to discover and order healthcare
products, receive conversational assistance, manage selected personal
health information and track deliveries, while ComfortCare maintains
centralized control over inventory, orders, logistics, finance, partner
operations and reporting.

### Core Platforms

1.  Customer Mobile App
2.  POS System
3.  Partner Pharmacy Portal
4.  Rider / Logistics App
5.  Staff & Sales Portal
6.  Admin Portal
7.  Central Backend & Intelligence Layer

> Clinical, regulatory, financial and commercial rules marked as
> configurable must be approved by ComfortCare before production.

------------------------------------------------------------------------

## 2. Executive Summary

ComfortCare is not simply an e-commerce application. It is a
multi-channel pharmacy commerce and digital health platform.

The ecosystem connects:

**Customers → ComfortCare / Partner Pharmacy → Inventory → Order
Fulfilment → Logistics → Customer**

The system will provide:

-   E-commerce
-   POS
-   Partner pharmacy management
-   Inventory and stock management
-   Logistics and rider operations
-   Accounting and settlements
-   Sales/CRM
-   Staff attendance and presence reporting
-   AI conversational assistance
-   Personal health monitoring
-   Reporting and analytics
-   Role-based administration

The central backend will be the system of record for customers,
products, stock, orders, payments, deliveries, commissions, settlements,
staff events, notifications and audit records.

------------------------------------------------------------------------

## 3. Product Goals

### Business Goals

-   Increase sales through digital commerce.
-   Expand product availability through verified partner pharmacies.
-   Centralize fulfilment and logistics.
-   Improve inventory visibility.
-   Improve financial and operational reporting.
-   Generate measurable sales opportunities through AI.
-   Allow human sales agents to take over AI conversations.
-   Improve customer retention.
-   Support additional branches and partners.

### Customer Goals

-   Find healthcare products quickly.
-   Understand important product information.
-   Order products easily.
-   Pay securely.
-   Track deliveries.
-   Get useful conversational assistance.
-   Receive medication reminders.
-   Maintain selected health records.
-   Reorder frequently purchased products.

------------------------------------------------------------------------

## 4. Success Metrics

  -----------------------------------------------------------------------
  Area                                KPIs
  ----------------------------------- -----------------------------------
  Commerce                            Conversion rate, orders/day,
                                      average order value, repeat
                                      purchase rate

  Customer                            Active users, repeat customers,
                                      CSAT, complaint rate

  AI                                  Qualified conversations, handoffs,
                                      AI-assisted conversions

  Sales                               Leads, conversion rate, revenue per
                                      agent

  Inventory                           Stock accuracy, stock-out rate,
                                      expiry loss

  Logistics                           On-time delivery, failed delivery
                                      rate, average delivery time

  Partners                            Active partners, acceptance rate,
                                      fulfilment rate

  Staff                               Attendance, productive hours, sales
                                      per agent

  Finance                             Revenue, settlement accuracy,
                                      refund rate
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## 5. Product Ecosystem

### 5.1 Customer Mobile App

-   Account management
-   Product discovery
-   E-commerce
-   Cart and checkout
-   Payments
-   Prescription upload
-   AI assistant
-   Personal health
-   Medication reminders
-   Order tracking
-   Notifications
-   Customer support

### 5.2 POS

-   Product lookup
-   Barcode scanning
-   Cart
-   Customer selection
-   Prescription verification
-   Discounts
-   Payments
-   Receipts
-   Returns
-   Refunds
-   Shift management
-   Cash reconciliation
-   Sales reporting

### 5.3 Partner Pharmacy Portal

-   Registration
-   Verification
-   Pharmacy profile
-   Product catalogue
-   Inventory
-   Orders
-   Fulfilment
-   Earnings
-   Commissions
-   Settlements
-   Reports

### 5.4 Rider / Logistics App

-   Login
-   Availability
-   Delivery offers
-   Accept/reject
-   Pickup verification
-   Navigation
-   Delivery confirmation
-   Proof of delivery
-   Failed delivery
-   Earnings
-   Delivery history

### 5.5 Staff & Sales Portal

-   Leads
-   Customers
-   Conversations
-   AI handoffs
-   Follow-ups
-   Assisted orders
-   Sales
-   Commission
-   Attendance
-   Presence
-   Productivity

### 5.6 Admin Portal

-   Users
-   Roles
-   Branches
-   Partners
-   Products
-   Inventory
-   Orders
-   Logistics
-   Riders
-   Sales
-   Finance
-   AI
-   Health configuration
-   Reports
-   Promotions
-   Notifications
-   Audit logs
-   Settings

------------------------------------------------------------------------

## 6. Users, Roles & Permissions

  -----------------------------------------------------------------------
  Role                    Responsibilities        Access
  ----------------------- ----------------------- -----------------------
  Customer                Shop, order, pay, chat, Own account
                          track, manage own       
                          health data             

  Pharmacist              Prescription review,    Authorized orders
                          product guidance,       
                          escalation              

  POS Cashier             Physical sales and      Assigned branch
                          payments                

  Branch Manager          Branch operations       Assigned branch

  Partner Admin           Partner pharmacy        Own pharmacy
                          operations              

  Rider                   Deliveries              Assigned jobs

  Dispatcher              Delivery assignment and Logistics
                          monitoring              

  Sales Agent             Leads and assisted      Assigned leads
                          sales                   

  Inventory Manager       Stock management        Authorized locations

  Finance Officer         Payments and            Finance
                          settlements             

  Operations Admin        Operational management  Assigned modules

  Main Admin              Platform-wide           Full scope
                          configuration           
  -----------------------------------------------------------------------

### RBAC

Permissions should support:

-   View
-   Create
-   Edit
-   Delete
-   Approve
-   Reject
-   Refund
-   Export
-   Assign
-   Configure

Sensitive actions must require elevated permissions and audit logging.

------------------------------------------------------------------------

# 7. Customer Mobile App

## 7.1 Authentication & Onboarding

-   Phone/email registration
-   OTP verification
-   Login
-   Recovery
-   Logout
-   Customer profile
-   Delivery addresses
-   Communication preferences
-   Optional health profile
-   Consent management

## 7.2 Home

-   Search
-   Categories
-   Promotional banners
-   Featured products
-   Recommendations
-   Recent orders
-   Reorder shortcuts
-   AI assistant
-   Health reminders
-   Personalized content

## 7.3 Product Discovery

-   Search by product
-   Search by brand
-   Search by category
-   Filters
-   Sorting
-   Availability
-   Saved products
-   Product details

## 7.4 Product Details

-   Product name
-   Images
-   Brand
-   Description
-   Pack size
-   Price
-   Availability
-   Usage information
-   Warnings
-   Prescription requirement
-   Related products
-   Add to cart

## 7.5 Cart & Checkout

Cart:

-   Quantity
-   Remove
-   Save for later
-   Discounts
-   Subtotal
-   Delivery fee
-   Total

Checkout:

-   Customer information
-   Delivery address
-   Delivery option
-   Payment option
-   Order summary
-   Final amount
-   Confirmation

## 7.6 Orders

Customers can:

-   View current orders
-   View previous orders
-   Track deliveries
-   Cancel eligible orders
-   Request refunds where permitted
-   Reorder
-   View receipts

------------------------------------------------------------------------

# 8. Prescription Workflow

For prescription-required products:

1.  Customer uploads prescription.
2.  System creates pharmacist review task.
3.  Authorized pharmacist reviews.
4.  Pharmacist approves, rejects or requests clarification.
5.  Customer receives status update.
6.  Restricted product is released only after required verification.

Prescription states:

-   Uploaded
-   Received
-   Under Review
-   Clarification Required
-   Approved
-   Rejected
-   Expired

Prescription access must be restricted and audited.

------------------------------------------------------------------------

# 9. Payments

The platform should support approved Nigerian payment methods.

Payment states:

-   Pending
-   Successful
-   Failed
-   Reversed
-   Refunded
-   Partially Refunded

The backend must not rely only on client-side payment confirmation.

Payment records should include:

-   Transaction ID
-   Order ID
-   Customer
-   Amount
-   Currency
-   Provider
-   Status
-   Timestamp
-   Provider reference

Provider webhooks and reconciliation are required.

------------------------------------------------------------------------

# 10. AI Conversational Assistant

The AI assistant is a core differentiator.

It should support:

1.  Conversational customer support
2.  Product discovery
3.  Sales assistance
4.  Controlled health-information assistance

## AI Sales Capabilities

-   Understand customer intent.
-   Ask relevant follow-up questions.
-   Recommend appropriate OTC products when safe.
-   Explain products.
-   Compare products.
-   Recommend complementary products.
-   Detect buying intent.
-   Assist checkout.
-   Recover abandoned carts.
-   Promote approved offers.
-   Generate leads.
-   Hand conversations to sales agents.

## AI Customer Support

The AI can assist with:

-   Products
-   Orders
-   Payments
-   Delivery
-   Returns
-   Refunds
-   Pharmacy services

It may access live customer/order data only where authorized.

------------------------------------------------------------------------

# 11. AI Clinical Safety

The AI must:

-   Never claim to be a doctor or pharmacist.
-   Avoid presenting uncertain output as diagnosis.
-   Not independently prescribe prescription-only medicines.
-   Escalate high-risk symptoms.
-   Use approved medical/product knowledge.
-   Maintain knowledge-base versions.
-   Provide appropriate safety guidance.

High-risk scenarios may include:

-   Severe allergic reactions
-   Chest pain
-   Severe breathing difficulty
-   Stroke-like symptoms
-   Poisoning
-   Overdose
-   Severe bleeding
-   Serious pregnancy-related concerns
-   High-risk pediatric situations

Exact escalation rules must be approved by qualified clinical
professionals.

## AI-to-Human Handoff

  Trigger                 Action
  ----------------------- -------------------------------------
  User requests human     Sales agent/pharmacist handoff
  Prescription question   Pharmacist queue
  High-risk symptom       Safety response + escalation
  Buying intent           Lead creation / checkout assistance
  Low confidence          Clarify or hand off
  Complaint               Customer support/operations

The human agent should receive a conversation summary.

------------------------------------------------------------------------

# 12. Personal Health & Monitoring

Initial health features should focus on user-controlled records.

Potential records:

-   Allergies
-   Medication list
-   Medication reminders
-   Medication adherence
-   Blood pressure
-   Blood glucose
-   Weight
-   Temperature
-   Other configurable measurements
-   Health notes

Users should be able to:

-   Add measurements
-   View history
-   View trends
-   Set reminders
-   Manage medications
-   Share/export information where supported

The app must clearly state that these features do not replace
professional medical care.

------------------------------------------------------------------------

# 13. POS System

### Sales

-   New sale
-   Product search
-   Barcode scanning
-   Customer lookup
-   Cart
-   Discounts
-   Prescription verification
-   Payment
-   Receipt

### Transactions

-   Transaction history
-   Refunds
-   Returns
-   Cancelled transactions
-   Payment status

### Shift Management

-   Start shift
-   End shift
-   Cash count
-   Reconciliation
-   Variance reporting

### Reports

-   Sales by cashier
-   Sales by product
-   Sales by category
-   Sales by branch
-   Daily sales
-   Payment breakdown

------------------------------------------------------------------------

# 14. Inventory Management

The system must support:

-   Products
-   Categories
-   SKUs
-   Barcodes
-   Batch numbers
-   Expiry dates
-   Cost prices
-   Selling prices
-   Stock quantities
-   Reserved stock
-   Available stock
-   Damaged stock
-   Expired stock
-   Stock thresholds
-   Stock transfers
-   Stock adjustments
-   Stock receiving
-   Stock audits

## Pharmaceutical Inventory

Example:

> **Product:** Paracetamol 500mg\
> **Batch:** PCM-24091\
> **Expiry:** 09/2028\
> **Quantity:** 142

The system should support FEFO/FIFO rules where operationally
appropriate.

Expired products must never be available for sale.

------------------------------------------------------------------------

# 15. Partner Pharmacy Platform

Partner onboarding should include:

-   Business name
-   Pharmacy address
-   Contact details
-   Regulatory information
-   Pharmacist information
-   Operating hours
-   Delivery radius
-   Product catalogue
-   Bank/payment information
-   Verification documents
-   Approval

## Partner Dashboard

-   Orders
-   Pending orders
-   Accepted orders
-   Preparing orders
-   Ready orders
-   Completed orders
-   Cancelled orders
-   Inventory
-   Sales
-   Earnings
-   Commission
-   Settlements
-   Reports

Partners must only access their own data.

------------------------------------------------------------------------

# 16. Order Management

Recommended order lifecycle:

**Cart → Checkout → Payment Pending → Payment Confirmed → Order Placed →
Routing → Accepted → Picking → Ready for Pickup → Rider Assigned →
Picked Up → In Transit → Delivered**

Exception states:

-   Cancelled
-   Rejected
-   Failed Delivery
-   Returned
-   Refunded

The system must maintain an order-event timeline.

## Order Routing

Routing should consider:

-   Product availability
-   Customer location
-   Pharmacy location
-   Partner status
-   Operating hours
-   Delivery zone
-   Inventory
-   Commercial rules
-   Fulfilment priorities

Stock should be reserved where required.

------------------------------------------------------------------------

# 17. Logistics & Rider App

## Rider Workflow

1.  Login
2.  Set availability
3.  Receive delivery offer
4.  Accept/reject
5.  Navigate to pickup
6.  Verify pickup
7.  Pick up order
8.  Navigate to customer
9.  Verify customer
10. Complete delivery
11. Capture proof of delivery
12. Update delivery status

## Failed Delivery

-   Rider selects standardized reason.
-   Customer is notified.
-   System determines reattempt/return workflow.
-   Operations can intervene.
-   Inventory/payment/settlement records are updated as required.

## Dispatcher

-   Unassigned delivery queue
-   Active deliveries
-   Rider availability
-   Rider workload
-   Delivery map
-   Delivery list
-   Assignment/reassignment
-   SLA alerts
-   Failed deliveries
-   Delivery zones
-   Delivery fees
-   Performance reports

------------------------------------------------------------------------

# 18. Sales & CRM

Sales agents should have:

-   Lead inbox
-   Lead assignment
-   Customer profile
-   Conversation history
-   AI handoff
-   Follow-up tasks
-   Reminders
-   Assisted order creation
-   Sales tracking
-   Commission tracking
-   Conversion reporting

Sales attribution should distinguish:

-   Organic sales
-   AI-assisted sales
-   Human sales-agent-assisted sales
-   POS sales
-   Partner-generated sales

------------------------------------------------------------------------

# 19. Staff Attendance, Presence & Productivity

The system should maintain auditable staff attendance records.

Events may include:

-   Clock-in
-   Break started
-   Break ended
-   Clock-out
-   Active
-   Offline
-   Unavailable

Optional authorized workstation/session monitoring may record presence
events.

Example:

  Time    Event
  ------- ---------------
  08:01   Clocked in
  10:15   Break started
  10:32   Returned
  13:04   Break started
  13:21   Returned
  17:03   Clocked out

The system can calculate:

-   Total working time
-   Break time
-   Productive time
-   Late arrival
-   Early departure
-   Absence
-   Overtime

Any workplace presence monitoring must follow applicable employment and
privacy requirements.

------------------------------------------------------------------------

# 20. Accounting & Finance

Finance should include:

-   Sales revenue
-   Payments
-   Refunds
-   Reversals
-   Delivery charges
-   Partner commissions
-   Partner settlements
-   Rider earnings
-   Staff commissions
-   Purchases
-   Supplier expenses
-   Receivables
-   Payables
-   Reconciliation
-   Financial reports

## Illustrative Settlement

  Component                   Amount
  ------------------------ ---------
  Customer order             ₦15,000
  ComfortCare commission      ₦1,500
  Delivery fee                ₦1,000
  Partner earning            ₦12,500

> Figures are illustrative only. Actual commissions, taxes, delivery
> fees and settlement rules require approval.

------------------------------------------------------------------------

# 21. Admin Portal

## Dashboard

-   Revenue
-   Orders
-   Customers
-   Partners
-   Deliveries
-   Pending orders
-   Inventory alerts
-   Financial alerts
-   Staff activity

## Administration

-   Users
-   Roles
-   Permissions
-   Branches
-   Partners
-   Products
-   Categories
-   Pricing
-   Promotions
-   Inventory
-   Orders
-   Logistics
-   Riders
-   Sales
-   Finance
-   AI
-   Health configuration
-   Notifications
-   Audit logs
-   System settings

------------------------------------------------------------------------

# 22. Reporting & Analytics

## Executive

-   Revenue
-   Orders
-   Average order value
-   Active customers
-   Fulfilment
-   Delivery performance

## Commerce

-   Product sales
-   Category sales
-   Conversion
-   Repeat purchase
-   Abandoned carts

## Inventory

-   Stock levels
-   Stock valuation
-   Low stock
-   Expiring products
-   Expired products
-   Stock movement
-   Shrinkage

## Partner

-   Orders
-   Acceptance rate
-   Fulfilment rate
-   Sales
-   Commission
-   Settlements

## Logistics

-   Deliveries
-   Delivery SLA
-   Rider utilization
-   Failed deliveries
-   Delivery cost

## Sales

-   Leads
-   Conversion
-   Agent revenue
-   Follow-ups
-   AI handoffs

## Staff

-   Attendance
-   Presence
-   Working hours
-   Productivity
-   Sales

## Finance

-   Payments
-   Refunds
-   Commissions
-   Settlements
-   Expenses
-   Reconciliation

> KPI definitions must be centrally defined so dashboards and reports
> remain consistent.

------------------------------------------------------------------------

# 23. Notifications

Notifications should cover:

-   Order placed
-   Payment successful
-   Payment failed
-   Order accepted
-   Order rejected
-   Prescription status
-   Order ready
-   Rider assigned
-   Out for delivery
-   Delivered
-   Failed delivery
-   Refund
-   Medication reminder
-   Sales follow-up
-   Partner settlement
-   Low stock
-   Expiring products

Channels:

-   In-app
-   Push
-   SMS
-   Email

Marketing communications must respect user consent and preferences.

------------------------------------------------------------------------

# 24. Non-Functional Requirements

  -----------------------------------------------------------------------
  Area                                Requirement
  ----------------------------------- -----------------------------------
  Security                            TLS, encryption where appropriate,
                                      RBAC, secure secrets

  Privacy                             Consent, purpose limitation,
                                      restricted access and retention

  Availability                        High availability for ordering, POS
                                      and operations

  Performance                         Fast product search, checkout and
                                      POS

  Scalability                         Support increasing users, orders,
                                      partners and branches

  Auditability                        Financial, inventory, prescription
                                      and administrative audit logs

  Observability                       Logs, metrics, traces and alerts

  Accessibility                       Readable typography, contrast and
                                      accessible controls

  Localization                        Nigerian Naira, phone formats,
                                      addresses and time zone

  Backup                              Automated backup and tested
                                      recovery
  -----------------------------------------------------------------------

------------------------------------------------------------------------

# 25. Core Data Entities

-   User
-   Role
-   Permission
-   Customer
-   Customer Profile
-   Health Record
-   Medication
-   Product
-   Category
-   Product Batch
-   Inventory Location
-   Stock Movement
-   Branch
-   Partner
-   Order
-   Order Item
-   Prescription
-   Payment
-   Delivery
-   Rider
-   Lead
-   Conversation
-   Commission
-   Settlement
-   Attendance Event
-   Notification
-   Audit Event

------------------------------------------------------------------------

# 26. Critical End-to-End Workflows

## Customer Order

Customer discovers product → Product detail → Cart → Checkout → Payment
→ Order routing → Fulfilment → Picking → Rider assignment → Pickup →
Delivery → Proof of delivery → Completion → Inventory and financial
updates.

## Partner Fulfilment

Partner receives order → Verifies stock → Accepts → Reserves stock →
Picks/packs → Ready → Rider pickup → Delivery → Stock update → Partner
earning → Settlement.

## AI Sales Handoff

Customer chats → AI understands intent → AI assists → Buying intent
detected → Lead created → Sales agent assigned → Agent receives
conversation summary → Agent continues → Order created → Attribution
recorded.

## POS Sale

Cashier opens shift → Scans products → Customer selected → Prescription
checked if required → Discount → Payment → Receipt → Stock deduction →
Transaction recorded → Shift reconciliation.

## Failed Delivery

Rider fails delivery → Reason recorded → System triggers
reattempt/return workflow → Customer notified → Operations resolves →
Financial/inventory records updated.

------------------------------------------------------------------------

# 27. Initial UI/UX Screen Inventory

## Customer App

-   Splash
-   Onboarding
-   Login
-   OTP
-   Home
-   Search
-   Categories
-   Product Listing
-   Product Detail
-   Cart
-   Checkout
-   Payment
-   Order Success
-   Orders
-   Order Detail
-   Delivery Tracking
-   Prescription Upload
-   Prescription Status
-   AI Chat
-   Health Dashboard
-   Medication
-   Measurements
-   Profile
-   Addresses
-   Notifications
-   Support
-   Settings

## POS

-   Login
-   Shift Start
-   Sales
-   Product Search
-   Cart
-   Customer
-   Prescription Check
-   Discount
-   Payment
-   Receipt
-   Returns
-   Transactions
-   Shift Close
-   Reconciliation
-   Reports

## Partner Portal

-   Onboarding
-   Verification
-   Dashboard
-   Pharmacy Profile
-   Products
-   Inventory
-   Orders
-   Order Detail
-   Fulfilment
-   Earnings
-   Commission
-   Settlements
-   Reports
-   Staff
-   Settings

## Rider App

-   Login
-   Availability
-   Delivery Queue
-   Delivery Detail
-   Navigation
-   Pickup Verification
-   In Transit
-   Customer Delivery
-   Proof of Delivery
-   Failed Delivery
-   Earnings
-   History
-   Profile

## Sales/Staff Portal

-   Dashboard
-   Leads
-   Lead Detail
-   Conversations
-   AI Handoff
-   Customers
-   Follow-ups
-   Assisted Order
-   Sales
-   Commission
-   Attendance
-   Presence Timeline
-   Reports
-   Profile

## Admin

-   Dashboard
-   Users
-   Roles
-   Permissions
-   Branches
-   Partners
-   Products
-   Categories
-   Inventory
-   Orders
-   Logistics
-   Riders
-   Sales
-   AI
-   Health Configuration
-   Finance
-   Settlements
-   Reports
-   Promotions
-   Notifications
-   Audit Logs
-   Settings

------------------------------------------------------------------------

# 28. Integrations

Potential integrations:

-   Nigerian payment gateways
-   SMS/OTP
-   Email
-   Push notifications
-   Maps/geocoding/navigation
-   Barcode/QR scanning
-   Secure cloud storage
-   Analytics
-   Crash monitoring
-   Accounting/ERP
-   Health-device integrations in later phases

Each integration must define:

-   Timeout
-   Retry behavior
-   Failure behavior
-   Idempotency
-   Reconciliation
-   Monitoring

------------------------------------------------------------------------

# 29. Security, Privacy & Audit

Requirements:

-   Strong authentication
-   Secure session management
-   API-level authorization
-   Partner tenant isolation
-   Least privilege
-   Audit logging
-   Secure prescription storage
-   Health-data protection
-   Payment credential minimization
-   Security monitoring
-   Vulnerability management
-   Incident response
-   Defined data retention

Health information must receive stronger access controls than ordinary
commerce information.

------------------------------------------------------------------------

# 30. Recommended Delivery Phases

  -----------------------------------------------------------------------
  Phase                               Scope
  ----------------------------------- -----------------------------------
  Phase 1 --- Foundation              Identity, RBAC, products, branches,
                                      inventory foundation, order model,
                                      payments, admin

  Phase 2 --- Customer Commerce       Mobile catalogue, cart, checkout,
                                      orders, notifications and tracking

  Phase 3 --- POS                     POS, shifts, sales, receipts,
                                      inventory integration,
                                      reconciliation

  Phase 4 --- Logistics               Rider app, dispatch, tracking,
                                      proof of delivery

  Phase 5 --- Partners                Partner onboarding, catalogue,
                                      inventory, fulfilment, settlements

  Phase 6 --- Sales & Staff           CRM, AI handoff, sales performance,
                                      attendance

  Phase 7 --- AI & Health             Controlled AI, approved knowledge
                                      base, health records/reminders

  Phase 8 --- Advanced Analytics      BI, forecasting and optimization
  -----------------------------------------------------------------------

### MVP Principle

Launch a reliable:

**Commerce + Inventory + Payment + Fulfilment + Logistics**

core before introducing sophisticated AI and health automation.

The AI layer should initially use controlled knowledge with safety
testing and human escalation.

------------------------------------------------------------------------

# 31. High-Level Acceptance Criteria

The platform is acceptable when:

-   A verified customer can register.
-   A customer can browse products.
-   A customer can place an order.
-   Payment status is accurately reconciled.
-   Orders can be routed to a fulfilment source.
-   Stock can be reserved and deducted correctly.
-   Pharmacists can review prescriptions.
-   Partners can fulfil authorized orders.
-   Riders can complete deliveries.
-   Proof of delivery can be captured.
-   Failed deliveries can be managed.
-   POS sales update inventory.
-   Online and POS transactions use consistent financial records.
-   AI can hand conversations to human staff.
-   Sales agents can manage leads.
-   Staff attendance can be recorded.
-   Finance can reconcile payments and settlements.
-   Administrators can control permissions.
-   Critical actions are audited.
-   Reports reconcile with transaction data.

------------------------------------------------------------------------

# 32. Key Risks & Mitigations

  -----------------------------------------------------------------------
  Risk                                Mitigation
  ----------------------------------- -----------------------------------
  Unsafe AI advice                    Controlled knowledge, red-flag
                                      rules, pharmacist escalation

  Incorrect inventory                 Batch/location ledger,
                                      reservations, barcode workflows

  Partner data leakage                Tenant isolation and least
                                      privilege

  Payment mismatch                    Webhooks, idempotency, transaction
                                      ledger and reconciliation

  Delivery failure                    Standard exception states and
                                      reattempt/return rules

  Staff privacy concerns              Clear notice, purpose limitation
                                      and retention policy

  Scope creep                         Phased roadmap and change control

  Operational complexity              Central order state machine and
                                      clear ownership
  -----------------------------------------------------------------------

------------------------------------------------------------------------

# 33. Business Decisions Required Before Development

ComfortCare must finalize:

1.  Exact ComfortCare commission model.
2.  Partner commission model.
3.  Partner verification requirements.
4.  Prescription-required product categories.
5.  Pharmacist review policy.
6.  Delivery pricing.
7.  Delivery zones.
8.  Rider compensation.
9.  Cash-on-delivery policy, if supported.
10. Refund and cancellation policy.
11. Return policy by product category.
12. Payment providers.
13. Partner settlement schedule.
14. Sales-agent commission model.
15. Staff presence monitoring approach.
16. Staff monitoring retention policy.
17. Health-data consent and sharing policy.
18. AI knowledge sources.
19. Clinical reviewer and escalation process.
20. Applicable regulatory requirements.
21. Initial launch city/branches.
22. Initial partner pharmacy strategy.
23. Accounting/ERP integration requirements.

------------------------------------------------------------------------

# 34. Product & UX Principles

-   Healthcare trust first.
-   Clear and transparent pricing.
-   Simple search and checkout.
-   Clear safety information.
-   Clinical guidance must remain distinct from commercial persuasion.
-   Operational status must be visible to the correct user.
-   Consistent terminology across platforms.
-   Nigerian-first design assumptions.
-   Strong readability and accessibility.
-   Auditable financial and inventory operations.
-   Conversational but controlled AI.
-   Privacy by design.

------------------------------------------------------------------------

# 35. Next Product Artifacts

1.  Detailed Role & Permission Matrix
2.  Complete Business Rules
3.  Order State Specification
4.  Inventory Rules Specification
5.  Financial & Commission Rules
6.  Partner Operating Model
7.  Logistics & SLA Specification
8.  AI Safety & Knowledge Specification
9.  Health Data Specification
10. Database / ERD Specification
11. API Specification
12. Complete UI/UX Design Specification
13. Navigation Maps
14. Engineering Backlog
15. QA/UAT Test Plan

------------------------------------------------------------------------

# 36. Conclusion

ComfortCare should be built as a connected pharmacy and healthcare
commerce ecosystem.

The foundation is:

**Orders + Inventory + Payments + Partners + Logistics**

Around this foundation sit:

**Customer App + POS + Rider App + Sales/CRM + Staff Management +
Admin**

The AI and health layers then extend the platform into a more
personalized customer relationship system while remaining subject to
clinical safety, privacy and regulatory requirements.

This PRD serves as the baseline for product discovery, UI/UX design,
architecture and engineering planning.

Before production development begins, ComfortCare should approve the
open commercial, clinical, operational, financial and regulatory
decisions identified in this document.

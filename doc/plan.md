# 🏠 SQR Rental Platform - User-Centric Development Plan

## 📋 Overview

This document outlines the complete development roadmap for the SQR rental platform, organized by user roles and the specific actions each user can perform. This approach ensures that every feature is directly tied to real user needs and workflows, addressing the key pain points in the Nigerian rental market.

## 🎯 Nigerian Rental Market Pain Points We're Solving

- ✅ **Fake Listings**: Verified agents & properties only
- ✅ **Agent Dependence**: App-controlled inspections & fees  
- ✅ **Poor Dispute Support**: Escrow, ticketing, fast mediation
- ✅ **Outdated Listings**: Auto-expiry, weekly confirmation
- ✅ **No Local Info**: User-generated community reviews
- ✅ **Bad Mobile UX**: Speed, offline-first, mobile optimization
- ✅ **Poor Onboarding**: Guided flows, trust signals
- ✅ **No Trust Network**: Community building, referrals

## 👥 Platform User Roles

- **🏠 Tenants** - Property seekers looking for rental homes
- **🏢 Landlords** - Property owners listing and managing properties  
- **🔍 Inspection Agents** - Professional inspectors providing third-party assessments
- **👨‍💼 Admins** - Platform administrators ensuring system integrity

---

## 👤 TENANT USER JOURNEY & ACTIONS

> *The tenant is the primary user of our platform - someone looking for a rental property in Nigeria*

### 🔐 1. Account Management & Onboarding

#### 1.1 Account Creation & Verification ✅ COMPLETE
**User Story**: *"As a new tenant, I want to create an account so I can start searching for properties"*

**Actions Tenants Can Take**:
- ✅ **Sign up** with email/phone number (`POST /v1/create_user`)
- ✅ **Verify email** to activate account (`GET /v1/verify_email`)
- ✅ **Log in** to access the platform (`POST /v1/login_user`)
- ✅ **Reset password** if forgotten (`POST /v1/forgot_password`, `POST /v1/reset_password`)
- ✅ **Log out** from the platform (`POST /v1/logout`)
- ✅ **Refresh authentication** tokens (`POST /v1/refresh_token`)

#### 1.2 Profile Setup & Management 🔄 IN PROGRESS
**User Story**: *"As a tenant, I want to complete my profile so landlords can trust me and I can save my preferences"*

**Actions Tenants Can Take**:
- ✅ **View my profile** (`GET /v1/tenant/profile/{user_id}`)
- ✅ **Update basic profile** info (`PATCH /v1/tenant/profile`)
- 🔄 **Complete initial profile** setup (`POST /v1/tenant/profile`)
- 🔄 **Check profile completion** status (`GET /v1/tenant/profile/completion`)
- 🔄 **Upload verification documents** (ID, income proof) (`POST /v1/tenant/documents`)

#### 1.3 Preferences & Settings 🔄 PENDING
**User Story**: *"As a tenant, I want to set my preferences so the platform can show me relevant properties"*

**Actions Tenants Can Take**:
- 🔄 **Set location preferences** (preferred areas, commute distance)
- 🔄 **Set budget range** and payment preferences  
- 🔄 **Configure notification settings** (email, SMS, push)
- 🔄 **Set property preferences** (size, amenities, property type)

### 🔍 2. Property Discovery & Search

#### 2.1 Browsing & Search 🔄 PENDING
**User Story**: *"As a tenant, I want to find properties that match my needs and budget"*

**Actions Tenants Can Take**:
- 🔄 **Browse featured properties** (`GET /v1/properties/featured`)
- 🔄 **Search properties** with filters (`GET /v1/properties/search`)
- 🔄 **Filter by location** (city, area, proximity) (`GET /v1/properties/location/{city}/{state}`)
- 🔄 **Filter by price range** and property type
- 🔄 **View recent listings** (`GET /v1/properties/recent`)
- 🔄 **Get personalized recommendations** (`GET /v1/tenant/{tenant_id}/recommendations`)

#### 2.2 Property Details & Interaction 🔄 PENDING
**User Story**: *"As a tenant, I want to get detailed information about properties I'm interested in"*

**Actions Tenants Can Take**:
- 🔄 **View property details** (`GET /v1/properties/{property_id}`)
- 🔄 **View property photos/videos** and virtual tours
- 🔄 **Save properties** to favorites (`POST /v1/tenant/saved_properties`)
- 🔄 **Remove saved properties** (`DELETE /v1/tenant/saved_properties/{property_id}`)
- 🔄 **View all saved properties** (`GET /v1/tenant/saved_properties`)
- 🔄 **Share property** with family/friends
- 🔄 **Report suspicious listing** to admins

### 🏠 3. Property Inspection Process

#### 3.1 Inspection Requests 🔄 PENDING
**User Story**: *"As a tenant, I want to inspect properties either myself or with a professional agent"*

**Actions Tenants Can Take**:
- 🔄 **Request self-inspection** (`POST /v1/inspections` - type: "self")
- 🔄 **Request agent inspection** (`POST /v1/inspections` - type: "agent")  
- 🔄 **Choose inspection date/time** and confirm
- 🔄 **View my inspection requests** (`GET /v1/user/{user_id}/inspections`)
- 🔄 **Modify inspection details** (`PATCH /v1/inspections/{inspection_id}`)
- 🔄 **Cancel inspection** if needed (`DELETE /v1/inspections/{inspection_id}`)

#### 3.2 Inspection Execution 🔄 PENDING  
**User Story**: *"As a tenant, I want to conduct or participate in property inspections and get detailed reports"*

**Actions Tenants Can Take**:
- 🔄 **Receive inspection confirmation** and agent details
- 🔄 **Rate the inspection experience** after completion
- 🔄 **View inspection report** (`GET /v1/inspections/{inspection_id}/report`)
- 🔄 **Request additional inspection** if unsatisfied
- 🔄 **Download PDF report** for records

### 📄 4. Rental Application Process

#### 4.1 Application Submission 🔄 PENDING
**User Story**: *"As a tenant, I want to apply for properties I'm interested in renting"*

**Actions Tenants Can Take**:
- 🔄 **Submit rental application** (`POST /v1/applications`)
- 🔄 **Upload supporting documents** (income proof, references)
- 🔄 **View application status** (`GET /v1/applications/{application_id}`)
- 🔄 **Update application** before review (`PATCH /v1/applications/{application_id}`)
- 🔄 **Withdraw application** (`DELETE /v1/applications/{application_id}`)
- 🔄 **Track all my applications** (`GET /v1/user/{user_id}/applications`)

#### 4.2 Agreement & Move-in 🔄 PENDING
**User Story**: *"As a tenant, I want to complete the rental process and move into my new home"*

**Actions Tenants Can Take**:
- 🔄 **Review rental agreement** (`GET /v1/agreements/{agreement_id}`)
- 🔄 **Digitally sign agreement** (`POST /v1/agreements/{agreement_id}/sign`)
- 🔄 **Make security deposit payment** (`POST /v1/payments`)
- 🔄 **Schedule move-in inspection** 
- 🔄 **Confirm move-in** and start tenancy

### 💬 5. Communication & Support

#### 5.1 Messaging 🔄 PENDING
**User Story**: *"As a tenant, I want to communicate with landlords and agents securely"*

**Actions Tenants Can Take**:
- 🔄 **Send messages** to landlords/agents (`POST /v1/messages`)
- 🔄 **View conversation history** (`GET /v1/conversations/{conversation_id}`)
- 🔄 **See all my conversations** (`GET /v1/user/{user_id}/conversations`)
- 🔄 **Mark messages as read** (`POST /v1/messages/{message_id}/read`)
- 🔄 **Report inappropriate messages**

#### 5.2 Notifications & Alerts 🔄 PENDING
**User Story**: *"As a tenant, I want to stay updated on my applications, inspections, and new properties"*

**Actions Tenants Can Take**:
- 🔄 **View all notifications** (`GET /v1/notifications`)
- 🔄 **Mark notifications as read** (`POST /v1/notifications/{notification_id}/read`)
- 🔄 **Update notification preferences** (`PATCH /v1/notification_settings`)
- 🔄 **Delete old notifications** (`DELETE /v1/notifications/{notification_id}`)

### 💳 6. Payments & Financial Management

#### 6.1 Payment Processing 🔄 PENDING
**User Story**: *"As a tenant, I want to make secure payments for inspections, applications, and deposits"*

**Actions Tenants Can Take**:
- 🔄 **Pay inspection fees** (`POST /v1/payments`)
- 🔄 **Pay application fees** 
- 🔄 **Pay security deposits** through escrow
- 🔄 **View payment history** (`GET /v1/user/{user_id}/payment_history`)
- 🔄 **Request payment refunds** (`POST /v1/payments/{payment_id}/refund`)
- 🔄 **Update payment methods**

#### 6.2 Wallet & Refunds 🔄 PENDING
**User Story**: *"As a tenant, I want to manage my wallet and receive refunds when applicable"*

**Actions Tenants Can Take**:
- 🔄 **View wallet balance** (`GET /v1/wallet/balance`)
- 🔄 **Add money to wallet** 
- 🔄 **Withdraw funds** (`POST /v1/wallet/withdraw`)
- 🔄 **Track refund status**

### ⭐ 7. Reviews & Community

#### 7.1 Rating & Reviews 🔄 PENDING
**User Story**: *"As a tenant, I want to share my experience and help other tenants make informed decisions"*

**Actions Tenants Can Take**:
- 🔄 **Rate properties** after inspection/tenancy
- 🔄 **Review landlords** (`POST /v1/reviews`)
- 🔄 **Review inspection agents**
- 🔄 **View my reviews** (`GET /v1/user/{user_id}/reviews`)
- 🔄 **Update my reviews** (`PATCH /v1/reviews/{review_id}`)
- 🔄 **Report inappropriate reviews**

### 🤖 8. AI Assistant (TenantBot)

#### 8.1 Smart Assistance 🔄 PENDING
**User Story**: *"As a tenant, I want an AI assistant to help me find properties and answer questions"*

**Actions Tenants Can Take**:
- 🔄 **Chat with TenantBot** (`POST /v1/tenantbot/chat`)
- 🔄 **Get property recommendations** via chat
- 🔄 **Ask about neighborhoods** and local information
- 🔄 **View chat history** (`GET /v1/tenantbot/history`)
- 🔄 **Update bot preferences** (`PATCH /v1/tenantbot/preferences`)

---

## 🏢 LANDLORD USER JOURNEY & ACTIONS

> *The landlord is a property owner who wants to list, manage, and rent out their properties efficiently while ensuring they find reliable tenants*

### 🔐 1. Account Management & Business Setup

#### 1.1 Account Creation & Verification ✅ COMPLETE
**User Story**: *"As a landlord, I want to create an account so I can list my properties and manage rentals"*

**Actions Landlords Can Take**:

- ✅ **Sign up** with email/phone number (`POST /v1/create_user`)
- ✅ **Verify email** to activate account (`GET /v1/verify_email`)
- ✅ **Log in** to access the platform (`POST /v1/login_user`)
- ✅ **Reset password** if forgotten (`POST /v1/forgot_password`, `POST /v1/reset_password`)
- ✅ **Log out** from the platform (`POST /v1/logout`)
- ✅ **Refresh authentication** tokens (`POST /v1/refresh_token`)

#### 1.2 Landlord Profile Setup 🔄 PENDING
**User Story**: *"As a landlord, I want to set up my profile so tenants can trust me and I can showcase my properties professionally"*

**Actions Landlords Can Take**:

- 🔄 **Create landlord profile** (`POST /v1/landlord/profile`)
- 🔄 **View my profile** (`GET /v1/landlord/profile/{user_id}`)
- 🔄 **Update profile information** (`PATCH /v1/landlord/profile`)
- 🔄 **Upload business documents** (CAC, property docs)
- 🔄 **Verify business registration** (`POST /v1/landlord/verify_business`)
- 🔄 **Set property management preferences**

#### 1.3 Dashboard & Analytics 🔄 PENDING
**User Story**: *"As a landlord, I want to see an overview of my properties, applications, and earnings"*

**Actions Landlords Can Take**:

- 🔄 **View landlord dashboard** with key metrics
- 🔄 **Get landlord statistics** (`GET /v1/landlord/stats`)
- 🔄 **Track property performance** and views
- 🔄 **Monitor application rates** and tenant interest
- 🔄 **View earnings summary** and payment history

### 🏠 2. Property Management

#### 2.1 Property Listing & CRUD 🔄 PENDING
**User Story**: *"As a landlord, I want to create and manage property listings to attract quality tenants"*

**Actions Landlords Can Take**:

- 🔄 **Create new property listing** (`POST /v1/properties`)
- 🔄 **View my properties** (`GET /v1/landlord/{landlord_id}/properties`)
- 🔄 **Update property details** (`PATCH /v1/properties/{property_id}`)
- 🔄 **Delete/remove property** (`DELETE /v1/properties/{property_id}`)
- 🔄 **Change property status** (available, rented, under_maintenance) (`PATCH /v1/properties/{property_id}/status`)
- 🔄 **Set property pricing** and rental terms

#### 2.2 Media & Documentation 🔄 PENDING
**User Story**: *"As a landlord, I want to upload high-quality photos and documents to showcase my properties"*

**Actions Landlords Can Take**:

- 🔄 **Upload property photos** (`POST /v1/properties/{property_id}/media`)
- 🔄 **Upload property videos** and virtual tours
- 🔄 **Upload property documents** (certificates, floor plans)
- 🔄 **Reorder media** for optimal presentation
- 🔄 **Delete outdated media**
- 🔄 **Set featured photo** for listings

#### 2.3 Property Promotion & Visibility 🔄 PENDING
**User Story**: *"As a landlord, I want to promote my properties to reach more potential tenants"*

**Actions Landlords Can Take**:

- 🔄 **Feature property** for increased visibility
- 🔄 **Boost property** in search results (paid)
- 🔄 **Share property** on social media
- 🔄 **Track property views** and engagement
- 🔄 **Get listing optimization** suggestions
- 🔄 **Monitor competitor pricing**

### 🔍 3. Inspection Management

#### 3.1 Inspection Requests 🔄 PENDING
**User Story**: *"As a landlord, I want to manage inspection requests for my properties efficiently"*

**Actions Landlords Can Take**:

- 🔄 **View inspection requests** for my properties
- 🔄 **Approve/decline inspection** requests
- 🔄 **Set available inspection times**
- 🔄 **Confirm inspection appointments**
- 🔄 **Reschedule inspections** if needed
- 🔄 **Block specific dates** from inspection availability

#### 3.2 Inspection Participation 🔄 PENDING
**User Story**: *"As a landlord, I want to participate in or monitor property inspections"*

**Actions Landlords Can Take**:

- 🔄 **Receive inspection notifications**
- 🔄 **Join inspection calls** (if virtual)
- 🔄 **View inspection reports** (`GET /v1/inspections/{inspection_id}/report`)
- 🔄 **Respond to inspection feedback**
- 🔄 **Address property issues** identified during inspection
- 🔄 **Rate inspection agents**

### 📄 4. Tenant Application Management

#### 4.1 Application Review Process 🔄 PENDING
**User Story**: *"As a landlord, I want to review tenant applications to find the best tenants for my properties"*

**Actions Landlords Can Take**:

- 🔄 **View incoming applications** (`GET /v1/landlord/{landlord_id}/applications`)
- 🔄 **Review application details** (`GET /v1/applications/{application_id}`)
- 🔄 **Check tenant background** and references
- 🔄 **Approve applications** (`POST /v1/applications/{application_id}/approve`)
- 🔄 **Decline applications** with reasons (`POST /v1/applications/{application_id}/decline`)
- 🔄 **Request additional information** from tenants

#### 4.2 Tenant Screening & Verification 🔄 PENDING
**User Story**: *"As a landlord, I want to verify tenant information to make informed decisions"*

**Actions Landlords Can Take**:

- 🔄 **View tenant profiles** and ratings
- 🔄 **Check tenant verification status**
- 🔄 **Review tenant documents** (ID, income proof)
- 🔄 **Contact tenant references**
- 🔄 **Run background checks** (if available)
- 🔄 **Review tenant rental history**

#### 4.3 Agreement & Move-in Process 🔄 PENDING
**User Story**: *"As a landlord, I want to complete the rental process with approved tenants"*

**Actions Landlords Can Take**:

- 🔄 **Create rental agreement** (`POST /v1/agreements`)
- 🔄 **Send agreement to tenant** for signing
- 🔄 **Sign rental agreement** (`POST /v1/agreements/{agreement_id}/sign`)
- 🔄 **Collect security deposit** through escrow
- 🔄 **Schedule move-in inspection**
- 🔄 **Complete move-in process**

### 🔍 5. Communication & Tenant Relations

#### 5.1 Messaging & Communication 🔄 PENDING
**User Story**: *"As a landlord, I want to communicate with prospective and current tenants effectively"*

**Actions Landlords Can Take**:

- 🔄 **Send messages** to interested tenants (`POST /v1/messages`)
- 🔄 **View conversations** (`GET /v1/conversations/{conversation_id}`)
- 🔄 **Respond to tenant inquiries**
- 🔄 **Send property updates** to interested parties
- 🔄 **Broadcast announcements** to multiple tenants
- 🔄 **Schedule property tours** via messaging

#### 5.2 Notifications & Alerts 🔄 PENDING
**User Story**: *"As a landlord, I want to stay updated on property interest, applications, and issues"*

**Actions Landlords Can Take**:

- 🔄 **Receive new application alerts**
- 🔄 **Get inspection request notifications**
- 🔄 **View all notifications** (`GET /v1/notifications`)
- 🔄 **Mark notifications as read** (`POST /v1/notifications/{notification_id}/read`)
- 🔄 **Configure notification preferences** (`PATCH /v1/notification_settings`)
- 🔄 **Set up property alert triggers**

### 💳 6. Financial Management

#### 6.1 Payment & Revenue Tracking 🔄 PENDING
**User Story**: *"As a landlord, I want to track payments and manage my rental income"*

**Actions Landlords Can Take**:

- 🔄 **View payment history** (`GET /v1/user/{user_id}/payment_history`)
- 🔄 **Track rental income** from all properties
- 🔄 **Monitor deposit payments** and escrow status
- 🔄 **Generate payment reports** for tax purposes
- 🔄 **Set up automatic payment** notifications
- 🔄 **Request payment verification** documents

#### 6.2 Wallet & Withdrawals 🔄 PENDING
**User Story**: *"As a landlord, I want to manage my earnings and withdraw funds securely"*

**Actions Landlords Can Take**:

- 🔄 **View wallet balance** (`GET /v1/wallet/balance`)
- 🔄 **Withdraw earnings** (`POST /v1/wallet/withdraw`)
- 🔄 **Set up bank account** for withdrawals
- 🔄 **Track withdrawal history**
- 🔄 **Manage payment methods**
- 🔄 **Handle refund requests** from tenants

### ⭐ 7. Reviews & Reputation Management

#### 7.1 Reviews & Ratings 🔄 PENDING
**User Story**: *"As a landlord, I want to build a good reputation and get feedback from tenants"*

**Actions Landlords Can Take**:

- 🔄 **View my reviews** (`GET /v1/user/{user_id}/reviews`)
- 🔄 **Respond to tenant reviews**
- 🔄 **Rate tenants** after tenancy (`POST /v1/reviews`)
- 🔄 **Report inappropriate reviews**
- 🔄 **Request reviews** from satisfied tenants
- 🔄 **Monitor rating trends** and feedback

### 📊 8. Analytics & Insights

#### 8.1 Property Performance Analytics 🔄 PENDING
**User Story**: *"As a landlord, I want insights into my property performance to optimize my listings"*

**Actions Landlords Can Take**:

- 🔄 **View property analytics** (views, inquiries, applications)
- 🔄 **Track market trends** in my area
- 🔄 **Compare property performance**
- 🔄 **Get pricing recommendations**
- 🔄 **Monitor competitive analysis**
- 🔄 **Export performance reports**
rpc GetInspectionRequest(GetInspectionRequestRequest) returns (GetInspectionRequestResponse)
rpc UpdateInspectionRequest(UpdateInspectionRequestRequest) returns (UpdateInspectionRequestResponse)
---

## 🔍 INSPECTION AGENT USER JOURNEY & ACTIONS

> *The inspection agent is a professional who conducts property inspections on behalf of tenants, earning income through the platform*

### 🔐 1. Account Management & Professional Setup

#### 1.1 Account Creation & Verification ✅ COMPLETE
**User Story**: *"As an inspection agent, I want to create an account so I can offer inspection services and earn income"*

**Actions Inspection Agents Can Take**:

- ✅ **Sign up** with email/phone number (`POST /v1/create_user`)
- ✅ **Verify email** to activate account (`GET /v1/verify_email`)
- ✅ **Log in** to access the platform (`POST /v1/login_user`)
- ✅ **Reset password** if forgotten (`POST /v1/forgot_password`, `POST /v1/reset_password`)
- ✅ **Log out** from the platform (`POST /v1/logout`)
- ✅ **Refresh authentication** tokens (`POST /v1/refresh_token`)

#### 1.2 Agent Profile Setup 🔄 PENDING
**User Story**: *"As an inspection agent, I want to set up my professional profile to attract clients and showcase my expertise"*

**Actions Inspection Agents Can Take**:

- 🔄 **Create agent profile** (`POST /v1/agent/profile`)
- 🔄 **View my profile** (`GET /v1/agent/profile/{user_id}`)
- 🔄 **Update profile information** (`PATCH /v1/agent/profile`)
- 🔄 **Upload professional credentials** (certifications, licenses)
- 🔄 **Set service areas** and coverage zones
- 🔄 **Upload profile photo** and professional documents

#### 1.3 Availability & Schedule Management 🔄 PENDING
**User Story**: *"As an inspection agent, I want to manage my availability to receive inspection requests that fit my schedule"*

**Actions Inspection Agents Can Take**:

- 🔄 **Set my availability** (`POST /v1/agent/availability`)
- 🔄 **Update working hours** and days
- 🔄 **Block specific dates** when unavailable
- 🔄 **Set maximum daily inspections**
- 🔄 **Configure travel radius** for accepting jobs
- 🔄 **Update availability status** (active, busy, offline)

### 📋 2. Inspection Request Management

#### 2.1 Receiving & Managing Requests 🔄 PENDING
**User Story**: *"As an inspection agent, I want to receive and manage inspection requests efficiently"*

**Actions Inspection Agents Can Take**:

- 🔄 **View available inspection requests** in my area
- 🔄 **See my assigned inspections** (`GET /v1/agent/{agent_id}/inspections`)
- 🔄 **Accept inspection requests** (`POST /v1/agent/inspections/{inspection_id}/accept`)
- 🔄 **Decline inspection requests** (`POST /v1/agent/inspections/{inspection_id}/decline`)
- 🔄 **Request inspection details** and property information
- 🔄 **Communicate with tenants** about inspection requirements

#### 2.2 Inspection Scheduling 🔄 PENDING
**User Story**: *"As an inspection agent, I want to coordinate inspection schedules with all parties involved"*

**Actions Inspection Agents Can Take**:

- 🔄 **Propose inspection times** to tenants and landlords
- 🔄 **Confirm inspection appointments** (`POST /v1/inspections/{inspection_id}/confirm`)
- 🔄 **Reschedule inspections** if needed
- 🔄 **Set inspection reminders**
- 🔄 **Contact parties** for schedule changes
- 🔄 **Update inspection status**

### 🏠 3. Inspection Execution

#### 3.1 Conducting Inspections 🔄 PENDING
**User Story**: *"As an inspection agent, I want to conduct thorough property inspections using professional tools and checklists"*

**Actions Inspection Agents Can Take**:

- 🔄 **Start inspection** (`POST /v1/inspections/{inspection_id}/start`)
- 🔄 **Use digital checklist** (`POST /v1/inspections/{inspection_id}/checklist`)
- 🔄 **Take inspection photos/videos** (`POST /v1/inspections/{inspection_id}/media`)
- 🔄 **Record inspection notes** and observations
- 🔄 **Identify property issues** and defects
- 🔄 **Complete inspection** (`POST /v1/inspections/{inspection_id}/complete`)

#### 3.2 Report Generation 🔄 PENDING
**User Story**: *"As an inspection agent, I want to create comprehensive inspection reports for my clients"*

**Actions Inspection Agents Can Take**:

- 🔄 **Generate inspection report** automatically
- 🔄 **Edit and customize report** details
- 🔄 **Add professional recommendations**
- 🔄 **Include repair cost estimates**
- 🔄 **Submit final report** for client review
- 🔄 **Export report as PDF** for download

### 💼 4. Business Management

#### 4.1 Earnings & Payments 🔄 PENDING
**User Story**: *"As an inspection agent, I want to track my earnings and manage payments efficiently"*

**Actions Inspection Agents Can Take**:

- 🔄 **View earnings dashboard** (`GET /v1/agent/earnings`)
- 🔄 **Track completed inspections** and fees
- 🔄 **View payment history** (`GET /v1/user/{user_id}/payment_history`)
- 🔄 **Withdraw earnings** (`POST /v1/wallet/withdraw`)
- 🔄 **Set up bank account** for payments
- 🔄 **Generate earnings reports** for tax purposes

#### 4.2 Performance Analytics 🔄 PENDING
**User Story**: *"As an inspection agent, I want to monitor my performance and improve my service quality"*

**Actions Inspection Agents Can Take**:

- 🔄 **View performance metrics** (completion rate, ratings)
- 🔄 **Track client satisfaction** scores
- 🔄 **Monitor inspection volume** trends
- 🔄 **See earning potential** in different areas
- 🔄 **Get feedback insights** from clients
- 🔄 **Compare performance** with other agents

### ⭐ 5. Client Relations & Reviews

#### 5.1 Client Communication 🔄 PENDING
**User Story**: *"As an inspection agent, I want to maintain good relationships with tenants and landlords"*

**Actions Inspection Agents Can Take**:

- 🔄 **Message clients** before and after inspections (`POST /v1/messages`)
- 🔄 **Provide inspection updates** during the process
- 🔄 **Answer client questions** about the report
- 🔄 **Follow up** after inspection completion
- 🔄 **Handle complaints** or concerns professionally
- 🔄 **Build client relationships** for repeat business

#### 5.2 Reviews & Reputation 🔄 PENDING
**User Story**: *"As an inspection agent, I want to build a strong reputation to attract more clients"*

**Actions Inspection Agents Can Take**:

- 🔄 **View my reviews** from clients (`GET /v1/user/{user_id}/reviews`)
- 🔄 **Respond to client reviews** professionally
- 🔄 **Request reviews** from satisfied clients
- 🔄 **Monitor rating trends** and feedback
- 🔄 **Address negative feedback** constructively
- 🔄 **Showcase positive reviews** in profile

---

## 👨‍💼 ADMIN USER JOURNEY & ACTIONS

> *The admin is responsible for platform integrity, user safety, dispute resolution, and overall system management*

### 🛡️ 1. Platform Security & User Management

#### 1.1 User Account Oversight 🔄 PENDING
**User Story**: *"As an admin, I want to monitor and manage user accounts to ensure platform safety"*

**Actions Admins Can Take**:

- 🔄 **View all users list** (`GET /v1/admin/users`)
- 🔄 **Search users** by various criteria
- 🔄 **View user details** and activity history
- 🔄 **Suspend user accounts** (`POST /v1/admin/users/{user_id}/suspend`)
- 🔄 **Reactivate suspended accounts**
- 🔄 **Delete spam/fake accounts**

#### 1.2 Verification & Approval Management 🔄 PENDING
**User Story**: *"As an admin, I want to verify users and properties to maintain platform quality"*

**Actions Admins Can Take**:

- 🔄 **Review user verification** documents
- 🔄 **Approve/reject user** verification requests
- 🔄 **Verify property listings** (`POST /v1/admin/properties/{property_id}/verify`)
- 🔄 **Review agent credentials** and certifications
- 🔄 **Manage verification queues**
- 🔄 **Set verification standards** and requirements

### 📊 2. Platform Analytics & Monitoring

#### 2.1 System Metrics & Performance 🔄 PENDING
**User Story**: *"As an admin, I want to monitor platform performance and user engagement"*

**Actions Admins Can Take**:

- 🔄 **View platform statistics** (`GET /v1/admin/stats`)
- 🔄 **Monitor user activity** and engagement metrics
- 🔄 **Track property listing** trends
- 🔄 **Monitor inspection completion** rates
- 🔄 **View revenue analytics** and payment metrics
- 🔄 **Generate platform reports** (`GET /v1/admin/reports/{report_type}`)

#### 2.2 Fraud Detection & Prevention 🔄 PENDING
**User Story**: *"As an admin, I want to detect and prevent fraudulent activities on the platform"*

**Actions Admins Can Take**:

- 🔄 **Monitor suspicious activities** and patterns
- 🔄 **Review flagged listings** and users
- 🔄 **Investigate fraud reports** from users
- 🔄 **Block suspicious IP addresses** and accounts
- 🔄 **Review payment anomalies** and chargebacks
- 🔄 **Implement fraud prevention** measures

### ⚖️ 3. Dispute Resolution & Support

#### 3.1 Dispute Management 🔄 PENDING
**User Story**: *"As an admin, I want to handle disputes between users fairly and efficiently"*

**Actions Admins Can Take**:

- 🔄 **View open disputes** and tickets
- 🔄 **Review dispute details** and evidence
- 🔄 **Communicate with disputing parties**
- 🔄 **Mediate between users** to find solutions
- 🔄 **Make final decisions** on disputes (`POST /v1/admin/disputes/{dispute_id}/handle`)
- 🔄 **Process refunds** and compensations

#### 3.2 Customer Support 🔄 PENDING
**User Story**: *"As an admin, I want to provide excellent customer support to all platform users"*

**Actions Admins Can Take**:

- 🔄 **Handle support tickets** and inquiries
- 🔄 **Respond to user complaints**
- 🔄 **Provide technical assistance**
- 🔄 **Guide users** through platform features
- 🔄 **Escalate complex issues** to technical team
- 🔄 **Maintain support knowledge base**

### 🔧 4. Content & Quality Management

#### 4.1 Content Moderation 🔄 PENDING
**User Story**: *"As an admin, I want to maintain high-quality content and appropriate communication on the platform"*

**Actions Admins Can Take**:

- 🔄 **Review reported content** and messages
- 🔄 **Moderate user reviews** and ratings
- 🔄 **Remove inappropriate content**
- 🔄 **Monitor property descriptions** for accuracy
- 🔄 **Enforce community guidelines**
- 🔄 **Ban users** for policy violations

#### 4.2 Feature Management 🔄 PENDING
**User Story**: *"As an admin, I want to manage platform features and configurations"*

**Actions Admins Can Take**:

- 🔄 **Configure platform settings** and parameters
- 🔄 **Manage featured properties** and promotions
- 🔄 **Set inspection fees** and pricing
- 🔄 **Update platform policies** and terms
- 🔄 **Deploy feature flags** and A/B tests
- 🔄 **Manage system announcements**

### 💰 5. Financial Management & Operations

#### 5.1 Payment & Revenue Management 🔄 PENDING
**User Story**: *"As an admin, I want to oversee platform finances and payment operations"*

**Actions Admins Can Take**:

- 🔄 **Monitor platform revenue** and commission
- 🔄 **Track payment processing** and failures
- 🔄 **Handle payment disputes** and chargebacks
- 🔄 **Manage escrow accounts** and deposits
- 🔄 **Process agent payments** and commissions
- 🔄 **Generate financial reports** for stakeholders

---

## 🚀 IMPLEMENTATION ROADMAP BY USER ROLE

### Phase 1: Foundation (Weeks 1-2) ✅ COMPLETE
**Focus**: Authentication and basic user management

- ✅ Authentication system for all user types
- ✅ Basic tenant profile management
- ✅ User verification and security features

### Phase 2: Tenant Experience (Weeks 3-5) 🔄 IN PROGRESS
**Focus**: Complete tenant journey implementation

- 🔄 Advanced tenant profile management
- 🔄 Property search and discovery features
- 🔄 Property saving and recommendation system
- 🔄 Tenant application submission workflow

### Phase 3: Landlord Tools (Weeks 6-8) 🔄 PENDING
**Focus**: Landlord property management and tenant selection

- 🔄 Landlord profile and business verification
- 🔄 Property CRUD operations and media management
- 🔄 Application review and tenant screening
- 🔄 Rental agreement creation and management

### Phase 4: Inspection System (Weeks 9-11) 🔄 PENDING
**Focus**: Complete inspection workflow for all parties

- 🔄 Inspection agent profile and availability management
- 🔄 Inspection request and scheduling system
- 🔄 Mobile inspection tools and checklist
- 🔄 Report generation and approval workflow

### Phase 5: Communication & Payments (Weeks 12-13) 🔄 PENDING
**Focus**: Platform communication and financial transactions

- 🔄 In-app messaging system for all user types
- 🔄 Notification system and preferences
- 🔄 Payment processing and escrow management
- 🔄 Agent earnings and withdrawal system

### Phase 6: Community & Trust (Weeks 14-15) 🔄 PENDING
**Focus**: Reviews, ratings, and community features

- 🔄 Multi-directional review system
- 🔄 Rating and reputation management
- 🔄 Community features and local insights
- 🔄 Trust signals and verification badges

### Phase 7: Admin & Analytics (Weeks 15-16) 🔄 PENDING
**Focus**: Platform management and business intelligence

- 🔄 Admin dashboard and user management
- 🔄 Dispute resolution and support tools
- 🔄 Analytics and reporting system
- 🔄 Fraud detection and prevention

### Phase 8: AI Assistant (Weeks 16-17) 🔄 PENDING
**Focus**: Intelligent assistance and recommendations

- 🔄 TenantBot AI assistant implementation
- 🔄 Natural language property search
- 🔄 Intelligent recommendations and matching
- 🔄 Automated customer support

---

## 📊 SUCCESS METRICS BY USER ROLE

### Tenant Success Metrics
- **Conversion Rate**: % of browsers who submit applications
- **Time to Find**: Average days from signup to application submission
- **Satisfaction Score**: Post-inspection and post-move-in ratings
- **Platform Stickiness**: Return visits and saved properties

### Landlord Success Metrics
- **Listing Performance**: Views, inquiries, and applications per property
- **Time to Rent**: Average days from listing to tenant selection
- **Quality Score**: Tenant satisfaction with properties and landlords
- **Revenue Growth**: Income from successful rentals through platform

### Inspection Agent Success Metrics
- **Utilization Rate**: % of available time slots filled with inspections
- **Completion Rate**: % of accepted inspections successfully completed
- **Client Satisfaction**: Average ratings from tenants and landlords
- **Earnings Growth**: Monthly income trends and repeat clients

### Platform Success Metrics
- **User Growth**: Monthly active users across all roles
- **Transaction Volume**: Total inspections, applications, and rentals
- **Revenue Per User**: Average revenue generated per active user
- **Trust Score**: Overall platform safety and satisfaction ratings

---

## 🔚 NEXT STEPS

### Week 1 Priorities:
1. Complete tenant profile management system
2. Begin landlord profile implementation
3. Set up property management database integration

### Week 2 Priorities:
1. Implement property CRUD operations
2. Build property search and filtering system
3. Create inspection agent profile system

### Week 3 Priorities:
1. Develop inspection request workflow
2. Build messaging system infrastructure
3. Implement payment processing framework

This user-centric approach ensures every feature directly addresses real user needs and creates clear value for each platform participant, resulting in a more intuitive and successful rental platform.

---

## 🛠️ TECHNICAL IMPLEMENTATION DETAILS

### Current Tech Stack ✅ IMPLEMENTED

- **Backend**: Go with gRPC + HTTP Gateway
- **Database**: PostgreSQL with SQLC code generation
- **Cache**: Redis with custom cache layer
- **Queue**: Asynq for background tasks
- **Authentication**: PASETO tokens with refresh mechanism
- **Rate Limiting**: Redis-based sliding window algorithm
- **API Documentation**: OpenAPI/Swagger with auto-generation

### Required Integrations 🔄 PENDING

- **File Storage**: AWS S3 or Cloudinary for media uploads
- **Payment Gateway**: Paystack/Flutterwave for Nigerian market
- **Maps**: Google Maps API for location services
- **Push Notifications**: Firebase Cloud Messaging
- **Email Service**: SendGrid or AWS SES for transactional emails
- **Monitoring**: Prometheus + Grafana for observability
- **Deployment**: Docker + Kubernetes for scalability

### Rate Limiting Strategy ✅ IMPLEMENTED

**Current Rules**:
```go
"/pb.Sqr/CreateUser": {RPS: 2, Window: time.Minute, Scope: "ip"},
"/pb.Sqr/LoginUser": {RPS: 10, Window: time.Minute, Scope: "ip"},
"/pb.Sqr/UpdateTenantProfile": {RPS: 30, Window: time.Minute, Scope: "user"},
```

**Planned Rules**:
```go
"/pb.Sqr/SearchProperties": {RPS: 100, Window: time.Minute, Scope: "user"},
"/pb.Sqr/CreateInspectionRequest": {RPS: 5, Window: time.Hour, Scope: "user"},
"/pb.Sqr/SubmitRentalApplication": {RPS: 3, Window: time.Hour, Scope: "user"},
"/pb.Sqr/InitiatePayment": {RPS: 10, Window: time.Minute, Scope: "user"},
```

---

## 📚 API ENDPOINT MAPPING BY USER ROLE

### 🔐 AUTHENTICATION (All Users) ✅ COMPLETE

| Endpoint | Method | Purpose | Status |
|----------|---------|---------|---------|
| `/v1/create_user` | POST | User registration | ✅ Complete |
| `/v1/login_user` | POST | User authentication | ✅ Complete |
| `/v1/verify_email` | GET | Email verification | ✅ Complete |
| `/v1/update_user` | PATCH | Basic profile updates | ✅ Complete |
| `/v1/refresh_token` | POST | Token refresh | ✅ Complete |
| `/v1/logout` | POST | User logout | ✅ Complete |
| `/v1/forgot_password` | POST | Password reset request | ✅ Complete |
| `/v1/reset_password` | POST | Password reset confirmation | ✅ Complete |

### 👤 TENANT ENDPOINTS

| Endpoint | Method | Purpose | Status |
|----------|---------|---------|---------|
| `/v1/tenant/profile` | POST | Create tenant profile | 🔄 Pending |
| `/v1/tenant/profile/{user_id}` | GET | Get tenant profile | ✅ Complete |
| `/v1/tenant/profile` | PATCH | Update tenant profile | ✅ Complete |
| `/v1/tenant/profile/completion` | GET | Profile completion status | 🔄 Pending |
| `/v1/tenant/documents` | POST | Upload documents | 🔄 Pending |
| `/v1/properties/search` | GET | Search properties | 🔄 Pending |
| `/v1/properties/featured` | GET | Featured properties | 🔄 Pending |
| `/v1/properties/{property_id}` | GET | Property details | 🔄 Pending |
| `/v1/tenant/saved_properties` | POST/GET/DELETE | Manage saved properties | 🔄 Pending |
| `/v1/inspections` | POST | Request inspection | 🔄 Pending |
| `/v1/applications` | POST | Submit rental application | 🔄 Pending |

### 🏢 LANDLORD ENDPOINTS

| Endpoint | Method | Purpose | Status |
|----------|---------|---------|---------|
| `/v1/landlord/profile` | POST | Create landlord profile | 🔄 Pending |
| `/v1/landlord/profile/{user_id}` | GET | Get landlord profile | 🔄 Pending |
| `/v1/landlord/profile` | PATCH | Update landlord profile | 🔄 Pending |
| `/v1/landlord/verify_business` | POST | Business verification | 🔄 Pending |
| `/v1/landlord/stats` | GET | Landlord statistics | 🔄 Pending |
| `/v1/properties` | POST | Create property listing | 🔄 Pending |
| `/v1/properties/{property_id}` | PATCH/DELETE | Manage property | 🔄 Pending |
| `/v1/landlord/{landlord_id}/properties` | GET | List properties | 🔄 Pending |
| `/v1/properties/{property_id}/media` | POST | Upload media | 🔄 Pending |
| `/v1/applications/{application_id}/review` | POST | Review application | 🔄 Pending |

### 🔍 INSPECTION AGENT ENDPOINTS

| Endpoint | Method | Purpose | Status |
|----------|---------|---------|---------|
| `/v1/agent/profile` | POST | Create agent profile | 🔄 Pending |
| `/v1/agent/profile/{user_id}` | GET | Get agent profile | 🔄 Pending |
| `/v1/agent/profile` | PATCH | Update agent profile | 🔄 Pending |
| `/v1/agent/availability` | POST | Set availability | 🔄 Pending |
| `/v1/agent/earnings` | GET | View earnings | 🔄 Pending |
| `/v1/agent/{agent_id}/inspections` | GET | Agent's inspections | 🔄 Pending |
| `/v1/agent/inspections/{inspection_id}/accept` | POST | Accept inspection | 🔄 Pending |
| `/v1/inspections/{inspection_id}/start` | POST | Start inspection | 🔄 Pending |
| `/v1/inspections/{inspection_id}/complete` | POST | Complete inspection | 🔄 Pending |

### 👨‍💼 ADMIN ENDPOINTS

| Endpoint | Method | Purpose | Status |
|----------|---------|---------|---------|
| `/v1/admin/users` | GET | List users | 🔄 Pending |
| `/v1/admin/users/{user_id}/suspend` | POST | Suspend user | 🔄 Pending |
| `/v1/admin/properties/{property_id}/verify` | POST | Verify property | 🔄 Pending |
| `/v1/admin/stats` | GET | Platform statistics | 🔄 Pending |
| `/v1/admin/disputes/{dispute_id}/handle` | POST | Handle dispute | 🔄 Pending |
| `/v1/admin/reports/{report_type}` | GET | Generate reports | 🔄 Pending |

### 💬 COMMUNICATION ENDPOINTS (All Users)

| Endpoint | Method | Purpose | Status |
|----------|---------|---------|---------|
| `/v1/messages` | POST | Send message | 🔄 Pending |
| `/v1/conversations/{conversation_id}` | GET | Get conversation | 🔄 Pending |
| `/v1/user/{user_id}/conversations` | GET | List conversations | 🔄 Pending |
| `/v1/notifications` | GET | Get notifications | 🔄 Pending |
| `/v1/notification_settings` | PATCH | Update settings | 🔄 Pending |

### 💳 PAYMENT ENDPOINTS (All Users)

| Endpoint | Method | Purpose | Status |
|----------|---------|---------|---------|
| `/v1/payments` | POST | Initiate payment | 🔄 Pending |
| `/v1/payments/{payment_id}/verify` | POST | Verify payment | 🔄 Pending |
| `/v1/user/{user_id}/payment_history` | GET | Payment history | 🔄 Pending |
| `/v1/wallet/balance` | GET | Wallet balance | 🔄 Pending |
| `/v1/wallet/withdraw` | POST | Withdraw funds | 🔄 Pending |

### ⭐ REVIEW ENDPOINTS (All Users)

| Endpoint | Method | Purpose | Status |
|----------|---------|---------|---------|
| `/v1/reviews` | POST | Create review | 🔄 Pending |
| `/v1/reviews/{review_id}` | GET/PATCH/DELETE | Manage review | 🔄 Pending |
| `/v1/user/{user_id}/reviews` | GET | User reviews | 🔄 Pending |
| `/v1/user/{user_id}/rating` | GET | User rating | 🔄 Pending |

### 🤖 AI ASSISTANT ENDPOINTS

| Endpoint | Method | Purpose | Status |
|----------|---------|---------|---------|
| `/v1/tenantbot/chat` | POST | Chat with AI | 🔄 Pending |
| `/v1/tenantbot/history` | GET | Chat history | 🔄 Pending |
| `/v1/tenantbot/preferences` | PATCH | Update preferences | 🔄 Pending |
| `/v1/tenantbot/suggestions` | GET | Get suggestions | 🔄 Pending |

---

## 🎯 CONCLUSION

This user-centric development plan transforms the SQR rental platform from a feature-driven approach to a user-journey-driven architecture. By organizing every capability around the specific actions each user role needs to perform, we ensure that:

- **Every endpoint serves a real user need** - No unnecessary complexity
- **User flows are intuitive** - Natural progression from discovery to completion  
- **Implementation priorities are clear** - Focus on high-impact user actions first
- **Testing is comprehensive** - Each user story can be validated independently
- **Maintenance is sustainable** - Clear separation of concerns by user role

### 🚀 Key Success Factors

1. **User-First Design**: Every feature directly addresses pain points in the Nigerian rental market
2. **Progressive Implementation**: Build core user journeys first, then enhance with advanced features
3. **Quality Assurance**: Maintain high standards for verification, security, and user experience
4. **Scalable Architecture**: Technical foundation supports growth across all user segments
5. **Community Building**: Foster trust and engagement through reviews, verification, and support

### 🎯 Next Development Cycle

**Week 1**: Complete tenant profile management and begin landlord onboarding
**Week 2**: Implement property management and basic search functionality  
**Week 3**: Build inspection request workflow and agent matching system

This approach ensures we build a platform that not only solves technical requirements but creates genuine value for every participant in the Nigerian rental ecosystem.

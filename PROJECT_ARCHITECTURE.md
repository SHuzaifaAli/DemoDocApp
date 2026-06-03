## Phase 1: Project Architecture - Hospital Booking Management System

### 1. System Design

#### Overview

The Hospital Booking Management System is designed as a scalable, secure, and fault-tolerant platform to manage hospital appointments, patient records, doctor schedules, and administrative tasks. It will cater to multiple user roles: Patient, Doctor, Hospital Admin, and Super Admin. The system will support Android, iOS, and a Web Admin Panel, leveraging a Flutter frontend with GetX for state management, and a Supabase backend with PostgreSQL as the primary database.

#### Architectural Style: Feature-First Clean Architecture

The system will adhere to a **Feature-First Clean Architecture** approach. This means the codebase will be organized primarily by feature, with each feature maintaining its own `data`, `domain`, and `presentation` layers. This promotes modularity, maintainability, and scalability, allowing independent development and deployment of features.

#### Key Components:

*   **Client Applications (Frontend):** Developed using Flutter, providing native experiences on Android and iOS, and a responsive web interface for the Admin Panel. GetX will be used for state management, dependency injection, and routing.
*   **Backend Services (Supabase):** A comprehensive backend-as-a-service platform providing:
    *   **Authentication:** Supabase Auth for user management, including JWT validation, MFA, and social logins.
    *   **Database:** PostgreSQL for structured data storage, with robust RLS policies, indexing, and audit logging.
    *   **Realtime:** Supabase Realtime for instant updates and notifications.
    *   **Storage:** Supabase Storage for handling media files (e.g., patient reports, doctor certificates).
    *   **Edge Functions (RPC):** Serverless functions for complex business logic, integrations, and secure operations.
*   **Third-Party Integrations:**
    *   **Firebase Cloud Messaging (FCM):** For push notifications across all platforms.
    *   **Agora:** For real-time video and audio consultations.
    *   **Stripe, JazzCash, EasyPaisa:** For payment processing.
    *   **Google Maps:** For location-based services (e.g., finding nearby hospitals).
    *   **Twilio:** For SMS notifications.
    *   **SendGrid:** For email notifications.
    *   **Firebase Analytics & Crashlytics:** For monitoring application performance and user behavior.
    *   **Sentry:** For advanced error monitoring and reporting.
*   **CI/CD (GitHub Actions):** Automated workflows for testing, building, and deploying the application to various environments (Development, Staging, Production).

#### Data Flow

1.  **User Interaction:** Users interact with the Flutter frontend (Mobile/Web Admin).
2.  **Presentation Layer:** UI events trigger actions in the Presentation layer (Controllers/Bindings).
3.  **Domain Layer:** Use Cases in the Domain layer orchestrate business logic, interacting with Repositories.
4.  **Data Layer:** Repositories abstract data sources, communicating with Supabase services (Auth, Database, Storage, Edge Functions).
5.  **Supabase Backend:** Handles authentication, data persistence (PostgreSQL), real-time updates, and server-side logic via Edge Functions.
6.  **Third-Party Services:** Supabase Edge Functions or client-side logic interact with external services like FCM, Agora, Payment Gateways, etc.
7.  **Notifications:** FCM, Twilio, and SendGrid deliver notifications to users.

### 2. Architecture Diagram

```mermaid
graph TD
    subgraph Clients
        A[Mobile App (Flutter)]
        B[Web Admin Panel (Flutter)]
    end

    subgraph Backend (Supabase)
        C[Supabase Auth] --> D[PostgreSQL Database]
        E[Supabase Realtime] --> D
        F[Supabase Storage] --> D
        G[Supabase Edge Functions (RPC)] --> D
    end

    subgraph Third-Party Services
        H[Firebase FCM] <--> A
        H <--> B
        I[Agora (Video/Audio)] <--> A
        I <--> B
        J[Payment Gateways (Stripe, JazzCash, EasyPaisa)] <--> G
        K[Google Maps] <--> A
        K <--> B
        L[Twilio (SMS)] <--> G
        M[SendGrid (Email)] <--> G
        N[Firebase Analytics] <--> A
        N <--> B
        O[Firebase Crashlytics] <--> A
        O <--> B
        P[Sentry (Monitoring)] <--> A
        P <--> B
    end

    A -- UI Events --> Q[Presentation Layer (GetX)]
    B -- UI Events --> Q
    Q -- Use Cases --> R[Domain Layer]
    R -- Repositories --> S[Data Layer]
    S -- API Calls --> C
    S -- Database Queries --> G
    G -- Integrations --> J
    G -- Integrations --> L
    G -- Integrations --> M
    C -- Auth Tokens --> Q
    D -- Realtime Updates --> E
    E -- Notifications --> A
    E -- Notifications --> B

    subgraph DevOps
        T[GitHub Actions] --> U[Build & Deploy]
        U --> A
        U --> B
        U --> C
    end

    style A fill:#f9f,stroke:#333,stroke-width:2px
    style B fill:#f9f,stroke:#333,stroke-width:2px
    style C fill:#bbf,stroke:#333,stroke-width:2px
    style D fill:#bbf,stroke:#333,stroke-width:2px
    style E fill:#bbf,stroke:#333,stroke-width:2px
    style F fill:#bbf,stroke:#333,stroke-width:2px
    style G fill:#bbf,stroke:#333,stroke-width:2px
    style H fill:#ccf,stroke:#333,stroke-width:2px
    style I fill:#ccf,stroke:#333,stroke-width:2px
    style J fill:#ccf,stroke:#333,stroke-width:2px
    style K fill:#ccf,stroke:#333,stroke-width:2px
    style L fill:#ccf,stroke:#333,stroke-width:2px
    style M fill:#ccf,stroke:#333,stroke-width:2px
    style N fill:#ccf,stroke:#333,stroke-width:2px
    style O fill:#ccf,stroke:#333,stroke-width:2px
    style P fill:#ccf,stroke:#333,stroke-width:2px
    style Q fill:#afa,stroke:#333,stroke-width:2px
    style R fill:#afa,stroke:#333,stroke-width:2px
    style S fill:#afa,stroke:#333,stroke-width:2px
    style T fill:#ffc,stroke:#333,stroke-width:2px
    style U fill:#ffc,stroke:#333,stroke-width:2px
```

### 3. ERD (Entity-Relationship Diagram)

*(To be generated in Phase 2: Database Design)*

### 4. Module Breakdown

The system will be broken down into the following core modules, each following the Feature-First Clean Architecture principles:

*   **Authentication:** Handles user registration, login, OTP verification, social login, MFA, and role-based access control.
*   **User Management:** Manages different user roles (Patient, Doctor, Hospital Admin, Super Admin) and their profiles.
*   **Hospital Management:** For Super Admins to manage multiple hospitals, departments, and their configurations.
*   **Doctor Management:** For Hospital Admins to manage doctor profiles, specialties, availability, and schedules.
*   **Patient Management:** For doctors and admins to view patient medical history, prescriptions, and lab reports.
*   **Appointments:** Core module for booking, managing, rescheduling, and canceling appointments for patients, doctors, and admins.
*   **Video Consultation:** Integrates Agora for secure video/audio calls, chat, and file sharing during consultations.
*   **Payments:** Handles payment processing via Stripe, JazzCash, and EasyPaisa for appointments and subscriptions.
*   **Notifications:** Manages push, SMS, email, and in-app notifications for various events (appointment reminders, status updates).
*   **Reports & Analytics:** Provides dashboards and reports for revenue, appointments, doctor performance, and patient statistics.
*   **Compliance:** Ensures adherence to healthcare regulations like HIPAA and GDPR through audit logs, data encryption, and access controls.

### 5. User Flow

#### 5.1. Patient User Flow (Example: Booking an Appointment)

1.  **Launch App:** Patient opens the mobile application.
2.  **Authentication:** Patient logs in or registers. (If new, completes profile setup).
3.  **Dashboard:** Patient views their personalized dashboard (upcoming appointments, recent doctors).
4.  **Search Doctors:** Patient navigates to 'Search Doctors' feature.
5.  **Filter/Browse:** Patient filters doctors by specialty, hospital, availability, or rating.
6.  **View Doctor Profile:** Patient selects a doctor to view their detailed profile (bio, experience, reviews, available slots).
7.  **Select Slot:** Patient chooses a preferred date and time slot.
8.  **Confirm Appointment:** Patient reviews appointment details and confirms.
9.  **Payment:** Patient proceeds to payment gateway (Stripe, JazzCash, EasyPaisa).
10. **Payment Confirmation:** Upon successful payment, appointment is confirmed.
11. **Notification:** Patient receives push, SMS, and email notifications with appointment details.
12. **Appointment History:** Confirmed appointment appears in patient's 'Appointment History'.

#### 5.2. Doctor User Flow (Example: Conducting a Video Consultation)

1.  **Launch App:** Doctor logs into the mobile/web application.
2.  **Dashboard:** Doctor views their dashboard (today's appointments, patient queue).
3.  **Upcoming Appointment:** Doctor sees an upcoming video consultation.
4.  **Join Call:** At the scheduled time, doctor clicks 'Join Call'.
5.  **Agora Integration:** Agora SDK initializes, establishing a video/audio connection with the patient.
6.  **Consultation:** Doctor conducts the consultation, using in-call chat and file sharing if needed.
7.  **Consultation Notes:** During or after the call, doctor adds consultation notes to the patient's record.
8.  **Prescription:** Doctor generates and issues an e-prescription.
9.  **Update Patient History:** Consultation details, notes, and prescriptions are saved to the patient's medical history.
10. **Notification:** Patient receives notification about new prescription/notes.

#### 5.3. Hospital Admin User Flow (Example: Managing Doctors)

1.  **Login:** Hospital Admin logs into the Web Admin Panel.
2.  **Dashboard:** Admin views hospital-specific analytics and operational overview.
3.  **Doctor Management:** Admin navigates to 'Doctor Management' section.
4.  **View Doctors:** Admin sees a list of all doctors associated with their hospital.
5.  **Add New Doctor:** Admin clicks 'Add Doctor', fills in doctor details (personal info, specialty, credentials, availability).
6.  **Edit Doctor Profile:** Admin can edit existing doctor profiles, update availability, or assign to departments.
7.  **Deactivate Doctor:** Admin can deactivate a doctor's account if necessary.
8.  **Audit Log:** All actions performed by the admin are recorded in audit logs for compliance.

### 6. Dependency Map

*(To be detailed with specific libraries and their interdependencies in subsequent phases, especially during Flutter Foundation setup)*

### 7. State Management Strategy

**GetX** will be the sole state management solution, leveraging its core features:

*   **GetxController:** For managing business logic and state for individual screens or features.
*   **GetBuilder/Obx:** For reactive UI updates.
*   **Get.put/Get.find:** For dependency injection, ensuring controllers and services are easily accessible and managed.
*   **Get.to/Get.off:** For robust routing and navigation.
*   **GetStorage:** For local persistent storage of user preferences and cached data.
*   **Workers:** For handling background tasks and debouncing.

### 8. Security Plan

*   **Authentication & Authorization:**
    *   **JWT Validation:** Supabase Auth handles JWT token generation and validation for secure API access.
    *   **Role-Based Access Control (RBAC):** Implemented via Supabase RLS policies and application-level checks based on user roles (Patient, Doctor, Hospital Admin, Super Admin).
    *   **Multi-Factor Authentication (MFA):** Supported for enhanced security.
    *   **Biometric Login:** For convenient and secure access on mobile devices.
*   **Data Security:**
    *   **Row-Level Security (RLS):** Crucial for PostgreSQL, ensuring users only access data they are authorized to see.
    *   **Encryption At Rest:** PostgreSQL data will be encrypted at rest by Supabase.
    *   **Encryption In Transit:** All communication will use HTTPS/WSS (TLS encryption).
    *   **Secure Storage:** Sensitive data on client devices will be stored using secure storage mechanisms (e.g., `flutter_secure_storage`).
*   **Audit & Monitoring:**
    *   **Audit Logs:** Comprehensive logging of all critical user actions and system events for compliance and security monitoring.
    *   **Access Logs:** Detailed records of who accessed what data and when.
    *   **Rate Limiting:** Implemented at the API gateway level to prevent abuse and brute-force attacks.
    *   **Sentry:** For real-time error and performance monitoring to detect and respond to security incidents.
*   **Healthcare Compliance:**
    *   **HIPAA (Health Insurance Portability and Accountability Act):** Adherence to privacy and security rules for protected health information (PHI).
    *   **GDPR (General Data Protection Regulation):** Compliance with data protection and privacy laws for EU citizens.

### 9. Deployment Plan

*   **Environments:** Separate environments for Development, Staging, and Production.
*   **Supabase Deployment:** Supabase projects will be configured for each environment, with schema migrations managed via `supabase cli`.
*   **Flutter Deployment:**
    *   **Mobile (Android/iOS):** Automated builds and releases via GitHub Actions to respective app stores (Google Play Store, Apple App Store).
    *   **Web Admin Panel:** Deployed as a static web application, potentially hosted on Supabase Storage or a dedicated CDN, with automated deployments via GitHub Actions.
*   **CI/CD:** GitHub Actions will automate:
    *   Code linting and formatting checks.
    *   Unit, Widget, and Integration tests.
    *   Building and packaging applications.
    *   Deployment to various environments.
*   **Monitoring:** Sentry for application performance monitoring (APM) and error tracking; Firebase Analytics for user behavior insights.

### 10. Folder Structure

*(To be detailed and implemented in Phase 4: Flutter Foundation)*

### 11. Coding Standards

*   **SOLID Principles:** Adherence to Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, and Dependency Inversion principles.
*   **DRY (Don't Repeat Yourself):** Avoid code duplication.
*   **Clean Code:** Emphasis on readability, maintainability, and clear naming conventions.
*   **Feature-First:** Code organized by feature, with clear separation of `data`, `domain`, and `presentation` layers.
*   **No Placeholders/TODOs:** All generated code will be production-ready.

### 12. Performance Rules

*   **Scalability:** Designed to support 100,000+ users and millions of appointments.
*   **Optimization:**
    *   **Pagination & Infinite Scroll:** For loading large lists of data efficiently.
    *   **Lazy Loading:** For UI components and data to reduce initial load times.
    *   **Caching:** Client-side and server-side caching to minimize redundant data fetches.
    *   **Optimized Queries:** Efficient PostgreSQL queries with proper indexing.
    *   **Background Processing:** For non-critical tasks to avoid blocking the UI.
*   **Avoidance:**
    *   **N+1 Queries:** Prevented through proper data fetching strategies.
    *   **Full Table Reads:** Minimized by using indexed queries and RLS.
    *   **Blocking UI:** Asynchronous operations and proper state management to ensure a smooth user experience.

### 13. Error Handling

*   **Result<T> Pattern:** All asynchronous operations will return a `Result` type (e.g., `Either<Failure, Success>`) to explicitly handle success and failure states.
*   **States:** Each operation will manage Success, Loading, Failure, Retry, and Offline states.
*   **No Silent Failures:** Errors will be explicitly caught, logged, and presented to the user where appropriate.

### 14. Offline First

*   **Caching:** Local caching of essential data to allow the app to function offline.
*   **Queued Actions:** User actions performed offline will be queued and synchronized with the backend once connectivity is restored.
*   **Sync Engine:** A robust mechanism to handle data synchronization and conflict resolution.

### 15. UI Rules

*   **Material 3:** Adherence to the latest Material Design guidelines for a modern and consistent UI.
*   **Responsiveness:** UI designed to adapt seamlessly across mobile, tablet, and desktop form factors.
*   **Accessibility:** Implementation of screen reader support, large font options, dark mode, and high contrast themes.

### 16. Testing Requirements

*   **Comprehensive Testing:** Unit, Widget, Integration, Repository, and API tests.
*   **Coverage Goal:** Aim for 90%+ code coverage.

### 17. DevOps

*   **Docker:** Containerization for backend services (if custom services are added beyond Supabase Edge Functions) and local development environments.
*   **GitHub Actions:** For CI/CD automation.
*   **Supabase Migrations:** Managed database schema changes.
*   **Environment Separation:** Strict separation of Development, Staging, and Production environments.

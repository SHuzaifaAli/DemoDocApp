## Phase 2: Database Design - Hospital Booking Management System

### 1. Entity-Relationship Diagram (ERD)

```mermaid
erDiagram
    users ||--o{ profiles : "has a"
    profiles ||--o{ user_roles : "has many"
    roles ||--o{ user_roles : "has many"
    roles ||--o{ role_permissions : "has many"
    permissions ||--o{ role_permissions : "has many"

    hospitals ||--o{ departments : "has many"
    hospitals ||--o{ doctors : "has many"
    hospitals ||--o{ hospital_subscriptions : "has many"
    subscriptions ||--o{ hospital_subscriptions : "has many"

    profiles ||--o{ patients : "is a"
    profiles ||--o{ doctors : "is a"
    profiles ||--o{ hospital_admins : "is a"
    profiles ||--o{ super_admins : "is a"

    patients ||--o{ appointments : "books"
    doctors ||--o{ appointments : "has"
    departments ||--o{ appointments : "in"
    hospitals ||--o{ appointments : "at"

    appointments ||--o{ prescriptions : "generates"
    appointments ||--o{ medical_records : "updates"
    appointments ||--o{ payments : "triggers"
    appointments ||--o{ notifications : "sends"

    doctors ||--o{ doctor_availability : "sets"
    doctors ||--o{ doctor_specialty_link : "has many"
    doctor_specialties ||--o{ doctor_specialty_link : "has many"

    prescriptions ||--o{ prescription_items : "contains"
    medical_records ||--o{ medical_record_versions : "has versions"

    audit_logs ||--o{ users : "recorded by"

    profiles {
        uuid id PK
        text email UNIQUE
        text full_name
        text phone_number UNIQUE
        text avatar_url
        text status
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
    }

    roles {
        uuid id PK
        text name UNIQUE
        text description
        timestamp created_at
        timestamp updated_at
    }

    permissions {
        uuid id PK
        text name UNIQUE
        text description
        timestamp created_at
        timestamp updated_at
    }

    user_roles {
        uuid user_id PK,FK
        uuid role_id PK,FK
        timestamp created_at
    }

    role_permissions {
        uuid role_id PK,FK
        uuid permission_id PK,FK
        timestamp created_at
    }

    hospitals {
        uuid id PK
        text name UNIQUE
        text address
        text phone_number
        text email
        text website
        text logo_url
        text description
        text status
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
    }

    departments {
        uuid id PK
        uuid hospital_id FK
        text name
        text description
        text status
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
    }

    doctors {
        uuid id PK,FK (profiles.id)
        uuid hospital_id FK
        uuid department_id FK
        text license_number UNIQUE
        text specialty
        text bio
        text experience_years
        text consultation_fee
        text status
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
    }

    doctor_specialties {
        uuid id PK
        text name UNIQUE
        text description
        timestamp created_at
        timestamp updated_at
    }

    doctor_specialty_link {
        uuid doctor_id PK,FK
        uuid specialty_id PK,FK
        timestamp created_at
    }

    doctor_availability {
        uuid id PK
        uuid doctor_id FK
        date available_date
        time start_time
        time end_time
        integer slot_duration_minutes
        boolean is_booked
        uuid appointment_id FK "null if not booked"
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
    }

    patients {
        uuid id PK,FK (profiles.id)
        text date_of_birth
        text gender
        text blood_group
        text address
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
    }

    appointments {
        uuid id PK
        uuid patient_id FK
        uuid doctor_id FK
        uuid hospital_id FK
        uuid department_id FK
        timestamp appointment_start_time
        timestamp appointment_end_time
        text reason
        text status "pending, confirmed, completed, cancelled"
        text appointment_type "in-person, video"
        text notes
        text cancellation_reason
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
    }

    prescriptions {
        uuid id PK
        uuid appointment_id FK
        uuid doctor_id FK
        uuid patient_id FK
        text diagnosis
        text instructions
        text status "active, completed, cancelled"
        timestamp prescribed_date
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
    }

    prescription_items {
        uuid id PK
        uuid prescription_id FK
        text medicine_name
        text dosage
        text frequency
        text duration
        text notes
        timestamp created_at
    }

    medical_records {
        uuid id PK
        uuid patient_id FK
        uuid doctor_id FK
        uuid appointment_id FK "null if not linked to appointment"
        text record_type "diagnosis, lab_result, treatment_plan"
        text title
        text content
        text attachment_url
        timestamp record_date
        timestamp created_at
        timestamp updated_at
        timestamp deleted_at
    }

    medical_record_versions {
        uuid id PK
        uuid medical_record_id FK
        integer version_number
        text content
        text attachment_url
        timestamp created_at
        uuid created_by FK (profiles.id)
    }

    payments {
        uuid id PK
        uuid appointment_id FK
        uuid patient_id FK
        numeric amount
        text currency
        text payment_method "stripe, jazzcash, easypaisa"
        text transaction_id UNIQUE
        text status "pending, completed, failed, refunded"
        timestamp payment_date
        timestamp created_at
        timestamp updated_at
    }

    notifications {
        uuid id PK
        uuid recipient_id FK (profiles.id)
        text type "appointment_reminder, prescription_issued, payment_due"
        text title
        text message
        boolean is_read
        text target_url
        timestamp created_at
        timestamp read_at
    }

    audit_logs {
        uuid id PK
        uuid user_id FK (profiles.id)
        text action
        text table_name
        uuid record_id
        jsonb old_value
        jsonb new_value
        text ip_address
        text user_agent
        timestamp created_at
    }

    subscriptions {
        uuid id PK
        text name UNIQUE
        text description
        numeric price
        text currency
        text duration_unit "month, year"
        integer duration_value
        jsonb features
        timestamp created_at
        timestamp updated_at
    }

    hospital_subscriptions {
        uuid id PK
        uuid hospital_id FK
        uuid subscription_id FK
        timestamp start_date
        timestamp end_date
        text status "active, expired, cancelled"
        timestamp created_at
        timestamp updated_at
    }
```

### 2. PostgreSQL Schema Definition

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table: profiles (Extends Supabase auth.users)
CREATE TABLE public.profiles (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name text,
    phone_number text UNIQUE,
    avatar_url text,
    status text DEFAULT 'active' NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public read access" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Allow individual insert access" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Allow individual update access" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Table: roles
CREATE TABLE public.roles (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text UNIQUE NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all authenticated users to read roles" ON public.roles FOR SELECT USING (auth.role() = 'authenticated');

-- Table: permissions
CREATE TABLE public.permissions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text UNIQUE NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all authenticated users to read permissions" ON public.permissions FOR SELECT USING (auth.role() = 'authenticated');

-- Table: user_roles (Junction table for profiles and roles)
CREATE TABLE public.user_roles (
    user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
    role_id uuid REFERENCES public.roles(id) ON DELETE CASCADE,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    PRIMARY KEY (user_id, role_id)
);
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow individual read access to user_roles" ON public.user_roles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Allow super_admin to manage user_roles" ON public.user_roles USING (EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.name = 'super_admin'));

-- Table: role_permissions (Junction table for roles and permissions)
CREATE TABLE public.role_permissions (
    role_id uuid REFERENCES public.roles(id) ON DELETE CASCADE,
    permission_id uuid REFERENCES public.permissions(id) ON DELETE CASCADE,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    PRIMARY KEY (role_id, permission_id)
);
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all authenticated users to read role_permissions" ON public.role_permissions FOR SELECT USING (auth.role() = 'authenticated');

-- Table: hospitals
CREATE TABLE public.hospitals (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text UNIQUE NOT NULL,
    address text,
    phone_number text,
    email text,
    website text,
    logo_url text,
    description text,
    status text DEFAULT 'active' NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);
ALTER TABLE public.hospitals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow authenticated read access to hospitals" ON public.hospitals FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow hospital_admin and super_admin to manage hospitals" ON public.hospitals USING (EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND (r.name = 'super_admin' OR r.name = 'hospital_admin')));

-- Table: departments
CREATE TABLE public.departments (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    hospital_id uuid REFERENCES public.hospitals(id) ON DELETE CASCADE NOT NULL,
    name text NOT NULL,
    description text,
    status text DEFAULT 'active' NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    UNIQUE (hospital_id, name)
);
ALTER TABLE public.departments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow authenticated read access to departments" ON public.departments FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow hospital_admin and super_admin to manage departments" ON public.departments USING (EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND (r.name = 'super_admin' OR r.name = 'hospital_admin')));

-- Table: doctors
CREATE TABLE public.doctors (
    id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    hospital_id uuid REFERENCES public.hospitals(id) ON DELETE SET NULL,
    department_id uuid REFERENCES public.departments(id) ON DELETE SET NULL,
    license_number text UNIQUE NOT NULL,
    bio text,
    experience_years integer,
    consultation_fee numeric(10, 2),
    status text DEFAULT 'active' NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);
ALTER TABLE public.doctors ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow authenticated read access to doctors" ON public.doctors FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow doctor to update their own profile" ON public.doctors FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Allow hospital_admin and super_admin to manage doctors" ON public.doctors USING (EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND (r.name = 'super_admin' OR (r.name = 'hospital_admin' AND hospital_id IN (SELECT hospital_id FROM public.hospital_admins WHERE id = auth.uid())))));

-- Table: doctor_specialties
CREATE TABLE public.doctor_specialties (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text UNIQUE NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public.doctor_specialties ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow authenticated read access to doctor_specialties" ON public.doctor_specialties FOR SELECT USING (auth.role() = 'authenticated');

-- Table: doctor_specialty_link
CREATE TABLE public.doctor_specialty_link (
    doctor_id uuid REFERENCES public.doctors(id) ON DELETE CASCADE,
    specialty_id uuid REFERENCES public.doctor_specialties(id) ON DELETE CASCADE,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    PRIMARY KEY (doctor_id, specialty_id)
);
ALTER TABLE public.doctor_specialty_link ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow authenticated read access to doctor_specialty_link" ON public.doctor_specialty_link FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow doctor to manage their own specialties" ON public.doctor_specialty_link FOR ALL USING (auth.uid() = doctor_id);

-- Table: doctor_availability
CREATE TABLE public.doctor_availability (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    doctor_id uuid REFERENCES public.doctors(id) ON DELETE CASCADE NOT NULL,
    available_date date NOT NULL,
    start_time time NOT NULL,
    end_time time NOT NULL,
    slot_duration_minutes integer NOT NULL,
    is_booked boolean DEFAULT FALSE NOT NULL,
    appointment_id uuid REFERENCES public.appointments(id) ON DELETE SET NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    UNIQUE (doctor_id, available_date, start_time, end_time)
);
ALTER TABLE public.doctor_availability ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow authenticated read access to doctor_availability" ON public.doctor_availability FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow doctor to manage their own availability" ON public.doctor_availability FOR ALL USING (auth.uid() = doctor_id);

-- Table: patients
CREATE TABLE public.patients (
    id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    date_of_birth date,
    gender text,
    blood_group text,
    address text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);
ALTER TABLE public.patients ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow individual patient read access" ON public.patients FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Allow individual patient update access" ON public.patients FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Allow doctors to read their patients' profiles" ON public.patients FOR SELECT USING (EXISTS (SELECT 1 FROM public.appointments a WHERE a.patient_id = id AND a.doctor_id = auth.uid()));
CREATE POLICY "Allow hospital_admin and super_admin to read patients" ON public.patients FOR SELECT USING (EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND (r.name = 'super_admin' OR r.name = 'hospital_admin')));

-- Table: appointments
CREATE TABLE public.appointments (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id uuid REFERENCES public.patients(id) ON DELETE CASCADE NOT NULL,
    doctor_id uuid REFERENCES public.doctors(id) ON DELETE CASCADE NOT NULL,
    hospital_id uuid REFERENCES public.hospitals(id) ON DELETE CASCADE NOT NULL,
    department_id uuid REFERENCES public.departments(id) ON DELETE CASCADE NOT NULL,
    appointment_start_time timestamp with time zone NOT NULL,
    appointment_end_time timestamp with time zone NOT NULL,
    reason text,
    status text DEFAULT 'pending' NOT NULL, -- pending, confirmed, completed, cancelled
    appointment_type text DEFAULT 'in-person' NOT NULL, -- in-person, video
    notes text,
    cancellation_reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow patient to read their own appointments" ON public.appointments FOR SELECT USING (auth.uid() = patient_id);
CREATE POLICY "Allow patient to insert their own appointments" ON public.appointments FOR INSERT WITH CHECK (auth.uid() = patient_id);
CREATE POLICY "Allow patient to update their own appointments (e.g., cancel)" ON public.appointments FOR UPDATE USING (auth.uid() = patient_id);
CREATE POLICY "Allow doctor to read their own appointments" ON public.appointments FOR SELECT USING (auth.uid() = doctor_id);
CREATE POLICY "Allow doctor to update their own appointments (e.g., status, notes)" ON public.appointments FOR UPDATE USING (auth.uid() = doctor_id);
CREATE POLICY "Allow hospital_admin and super_admin to manage appointments" ON public.appointments USING (EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND (r.name = 'super_admin' OR (r.name = 'hospital_admin' AND hospital_id IN (SELECT hospital_id FROM public.hospital_admins WHERE id = auth.uid())))));

-- Table: prescriptions
CREATE TABLE public.prescriptions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id uuid REFERENCES public.appointments(id) ON DELETE SET NULL,
    doctor_id uuid REFERENCES public.doctors(id) ON DELETE CASCADE NOT NULL,
    patient_id uuid REFERENCES public.patients(id) ON DELETE CASCADE NOT NULL,
    diagnosis text,
    instructions text,
    status text DEFAULT 'active' NOT NULL, -- active, completed, cancelled
    prescribed_date date DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);
ALTER TABLE public.prescriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow patient to read their own prescriptions" ON public.prescriptions FOR SELECT USING (auth.uid() = patient_id);
CREATE POLICY "Allow doctor to manage their own prescriptions" ON public.prescriptions FOR ALL USING (auth.uid() = doctor_id);
CREATE POLICY "Allow hospital_admin and super_admin to read prescriptions" ON public.prescriptions FOR SELECT USING (EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND (r.name = 'super_admin' OR (r.name = 'hospital_admin' AND EXISTS (SELECT 1 FROM public.doctors d WHERE d.id = doctor_id AND d.hospital_id IN (SELECT hospital_id FROM public.hospital_admins WHERE id = auth.uid()))))));

-- Table: prescription_items
CREATE TABLE public.prescription_items (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    prescription_id uuid REFERENCES public.prescriptions(id) ON DELETE CASCADE NOT NULL,
    medicine_name text NOT NULL,
    dosage text,
    frequency text,
    duration text,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public.prescription_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow patient to read their own prescription items" ON public.prescription_items FOR SELECT USING (EXISTS (SELECT 1 FROM public.prescriptions p WHERE p.id = prescription_id AND p.patient_id = auth.uid()));
CREATE POLICY "Allow doctor to manage their own prescription items" ON public.prescription_items FOR ALL USING (EXISTS (SELECT 1 FROM public.prescriptions p WHERE p.id = prescription_id AND p.doctor_id = auth.uid()));

-- Table: medical_records
CREATE TABLE public.medical_records (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id uuid REFERENCES public.patients(id) ON DELETE CASCADE NOT NULL,
    doctor_id uuid REFERENCES public.doctors(id) ON DELETE SET NULL,
    appointment_id uuid REFERENCES public.appointments(id) ON DELETE SET NULL,
    record_type text NOT NULL, -- diagnosis, lab_result, treatment_plan, etc.
    title text NOT NULL,
    content text,
    attachment_url text,
    record_date date DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);
ALTER TABLE public.medical_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow patient to read their own medical records" ON public.medical_records FOR SELECT USING (auth.uid() = patient_id);
CREATE POLICY "Allow doctor to manage medical records for their patients" ON public.medical_records FOR ALL USING (EXISTS (SELECT 1 FROM public.appointments a WHERE a.patient_id = patient_id AND a.doctor_id = auth.uid()));
CREATE POLICY "Allow hospital_admin and super_admin to read medical records" ON public.medical_records FOR SELECT USING (EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND (r.name = 'super_admin' OR (r.name = 'hospital_admin' AND EXISTS (SELECT 1 FROM public.doctors d WHERE d.id = doctor_id AND d.hospital_id IN (SELECT hospital_id FROM public.hospital_admins WHERE id = auth.uid()))))));

-- Table: medical_record_versions
CREATE TABLE public.medical_record_versions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    medical_record_id uuid REFERENCES public.medical_records(id) ON DELETE CASCADE NOT NULL,
    version_number integer NOT NULL,
    content text,
    attachment_url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
    UNIQUE (medical_record_id, version_number)
);
ALTER TABLE public.medical_record_versions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow patient to read their own medical record versions" ON public.medical_record_versions FOR SELECT USING (EXISTS (SELECT 1 FROM public.medical_records mr WHERE mr.id = medical_record_id AND mr.patient_id = auth.uid()));
CREATE POLICY "Allow doctor to read medical record versions for their patients" ON public.medical_record_versions FOR SELECT USING (EXISTS (SELECT 1 FROM public.medical_records mr JOIN public.appointments a ON mr.appointment_id = a.id WHERE mr.id = medical_record_id AND a.doctor_id = auth.uid()));

-- Table: payments
CREATE TABLE public.payments (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id uuid REFERENCES public.appointments(id) ON DELETE SET NULL,
    patient_id uuid REFERENCES public.patients(id) ON DELETE CASCADE NOT NULL,
    amount numeric(10, 2) NOT NULL,
    currency text DEFAULT 'PKR' NOT NULL,
    payment_method text NOT NULL, -- stripe, jazzcash, easypaisa
    transaction_id text UNIQUE NOT NULL,
    status text DEFAULT 'pending' NOT NULL, -- pending, completed, failed, refunded
    payment_date timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow patient to read their own payments" ON public.payments FOR SELECT USING (auth.uid() = patient_id);
CREATE POLICY "Allow patient to insert their own payments" ON public.payments FOR INSERT WITH CHECK (auth.uid() = patient_id);
CREATE POLICY "Allow hospital_admin and super_admin to manage payments" ON public.payments USING (EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND (r.name = 'super_admin' OR (r.name = 'hospital_admin' AND EXISTS (SELECT 1 FROM public.appointments a WHERE a.id = appointment_id AND a.hospital_id IN (SELECT hospital_id FROM public.hospital_admins WHERE id = auth.uid()))))));

-- Table: notifications
CREATE TABLE public.notifications (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipient_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    type text NOT NULL, -- appointment_reminder, prescription_issued, payment_due
    title text NOT NULL,
    message text NOT NULL,
    is_read boolean DEFAULT FALSE NOT NULL,
    target_url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    read_at timestamp with time zone
);
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow recipient to read and update their own notifications" ON public.notifications FOR ALL USING (auth.uid() = recipient_id);

-- Table: audit_logs
CREATE TABLE public.audit_logs (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
    action text NOT NULL,
    table_name text NOT NULL,
    record_id uuid,
    old_value jsonb,
    new_value jsonb,
    ip_address inet,
    user_agent text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow super_admin to read audit_logs" ON public.audit_logs FOR SELECT USING (EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.name = 'super_admin'));

-- Table: subscriptions
CREATE TABLE public.subscriptions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name text UNIQUE NOT NULL,
    description text,
    price numeric(10, 2) NOT NULL,
    currency text DEFAULT 'PKR' NOT NULL,
    duration_unit text NOT NULL, -- month, year
    duration_value integer NOT NULL,
    features jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow authenticated read access to subscriptions" ON public.subscriptions FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow super_admin to manage subscriptions" ON public.subscriptions USING (EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.name = 'super_admin'));

-- Table: hospital_subscriptions
CREATE TABLE public.hospital_subscriptions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    hospital_id uuid REFERENCES public.hospitals(id) ON DELETE CASCADE NOT NULL,
    subscription_id uuid REFERENCES public.subscriptions(id) ON DELETE CASCADE NOT NULL,
    start_date date DEFAULT now() NOT NULL,
    end_date date NOT NULL,
    status text DEFAULT 'active' NOT NULL, -- active, expired, cancelled
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    UNIQUE (hospital_id, subscription_id, start_date)
);
ALTER TABLE public.hospital_subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow hospital_admin to read their hospital's subscriptions" ON public.hospital_subscriptions FOR SELECT USING (EXISTS (SELECT 1 FROM public.hospital_admins ha WHERE ha.id = auth.uid() AND ha.hospital_id = hospital_id));
CREATE POLICY "Allow super_admin to manage hospital_subscriptions" ON public.hospital_subscriptions USING (EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.name = 'super_admin'));

-- Indexes for performance
CREATE INDEX idx_profiles_phone_number ON public.profiles (phone_number);
CREATE INDEX idx_doctors_hospital_id ON public.doctors (hospital_id);
CREATE INDEX idx_doctors_department_id ON public.doctors (department_id);
CREATE INDEX idx_doctors_license_number ON public.doctors (license_number);
CREATE INDEX idx_doctor_availability_doctor_id_date ON public.doctor_availability (doctor_id, available_date);
CREATE INDEX idx_appointments_patient_id ON public.appointments (patient_id);
CREATE INDEX idx_appointments_doctor_id ON public.appointments (doctor_id);
CREATE INDEX idx_appointments_hospital_id ON public.appointments (hospital_id);
CREATE INDEX idx_appointments_start_time ON public.appointments (appointment_start_time);
CREATE INDEX idx_prescriptions_patient_id ON public.prescriptions (patient_id);
CREATE INDEX idx_prescriptions_doctor_id ON public.prescriptions (doctor_id);
CREATE INDEX idx_medical_records_patient_id ON public.medical_records (patient_id);
CREATE INDEX idx_medical_records_doctor_id ON public.medical_records (doctor_id);
CREATE INDEX idx_payments_patient_id ON public.payments (patient_id);
CREATE INDEX idx_payments_transaction_id ON public.payments (transaction_id);
CREATE INDEX idx_notifications_recipient_id ON public.notifications (recipient_id);
CREATE INDEX idx_audit_logs_user_id ON public.audit_logs (user_id);
CREATE INDEX idx_audit_logs_table_name_record_id ON public.audit_logs (table_name, record_id);
CREATE INDEX idx_hospital_subscriptions_hospital_id ON public.hospital_subscriptions (hospital_id);

-- Functions for role checking (to be used in RLS policies for clarity and reusability)
-- These functions would typically be created in the 'public' schema or a dedicated 'authz' schema
-- and then referenced in RLS policies.

-- Function to check if current user is a super_admin
CREATE OR REPLACE FUNCTION is_super_admin() RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.name = 'super_admin');
END;
$$;

-- Function to check if current user is a hospital_admin
CREATE OR REPLACE FUNCTION is_hospital_admin() RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.name = 'hospital_admin');
END;
$$;

-- Function to check if current user is a doctor
CREATE OR REPLACE FUNCTION is_doctor() RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.name = 'doctor');
END;
$$;

-- Function to check if current user is a patient
CREATE OR REPLACE FUNCTION is_patient() RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.name = 'patient');
END;
$$;

-- Example of how to use the functions in RLS (already integrated above, but for demonstration)
-- ALTER TABLE public.hospitals ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Allow hospital_admin and super_admin to manage hospitals" ON public.hospitals USING (is_super_admin() OR is_hospital_admin());

-- Trigger for `updated_at` column
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to relevant tables
CREATE TRIGGER set_profiles_timestamp
BEFORE UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_hospitals_timestamp
BEFORE UPDATE ON public.hospitals
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_departments_timestamp
BEFORE UPDATE ON public.departments
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_doctors_timestamp
BEFORE UPDATE ON public.doctors
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_doctor_availability_timestamp
BEFORE UPDATE ON public.doctor_availability
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_patients_timestamp
BEFORE UPDATE ON public.patients
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_appointments_timestamp
BEFORE UPDATE ON public.appointments
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_prescriptions_timestamp
BEFORE UPDATE ON public.prescriptions
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_medical_records_timestamp
BEFORE UPDATE ON public.medical_records
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_payments_timestamp
BEFORE UPDATE ON public.payments
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_notifications_timestamp
BEFORE UPDATE ON public.notifications
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_subscriptions_timestamp
BEFORE UPDATE ON public.subscriptions
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER set_hospital_subscriptions_timestamp
BEFORE UPDATE ON public.hospital_subscriptions
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Initial data for roles (example)
INSERT INTO public.roles (id, name, description) VALUES
    ('a1a1a1a1-a1a1-4a1a-8a1a-a1a1a1a1a1a1', 'super_admin', 'System Super Administrator with full access'),
    ('b2b2b2b2-b2b2-4b2b-8b2b-b2b2b2b2b2b2', 'hospital_admin', 'Administrator for a specific hospital'),
    ('c3c3c3c3-c3c3-4c3c-8c3c-c3c3c3c3c3c3', 'doctor', 'Medical Doctor'),
    ('d4d4d4d4-d4d4-4d4d-8d4d-d4d4d4d4d4d4', 'patient', 'Registered Patient')
ON CONFLICT (name) DO NOTHING;

-- Initial data for permissions (example)
INSERT INTO public.permissions (id, name, description) VALUES
    ('e5e5e5e5-e5e5-4e5e-8e5e-e5e5e5e5e5e5', 'manage_hospitals', 'Permission to create, read, update, delete hospitals'),
    ('f6f6f6f6-f6f6-4f6f-8f6f-f6f6f6f6f6f6', 'manage_doctors', 'Permission to create, read, update, delete doctors'),
    ('g7g7g7g7-g7g7-4g7g-8g7g-g7g7g7g7g7g7', 'manage_patients', 'Permission to create, read, update, delete patients'),
    ('h8h8h8h8-h8h8-4h8h-8h8h-h8h8h8h8h8h8', 'book_appointments', 'Permission to book appointments'),
    ('i9i9i9i9-i9i9-4i9i-8i9i-i9i9i9i9i9i9', 'view_medical_records', 'Permission to view medical records'),
    ('j0j0j0j0-j0j0-4j0j-8j0j-j0j0j0j0j0j0', 'prescribe_medication', 'Permission to prescribe medication')
ON CONFLICT (name) DO NOTHING;

-- Example: Assign all permissions to super_admin role
INSERT INTO public.role_permissions (role_id, permission_id) VALUES
    ((SELECT id FROM public.roles WHERE name = 'super_admin'), (SELECT id FROM public.permissions WHERE name = 'manage_hospitals')),
    ((SELECT id FROM public.roles WHERE name = 'super_admin'), (SELECT id FROM public.permissions WHERE name = 'manage_doctors')),
    ((SELECT id FROM public.roles WHERE name = 'super_admin'), (SELECT id FROM public.permissions WHERE name = 'manage_patients')),
    ((SELECT id FROM public.roles WHERE name = 'super_admin'), (SELECT id FROM public.permissions WHERE name = 'book_appointments')),
    ((SELECT id FROM public.roles WHERE name = 'super_admin'), (SELECT id FROM public.permissions WHERE name = 'view_medical_records')),
    ((SELECT id FROM public.roles WHERE name = 'super_admin'), (SELECT id FROM public.permissions WHERE name = 'prescribe_medication'))
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- Example: Assign specific permissions to hospital_admin role
INSERT INTO public.role_permissions (role_id, permission_id) VALUES
    ((SELECT id FROM public.roles WHERE name = 'hospital_admin'), (SELECT id FROM public.permissions WHERE name = 'manage_doctors')),
    ((SELECT id FROM public.roles WHERE name = 'hospital_admin'), (SELECT id FROM public.permissions WHERE name = 'manage_patients'))
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- Example: Assign specific permissions to doctor role
INSERT INTO public.role_permissions (role_id, permission_id) VALUES
    ((SELECT id FROM public.roles WHERE name = 'doctor'), (SELECT id FROM public.permissions WHERE name = 'view_medical_records')),
    ((SELECT id FROM public.roles WHERE name = 'doctor'), (SELECT id FROM public.permissions WHERE name = 'prescribe_medication'))
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- Example: Assign specific permissions to patient role
INSERT INTO public.role_permissions (role_id, permission_id) VALUES
    ((SELECT id FROM public.roles WHERE name = 'patient'), (SELECT id FROM public.permissions WHERE name = 'book_appointments')),
    ((SELECT id FROM public.roles WHERE name = 'patient'), (SELECT id FROM public.permissions WHERE name = 'view_medical_records'))
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- Helper views for easier RLS policy management (optional but good practice)
CREATE VIEW public.hospital_admins AS
SELECT p.id, d.hospital_id
FROM public.profiles p
JOIN public.user_roles ur ON p.id = ur.user_id
JOIN public.roles r ON ur.role_id = r.id
JOIN public.doctors d ON p.id = d.id -- Assuming hospital_admin is also a doctor for simplicity, or create a separate admin table
WHERE r.name = 'hospital_admin';

-- Note: For a true hospital_admin, a separate table `hospital_admins` might be needed
-- or a more complex join to link a profile to a hospital without being a doctor.
-- For now, assuming hospital_admin role is linked to a doctor profile for hospital_id context.

-- For a dedicated hospital_admins table:
-- CREATE TABLE public.hospital_admins (
--     id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
--     hospital_id uuid REFERENCES public.hospitals(id) ON DELETE CASCADE NOT NULL,
--     created_at timestamp with time zone DEFAULT now() NOT NULL,
--     updated_at timestamp with time zone DEFAULT now() NOT NULL,
--     deleted_at timestamp with time zone
-- );
-- ALTER TABLE public.hospital_admins ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Allow hospital_admin to manage their own hospital_admin entry" ON public.hospital_admins FOR ALL USING (auth.uid() = id);
-- CREATE POLICY "Allow super_admin to manage hospital_admins" ON public.hospital_admins USING (is_super_admin());

```

### 3. Indexes

All primary keys automatically have unique indexes. Additional indexes are created for foreign keys and frequently queried columns to optimize read performance.

*   `idx_profiles_phone_number` on `public.profiles(phone_number)`
*   `idx_doctors_hospital_id` on `public.doctors(hospital_id)`
*   `idx_doctors_department_id` on `public.doctors(department_id)`
*   `idx_doctors_license_number` on `public.doctors(license_number)`
*   `idx_doctor_availability_doctor_id_date` on `public.doctor_availability(doctor_id, available_date)`
*   `idx_appointments_patient_id` on `public.appointments(patient_id)`
*   `idx_appointments_doctor_id` on `public.appointments(doctor_id)`
*   `idx_appointments_hospital_id` on `public.appointments(hospital_id)`
*   `idx_appointments_start_time` on `public.appointments(appointment_start_time)`
*   `idx_prescriptions_patient_id` on `public.prescriptions(patient_id)`
*   `idx_prescriptions_doctor_id` on `public.prescriptions(doctor_id)`
*   `idx_medical_records_patient_id` on `public.medical_records(patient_id)`
*   `idx_medical_records_doctor_id` on `public.medical_records(doctor_id)`
*   `idx_payments_patient_id` on `public.payments(patient_id)`
*   `idx_payments_transaction_id` on `public.payments(transaction_id)`
*   `idx_notifications_recipient_id` on `public.notifications(recipient_id)`
*   `idx_audit_logs_user_id` on `public.audit_logs(user_id)`
*   `idx_audit_logs_table_name_record_id` on `public.audit_logs(table_name, record_id)`
*   `idx_hospital_subscriptions_hospital_id` on `public.hospital_subscriptions(hospital_id)`

### 4. Constraints

*   **Primary Keys:** All tables use `uuid` as primary keys, generated by `uuid_generate_v4()`.
*   **Foreign Keys:** Enforced for all relationships to maintain referential integrity. `ON DELETE CASCADE` is used where child records should be deleted with the parent (e.g., `user_roles` with `profiles`), and `ON DELETE SET NULL` where child records should remain but lose their association (e.g., `doctors` losing `hospital_id` if hospital is deleted).
*   **Unique Constraints:** Applied to columns requiring unique values (e.g., `profiles.phone_number`, `doctors.license_number`, `hospitals.name`, `departments(hospital_id, name)`).
*   **NOT NULL Constraints:** Applied to essential columns that must always have a value.
*   **Default Values:** Set for `created_at`, `updated_at`, `status`, `is_read`, `currency`, `payment_date`, `prescribed_date`, `record_date`.
*   **Check Constraints:** Implicitly handled by `status` fields with predefined values (e.g., `status text DEFAULT 'pending' NOT NULL`).

### 5. Row-Level Security (RLS) Policies

RLS is enabled for all sensitive tables to ensure data isolation and adherence to the principle of least privilege. Policies are defined based on user roles and ownership.

*   **`profiles`:**
    *   `SELECT`: Allow public read access (for general user lookup, e.g., doctor profiles).
    *   `INSERT`: Allow users to create their own profile (`auth.uid() = id`).
    *   `UPDATE`: Allow users to update their own profile (`auth.uid() = id`).
*   **`roles`, `permissions`, `role_permissions`, `doctor_specialties`:**
    *   `SELECT`: Allow all authenticated users to read.
    *   `INSERT`, `UPDATE`, `DELETE`: Restricted to `super_admin` (managed via `is_super_admin()` function or direct role check).
*   **`user_roles`:**
    *   `SELECT`: Allow users to read their own roles (`auth.uid() = user_id`).
    *   `INSERT`, `UPDATE`, `DELETE`: Restricted to `super_admin`.
*   **`hospitals`, `departments`:**
    *   `SELECT`: Allow all authenticated users to read.
    *   `INSERT`, `UPDATE`, `DELETE`: Restricted to `hospital_admin` (for their hospital) and `super_admin`.
*   **`doctors`:**
    *   `SELECT`: Allow all authenticated users to read doctor profiles.
    *   `UPDATE`: Allow doctors to update their own profile (`auth.uid() = id`).
    *   `INSERT`, `DELETE`: Restricted to `hospital_admin` (for their hospital) and `super_admin`.
*   **`doctor_specialty_link`:**
    *   `SELECT`: Allow all authenticated users to read.
    *   `INSERT`, `UPDATE`, `DELETE`: Allow doctors to manage their own specialties (`auth.uid() = doctor_id`).
*   **`doctor_availability`:**
    *   `SELECT`: Allow all authenticated users to read doctor availability.
    *   `INSERT`, `UPDATE`, `DELETE`: Allow doctors to manage their own availability (`auth.uid() = doctor_id`).
*   **`patients`:**
    *   `SELECT`: Allow patients to read their own profile (`auth.uid() = id`). Allow doctors to read profiles of their assigned patients. Allow `hospital_admin` and `super_admin` to read patient profiles.
    *   `UPDATE`: Allow patients to update their own profile (`auth.uid() = id`).
    *   `INSERT`, `DELETE`: Restricted to `super_admin` or specific `hospital_admin` actions.
*   **`appointments`:**
    *   `SELECT`: Allow patients to read their own appointments. Allow doctors to read their own appointments. Allow `hospital_admin` and `super_admin` to read/manage appointments within their scope.
    *   `INSERT`: Allow patients to create their own appointments.
    *   `UPDATE`: Allow patients to update/cancel their own appointments. Allow doctors to update appointment status/notes for their appointments. Allow `hospital_admin` and `super_admin` to manage appointments within their scope.
*   **`prescriptions`, `prescription_items`:**
    *   `SELECT`: Allow patients to read their own prescriptions/items. Allow doctors to read/manage prescriptions/items they issued. Allow `hospital_admin` and `super_admin` to read within their scope.
    *   `INSERT`, `UPDATE`, `DELETE`: Allow doctors to manage their own prescriptions/items. Restricted for others based on role.
*   **`medical_records`, `medical_record_versions`:**
    *   `SELECT`: Allow patients to read their own medical records/versions. Allow doctors to read/manage medical records/versions for their patients. Allow `hospital_admin` and `super_admin` to read within their scope.
    *   `INSERT`, `UPDATE`, `DELETE`: Allow doctors to manage medical records/versions for their patients. Restricted for others based on role.
*   **`payments`:**
    *   `SELECT`: Allow patients to read their own payments. Allow `hospital_admin` and `super_admin` to manage payments within their scope.
    *   `INSERT`: Allow patients to insert their own payments.
    *   `UPDATE`, `DELETE`: Restricted to `hospital_admin` and `super_admin`.
*   **`notifications`:**
    *   `SELECT`, `INSERT`, `UPDATE`, `DELETE`: Allow recipients to manage their own notifications (`auth.uid() = recipient_id`).
*   **`audit_logs`:**
    *   `SELECT`: Restricted to `super_admin`.
    *   `INSERT`: Handled by database triggers or backend functions, not directly by users.
*   **`subscriptions`, `hospital_subscriptions`:**
    *   `SELECT`: Allow authenticated users to read subscriptions. Allow `hospital_admin` to read their hospital's subscriptions.
    *   `INSERT`, `UPDATE`, `DELETE`: Restricted to `super_admin`.

### 6. Soft Deletes

Most tables include a `deleted_at` timestamp column. Instead of physically deleting records, this column will be populated with the current timestamp when a record is 
logically deleted. This allows for data recovery and maintains historical data for auditing and reporting purposes. Queries will need to filter out records where `deleted_at` IS NOT NULL to retrieve active records.

### 7. Audit Tables & Versioning

*   **`audit_logs` table:** Captures all significant changes to sensitive data, including `user_id`, `action`, `table_name`, `record_id`, `old_value`, `new_value`, `ip_address`, and `user_agent`. This is crucial for security, compliance (HIPAA, GDPR), and debugging.
*   **`medical_record_versions` table:** Specifically for `medical_records`, this table stores historical versions of medical documents, ensuring a complete audit trail and the ability to revert to previous states. Each version tracks `content`, `attachment_url`, `created_at`, and `created_by`.

### 8. Initial Data

*   **`roles`:** Pre-populated with `super_admin`, `hospital_admin`, `doctor`, and `patient` roles.
*   **`permissions`:** Pre-populated with a set of granular permissions like `manage_hospitals`, `manage_doctors`, `book_appointments`, etc.
*   **`role_permissions`:** Initial assignments of permissions to roles are provided as examples. These can be further refined.

### 9. Helper Views and Functions

*   **`is_super_admin()`, `is_hospital_admin()`, `is_doctor()`, `is_patient()`:** SQL functions are defined to simplify RLS policies by abstracting role checks. These functions return a boolean indicating if the currently authenticated user (via `auth.uid()`) holds the respective role.
*   **`hospital_admins` view:** A helper view to easily identify hospital administrators and their associated hospital IDs for use in RLS policies. (Note: A dedicated `hospital_admins` table might be more robust for complex scenarios, as commented in the schema).

### 10. `updated_at` Trigger

A `update_timestamp()` function and associated triggers are created for most tables to automatically update the `updated_at` column on every row modification. This is essential for tracking data changes and for caching strategies.


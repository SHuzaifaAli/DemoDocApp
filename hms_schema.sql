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
CREATE POLICY "Allow hospital_admin and super_admin to manage doctors" ON public.doctors USING (EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND (r.name = 'super_admin' OR r.name = 'hospital_admin')));

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
CREATE POLICY "Allow hospital_admin and super_admin to manage appointments" ON public.appointments USING (EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND (r.name = 'super_admin' OR r.name = 'hospital_admin')));

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
CREATE POLICY "Allow hospital_admin and super_admin to read prescriptions" ON public.prescriptions FOR SELECT USING (EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND (r.name = 'super_admin' OR r.name = 'hospital_admin')));

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
CREATE POLICY "Allow hospital_admin and super_admin to read medical records" ON public.medical_records FOR SELECT USING (EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND (r.name = 'super_admin' OR r.name = 'hospital_admin')));

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
CREATE POLICY "Allow hospital_admin and super_admin to manage payments" ON public.payments USING (EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND (r.name = 'super_admin' OR r.name = 'hospital_admin')));

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
CREATE POLICY "Allow hospital_admin to read their hospital's subscriptions" ON public.hospital_subscriptions FOR SELECT USING (EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.name = 'hospital_admin'));
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
CREATE OR REPLACE FUNCTION is_super_admin() RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.name = 'super_admin');
END;
$$;

CREATE OR REPLACE FUNCTION is_hospital_admin() RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.name = 'hospital_admin');
END;
$$;

CREATE OR REPLACE FUNCTION is_doctor() RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.name = 'doctor');
END;
$$;

CREATE OR REPLACE FUNCTION is_patient() RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN EXISTS (SELECT 1 FROM public.user_roles ur JOIN public.roles r ON ur.role_id = r.id WHERE ur.user_id = auth.uid() AND r.name = 'patient');
END;
$$;

-- Trigger for `updated_at` column
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to relevant tables
CREATE TRIGGER set_profiles_timestamp BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER set_hospitals_timestamp BEFORE UPDATE ON public.hospitals FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER set_departments_timestamp BEFORE UPDATE ON public.departments FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER set_doctors_timestamp BEFORE UPDATE ON public.doctors FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER set_doctor_availability_timestamp BEFORE UPDATE ON public.doctor_availability FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER set_patients_timestamp BEFORE UPDATE ON public.patients FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER set_appointments_timestamp BEFORE UPDATE ON public.appointments FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER set_prescriptions_timestamp BEFORE UPDATE ON public.prescriptions FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER set_medical_records_timestamp BEFORE UPDATE ON public.medical_records FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER set_payments_timestamp BEFORE UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER set_notifications_timestamp BEFORE UPDATE ON public.notifications FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER set_subscriptions_timestamp BEFORE UPDATE ON public.subscriptions FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER set_hospital_subscriptions_timestamp BEFORE UPDATE ON public.hospital_subscriptions FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Initial data for roles
INSERT INTO public.roles (id, name, description) VALUES
    ('a1a1a1a1-a1a1-4a1a-8a1a-a1a1a1a1a1a1', 'super_admin', 'System Super Administrator with full access'),
    ('b2b2b2b2-b2b2-4b2b-8b2b-b2b2b2b2b2b2', 'hospital_admin', 'Administrator for a specific hospital'),
    ('c3c3c3c3-c3c3-4c3c-8c3c-c3c3c3c3c3c3', 'doctor', 'Medical Doctor'),
    ('d4d4d4d4-d4d4-4d4d-8d4d-d4d4d4d4d4d4', 'patient', 'Registered Patient')
ON CONFLICT (name) DO NOTHING;

-- Initial data for permissions
INSERT INTO public.permissions (id, name, description) VALUES
    ('e5e5e5e5-e5e5-4e5e-8e5e-e5e5e5e5e5e5', 'manage_hospitals', 'Permission to create, read, update, delete hospitals'),
    ('f6f6f6f6-f6f6-4f6f-8f6f-f6f6f6f6f6f6', 'manage_doctors', 'Permission to create, read, update, delete doctors'),
    ('11111111-1111-1111-1111-111111111111', 'manage_patients', 'Permission to create, read, update, delete patients'),
    ('22222222-2222-2222-2222-222222222222', 'book_appointments', 'Permission to book appointments'),
    ('33333333-3333-3333-3333-333333333333', 'view_medical_records', 'Permission to view medical records'),
    ('44444444-4444-4444-4444-444444444444', 'prescribe_medication', 'Permission to prescribe medication')
ON CONFLICT (name) DO NOTHING;

-- Helper views for easier RLS policy management
CREATE OR REPLACE VIEW public.hospital_admins AS
SELECT p.id, d.hospital_id
FROM public.profiles p
JOIN public.user_roles ur ON p.id = ur.user_id
JOIN public.roles r ON ur.role_id = r.id
JOIN public.doctors d ON p.id = d.id
WHERE r.name = 'hospital_admin';

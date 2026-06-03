-- CREATE MISSING TABLES AND POPULATE DUMMY DATA FOR HOSPITAL BOOKING MANAGEMENT SYSTEM

-- 0. Create Missing Tables (if any)
CREATE TABLE IF NOT EXISTS public.consultation_chats (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id uuid REFERENCES public.appointments(id) ON DELETE CASCADE NOT NULL,
    sender_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    message text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);
ALTER TABLE public.consultation_chats ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow participants to read their own chats" ON public.consultation_chats FOR SELECT USING (EXISTS (SELECT 1 FROM public.appointments a WHERE a.id = appointment_id AND (a.patient_id = auth.uid() OR a.doctor_id = auth.uid())));
CREATE POLICY "Allow participants to insert their own chats" ON public.consultation_chats FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM public.appointments a WHERE a.id = appointment_id AND (a.patient_id = auth.uid() OR a.doctor_id = auth.uid())) AND auth.uid() = sender_id);

-- 1. Hospitals
INSERT INTO public.hospitals (id, name, address, phone_number, email, website)
VALUES 
('a1a1a1a1-1111-1111-1111-111111111111', 'City General Hospital', '123 Medical Ave, Downtown', '+1234567890', 'info@citygeneral.com', 'www.citygeneral.com'),
('b2b2b2b2-2222-2222-2222-222222222222', 'St. Mary Children Hospital', '456 Kids Lane, Uptown', '+1234567891', 'contact@stmarykids.com', 'www.stmarykids.com')
ON CONFLICT (id) DO NOTHING;

-- 2. Departments
INSERT INTO public.departments (id, hospital_id, name, description)
VALUES 
('d1d1d1d1-1111-1111-1111-111111111111', 'a1a1a1a1-1111-1111-1111-111111111111', 'Cardiology', 'Heart and blood vessel care'),
('d2d2d2d2-2222-2222-2222-222222222222', 'a1a1a1a1-1111-1111-1111-111111111111', 'Neurology', 'Brain and nervous system care'),
('d3d3d3d3-3333-3333-3333-333333333333', 'b2b2b2b2-2222-2222-2222-222222222222', 'Pediatrics', 'Specialized care for children')
ON CONFLICT (id) DO NOTHING;

-- 3. Profiles (Auth-linked)
-- These must be inserted into auth.users first if we want real login, 
-- but for data visibility in the dashboard, inserting into public.profiles is sufficient.
-- NOTE: We are using placeholder UUIDs.
INSERT INTO public.profiles (id, full_name, status, updated_at)
VALUES 
('f1f1f1f1-1111-1111-1111-111111111111', 'System Administrator', 'active', now()),
('f2f2f2f2-2222-2222-2222-222222222222', 'Dr. Alice Smith', 'active', now()),
('f3f3f3f3-3333-3333-3333-333333333333', 'Dr. Bob Johnson', 'active', now()),
('f4f4f4f4-4444-4444-4444-444444444444', 'Charlie Brown', 'active', now()),
('f5f5f5f5-5555-5555-5555-555555555555', 'Diana Prince', 'active', now())
ON CONFLICT (id) DO NOTHING;

-- 4. User Roles
INSERT INTO public.user_roles (user_id, role_id)
VALUES 
('f1f1f1f1-1111-1111-1111-111111111111', 'a1a1a1a1-a1a1-4a1a-8a1a-a1a1a1a1a1a1'), -- super_admin
('f2f2f2f2-2222-2222-2222-222222222222', 'c3c3c3c3-c3c3-4c3c-8c3c-c3c3c3c3c3c3'), -- doctor
('f3f3f3f3-3333-3333-3333-333333333333', 'c3c3c3c3-c3c3-4c3c-8c3c-c3c3c3c3c3c3'), -- doctor
('f4f4f4f4-4444-4444-4444-444444444444', 'd4d4d4d4-d4d4-4d4d-8d4d-d4d4d4d4d4d4'), -- patient
('f5f5f5f5-5555-5555-5555-555555555555', 'd4d4d4d4-d4d4-4d4d-8d4d-d4d4d4d4d4d4')  -- patient
ON CONFLICT (user_id, role_id) DO NOTHING;

-- 5. Doctors
INSERT INTO public.doctors (id, hospital_id, department_id, license_number, specialty, bio, experience_years, consultation_fee)
VALUES 
('f2f2f2f2-2222-2222-2222-222222222222', 'a1a1a1a1-1111-1111-1111-111111111111', 'd1d1d1d1-1111-1111-1111-111111111111', 'LIC-12345', 'Cardiologist', 'Expert in heart surgeries.', 15, 150.00),
('f3f3f3f3-3333-3333-3333-333333333333', 'a1a1a1a1-1111-1111-1111-111111111111', 'd2d2d2d2-2222-2222-2222-222222222222', 'LIC-67890', 'Neurologist', 'Specialized in neuro diseases.', 10, 120.00)
ON CONFLICT (id) DO NOTHING;

-- 6. Patients
INSERT INTO public.patients (id, date_of_birth, gender, blood_group)
VALUES 
('f4f4f4f4-4444-4444-4444-444444444444', '1990-05-15', 'male', 'O+'),
('f5f5f5f5-5555-5555-5555-555555555555', '1985-10-20', 'female', 'A-')
ON CONFLICT (id) DO NOTHING;

-- 7. Appointments
INSERT INTO public.appointments (id, patient_id, doctor_id, hospital_id, department_id, appointment_start_time, appointment_end_time, status, reason)
VALUES 
('e1e1e1e1-1111-1111-1111-111111111111', 'f4f4f4f4-4444-4444-4444-444444444444', 'f2f2f2f2-2222-2222-2222-222222222222', 'a1a1a1a1-1111-1111-1111-111111111111', 'd1d1d1d1-1111-1111-1111-111111111111', now() + interval '1 day', now() + interval '1 day 30 minutes', 'confirmed', 'Regular heart checkup'),
('e2e2e2e2-2222-2222-2222-222222222222', 'f5f5f5f5-5555-5555-5555-555555555555', 'f3f3f3f3-3333-3333-3333-333333333333', 'a1a1a1a1-1111-1111-1111-111111111111', 'd2d2d2d2-2222-2222-2222-222222222222', now() + interval '2 days', now() + interval '2 days 30 minutes', 'pending', 'Frequent headaches'),
('e3e3e3e3-3333-3333-3333-333333333333', 'f4f4f4f4-4444-4444-4444-444444444444', 'f3f3f3f3-3333-3333-3333-333333333333', 'a1a1a1a1-1111-1111-1111-111111111111', 'd2d2d2d2-2222-2222-2222-222222222222', now() - interval '5 days', now() - interval '5 days 30 minutes', 'completed', 'Initial neuro consultation')
ON CONFLICT (id) DO NOTHING;

-- 8. Consultation Chats
INSERT INTO public.consultation_chats (appointment_id, sender_id, message)
VALUES 
('e3e3e3e3-3333-3333-3333-333333333333', 'f4f4f4f4-4444-4444-4444-444444444444', 'Hello Dr. Johnson, I am ready for the call.'),
('e3e3e3e3-3333-3333-3333-333333333333', 'f3f3f3f3-3333-3333-3333-333333333333', 'Hello Charlie, let me review your history first.')
ON CONFLICT DO NOTHING;

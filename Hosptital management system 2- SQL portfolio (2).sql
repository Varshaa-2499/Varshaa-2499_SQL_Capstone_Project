-- Creating database and tables -- primary and foreign key --
create database Hospital_management_system;
use Hospital_management_system;

-- Doctor table
create table Doctor (doctor_id varchar(10) primary key, first_name varchar(20), last_name varchar(20), 
specialization varchar(30), phone_number varchar(20), years_experience int,
hospital_branch varchar(30), email varchar(30));

-- Patient table
create table Patient (patient_id varchar(10) primary key, first_name varchar(20), last_name varchar(20), 
gender varchar(10), date_of_birth date, contact_number varchar(20), address varchar(30),
registration_date date, insurance_provider varchar(20), insurance_number varchar(20), email varchar(30));

-- Appointment table
create table Appointments (appointment_id varchar(10) primary key,  patient_id VARCHAR(10), doctor_id VARCHAR(10), 
appointment_date date, reason_for_visit varchar(50),
appointment_status varchar(20),
FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
FOREIGN KEY (doctor_id) REFERENCES Doctor(doctor_id));

-- Treatment table
create table Treatment (treatment_id varchar(10) primary key, appointment_id varchar(10), treatment_type varchar(20),
 treatment_description varchar(30),
cost decimal(10,2), treatment_date date,
FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)); 
drop table Billing;

-- Billing table
create table Billing (bill_id varchar(10) primary key, patient_id varchar(10), treatment_id varchar(10), bill_date date, 
amount decimal(10,2), payment_method varchar(20), payment_status varchar(10),
FOREIGN KEY (patient_id) REFERENCES Patient(patient_id));

-- Preview data
select * from Doctor;
select * from Patient;
select * from Appointments;
select * from Treatment;
select * from Billing;

-- Total Appointments
select distinct count(appointment_id) as Total_Appointments
from Appointments;

-- Total number of appointments per doctor
select d.doctor_id, d.first_name, d.last_name, count(a.appointment_id) as Number_of_Appointments
from Doctor d
join Appointments a on d.doctor_id = a.doctor_id
group by d.doctor_id;

-- Average treatment cost per specialization
select d.specialization, avg(t.cost) as Total_cost
from Doctor d
join Appointments a on d.doctor_id = a.doctor_id
join Treatment t on a.appointment_id = t.appointment_id
group by d.specialization;

-- List of patients with their latest appointment date
select a.patient_id, p.first_name, p.last_name, max(a.appointment_date) as Latest_appointment
from Appointments a
join Patient p on a.patient_id = p.patient_id
group by a.patient_id
limit 5;

-- Top 3 doctors with highest number of appointments (using window function and CTE)
with doc_count as(
select doctor_id, count(appointment_id) as Total_appointments
from Appointments
group by doctor_id),
ranked_docs as (
  select *, rank() over (order by total_appointments desc) as doc_rank
  from doc_count
)
select * from ranked_docs
where doc_rank <= 3;

-- Find the total revenue generated per hospital branch
select d.hospital_branch, sum(t.cost) as Total_revenue
from Doctor d
join Appointments a on d.doctor_id = a.doctor_id
join Treatment t on a.appointment_id = t.appointment_id
group by d.hospital_branch;

-- Find most common reason for visit (mode)
select reason_for_visit, COUNT(*) AS frequent_visit
from Appointments
group by reason_for_visit
order by 2 DESC
limit 3;


-- Calculate total billing per patient and show only those with more than ₹10,000 (CTE)
with patient_bills as (
  select p.patient_id, concat(p.first_name,'', p.last_name) as Patient_name, SUM(t.cost) as Total_cost
  from Patient p
  join Appointments a on p.patient_id = a.patient_id
  join treatment t on a.appointment_id = t.appointment_id
  group by p.patient_id
)
select * from patient_bills
where Total_cost > 10000;

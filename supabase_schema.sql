-- KMI QA & Inspection Portal
-- Supabase/PostgreSQL starter schema
-- Jalankan setelah membuat project Supabase.
create extension if not exists "pgcrypto";

create table if not exists profiles (
 id uuid primary key default gen_random_uuid(),
 username text unique not null,
 full_name text not null,
 role text not null check (role in ('ADMIN','INSPECTION','STAFF','SUPPLIER')),
 supplier_code text,
 active boolean default true,
 created_at timestamptz default now()
);

create table if not exists suppliers (
 id uuid primary key default gen_random_uuid(),
 supplier_code text unique not null,
 supplier_name text not null,
 active boolean default true,
 created_at timestamptz default now()
);

create table if not exists shipments_checksheet (
 id uuid primary key default gen_random_uuid(),
 transaction_no text unique not null,
 supplier_id uuid references suppliers(id),
 delivery_date date,
 part_number text,
 part_name text,
 quantity numeric,
 remark text,
 file_url text,
 status text not null default 'Submitted',
 submitted_by uuid references profiles(id),
 reviewed_by uuid references profiles(id),
 reviewed_at timestamptz,
 review_note text,
 created_at timestamptz default now()
);

create table if not exists ng_performance (
 id uuid primary key default gen_random_uuid(),
 supplier_id uuid references suppliers(id),
 period_date date not null,
 part_number text,
 part_name text,
 qty_delivery numeric default 0,
 qty_ng numeric default 0,
 ng_type text,
 ng_sheet_no text,
 file_url text,
 created_at timestamptz default now()
);

create table if not exists hatsumono_submissions (
 id uuid primary key default gen_random_uuid(),
 submission_no text unique not null,
 supplier_id uuid references suppliers(id),
 doc_type text not null check (doc_type in ('Pre-Hatsumono','Hatsumono')),
 part_number text,
 target_trial date,
 foto_produk_url text,
 foto_fasilitas_url text,
 welder_url text,
 inspector_url text,
 status text default 'Submitted',
 reviewer_id uuid references profiles(id),
 review_note text,
 created_at timestamptz default now()
);

create table if not exists pcc_submissions (
 id uuid primary key default gen_random_uuid(),
 pcc_no text unique not null,
 supplier_id uuid references suppliers(id),
 problem_name text,
 description text,
 quantity numeric,
 file_url text,
 status text default 'Submitted',
 purchasing_user uuid references profiles(id),
 qa_user uuid references profiles(id),
 kintone_ref text,
 created_at timestamptz default now(),
 updated_at timestamptz default now()
);

create table if not exists checksheets (
 id uuid primary key default gen_random_uuid(),
 stamp_lot text not null,
 part_number text,
 process_name text,
 operator_name text,
 parameter_name text,
 standard_value text,
 actual_value text,
 result_status text,
 remark text,
 photo_url text,
 created_by uuid references profiles(id),
 created_at timestamptz default now()
);

create table if not exists daily_qa_reports (
 id uuid primary key default gen_random_uuid(),
 report_no text unique not null,
 stamp_number text,
 line_name text,
 process_name text,
 status text check (status in ('OK','NG','Hold')),
 location text,
 quantity numeric,
 urgent boolean default false,
 photo_url text,
 remark text,
 created_by uuid references profiles(id),
 created_at timestamptz default now()
);

create table if not exists inspection_requests (
 id uuid primary key default gen_random_uuid(),
 queue_no text unique not null,
 requester uuid references profiles(id),
 inspection_type text,
 product_part text,
 line_name text,
 quantity numeric,
 priority text check (priority in ('Normal','High','Urgent')) default 'Normal',
 eta timestamptz,
 reason text,
 attachment_url text,
 status text check (status in ('Waiting','In Progress','Completed','Rejected','Cancelled')) default 'Waiting',
 inspector uuid references profiles(id),
 started_at timestamptz,
 completed_at timestamptz,
 result_status text,
 result_note text,
 created_at timestamptz default now()
);

create table if not exists audit_logs (
 id uuid primary key default gen_random_uuid(),
 user_id uuid references profiles(id),
 module text,
 record_id uuid,
 action text,
 old_status text,
 new_status text,
 note text,
 created_at timestamptz default now()
);

-- Useful indexes
create index if not exists idx_queue_status_priority on inspection_requests(status, priority, created_at);
create index if not exists idx_ng_supplier_period on ng_performance(supplier_id, period_date);
create index if not exists idx_shipments_status on shipments_checksheet(status);
create index if not exists idx_pcc_status on pcc_submissions(status);
create index if not exists idx_daily_report_date on daily_qa_reports(created_at);


-- POS MVP: initial database schema
-- Currency: USD only. All monetary values are integer cents.

create extension if not exists pgcrypto;

create type public.app_role as enum ('owner', 'cashier');

create table public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    display_name text not null,
    role public.app_role not null default 'cashier',
    active boolean not null default true,
    created_at timestamptz not null default now()
);

create table public.categories (
    id uuid primary key default gen_random_uuid(),
    name text not null unique,
    active boolean not null default true,
    created_at timestamptz not null default now()
);

create table public.products (
    id uuid primary key default gen_random_uuid(),
    category_id uuid references public.categories(id),
    name text not null,
    description text,
    active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table public.product_variants (
    id uuid primary key default gen_random_uuid(),
    product_id uuid not null references public.products(id),
    sku text unique,
    size text,
    colour text,
    price_cents bigint not null check (price_cents >= 0),
    stock_on_hand integer not null default 0 check (stock_on_hand >= 0),
    active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table public.shifts (
    id uuid primary key default gen_random_uuid(),
    cashier_id uuid not null references public.profiles(id),
    device_id text,
    opening_float_cents bigint not null
        check (opening_float_cents >= 0),
    status text not null default 'open'
        check (status in ('open', 'closed')),
    opened_at timestamptz not null default now(),
    closed_at timestamptz,
    counted_cash_cents bigint
        check (counted_cash_cents is null or counted_cash_cents >= 0),
    closing_note text,
    created_at timestamptz not null default now(),
    check (
        (status = 'open' and closed_at is null)
        or
        (status = 'closed' and closed_at is not null)
    )
);

-- A cashier should have at most one open shift at a time.
create unique index one_open_shift_per_cashier
    on public.shifts(cashier_id)
    where status = 'open';

create table public.sales (
    id uuid primary key default gen_random_uuid(),
    cashier_id uuid not null references public.profiles(id),
    shift_id uuid not null references public.shifts(id),
    device_id text,
    idempotency_key uuid not null unique,
    status text not null default 'completed'
        check (
            status in (
                'completed',
                'void_requested',
                'voided',
                'refund_requested',
                'refunded'
            )
        ),
    subtotal_cents bigint not null check (subtotal_cents >= 0),
    total_cents bigint not null check (total_cents >= 0),
    created_at timestamptz not null default now()
);

create index sales_created_at_idx on public.sales(created_at desc);
create index sales_cashier_idx on public.sales(cashier_id, created_at desc);
create index sales_shift_idx on public.sales(shift_id);

create table public.sale_items (
    id uuid primary key default gen_random_uuid(),
    sale_id uuid not null references public.sales(id),
    variant_id uuid not null references public.product_variants(id),
    product_name text not null,
    variant_description text,
    quantity integer not null check (quantity > 0),
    unit_price_cents bigint not null check (unit_price_cents >= 0),
    line_total_cents bigint not null check (line_total_cents >= 0),
    created_at timestamptz not null default now()
);

create index sale_items_sale_idx on public.sale_items(sale_id);

create table public.payments (
    id uuid primary key default gen_random_uuid(),
    sale_id uuid not null unique references public.sales(id),
    method text not null
        check (method in ('cash', 'ecocash_usd', 'bank_transfer_usd')),
    amount_cents bigint not null check (amount_cents >= 0),
    tendered_cents bigint check (tendered_cents >= 0),
    change_cents bigint not null default 0 check (change_cents >= 0),
    created_at timestamptz not null default now(),
    check (
        method = 'cash'
        or (tendered_cents is null and change_cents = 0)
    ),
    check (
        method <> 'cash'
        or (
            tendered_cents is not null
            and tendered_cents >= amount_cents
            and change_cents = tendered_cents - amount_cents
        )
    )
);

create table public.cash_movements (
    id uuid primary key default gen_random_uuid(),
    shift_id uuid not null references public.shifts(id),
    cashier_id uuid not null references public.profiles(id),
    movement_type text not null
        check (movement_type in ('expense', 'cash_drop', 'cash_top_up')),
    amount_cents bigint not null check (amount_cents > 0),
    reason text not null,
    created_at timestamptz not null default now()
);

create table public.stock_receipts (
    id uuid primary key default gen_random_uuid(),
    received_by uuid not null references public.profiles(id),
    device_id text,
    reference text,
    note text,
    status text not null default 'pending'
        check (status in ('pending', 'approved', 'rejected')),
    reviewed_by uuid references public.profiles(id),
    reviewed_at timestamptz,
    review_note text,
    created_at timestamptz not null default now()
);

create index stock_receipts_status_idx
    on public.stock_receipts(status, created_at desc);

create table public.stock_receipt_items (
    id uuid primary key default gen_random_uuid(),
    receipt_id uuid not null references public.stock_receipts(id),
    variant_id uuid not null references public.product_variants(id),
    quantity integer not null check (quantity > 0),
    note text,
    created_at timestamptz not null default now(),
    unique (receipt_id, variant_id)
);

create table public.stock_movements (
    id uuid primary key default gen_random_uuid(),
    variant_id uuid not null references public.product_variants(id),
    movement_type text not null
        check (
            movement_type in (
                'sale',
                'receipt',
                'refund',
                'adjustment'
            )
        ),
    quantity_delta integer not null check (quantity_delta <> 0),
    sale_id uuid references public.sales(id),
    receipt_id uuid references public.stock_receipts(id),
    note text,
    created_by uuid references public.profiles(id),
    created_at timestamptz not null default now()
);

create index stock_movements_variant_idx
    on public.stock_movements(variant_id, created_at desc);

create table public.audit_log (
    id bigint generated always as identity primary key,
    actor_id uuid,
    table_name text not null,
    record_id text,
    action text not null,
    old_data jsonb,
    new_data jsonb,
    created_at timestamptz not null default now()
);

-- Role helper. SECURITY DEFINER avoids recursive profile RLS checks.
create or replace function public.is_owner()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
    select exists (
        select 1
        from public.profiles p
        where p.id = (select auth.uid())
          and p.role = 'owner'
          and p.active = true
    );
$$;

-- Generic audit trigger for important record changes.
create or replace function public.write_audit_log()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
    old_row jsonb;
    new_row jsonb;
    row_id text;
begin
    if tg_op <> 'INSERT' then
        old_row := to_jsonb(old);
    end if;

    if tg_op <> 'DELETE' then
        new_row := to_jsonb(new);
    end if;

    row_id := coalesce(new_row ->> 'id', old_row ->> 'id');

    insert into public.audit_log (
        actor_id, table_name, record_id, action, old_data, new_data
    )
    values (
        (select auth.uid()),
        tg_table_name,
        row_id,
        tg_op,
        old_row,
        new_row
    );

    if tg_op = 'DELETE' then
        return old;
    end if;

    return new;
end;
$$;

create trigger audit_categories
after insert or update or delete on public.categories
for each row execute function public.write_audit_log();

create trigger audit_products
after insert or update or delete on public.products
for each row execute function public.write_audit_log();

create trigger audit_product_variants
after insert or update or delete on public.product_variants
for each row execute function public.write_audit_log();

create trigger audit_shifts
after insert or update or delete on public.shifts
for each row execute function public.write_audit_log();

create trigger audit_sales
after insert or update or delete on public.sales
for each row execute function public.write_audit_log();

create trigger audit_cash_movements
after insert or update or delete on public.cash_movements
for each row execute function public.write_audit_log();

create trigger audit_stock_receipts
after insert or update or delete on public.stock_receipts
for each row execute function public.write_audit_log();

create trigger audit_stock_movements
after insert or update or delete on public.stock_movements
for each row execute function public.write_audit_log();

-- Enable RLS on every application table.
alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.product_variants enable row level security;
alter table public.shifts enable row level security;
alter table public.sales enable row level security;
alter table public.sale_items enable row level security;
alter table public.payments enable row level security;
alter table public.cash_movements enable row level security;
alter table public.stock_receipts enable row level security;
alter table public.stock_receipt_items enable row level security;
alter table public.stock_movements enable row level security;
alter table public.audit_log enable row level security;

-- Profiles: users can see their own profile; owners manage all profiles.
create policy profiles_select on public.profiles
for select to authenticated
using (id = (select auth.uid()) or (select public.is_owner()));

create policy profiles_owner_manage on public.profiles
for all to authenticated
using ((select public.is_owner()))
with check ((select public.is_owner()));

-- Product catalogue: cashiers can read active items; owners manage the catalogue.
create policy categories_read_active on public.categories
for select to authenticated
using (active = true or (select public.is_owner()));

create policy categories_owner_manage on public.categories
for all to authenticated
using ((select public.is_owner()))
with check ((select public.is_owner()));

create policy products_read_active on public.products
for select to authenticated
using (active = true or (select public.is_owner()));

create policy products_owner_manage on public.products
for all to authenticated
using ((select public.is_owner()))
with check ((select public.is_owner()));

create policy variants_read_active on public.product_variants
for select to authenticated
using (active = true or (select public.is_owner()));

create policy variants_owner_manage on public.product_variants
for all to authenticated
using ((select public.is_owner()))
with check ((select public.is_owner()));

-- Shifts: cashiers can open a shift and see/update their own shift.
create policy shifts_owner_manage on public.shifts
for all to authenticated
using ((select public.is_owner()))
with check ((select public.is_owner()));

create policy shifts_cashier_read on public.shifts
for select to authenticated
using (cashier_id = (select auth.uid()));

create policy shifts_cashier_insert on public.shifts
for insert to authenticated
with check (
    cashier_id = (select auth.uid())
    and status = 'open'
);

create policy shifts_cashier_update on public.shifts
for update to authenticated
using (
    cashier_id = (select auth.uid())
    and status = 'open'
)
with check (
    cashier_id = (select auth.uid())
    and status in ('open', 'closed')
);

-- Sales: cashier creates and reads their own; owners manage all.
create policy sales_owner_manage on public.sales
for all to authenticated
using ((select public.is_owner()))
with check ((select public.is_owner()));

create policy sales_cashier_read on public.sales
for select to authenticated
using (cashier_id = (select auth.uid()));

create policy sales_cashier_insert on public.sales
for insert to authenticated
with check (
    cashier_id = (select auth.uid())
    and status = 'completed'
    and exists (
        select 1 from public.shifts s
        where s.id = shift_id
          and s.cashier_id = (select auth.uid())
          and s.status = 'open'
    )
);

create policy sale_items_owner_manage on public.sale_items
for all to authenticated
using ((select public.is_owner()))
with check ((select public.is_owner()));

create policy sale_items_cashier_read on public.sale_items
for select to authenticated
using (
    exists (
        select 1 from public.sales s
        where s.id = sale_id and s.cashier_id = (select auth.uid())
    )
);

create policy sale_items_cashier_insert on public.sale_items
for insert to authenticated
with check (
    exists (
        select 1 from public.sales s
        where s.id = sale_id
          and s.cashier_id = (select auth.uid())
          and s.status = 'completed'
    )
);

create policy payments_owner_manage on public.payments
for all to authenticated
using ((select public.is_owner()))
with check ((select public.is_owner()));

create policy payments_cashier_read on public.payments
for select to authenticated
using (
    exists (
        select 1 from public.sales s
        where s.id = sale_id and s.cashier_id = (select auth.uid())
    )
);

create policy payments_cashier_insert on public.payments
for insert to authenticated
with check (
    exists (
        select 1 from public.sales s
        where s.id = sale_id
          and s.cashier_id = (select auth.uid())
          and s.status = 'completed'
    )
);

-- Cash movements: cashier records movements on their own open shift.
create policy cash_movements_owner_manage on public.cash_movements
for all to authenticated
using ((select public.is_owner()))
with check ((select public.is_owner()));

create policy cash_movements_cashier_read on public.cash_movements
for select to authenticated
using (cashier_id = (select auth.uid()));

create policy cash_movements_cashier_insert on public.cash_movements
for insert to authenticated
with check (
    cashier_id = (select auth.uid())
    and exists (
        select 1 from public.shifts s
        where s.id = shift_id
          and s.cashier_id = (select auth.uid())
          and s.status = 'open'
    )
);

-- Stock receipts: cashier submits pending deliveries; owner reviews them.
create policy receipts_owner_manage on public.stock_receipts
for all to authenticated
using ((select public.is_owner()))
with check ((select public.is_owner()));

create policy receipts_cashier_read on public.stock_receipts
for select to authenticated
using (received_by = (select auth.uid()));

create policy receipts_cashier_insert on public.stock_receipts
for insert to authenticated
with check (
    received_by = (select auth.uid())
    and status = 'pending'
    and reviewed_by is null
    and reviewed_at is null
);

create policy receipt_items_owner_manage on public.stock_receipt_items
for all to authenticated
using ((select public.is_owner()))
with check ((select public.is_owner()));

create policy receipt_items_cashier_read on public.stock_receipt_items
for select to authenticated
using (
    exists (
        select 1 from public.stock_receipts r
        where r.id = receipt_id and r.received_by = (select auth.uid())
    )
);

create policy receipt_items_cashier_insert on public.stock_receipt_items
for insert to authenticated
with check (
    exists (
        select 1 from public.stock_receipts r
        where r.id = receipt_id
          and r.received_by = (select auth.uid())
          and r.status = 'pending'
    )
);

-- Stock movement history and audit records are owner-readable only.
create policy stock_movements_owner_manage on public.stock_movements
for all to authenticated
using ((select public.is_owner()))
with check ((select public.is_owner()));

create policy audit_log_owner_read on public.audit_log
for select to authenticated
using ((select public.is_owner()));

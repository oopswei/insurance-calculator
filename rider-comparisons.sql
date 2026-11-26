-- 各式比較表管理：請在 Supabase Dashboard > SQL Editor 執行一次
-- 沿用既有 public.admin_users.user_id 作為管理員授權依據。

create table if not exists public.rider_comparisons (
  id uuid primary key default gen_random_uuid(),
  category text not null default '一般比較',
  title text not null,
  image_paths text[] not null default '{}',
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.rider_comparisons enable row level security;
grant select on public.rider_comparisons to anon, authenticated;
grant insert, update, delete on public.rider_comparisons to authenticated;

drop policy if exists "Public can view active rider comparisons" on public.rider_comparisons;
create policy "Public can view active rider comparisons"
on public.rider_comparisons for select to anon, authenticated
using (is_active = true or exists (
  select 1 from public.admin_users a where a.user_id = (select auth.uid())
));

drop policy if exists "Admins manage rider comparisons" on public.rider_comparisons;
create policy "Admins manage rider comparisons"
on public.rider_comparisons for all to authenticated
using (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())))
with check (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())));

-- 比較表圖片公開讀取，僅 admin_users 管理員可上傳、修改及刪除。
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('rider-comparisons', 'rider-comparisons', true, 15728640,
        array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set
  public = true,
  file_size_limit = 15728640,
  allowed_mime_types = array['image/jpeg','image/png','image/webp'];

grant select on storage.objects to anon, authenticated;
grant insert, update, delete on storage.objects to authenticated;

drop policy if exists "Public can view rider comparison images" on storage.objects;
create policy "Public can view rider comparison images"
on storage.objects for select to anon, authenticated
using (bucket_id = 'rider-comparisons');

drop policy if exists "Admins upload rider comparison images" on storage.objects;
create policy "Admins upload rider comparison images"
on storage.objects for insert to authenticated
with check (bucket_id = 'rider-comparisons' and exists (
  select 1 from public.admin_users a where a.user_id = (select auth.uid())
));

drop policy if exists "Admins update rider comparison images" on storage.objects;
create policy "Admins update rider comparison images"
on storage.objects for update to authenticated
using (bucket_id = 'rider-comparisons' and exists (
  select 1 from public.admin_users a where a.user_id = (select auth.uid())
))
with check (bucket_id = 'rider-comparisons' and exists (
  select 1 from public.admin_users a where a.user_id = (select auth.uid())
));

drop policy if exists "Admins delete rider comparison images" on storage.objects;
create policy "Admins delete rider comparison images"
on storage.objects for delete to authenticated
using (bucket_id = 'rider-comparisons' and exists (
  select 1 from public.admin_users a where a.user_id = (select auth.uid())
));

-- 匯入目前首頁既有的兩個比較表；圖片沿用專案 assets，不需重複上傳。
insert into public.rider_comparisons(category,title,image_paths,sort_order,is_active)
select '一般比較','新舊溫心大心比較表',array['legacy:assets/rider-comparisons/新舊溫心大心比較表.jpg'],1,true
where not exists (select 1 from public.rider_comparisons where title='新舊溫心大心比較表');

insert into public.rider_comparisons(category,title,image_paths,sort_order,is_active)
select '一般比較','意外險升級比較表',array[
 'legacy:assets/rider-comparisons/意外險升級比較表-1.jpg',
 'legacy:assets/rider-comparisons/意外險升級比較表-2.jpg',
 'legacy:assets/rider-comparisons/意外險升級比較表-3.jpg'
],2,true
where not exists (select 1 from public.rider_comparisons where title='意外險升級比較表');

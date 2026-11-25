-- 理賠案例管理：請在 Supabase Dashboard > SQL Editor 執行一次
-- 使用既有 admin_users.user_id 作為管理員授權依據

create table if not exists public.claims (
  id uuid primary key default gen_random_uuid(),
  category text not null check (category in ('癌症／重大疾病','意外／骨折','住院／手術／實支實付','其他')),
  title text not null,
  image_paths text[] not null default '{}',
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.claims enable row level security;
grant select on public.claims to anon, authenticated;
grant insert, update, delete on public.claims to authenticated;
drop policy if exists "Public can view claims" on public.claims;
create policy "Public can view claims" on public.claims for select to anon, authenticated using (true);
drop policy if exists "Admins manage claims" on public.claims;
create policy "Admins manage claims" on public.claims for all to authenticated
using (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())))
with check (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())));

-- 建立公開讀取、管理員寫入的圖片 bucket
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('claims-images', 'claims-images', true, 15728640, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public = true, file_size_limit = 15728640,
  allowed_mime_types = array['image/jpeg','image/png','image/webp'];

grant select on storage.objects to anon, authenticated;
grant insert, update, delete on storage.objects to authenticated;
drop policy if exists "Public can view claim images" on storage.objects;
create policy "Public can view claim images" on storage.objects for select to anon, authenticated
using (bucket_id = 'claims-images');
drop policy if exists "Admins upload claim images" on storage.objects;
create policy "Admins upload claim images" on storage.objects for insert to authenticated
with check (bucket_id = 'claims-images' and exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())));
drop policy if exists "Admins update claim images" on storage.objects;
create policy "Admins update claim images" on storage.objects for update to authenticated
using (bucket_id = 'claims-images' and exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())))
with check (bucket_id = 'claims-images' and exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())));
drop policy if exists "Admins delete claim images" on storage.objects;
create policy "Admins delete claim images" on storage.objects for delete to authenticated
using (bucket_id = 'claims-images' and exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())));


-- 分類順序：管理員可在後台拖曳分類，首頁依此排序
create table if not exists public.claim_category_order (
  category text primary key check (category in ('癌症／重大疾病','意外／骨折','住院／手術／實支實付','其他')),
  sort_order integer not null default 0,
  updated_at timestamptz not null default now()
);
alter table public.claim_category_order enable row level security;
grant select on public.claim_category_order to anon, authenticated;
grant insert, update, delete on public.claim_category_order to authenticated;
drop policy if exists "Public can view claim category order" on public.claim_category_order;
create policy "Public can view claim category order" on public.claim_category_order for select to anon, authenticated using (true);
drop policy if exists "Admins manage claim category order" on public.claim_category_order;
create policy "Admins manage claim category order" on public.claim_category_order for all to authenticated
using (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())))
with check (exists (select 1 from public.admin_users a where a.user_id = (select auth.uid())));
insert into public.claim_category_order(category,sort_order) values
('癌症／重大疾病',1),('意外／骨折',2),('住院／手術／實支實付',3),('其他',4)
on conflict (category) do nothing;

-- 將現有 20 件靜態案例匯入資料庫，原圖仍使用專案 claims/ 資料夾。
insert into public.claims (category, title, image_paths, sort_order)
select * from (values
('癌症／重大疾病','62歲女｜直腸癌',array['legacy:claims/01-cancer.jpg'],1),
('癌症／重大疾病','46歲女｜乳癌',array['legacy:claims/02-cancer.jpg'],2),
('癌症／重大疾病','2歲男｜眼癌',array['legacy:claims/11-cancer.jpg'],3),
('癌症／重大疾病','16歲女｜抗 NMDA 受體腦炎',array['legacy:claims/18-cancer.jpg'],4),
('癌症／重大疾病','58歲女｜大腸癌',array['legacy:claims/20-cancer.jpg'],5),
('意外／骨折','38歲男｜意外身故',array['legacy:claims/07-accident.jpg'],6),
('意外／骨折','63歲男｜橈骨骨裂',array['legacy:claims/14-accident.jpg'],7),
('意外／骨折','10歲女｜橈骨尺骨骨折',array['legacy:claims/15-accident.jpg'],8),
('意外／骨折','1歲女｜意外燙傷',array['legacy:claims/16-accident.jpg'],9),
('住院／手術／實支實付','71歲女｜腰椎壓迫',array['legacy:claims/03-medical.jpg'],10),
('住院／手術／實支實付','34歲女｜拔智齒',array['legacy:claims/04-medical.jpg'],11),
('住院／手術／實支實付','36歲女｜子宮肌瘤',array['legacy:claims/05-medical.jpg'],12),
('住院／手術／實支實付','49歲男｜睡眠呼吸中止症',array['legacy:claims/06-medical.jpg'],13),
('住院／手術／實支實付','36歲女｜膽囊切除',array['legacy:claims/08-medical.jpg'],14),
('住院／手術／實支實付','43歲女｜子宮肌瘤',array['legacy:claims/09-medical.jpg'],15),
('住院／手術／實支實付','44歲女｜子宮肌瘤',array['legacy:claims/10-medical.jpg'],16),
('住院／手術／實支實付','59歲男｜心臟支架',array['legacy:claims/12-medical.jpg'],17),
('住院／手術／實支實付','65歲男｜心臟支架',array['legacy:claims/13-medical.jpg'],18),
('住院／手術／實支實付','47歲男｜鼻中膈彎曲',array['legacy:claims/17-medical.jpg'],19),
('住院／手術／實支實付','大腸息肉切除',array['legacy:claims/19-medical.jpg'],20)
) as seed(category,title,image_paths,sort_order)
where not exists (select 1 from public.claims);

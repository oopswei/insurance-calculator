# 保險試算中心（GitHub Pages + Supabase）

## 專案內容
- `index.html`：三項試算工具入口。
- `products/man-yu-zhong-xin/`：滿溢鍾心保險金預估。
- `products/shi-zhi-shi-fu/`：實支實付保費比較。
- `products/genesis-risk-premium/`：創世紀危險保費試算。
- `admin/index.html`：創世紀年度費率管理後台。
- `supabase/schema.sql`：Supabase 資料表、RLS 權限設定。
- `supabase/seed_115.csv`：由使用者提供的 Excel「115」工作表匯出的 115 年男女費率（0～99 歲）。
- `config.example.js`：Supabase 前端設定範本。

## 一、建立 Supabase 資料庫
1. 登入 Supabase，建立一個專案。
2. 開啟 **SQL Editor**，執行 `supabase/schema.sql` 全部內容。
3. 到 **Authentication → Users** 建立管理者登入帳號。
4. 複製管理者的 User UID，回到 SQL Editor，執行：
   ```sql
   insert into public.admin_users (user_id) values ('貼上管理者 User UID');
   ```
5. 匯入初始 115 年費率：開啟 **Table Editor → genesis_risk_rates → Import data from CSV**，匯入 `supabase/seed_115.csv`。確認欄位對應 `rate_year, age, male_rate, female_rate`。
6. 將 `config.example.js` 複製成 `config.js`，填入 Supabase **Project URL** 與 **anon/public key**。不要使用 `service_role` key，也不要把它放到前端。

## 二、設定網站
1. 將整個資料夾內容上傳至 GitHub Repository 根目錄。
2. `config.js` 也必須部署到網站根目錄，才能連線 Supabase。注意：其中只能放 anon/public key。
3. 開啟 GitHub Pages，選擇 `main` 分支與 `/(root)`。
4. 試算入口：`/`；管理後台：`/admin/`。

## 三、管理年度費率
1. 管理者開啟 `/admin/`，使用已加入 `admin_users` 的帳號登入。
2. 輸入民國年度，下載 CSV 範本，填入該年度 0～99 歲男性與女性的每萬保額年費率。
3. CSV 標題必須是 `rate_year,age,male_rate,female_rate`，年齡需完整且不可重複。
4. 選擇 CSV 並匯入。匯入相同年度會更新該年度資料，不會覆蓋其他年度。
5. 試算頁會依試算年度讀取該年度費率；若該年度尚未上傳，沿用最近一個較早年度的費率。新年度費率匯入後，對應年度的試算會自動改採新費率。

## 試算規則與假設
- 性別：男性／女性。
- 年齡：直接輸入目前保險年齡，或輸入民國出生年月日（6 碼或 7 碼，例如 `800512`、`1070630`）；出生日期依生日滿半年加一歲換算。
- 保額：輸入值視為淨危險保額，不扣除保單帳戶價值。
- 每月危險保費：`ROUND(淨危險保額 ÷ 10,000 × 每萬保額年費率 ÷ 12, 0)`。因表格費率單位為「每萬危險保額」，計算時須先將淨危險保額換算成萬。
- 每年危險保費：每月危險保費 × 12。
- 每年帳管費：1,200 元。
- 試算至 99 歲，假設淨危險保額固定、每年收取 12 個月帳管費。
- 第一個試算年度依使用者當地日期換算民國年度；每年年齡增加 1 歲。若未有對應年度費率，沿用最近一個較早年度費率。

## 重要限制
原始 Excel 工作表「115」註明危險保險費每年可能因參考死亡率指數不同而改變，表列金額僅供參考，實際以保險公司系統為準。本工具為簡化情境試算，未依「危險保費計算規範」區分各險別收費起點、保單週月日及未滿月按日比例；也不推算淨危險保額未來變化。正式數字應以保單條款及保險公司核定為準。

## 既有工具注意事項
- GitHub Pages 網站公開；不要放入客戶個資、保單資料或任何 Supabase service_role key。
- 本網站的公開 anon key 依賴 Supabase RLS 保護資料；不要關閉 RLS。

## 理賠案例管理後台（首次設定）

1. 使用 Supabase 專案既有管理員帳號登入 `admin/`。
2. 在 Supabase Dashboard → SQL Editor 執行專案根目錄的 `claims-admin.sql` 一次。這會建立 `claims` 資料表、`claims-images` 圖片 bucket、RLS 權限，並將原本 20 件靜態案例登錄至資料表。
3. 回到 GitHub Pages 首頁重新整理；理賠案例改由 Supabase 資料庫動態載入。
4. 管理員登入 `admin/` 後，在「理賠案例管理」新增分類、案例名稱，並可一次選取多張 JPG／PNG／WebP 圖片（每張上限 15 MB）。
5. 修改案例可變更分類與名稱，也可追加圖片；刪除案例會一併刪除該案例已上傳至 Storage 的圖片。原有 `legacy:` 圖片仍由專案 `claims/` 資料夾提供。

安全設定：圖片 bucket 設為公開讀取，因首頁訪客需能檢視案例；新增、修改、刪除資料及圖片僅允許 `admin_users` 表內的管理員 UID。請勿把 Supabase service_role key 放入前端。


## 各式比較表管理（新增功能）

1. 在 Supabase Dashboard → SQL Editor 執行專案根目錄的 `rider-comparisons.sql` 一次。
2. SQL 會建立 `rider_comparisons` 資料表及 `rider-comparisons` 圖片 bucket，並將原本的「新舊溫心大心比較表」與「意外險升級比較表」登錄到資料庫；既有圖片檔案不需重新上傳。
3. 管理員登入 `/admin/` 後，會看到「各式比較表管理」。
4. 可新增分類、比較表名稱及多張圖片；可編輯名稱／分類並追加圖片、啟用／停用、刪除及調整首頁排序。
5. 首頁標題顯示為「各式比較表」。點選比較表名稱會開啟檢視頁；多張圖片可使用上一張／下一張按鈕、縮圖或鍵盤左右方向鍵切換。
6. 圖片支援 JPG／PNG／WebP，每張上限 15 MB。公開訪客僅能讀取啟用的比較表及圖片，只有 `admin_users` 內的管理員可新增、修改、刪除。

注意：需先執行 `rider-comparisons.sql`，後台管理及首頁動態資料才會啟用。未執行 SQL 時，首頁仍會顯示原有兩個比較表的預設入口。

## 全站自動更新與快取管理

本專案已加入 `update.js`、`sw.js` 與 `version.json`：

- 首頁、管理後台、理賠案例、比較表檢視頁及四個試算工具都會註冊同一個 Service Worker。
- 同網域 HTML、JavaScript、CSS、圖片及字型採網路優先；有網路時會取得最新內容，離線時才回退快取。
- 每次部署新版本時，請同時更新 `sw.js` 的 `CACHE_VERSION`（改成新的唯一版本字串），並更新 `version.json` 的 `version` 與 `updatedAt`。瀏覽器下次開啟網站時會檢查 Service Worker 更新，啟用新版後清除本專案舊版快取。
- 此機制不會清除 Supabase 資料庫、管理員帳號、登入權限或資料表內容。
- 首次部署後，使用者可能需要重新載入一次，讓瀏覽器完成 Service Worker 接管；之後會自動檢查更新。

注意：Service Worker 僅能在 HTTPS 或 localhost 環境運作。GitHub Pages 預設符合 HTTPS 條件。

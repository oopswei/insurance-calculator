# 保險試算中心（GitHub Pages）

## 專案結構

```text
insurance-calculator-center/
├─ index.html
├─ products/
│  └─ man-yu-zhong-xin/
│     └─ index.html
├─ README.md
└─ GOOGLE-SITES.md
```

- `index.html`：試算中心入口。
- `products/man-yu-zhong-xin/index.html`：滿溢鍾心商品試算器。
- 新增商品時，新增 `products/<商品代碼>/index.html`，再在入口 `index.html` 新增商品卡片。

## 部署到 GitHub Pages

1. 建立一個 GitHub repository，例如 `insurance-calculator-center`。
2. 將本資料夾內的所有檔案上傳到 repository 根目錄。
3. 開啟 repository 的 **Settings → Pages**。
4. 在 **Build and deployment** 選擇 **Deploy from a branch**。
5. Branch 選 `main`，資料夾選 `/(root)`，按 **Save**。
6. 等待 GitHub Pages 完成部署，從 Pages 頁面上的 **Visit site** 取得網站網址。

GitHub Pages 會直接託管 HTML、CSS、JavaScript 等靜態檔案；此版已將費率表嵌入商品頁，不再呼叫 Apps Script。

## Google Sites

取得 GitHub Pages 網址後：

1. 開啟 Google Sites 編輯器。
2. 在入口頁選擇 **插入 → 嵌入 → 依網址**。
3. 貼上 GitHub Pages 首頁網址，或新增「滿溢鍾心」頁面並貼上商品頁網址。
4. 若嵌入預覽正常，調整區塊寬度與高度；若頁面內容太長，可在 Google Sites 使用「整頁嵌入」。
5. 發布 Google Sites。

若外部頁面無法嵌入，保留一般連結按鈕即可；不要因此把試算器改回 Apps Script。

## 擴充新商品

1. 新增 `products/<商品代碼>/index.html`。
2. 該商品頁自帶自己的費率表、公式與條款說明。
3. 在根目錄 `index.html` 的 `cards` 區塊複製一張卡片，更新商品名稱、摘要與連結。
4. 不同商品各自獨立，更新單一商品不必改動其他商品。

## 注意事項

- GitHub Pages 網站是公開網站；不要放入客戶姓名、身分證字號、保單號碼、登入憑證或其他個人資料。
- 本版為靜態前端試算，不包含資料庫、登入權限或個人試算紀錄。
- 本版保留整歲情境估算限制，正式結果仍以保單條款及保險公司核定為準。

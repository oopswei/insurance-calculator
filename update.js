/* 保險試算中心全站更新檢查：每次開啟頁面檢查 Service Worker 是否有新版。 */
(() => {
  if (!('serviceWorker' in navigator)) return;
  const scriptUrl = document.currentScript && document.currentScript.src;
  if (!scriptUrl) return;
  const swUrl = new URL('sw.js', scriptUrl);
  const scopeUrl = new URL('./', scriptUrl);
  window.addEventListener('load', async () => {
    try {
      const registration = await navigator.serviceWorker.register(swUrl.href, {
        scope: scopeUrl.pathname,
        updateViaCache: 'none'
      });
      await registration.update();
      if (registration.waiting && navigator.serviceWorker.controller) {
        registration.waiting.postMessage({ type: 'SKIP_WAITING' });
      }
      let refreshing = false;
      navigator.serviceWorker.addEventListener('controllerchange', () => {
        if (refreshing) return;
        refreshing = true;
        window.location.reload();
      });
    } catch (error) {
      console.warn('網站更新檢查未完成，仍可正常使用目前版本。', error);
    }
  }, { once: true });
})();

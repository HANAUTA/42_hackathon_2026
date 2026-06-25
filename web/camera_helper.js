// Web専用: マイクパーミッション不要でカメラデバイスを列挙するヘルパー。
// Flutter camera プラグインの availableCameras() は内部で
// getUserMedia({ audio:true, video:true }) を呼ぶためマイクが
// ブロックされていると永久に止まる。
// この関数は video:true / audio:false で先にカメラ権限のみ取得し、
// その後 enumerateDevices() でビデオデバイス一覧を JSON で返す。

async function enumerateCamerasWeb() {
  // まず Permissions API でカメラの現在の権限状態を確認する。
  // 「granted」ならすでに許可済みなので getUserMedia を呼ばずにスキップできる。
  // 「prompt」なら getUserMedia でダイアログを出す必要がある。
  // 「denied」なら何をしても取れない。
  let permState = 'prompt';
  try {
    const result = await navigator.permissions.query({ name: 'camera' });
    permState = result.state;
    console.log('[camera-helper] カメラ権限状態:', permState);
  } catch (e) {
    // Permissions API 非対応ブラウザは無視して getUserMedia にフォールバック
    console.log('[camera-helper] Permissions API 非対応: フォールバック');
  }

  if (permState === 'denied') {
    throw new Error('NotAllowedError: カメラへのアクセスがブロックされています。URLバーの🔒からカメラを「許可する」に変更してください。');
  }

  if (permState !== 'granted') {
    // 「prompt」または空: getUserMedia でダイアログを出す
    // ※ macOS システム権限が未付与の場合も permState が空になる。
    //    その場合 macOS の許可ダイアログが裏に隠れていることがある。
    console.log('[camera-helper] getUserMedia(video:true, audio:false) でカメラ権限をリクエスト中...');
    const timeoutMs = 15000;
    const stream = await Promise.race([
      navigator.mediaDevices.getUserMedia({ video: true, audio: false }),
      new Promise((_, reject) =>
        setTimeout(() => reject(new Error(
          'TIMEOUT: カメラ権限ダイアログが ' + (timeoutMs / 1000) + '秒以内に応答しませんでした。\n' +
          'macOS の「システム設定 → プライバシーとセキュリティ → カメラ」で\n' +
          'Google Chrome をオンにしてください。'
        )), timeoutMs)
      ),
    ]);
    // 権限確認のためだけに取得したので即停止
    stream.getTracks().forEach(t => t.stop());
    console.log('[camera-helper] カメラ権限取得成功');
  } else {
    console.log('[camera-helper] カメラ権限は既に granted → getUserMedia スキップ');
  }

  console.log('[camera-helper] デバイス列挙中...');
  const devices = await navigator.mediaDevices.enumerateDevices();
  const cameras = devices
    .filter(d => d.kind === 'videoinput')
    .map(d => {
      // ラベルから前面/背面を判定（ラベルが空の場合は front とみなす）
      const label = d.label.toLowerCase();
      const isFront = label === '' ||
        label.includes('front') ||
        label.includes('user') ||
        label.includes('facetime');
      return {
        deviceId: d.deviceId,
        label: d.label || `Camera (${d.deviceId.slice(0, 8)})`,
        isFront,
      };
    });

  console.log('%c[camera-helper]', 'color:#00bcd4;font-weight:bold',
    `検出カメラ数: ${cameras.length}`, cameras);

  return JSON.stringify(cameras);
}

window.enumerateCamerasWeb = enumerateCamerasWeb;

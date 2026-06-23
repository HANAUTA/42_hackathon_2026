// ブラウザ内でffmpeg.wasmを使い、撮影動画を720p縦型mp4に変換する。
// Flutter(Dart)側からwindow.processVideoWeb(bytes)で呼び出す。

let _ffmpeg = null;
let _loadPromise = null;

function _log(...args) {
  console.log('%c[ffmpeg-web]', 'color:#7c4dff;font-weight:bold', ...args);
}
function _err(...args) {
  console.error('%c[ffmpeg-web]', 'color:#ff5252;font-weight:bold', ...args);
}

// ファイルを取得しblob URL化する。404やHTMLフォールバックを掴んでいないか検証する。
// （toBlobURLはfetchが404でも気づかずHTMLをblob化し、importScriptsで失敗するため自前実装）
async function _toBlobURL(url, mimeType) {
  const res = await fetch(url);
  if (!res.ok) {
    throw new Error(`取得失敗 HTTP ${res.status} ${res.statusText}: ${url}`);
  }
  const ct = res.headers.get('content-type') || '(none)';
  const buf = await res.arrayBuffer();
  const head = new TextDecoder()
    .decode(new Uint8Array(buf.slice(0, 64)))
    .trimStart();
  if (head.startsWith('<!DOCTYPE') || head.startsWith('<html')) {
    throw new Error(
      `JSの代わりにHTMLが返却された（パス誤り/404フォールバックの疑い）: ${url}`,
    );
  }
  _log(`fetched ${url} -> ${res.status} / ${ct} / ${buf.byteLength}B`);
  return URL.createObjectURL(new Blob([buf], { type: mimeType }));
}

// ffmpeg.wasm本体を一度だけ読み込む（初回のみ約31MBのコアをダウンロード）。
async function _ensureLoaded() {
  if (_ffmpeg) {
    _log('既にロード済み（キャッシュ利用）');
    return _ffmpeg;
  }
  if (_loadPromise) {
    _log('ロード中の処理を待機');
    return _loadPromise;
  }

  _loadPromise = (async () => {
    const t0 = performance.now();
    try {
      _log('ロード開始');
      if (typeof FFmpegWASM === 'undefined') {
        throw new Error('FFmpegWASM が未定義（/ffmpeg/ffmpeg.js が読み込めていない）');
      }
      const { FFmpeg } = FFmpegWASM;
      const ffmpeg = new FFmpeg();

      // FFmpeg本体のログ・進捗をコンソールに流す。
      ffmpeg.on('log', ({ type, message }) => _log(`(${type})`, message));
      ffmpeg.on('progress', ({ progress, time }) => {
        _log(`進捗 ${(progress * 100).toFixed(1)}%  time=${time}`);
      });

      // シングルスレッド版コア。SharedArrayBuffer不要でCOOP/COEPヘッダ無しで動く。
      // ファイルは web/ffmpeg/ に同梱。ルート絶対パスでパス解決事故を防ぐ。
      const base = '/ffmpeg';
      _log('blob化開始', base);
      const classWorkerURL = await _toBlobURL(`${base}/814.ffmpeg.js`, 'text/javascript');
      const coreURL = await _toBlobURL(`${base}/ffmpeg-core.js`, 'text/javascript');
      const wasmURL = await _toBlobURL(`${base}/ffmpeg-core.wasm`, 'application/wasm');
      _log('blob化完了');

      _log('ffmpeg.load() 実行');
      await ffmpeg.load({ classWorkerURL, coreURL, wasmURL });

      _ffmpeg = ffmpeg;
      _log(`ロード完了 (${(performance.now() - t0).toFixed(0)}ms)`);
      return ffmpeg;
    } catch (e) {
      _err('ロード失敗:', e);
      _loadPromise = null; // 次回リトライできるようにする
      throw e;
    }
  })();

  return _loadPromise;
}

// 入力動画(webm等)のバイト列を受け取り、720x1280縦型mp4のバイト列を返す。
// 変換コマンドはモバイル版(video_processor_io.dart)と同一。
async function processVideoWeb(inputBytes) {
  const t0 = performance.now();
  try {
    _log(`変換開始: 入力 ${inputBytes.length} bytes (${(inputBytes.length / 1024 / 1024).toFixed(2)} MB)`);
    const ffmpeg = await _ensureLoaded();

    // 入力は拡張子付きにする（ffmpegがコンテナ形式を判別しやすくなる）。
    const inputName = 'input.webm';
    const outputName = 'output.mp4';

    _log('writeFile:', inputName);
    await ffmpeg.writeFile(inputName, inputBytes);

    const args = [
      '-y', '-i', inputName,
      '-vf',
      'scale=720:1280:force_original_aspect_ratio=decrease,' +
        'pad=720:1280:(ow-iw)/2:(oh-ih)/2:black',
      '-c:v', 'libx264', '-preset', 'fast', '-crf', '23',
      '-c:a', 'aac', '-b:a', '128k',
      '-movflags', '+faststart',
      outputName,
    ];
    _log('exec:', args.join(' '));
    const tExec = performance.now();
    await ffmpeg.exec(args);
    _log(`exec完了 (${(performance.now() - tExec).toFixed(0)}ms)`);

    _log('readFile:', outputName);
    const data = await ffmpeg.readFile(outputName);
    _log(`変換完了: 出力 ${data.length} bytes (${(data.length / 1024 / 1024).toFixed(2)} MB)`);

    try { await ffmpeg.deleteFile(inputName); } catch (e) {}
    try { await ffmpeg.deleteFile(outputName); } catch (e) {}

    _log(`総処理時間 ${(performance.now() - t0).toFixed(0)}ms`);
    return data; // Uint8Array
  } catch (e) {
    _err('変換失敗:', e);
    throw e;
  }
}

window.processVideoWeb = processVideoWeb;

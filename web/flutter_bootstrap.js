{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  config: {
    // This app is deployed with limited/no access to Google's CDN
    // (fonts.gstatic.com). When the bundled fonts (Vazirmatn/Roboto) are
    // missing a glyph, Flutter's CanvasKit renderer normally tries to
    // download a fallback font from https://fonts.gstatic.com/s/, which
    // just times out/fails repeatedly here. Pointing it at a same-origin
    // path instead means any such lookup fails fast (local 404) rather
    // than hammering an unreachable foreign host on every affected frame.
    fontFallbackBaseUrl: '/fallback_fonts/',
  },
});

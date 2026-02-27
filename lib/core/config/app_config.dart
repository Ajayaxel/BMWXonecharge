class AppConfig {
  // Reverb (WebSocket) – client only needs the key, not the secret
  static const String reverbHost = 'one-charge-1-charge.up.railway.app';
  static const int reverbPort = 443;
  static const String reverbAppKey = '5csvb4sew88zqnmcxuqg';
  static const String reverbScheme = 'wss';
  static const bool reverbUseTls = true; // use wss:// when true

  // Customer private channel auth (Bearer token)
  static const String broadcastingAuthUrl =
      'https://app.onecharge.io/api/broadcasting/auth';

  // API & storage
  static const String baseUrl = 'https://app.onecharge.io/api';
  // static const String baseUrl = 'http://192.168.0.60:8000/api';
  static const String storageUrl = 'https://app.onecharge.io/storage/';
  // static const String storageUrl = 'http://192.168.0.60:8000/storage/';
}

class EnvironmentConfig {
  static const String _env = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static bool get isDevelopment => _env == 'development';
  static bool get isProduction => _env == 'production';
}

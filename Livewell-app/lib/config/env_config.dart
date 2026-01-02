import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get supabaseApiUrl {
    const defineValue = String.fromEnvironment('SUPABASE_URL');
    if (defineValue.isNotEmpty) return defineValue;
    return dotenv.env['SUPABASE_URL'] ?? 'http://localhost:8000';
  }

  static String get supabasePublishableKey {
    const defineValue = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    if (defineValue.isNotEmpty) return defineValue;
    return dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';
  }

  static String get backendUrl {
    const defineValue = String.fromEnvironment('BACKEND_URL');
    if (defineValue.isNotEmpty) return defineValue;
    return dotenv.env['BACKEND_URL'] ?? '';
  }
}

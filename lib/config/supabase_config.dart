import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig{
  static const String supabaseUrl = 'https://optjgyebmdgmtcfaqqsx.supabase.co';
  static const String supabaseApi = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9wdGpneWVibWRnbXRjZmFxcXN4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5ODcwODEsImV4cCI6MjA2OTU2MzA4MX0.xhfLA-Ge3qSxr363wJBDK8YCVG4A4atufTM7Yt1_Hvw';

  static Future<void> initialize() async{
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseApi);
  }
  static SupabaseClient get client => Supabase.instance.client;
}

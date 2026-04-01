import { createClient } from '@supabase/supabase-flutter';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  final supabase = SupabaseClient(
    dotenv.env['SUPABASE_URL']!,
    dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final res = await supabase.from('app_settings').select('*');
  print('Settings: $res');
}

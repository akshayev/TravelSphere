// This is a helper to do a find-and-replace across the seed_data.dart file.
// It fixes 'description: -> 'description': (missing leading quote before colon)
//
// Run: dart run tool/fix_descriptions.dart
//
// OR just manually replace all occurrences of:
//   'description:
// with:
//   'description':
// in lib/data/seed_data.dart

void main() {
  final file = File('lib/data/seed_data.dart');
  var content = file.readAsStringSync();

  // Fix 'description: -> 'description':
  content = content.replaceAll("'description:", "'description':");

  file.writeAsStringSync(content);
  print('Fixed all description fields');
}

import 'dart:io';
// ignore_for_file: avoid_print, unused_local_variable
import 'dart:io';
void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  final opacityRegex = RegExp(r'\.withOpacity\(\s*([^)]+)\s*\)');
  final activeColorRegex = RegExp(r'activeColor:');

  for (final file in files) {
    var content = file.readAsStringSync();
    var original = content;

    content = content.replaceAllMapped(opacityRegex, (match) {
      return '.withValues(alpha: ${match.group(1)})';
    });
    
    if (file.path.contains('profile_screen.dart')) {
       content = content.replaceAll('activeColor:', 'activeThumbColor:');
    }

    if (content != original) {
      file.writeAsStringSync(content);
      print('Fixed \${file.path}');
    }
  }
}

const fs = require('fs');

const files = [
  'lib/widgets/team_members_view.dart',
  'lib/screens/employee_dashboard.dart',
  'lib/screens/graphics_editor_dashboard.dart',
  'lib/screens/videographer_dashboard.dart',
  'lib/screens/dual_role_dashboard.dart',
  'lib/screens/ceo_dashboard.dart',
];

for (const file of files) {
  if (!fs.existsSync(file)) continue;
  let code = fs.readFileSync(file, 'utf8');
  
  // We want to replace `Image.asset(availableAvatars[...]...)`
  // with `Transform.scale(scale: 1.7, child: Image.asset(...))`
  // but avoid double wrapping if we already did it.
  
  // First, temporarily un-wrap anything we might have wrapped:
  code = code.replace(/Transform\.scale\(\s*scale:\s*1\.7,\s*child:\s*(Image\.asset\([^)]+\))\s*\)/g, '$1');
  
  // Now, wrap all Image.asset(availableAvatars...
  // The regex to match Image.asset(availableAvatars[...], ...)
  // We match Image.asset up to the first closing parenthesis that isn't inside another parenthesis,
  // but since it's just `availableAvatars[something % something], fit: BoxFit.cover, width: X, height: Y)`
  // it's simple enough to just match until `)`
  code = code.replace(/(Image\.asset\(availableAvatars\[[^\]]+\][^)]+\))/g, 'Transform.scale(scale: 1.7, child: $1)');

  fs.writeFileSync(file, code, 'utf8');
}
console.log('Scaled all avatars');

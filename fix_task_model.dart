import 'dart:io';

void main() {
  var file = File('lib/models/models.dart');
  var content = file.readAsStringSync();
  
  // Fix Task constructor
  content = content.replaceFirst(
    'this.isApprovedByVideographer = false,',
    'this.isApprovedByVideographer = false,\n      this.isPaidToVideographer = false,'
  );
  
  // Fix Task.fromFirestore
  content = content.replaceFirst(
    "isApprovedByVideographer: data['isApprovedByVideographer'] ?? false,",
    "isApprovedByVideographer: data['isApprovedByVideographer'] ?? false,\n        isPaidToVideographer: data['isPaidToVideographer'] ?? false,"
  );
  
  // Fix Task.toFirestore
  content = content.replaceFirst(
    "'isApprovedByVideographer': isApprovedByVideographer,",
    "'isApprovedByVideographer': isApprovedByVideographer,\n        'isPaidToVideographer': isPaidToVideographer,"
  );
  
  file.writeAsStringSync(content);
  print('Updated models.dart');
}

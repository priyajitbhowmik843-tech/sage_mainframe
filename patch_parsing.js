const fs = require('fs');
const path = require('path');

function patchModels() {
    const filepath = path.join(__dirname, 'lib', 'models', 'models.dart');
    let content = fs.readFileSync(filepath, 'utf8');

    const target = `  factory FinanceEntry.fromFirestore(Map<String, dynamic> data, String docId) {
    return FinanceEntry(
      id: data['financeId'] ?? docId,
      label: data['label'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      isIncome: data['isIncome'] ?? true,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: data['category'] ?? '',
      incomeType: data['incomeType'],
      expenseType: data['expenseType'],
      clientId: data['clientId'],
      employeeId: data['employeeId'],
      paymentMonth: data['paymentMonth'],
      sessionCount: data['sessionCount'],
      isSessionBased: data['isSessionBased'],
      isAdvance: data['isAdvance'] ?? false,
      isLate: data['isLate'] ?? false,
      paymentMethod: data['paymentMethod'],
      discount: (data['discount'] ?? 0.0).toDouble(),
    );
  }`;

    const replacement = `  factory FinanceEntry.fromFirestore(Map<String, dynamic> data, String docId) {
    double parsedAmount = 0.0;
    if (data['amount'] is num) parsedAmount = (data['amount'] as num).toDouble();
    else if (data['amount'] is String) parsedAmount = double.tryParse(data['amount']) ?? 0.0;

    DateTime parsedDate = DateTime.now();
    if (data['date'] != null) {
      if (data['date'] is Timestamp) parsedDate = (data['date'] as Timestamp).toDate();
      else if (data['date'] is DateTime) parsedDate = data['date'];
      else if (data['date'] is String) parsedDate = DateTime.tryParse(data['date']) ?? DateTime.now();
      else if (data['date'] is int) parsedDate = DateTime.fromMillisecondsSinceEpoch(data['date']);
    }

    double parsedDiscount = 0.0;
    if (data['discount'] is num) parsedDiscount = (data['discount'] as num).toDouble();
    else if (data['discount'] is String) parsedDiscount = double.tryParse(data['discount']) ?? 0.0;

    return FinanceEntry(
      id: data['financeId'] ?? docId,
      label: data['label'] ?? '',
      amount: parsedAmount,
      isIncome: data['isIncome'] == true || data['isIncome'] == 'true',
      date: parsedDate,
      category: data['category'] ?? '',
      incomeType: data['incomeType'],
      expenseType: data['expenseType'],
      clientId: data['clientId'],
      employeeId: data['employeeId'],
      paymentMonth: data['paymentMonth'],
      sessionCount: data['sessionCount'],
      isSessionBased: data['isSessionBased'] == true || data['isSessionBased'] == 'true',
      isAdvance: data['isAdvance'] == true || data['isAdvance'] == 'true',
      isLate: data['isLate'] == true || data['isLate'] == 'true',
      paymentMethod: data['paymentMethod'],
      discount: parsedDiscount,
    );
  }`;

    content = content.replace(target, replacement);
    fs.writeFileSync(filepath, content, 'utf8');
    console.log('models.dart patched');
}

function patchAppState() {
    const filepath = path.join(__dirname, 'lib', 'state', 'app_state.dart');
    let content = fs.readFileSync(filepath, 'utf8');

    const target = `      for (var doc in snapshot.docs) {
        try {
          _finances.add(FinanceEntry.fromFirestore(doc.data(), doc.id));
        } catch (_) {}
      }`;
      
    const replacement = `      for (var doc in snapshot.docs) {
        try {
          _finances.add(FinanceEntry.fromFirestore(doc.data(), doc.id));
        } catch (e, stack) {
          print("Error parsing finance \${doc.id}: $e");
          print(stack);
        }
      }`;

    content = content.replace(target, replacement);
    fs.writeFileSync(filepath, content, 'utf8');
    console.log('app_state.dart patched');
}

patchModels();
patchAppState();

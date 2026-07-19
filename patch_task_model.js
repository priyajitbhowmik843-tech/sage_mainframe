const fs = require('fs');
let code = fs.readFileSync('lib/models/models.dart', 'utf8');

// 1. Add bool isMissed;
code = code.replace("bool isCompleted;", "bool isCompleted;\n    bool isMissed;");

// 2. Add to constructor
code = code.replace("this.isCompleted = false,", "this.isCompleted = false,\n      this.isMissed = false,");

// 3. Add to fromFirestore
code = code.replace("isCompleted: data['isCompleted'] ?? false,", "isCompleted: data['isCompleted'] ?? false,\n        isMissed: data['isMissed'] ?? false,");

// 4. Add to toFirestore
code = code.replace("'isCompleted': isCompleted,", "'isCompleted': isCompleted,\n        'isMissed': isMissed,");

fs.writeFileSync('lib/models/models.dart', code, 'utf8');
console.log('Patched Task model with isMissed flag');

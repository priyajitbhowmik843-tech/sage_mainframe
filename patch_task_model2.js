const fs = require('fs');
let code = fs.readFileSync('lib/models/models.dart', 'utf8');

// 1. Add bool isPaidToVideoEditor;
code = code.replace("bool isPaidToVideographer = false;", "bool isPaidToVideoEditor = false;\n    bool isPaidToVideographer = false;");
code = code.replace("this.isPaidToVideographer = false,", "this.isPaidToVideoEditor = false,\n      this.isPaidToVideographer = false,");
code = code.replace("isPaidToVideographer: data['isPaidToVideographer'] ?? false,", "isPaidToVideoEditor: data['isPaidToVideoEditor'] ?? false,\n        isPaidToVideographer: data['isPaidToVideographer'] ?? false,");
code = code.replace("'isPaidToVideographer': isPaidToVideographer,", "'isPaidToVideoEditor': isPaidToVideoEditor,\n        'isPaidToVideographer': isPaidToVideographer,");

fs.writeFileSync('lib/models/models.dart', code, 'utf8');
console.log('Patched Task model with isPaidToVideoEditor flag');

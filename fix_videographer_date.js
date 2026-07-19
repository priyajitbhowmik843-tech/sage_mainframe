const fs = require('fs');
let code = fs.readFileSync('lib/widgets/employee_metrics_panel.dart', 'utf8');

// Fix INR symbol
code = code.replace(/"\?\\\$\{rate/g, '"?${rate');
code = code.replace(/"\?\\\$\{totalPayout/g, '"?${totalPayout');
code = code.replace(/"\?\\\$\{/g, '"?${'); // fallback

// Ensure we import intl for DateFormat if not already
if (!code.includes("import 'package:intl/intl.dart';")) {
    code = "import 'package:intl/intl.dart';\n" + code;
}

// Now replace the videographer row to include the date
let search = "Expanded(child: Text(client?.name ?? 'Unknown Client', style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),";
let replace = "Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(client?.name ?? 'Unknown Client', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis), Text(DateFormat('dd MMM yyyy').format(t.createdAt), style: const TextStyle(fontSize: 9, color: Colors.black54))])),";
code = code.replace(search, replace);

fs.writeFileSync('lib/widgets/employee_metrics_panel.dart', code, 'utf8');
console.log('Fixed Videographer row and INR symbols');

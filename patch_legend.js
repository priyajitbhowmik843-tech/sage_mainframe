const fs = require('fs');

const files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
    'lib/screens/dual_role_dashboard.dart'
];

const newLegend = `legend: Wrap(
              spacing: 12,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(4)),
                      child: const Text("#", style: TextStyle(color: Colors.blue, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 4),
                    const Text("Video", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(4)),
                      child: const Text("#", style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 4),
                    const Text("Design/Post/Photo", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: Colors.purple.withOpacity(0.2), border: Border.all(color: Colors.purple), borderRadius: BorderRadius.circular(4)),
                      child: const Text("#", style: TextStyle(color: Colors.purple, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 4),
                    const Text("Session/Mtg", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: Colors.brown.withOpacity(0.2), border: Border.all(color: Colors.brown), borderRadius: BorderRadius.circular(4)),
                      child: const Text("#", style: TextStyle(color: Colors.brown, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 4),
                    const Text("Product", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                      child: const Text("#", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 4),
                    const Text("Misc", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: Colors.blueGrey.withOpacity(0.2), border: Border.all(color: Colors.blueGrey), borderRadius: BorderRadius.circular(4)),
                      child: const Text("#", style: TextStyle(color: Colors.blueGrey, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 4),
                    const Text("Other", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
              ],
            ),`;

for (const file of files) {
    if (fs.existsSync(file)) {
        let text = fs.readFileSync(file, 'utf8');
        let modified = false;

        const legendRegex = /legend:\s*Wrap\([\s\S]*?children:\s*\[[\s\S]*?Other[\s\S]*?\]\s*\),/g;
        if (legendRegex.test(text)) {
            text = text.replace(legendRegex, newLegend);
            modified = true;
            console.log("Updated legend via regex in " + file);
        }

        if (modified) {
            fs.writeFileSync(file, text, 'utf8');
        }
    }
}

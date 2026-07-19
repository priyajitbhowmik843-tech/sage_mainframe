const fs = require('fs');

const files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/dual_role_dashboard.dart',
    'lib/screens/employee_dashboard.dart'
];

// 1. The legend replacement (only in ceo_dashboard and dual_role_dashboard, employee_dashboard might not have it or have it differently)
// Legend in CEO and Dual Role Dashboard:
const legendRegex = /legend:\s*Wrap\([\s\S]*?children:\s*\[[\s\S]*?Row\([\s\S]*?color:\s*Colors\.deepOrange[\s\S]*?Other[\s\S]*?\]\s*\),/g;

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
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(4),
                      ),
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
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text("#", style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 4),
                    const Text("Design/Post", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.2),
                        border: Border.all(color: Colors.teal),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text("#", style: TextStyle(color: Colors.teal, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 4),
                    const Text("Active Client", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        border: Border.all(color: Colors.purple),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text("#", style: TextStyle(color: Colors.purple, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 4),
                    const Text("Lead Mtg", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.2),
                        border: Border.all(color: Colors.indigo),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text("#", style: TextStyle(color: Colors.indigo, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 4),
                    const Text("Product/Photo", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withOpacity(0.2),
                        border: Border.all(color: Colors.blueGrey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text("#", style: TextStyle(color: Colors.blueGrey, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 4),
                    const Text("Other", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                ),
              ],
            ),`;

// 2. The task counting and cell block replacement
const countRegex = /Builder\(\s*builder:\s*\(ctx\)\s*\{[\s\S]*?int\s*vCount\s*=\s*0;[\s\S]*?for\s*\(var\s*t\s*in\s*dayTasks\)\s*\{[\s\S]*?oCount\+\+;\s*\}[\s\S]*?return\s*Wrap\([\s\S]*?children:\s*\[[\s\S]*?oCount\.toString\(\)[\s\S]*?\}\s*,\s*\)/g;

const newCount = `Builder(
                      builder: (ctx) {
                        int vCount = 0;
                        int pCount = 0;
                        int aCount = 0;
                        int lCount = 0;
                        int phCount = 0;
                        int oCount = 0;
                        for (var t in dayTasks) {
                          final title = t.title.toLowerCase();
                          final type = (t.taskType ?? '').toLowerCase();
                          if (title.contains('video') || type.contains('video'))
                            vCount++;
                          else if (title.contains('post') || title.contains('design') || type.contains('post') || type.contains('design'))
                            pCount++;
                          else if (title.contains('active client') || type.contains('active client'))
                            aCount++;
                          else if (title.contains('lead') || title.contains('marketing') || type.contains('lead') || type.contains('marketing'))
                            lCount++;
                          else if (title.contains('product') || title.contains('photo') || type.contains('product') || type.contains('photo'))
                            phCount++;
                          else
                            oCount++;
                        }

                        return Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 2,
                          runSpacing: 2,
                          children: [
                            if (vCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(vCount.toString(), style: const TextStyle(color: Colors.blue, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            if (pCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  border: Border.all(color: Colors.orange),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(pCount.toString(), style: const TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            if (aCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withOpacity(0.2),
                                  border: Border.all(color: Colors.teal),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(aCount.toString(), style: const TextStyle(color: Colors.teal, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            if (lCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.2),
                                  border: Border.all(color: Colors.purple),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(lCount.toString(), style: const TextStyle(color: Colors.purple, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            if (phCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.withOpacity(0.2),
                                  border: Border.all(color: Colors.indigo),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(phCount.toString(), style: const TextStyle(color: Colors.indigo, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            if (oCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.withOpacity(0.2),
                                  border: Border.all(color: Colors.blueGrey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(oCount.toString(), style: const TextStyle(color: Colors.blueGrey, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        );
                      },
                    )`;

for (const file of files) {
    if (fs.existsSync(file)) {
        let text = fs.readFileSync(file, 'utf8');
        let modified = false;

        // Try replacing legend
        if (text.includes("Colors.deepOrange") && text.includes("legend: Wrap")) {
             // Let's do a more generic replacement for the legend
             const legendStart = text.indexOf("legend: Wrap(");
             if (legendStart !== -1) {
                 const gridDelegateStart = text.indexOf("gridDelegate:", legendStart);
                 if (gridDelegateStart !== -1) {
                     text = text.substring(0, legendStart) + newLegend + "\n          " + text.substring(gridDelegateStart);
                     modified = true;
                     console.log("Updated legend in " + file);
                 }
             }
        }

        // Try replacing the builder block
        const countStart = text.indexOf("Builder(\n                      builder: (ctx) {\n                        int vCount = 0;");
        if (countStart !== -1) {
            let countEnd = text.indexOf("                      },\n                    )", countStart);
            if (countEnd !== -1) {
                countEnd += "                      },\n                    )".length;
                text = text.substring(0, countStart) + newCount + text.substring(countEnd);
                modified = true;
                console.log("Updated cell count in " + file + " (Method 1)");
            } else {
                // employee dashboard might have different indentation
                countEnd = text.indexOf("                      },\n                    )", countStart);
                if (countEnd === -1) {
                    console.log("Could not find end of Builder block in", file);
                }
            }
        } else {
            // Employee dashboard might have different spacing
            const regex = /Builder\(\s*builder:\s*\(ctx\)\s*\{\s*int vCount = 0;[\s\S]*?children:\s*\[[\s\S]*?oCount\.toString\(\)[\s\S]*?\}\s*,\s*\)/;
            if (regex.test(text)) {
                text = text.replace(regex, newCount);
                modified = true;
                console.log("Updated cell count in " + file + " (Method 2 regex)");
            } else {
                console.log("Could not find Builder block to replace in", file);
            }
        }

        if (modified) {
            fs.writeFileSync(file, text, 'utf8');
        }
    }
}

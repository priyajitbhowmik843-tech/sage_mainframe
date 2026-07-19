const fs = require('fs');

const files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/dual_role_dashboard.dart',
    'lib/screens/employee_dashboard.dart'
];

const newCount = `Builder(
                      builder: (ctx) {
                        int videoCount = 0;
                        int postCount = 0;
                        int meetCount = 0;
                        int prodCount = 0;
                        int miscCount = 0;
                        int otherCount = 0;

                        for (var t in dayTasks) {
                          final title = t.title.toLowerCase();
                          final type = (t.taskType ?? '').toLowerCase();
                          
                          if (type.contains('video') || title.contains('video')) {
                            videoCount++;
                          } else if (type.contains('post') || type.contains('photo') || type.contains('design') || title.contains('post') || title.contains('photo') || title.contains('design')) {
                            postCount++;
                          } else if (type.contains('session') || type.contains('meeting') || title.contains('session') || title.contains('meeting') || type.contains('lead') || title.contains('lead')) {
                            meetCount++;
                          } else if (type.contains('product') || title.contains('product')) {
                            prodCount++;
                          } else if (type.contains('misc') || title.contains('misc') || type == 'miscellaneous' || title.contains('miscellaneous')) {
                            miscCount++;
                          } else {
                            otherCount++;
                          }
                        }

                        return Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 2,
                          runSpacing: 2,
                          children: [
                            if (videoCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(videoCount.toString(), style: const TextStyle(color: Colors.blue, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            if (postCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  border: Border.all(color: Colors.orange),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(postCount.toString(), style: const TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            if (meetCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.2),
                                  border: Border.all(color: Colors.purple),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(meetCount.toString(), style: const TextStyle(color: Colors.purple, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            if (prodCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.brown.withOpacity(0.2),
                                  border: Border.all(color: Colors.brown),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(prodCount.toString(), style: const TextStyle(color: Colors.brown, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            if (miscCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(miscCount.toString(), style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            if (otherCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.withOpacity(0.2),
                                  border: Border.all(color: Colors.blueGrey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(otherCount.toString(), style: const TextStyle(color: Colors.blueGrey, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        );
                      },
                    )`;

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

        const legendStart = text.indexOf("legend: Wrap(\n              spacing: 12,");
        if (legendStart !== -1) {
            const gridDelegateStart = text.indexOf("gridDelegate:", legendStart);
            if (gridDelegateStart !== -1) {
                text = text.substring(0, legendStart) + newLegend + "\n          " + text.substring(gridDelegateStart);
                modified = true;
                console.log("Updated legend in " + file);
            }
        }

        const countRegex = /Builder\(\s*builder:\s*\(ctx\)\s*\{\s*int (?:vCount|videoCount) = 0;[\s\S]*?children:\s*\[[\s\S]*?(?:oCount|otherCount)\.toString\(\)[\s\S]*?\}\s*,\s*\)/;
        if (countRegex.test(text)) {
            text = text.replace(countRegex, newCount);
            modified = true;
            console.log("Updated cell count in " + file);
        } else {
            console.log("Could not find Builder block to replace in", file);
        }

        if (modified) {
            fs.writeFileSync(file, text, 'utf8');
        }
    }
}

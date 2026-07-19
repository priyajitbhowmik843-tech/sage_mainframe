const fs = require('fs');

function updateFile(filename) {
    if (!fs.existsSync(filename)) return;
    let content = fs.readFileSync(filename, 'utf-8');

    // 1. Update list colors
    // One-liners
    content = content.replace(
        /else\s+if\s*\(\s*typeStr\.contains\('session'\)\s*\|\|\s*typeStr\.contains\('meeting'\)\s*\)\s*typeColor\s*=\s*Colors\.purple;/g,
        "else if (typeStr.contains('active client')) typeColor = Colors.indigo;\n        else if (typeStr.contains('lead')) typeColor = Colors.purple;\n        else if (typeStr.contains('session')) typeColor = Colors.pink;"
    );

    // Multi-liners in ceo_dashboard
    content = content.replace(
        /else\s+if\s*\(\s*typeStr\.contains\('session'\)\s*\|\|\n?\s*typeStr\.contains\('meeting'\)\s*\)\n\s*typeColor\s*=\s*Colors\.purple;/g,
        "else if (typeStr.contains('active client'))\n                        typeColor = Colors.indigo;\n                      else if (typeStr.contains('lead'))\n                        typeColor = Colors.purple;\n                      else if (typeStr.contains('session'))\n                        typeColor = Colors.pink;"
    );

    // 2. Update the Builder logic
    const oldBuilder = `                      int videoCount = 0;
                      int postCount = 0;
                      int meetCount = 0;
                      int prodCount = 0;
                      int miscCount = 0;
                      int otherCount = 0;

                      for (var t in dayTasks) {
                        final typeStr = (t.taskType ?? '').toLowerCase();
                        
                        if (typeStr.contains('video')) {
                          videoCount++;
                        } else if (typeStr.contains('post') || typeStr.contains('photo') || typeStr.contains('upload')) {
                          postCount++;
                        } else if (typeStr.contains('session') || typeStr.contains('meeting')) {
                          meetCount++;
                        } else if (typeStr.contains('product')) {
                          prodCount++;
                        } else if (typeStr.contains('misc')) {
                          miscCount++;
                        } else {
                          otherCount++;
                        }
                      }`;

    const newBuilder = `                      int videoCount = 0;
                      int postCount = 0;
                      int activeCount = 0;
                      int leadCount = 0;
                      int sessionCount = 0;
                      int prodCount = 0;
                      int miscCount = 0;
                      int otherCount = 0;

                      for (var t in dayTasks) {
                        final typeStr = (t.taskType ?? '').toLowerCase();
                        
                        if (typeStr.contains('video')) {
                          videoCount++;
                        } else if (typeStr.contains('post') || typeStr.contains('photo') || typeStr.contains('upload')) {
                          postCount++;
                        } else if (typeStr.contains('active client')) {
                          activeCount++;
                        } else if (typeStr.contains('lead')) {
                          leadCount++;
                        } else if (typeStr.contains('session')) {
                          sessionCount++;
                        } else if (typeStr.contains('product')) {
                          prodCount++;
                        } else if (typeStr.contains('misc')) {
                          miscCount++;
                        } else {
                          otherCount++;
                        }
                      }`;
    
    // Replace all occurrences of oldBuilder
    content = content.split(oldBuilder).join(newBuilder);

    // Replace the cells
    const oldCells = `                          if (videoCount > 0)
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
                            ),`;

    const newCells = `                          if (videoCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(4)),
                              child: Text(videoCount.toString(), style: const TextStyle(color: Colors.blue, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          if (postCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(4)),
                              child: Text(postCount.toString(), style: const TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          if (activeCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.2), border: Border.all(color: Colors.indigo), borderRadius: BorderRadius.circular(4)),
                              child: Text(activeCount.toString(), style: const TextStyle(color: Colors.indigo, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          if (leadCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(color: Colors.purple.withOpacity(0.2), border: Border.all(color: Colors.purple), borderRadius: BorderRadius.circular(4)),
                              child: Text(leadCount.toString(), style: const TextStyle(color: Colors.purple, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          if (sessionCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(color: Colors.pink.withOpacity(0.2), border: Border.all(color: Colors.pink), borderRadius: BorderRadius.circular(4)),
                              child: Text(sessionCount.toString(), style: const TextStyle(color: Colors.pink, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          if (prodCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(color: Colors.brown.withOpacity(0.2), border: Border.all(color: Colors.brown), borderRadius: BorderRadius.circular(4)),
                              child: Text(prodCount.toString(), style: const TextStyle(color: Colors.brown, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          if (miscCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                              child: Text(miscCount.toString(), style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          if (otherCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                              decoration: BoxDecoration(color: Colors.blueGrey.withOpacity(0.2), border: Border.all(color: Colors.blueGrey), borderRadius: BorderRadius.circular(4)),
                              child: Text(otherCount.toString(), style: const TextStyle(color: Colors.blueGrey, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),`;

    content = content.split(oldCells).join(newCells);

    // Replace the Legend
    const oldLegend = `              Wrap(
                spacing: 12,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(4)), child: const Text("#", style: TextStyle(color: Colors.blue, fontSize: 9, fontWeight: FontWeight.bold))), const SizedBox(width: 4), const Text("Video", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54))]),
                  Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(4)), child: const Text("#", style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold))), const SizedBox(width: 4), const Text("Design/Post/Photo", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54))]),
                  Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.purple.withOpacity(0.2), border: Border.all(color: Colors.purple), borderRadius: BorderRadius.circular(4)), child: const Text("#", style: TextStyle(color: Colors.purple, fontSize: 9, fontWeight: FontWeight.bold))), const SizedBox(width: 4), const Text("Session/Mtg", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54))]),
                  Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.brown.withOpacity(0.2), border: Border.all(color: Colors.brown), borderRadius: BorderRadius.circular(4)), child: const Text("#", style: TextStyle(color: Colors.brown, fontSize: 9, fontWeight: FontWeight.bold))), const SizedBox(width: 4), const Text("Product", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54))]),
                  Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)), child: const Text("#", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold))), const SizedBox(width: 4), const Text("Misc", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54))]),
                  Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.blueGrey.withOpacity(0.2), border: Border.all(color: Colors.blueGrey), borderRadius: BorderRadius.circular(4)), child: const Text("#", style: TextStyle(color: Colors.blueGrey, fontSize: 9, fontWeight: FontWeight.bold))), const SizedBox(width: 4), const Text("Other", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54))]),
                ],
              ),`;

    const newLegend = `              Wrap(
                spacing: 12,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(4)), child: const Text("#", style: TextStyle(color: Colors.blue, fontSize: 9, fontWeight: FontWeight.bold))), const SizedBox(width: 4), const Text("Video", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54))]),
                  Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(4)), child: const Text("#", style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold))), const SizedBox(width: 4), const Text("Design/Post/Photo", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54))]),
                  Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.2), border: Border.all(color: Colors.indigo), borderRadius: BorderRadius.circular(4)), child: const Text("#", style: TextStyle(color: Colors.indigo, fontSize: 9, fontWeight: FontWeight.bold))), const SizedBox(width: 4), const Text("Active Client", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54))]),
                  Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.purple.withOpacity(0.2), border: Border.all(color: Colors.purple), borderRadius: BorderRadius.circular(4)), child: const Text("#", style: TextStyle(color: Colors.purple, fontSize: 9, fontWeight: FontWeight.bold))), const SizedBox(width: 4), const Text("Lead Mtg", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54))]),
                  Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.pink.withOpacity(0.2), border: Border.all(color: Colors.pink), borderRadius: BorderRadius.circular(4)), child: const Text("#", style: TextStyle(color: Colors.pink, fontSize: 9, fontWeight: FontWeight.bold))), const SizedBox(width: 4), const Text("Session", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54))]),
                  Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.brown.withOpacity(0.2), border: Border.all(color: Colors.brown), borderRadius: BorderRadius.circular(4)), child: const Text("#", style: TextStyle(color: Colors.brown, fontSize: 9, fontWeight: FontWeight.bold))), const SizedBox(width: 4), const Text("Product", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54))]),
                  Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)), child: const Text("#", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold))), const SizedBox(width: 4), const Text("Misc", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54))]),
                  Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.blueGrey.withOpacity(0.2), border: Border.all(color: Colors.blueGrey), borderRadius: BorderRadius.circular(4)), child: const Text("#", style: TextStyle(color: Colors.blueGrey, fontSize: 9, fontWeight: FontWeight.bold))), const SizedBox(width: 4), const Text("Other", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54))]),
                ],
              );`;

    content = content.split(oldLegend).join(newLegend);

    fs.writeFileSync(filename, content, 'utf-8');
    console.log("Updated " + filename);
}

['lib/screens/ceo_dashboard.dart', 'lib/screens/cofounder_dashboard.dart', 'lib/screens/dual_role_dashboard.dart', 'lib/screens/employee_dashboard.dart'].forEach(updateFile);
console.log("All files processed.");

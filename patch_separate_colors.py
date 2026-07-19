import re

def update_file(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Update the typeColor logic (handles both one-liners and multi-liners)
    # E.g. `else if (typeStr.contains('session') || typeStr.contains('meeting')) typeColor = Colors.purple;`
    content = re.sub(
        r"else\s+if\s*\(\s*typeStr\.contains\('session'\)\s*\|\|\s*typeStr\.contains\('meeting'\)\s*\)\s*typeColor\s*=\s*Colors\.purple;",
        "else if (typeStr.contains('active client')) typeColor = Colors.indigo;\n        else if (typeStr.contains('lead')) typeColor = Colors.purple;\n        else if (typeStr.contains('session')) typeColor = Colors.pink;",
        content
    )

    # For the wrapped one in ceo_dashboard
    content = re.sub(
        r"else\s+if\s*\(\s*typeStr\.contains\('session'\)\s*\|\|\s*typeStr\.contains\('meeting'\)\s*\)\n\s*typeColor\s*=\s*Colors\.purple;",
        "else if (typeStr.contains('active client'))\n                        typeColor = Colors.indigo;\n                      else if (typeStr.contains('lead'))\n                        typeColor = Colors.purple;\n                      else if (typeStr.contains('session'))\n                        typeColor = Colors.pink;",
        content
    )

    # 2. Update the Builder block
    # We'll use regex to match the new Builder we just added recently.
    # It contains `int videoCount = 0; ... int otherCount = 0;` up to `return Wrap(...);`
    
    old_builder = """                      int videoCount = 0;
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
                      }"""

    new_builder = """                      int videoCount = 0;
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
                      }"""
    
    content = content.replace(old_builder, new_builder)

    # Also replace the Wrap cells block
    old_cells = """                          if (videoCount > 0)
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
                            ),"""

    new_cells = """                          if (videoCount > 0)
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
                            ),"""
    
    content = content.replace(old_cells, new_cells)

    # 3. Replace the Legend
    old_legend = """              Wrap(
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
              ),"""

    new_legend = """              Wrap(
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
              ),"""
    
    content = content.replace(old_legend, new_legend)

    with open(filename, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"Updated {filename}")

update_file('lib/screens/ceo_dashboard.dart')
update_file('lib/screens/cofounder_dashboard.dart')
update_file('lib/screens/dual_role_dashboard.dart')
update_file('lib/screens/employee_dashboard.dart')

print("All files patched successfully.")

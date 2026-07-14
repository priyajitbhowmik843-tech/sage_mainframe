const fs = require('fs');
const path = require('path');

function patchFile(filepath) {
    let content = fs.readFileSync(filepath, 'utf8');

    // 1. Replace the AlertDialog wrapper with a brutalist Dialog
    const dialogStart = `            return AlertDialog(
              backgroundColor: SageColors.background,
              title: const Text("EDIT CLIENT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
              content: SingleChildScrollView(`;
    
    const dialogReplacement = `            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 700),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: SageColors.yellowAccentContainer,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(6, 6))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("EDIT CLIENT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5)),
                    const SizedBox(height: 20),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: SingleChildScrollView(`;
    
    content = content.replace(dialogStart, dialogReplacement);

    // 2. Fix the SwitchListTile logic for Marketing Commission
    const switchTarget = `                    SwitchListTile(
                      title: const Text("Marketing Commission (20%)", style: TextStyle(fontSize: 12)),
                      value: hasMarketingCommission,
                      onChanged: (v) => setState(() => hasMarketingCommission = v),
                      contentPadding: EdgeInsets.zero,
                    ),`;
    const switchReplacement = `                    SwitchListTile(
                      title: Text("Marketing Commission (20%)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: marketingExecutiveId == null ? Colors.grey : Colors.black)),
                      value: hasMarketingCommission && marketingExecutiveId != null,
                      onChanged: marketingExecutiveId == null ? null : (v) => setState(() => hasMarketingCommission = v),
                      activeColor: SageColors.primary,
                      contentPadding: EdgeInsets.zero,
                    ),`;
    content = content.replace(switchTarget, switchReplacement);

    // 3. Fix the Dropdown logic for Marketing Executive
    const dropdownTarget = `                      onChanged: (v) => setState(() => marketingExecutiveId = v),`;
    const dropdownReplacement = `                      onChanged: (v) => setState(() {
                        marketingExecutiveId = v;
                        if (v == null) hasMarketingCommission = false;
                      }),`;
    content = content.replace(dropdownTarget, dropdownReplacement);

    // 4. Replace the actions at the bottom of AlertDialog to fit the new Column structure
    const actionsTarget = `              ),
                            actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: SageColors.primary),
                  onPressed: () {`;
    
    const actionsReplacement = `              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("CANCEL", style: TextStyle(color: SageColors.primary, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SageColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Colors.black, width: 1.5),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: () {`;
    
    content = content.replace(actionsTarget, actionsReplacement);

    // 5. Close the row and column in the end
    const endTarget = `                  child: const Text("SAVE"),
                ),
              ],
            );`;
    const endReplacement = `                  child: const Text("SAVE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );`;
    content = content.replace(endTarget, endReplacement);

    fs.writeFileSync(filepath, content, 'utf8');
}

const baseDir = path.join(__dirname, 'lib', 'screens');
patchFile(path.join(baseDir, 'ceo_dashboard.dart'));
patchFile(path.join(baseDir, 'cofounder_dashboard.dart'));
console.log("Patched UI in both dashboards");

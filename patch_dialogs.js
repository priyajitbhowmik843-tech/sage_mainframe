const fs = require('fs');
const path = require('path');

function patchFile(filepath) {
    let content = fs.readFileSync(filepath, 'utf8');

    // 1. Add variables
    const varTarget = '    String? assignedVideographerId = c.assignedVideographerId;';
    const varReplacement = `    String serviceType = c.serviceType;
    bool hasMarketingCommission = c.hasMarketingCommission;
    String? marketingExecutiveId = c.marketingExecutiveId;
    String? assignedVideographerId = c.assignedVideographerId;`;
    content = content.replace(varTarget, varReplacement);

    // 2. Add UI elements just before packageType dropdown
    // Note: The original code has "DropdownButtonFormField<String>(\n                      value: packageType,"
    // We use a regex to match it safely.
    const uiRegex = /                    DropdownButtonFormField<String>\(\s*value: packageType,/;
    const uiReplacement = `                    DropdownButtonFormField<String>(
                      value: serviceType,
                      decoration: const InputDecoration(labelText: "Service Type"),
                      dropdownColor: Colors.white,
                      items: ['Marketing', 'E-Commerce', 'Video Production'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (v) => setState(() => serviceType = v ?? 'Marketing'),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile(
                      title: const Text("Marketing Commission (20%)", style: TextStyle(fontSize: 12)),
                      value: hasMarketingCommission,
                      onChanged: (v) => setState(() => hasMarketingCommission = v),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: marketingExecutiveId,
                      decoration: const InputDecoration(labelText: "Assigned Marketing Exec"),
                      dropdownColor: Colors.white,
                      items: [
                        const DropdownMenuItem(value: null, child: Text("None", style: TextStyle(fontSize: 12))),
                        ...context.read<AppState>().employees.where((e) => e.role.toLowerCase().contains('marketing')).map(
                          (e) => DropdownMenuItem(value: e.id, child: Text(e.name, style: const TextStyle(fontSize: 12)))
                        ),
                      ],
                      onChanged: (v) => setState(() => marketingExecutiveId = v),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: packageType,`;
    content = content.replace(uiRegex, uiReplacement);

    // 3. Add to updateClient call
    const updateTarget = '                      packageType: packageType,';
    const updateReplacement = `                      serviceType: serviceType,
                      hasMarketingCommission: hasMarketingCommission,
                      marketingExecutiveId: marketingExecutiveId,
                      packageType: packageType,`;
    content = content.replace(updateTarget, updateReplacement);

    fs.writeFileSync(filepath, content, 'utf8');
}

const baseDir = path.join(__dirname, 'lib', 'screens');
patchFile(path.join(baseDir, 'ceo_dashboard.dart'));
patchFile(path.join(baseDir, 'cofounder_dashboard.dart'));
console.log("Patched both dashboards");

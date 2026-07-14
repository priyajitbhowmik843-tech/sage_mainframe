import os
import re

def patch_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Add variables
    var_target = r'    String\? assignedVideographerId = c\.assignedVideographerId;'
    var_replacement = '''    String serviceType = c.serviceType;
    bool hasMarketingCommission = c.hasMarketingCommission;
    String? marketingExecutiveId = c.marketingExecutiveId;
    String? assignedVideographerId = c.assignedVideographerId;'''
    content = re.sub(var_target, var_replacement, content)

    # 2. Add UI elements just before packageType dropdown
    ui_target = r'                    DropdownButtonFormField<String>\(\s*value: packageType,'
    ui_replacement = '''                    DropdownButtonFormField<String>(
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
                      value: packageType,'''
    content = re.sub(ui_target, ui_replacement, content)

    # 3. Add to updateClient call
    update_target = r'                      packageType: packageType,'
    update_replacement = '''                      serviceType: serviceType,
                      hasMarketingCommission: hasMarketingCommission,
                      marketingExecutiveId: marketingExecutiveId,
                      packageType: packageType,'''
    content = re.sub(update_target, update_replacement, content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

base_dir = r"c:\Users\Priyajit Bhowmik\Downloads\n sage os\sage os\sage os\sage_mainframe\lib\screens"
patch_file(os.path.join(base_dir, "ceo_dashboard.dart"))
patch_file(os.path.join(base_dir, "cofounder_dashboard.dart"))

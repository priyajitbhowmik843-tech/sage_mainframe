import os

cf_file = 'cofounder_dashboard.dart'
snip_file = 'snippet.dart'

with open(cf_file, 'r', encoding='utf-8') as f:
    lines = f.readlines()

with open(snip_file, 'r', encoding='utf-8') as f:
    snippet_lines = f.readlines()

start_idx = -1
end_idx = -1

for i, line in enumerate(lines):
    if '...AppState.personas.asMap().entries.map((entry) {' in line and start_idx == -1:
        start_idx = i
    if 'String _taskSubTab =' in line and end_idx == -1:
        end_idx = i - 3 # To go before the return and '}' of the _buildPersonnelTab
        break

if start_idx != -1 and end_idx != -1:
    new_lines = lines[:start_idx] + snippet_lines + lines[end_idx:]
    with open(cf_file, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    print('Replaced successfully')
else:
    print('Indices not found:', start_idx, end_idx)

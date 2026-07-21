import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';
import '../models/models.dart';

class TeamTasksTab extends StatefulWidget {
  final Color glowColor;
  final Color secondaryColor;
  final bool readOnly;

  const TeamTasksTab({
    super.key,
    required this.glowColor,
    required this.secondaryColor,
    this.readOnly = false,
  });

  @override
  State<TeamTasksTab> createState() => _TeamTasksTabState();
}

class _TeamTasksTabState extends State<TeamTasksTab> {
  DateTime _selectedDate = DateTime.now();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _showForm = false;
  String? _selectedAssignee;
  DateTime _deadline = DateTime.now();

  Map<String, bool> _selectedClients = {};
  Map<String, TextEditingController> _clientInstructions = {};

  List<DateTime> _weekDays() => List.generate(
    14,
    (i) =>
        DateTime.now().subtract(const Duration(days: 3)).add(Duration(days: i)),
  );

  String _monthName(int m) => [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ][m - 1];
  String _dayName(int d) => ['M', 'T', 'W', 'T', 'F', 'S', 'S'][d - 1];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    for (var ctrl in _clientInstructions.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  bool _isVideoEditor(List<Map<String, String>> assignees) {
    if (_selectedAssignee == null) return false;
    final a = assignees.firstWhere(
      (e) => e['id'] == _selectedAssignee,
      orElse: () => {},
    );
    return a['role'] == 'Video Editor';
  }

  bool _isContentEditor(List<Map<String, String>> assignees) {
    if (_selectedAssignee == null) return false;
    final a = assignees.firstWhere(
      (e) => e['id'] == _selectedAssignee,
      orElse: () => {},
    );
    return a['role'] == 'Content';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final assignees = <Map<String, String>>[
      ...state.employees.map(
        (e) => {'id': e.id, 'name': e.name, 'type': 'EMPLOYEE', 'role': e.role},
      ),
      {
        'id': 'COF-RIT-001',
        'name': 'Ritam',
        'type': 'CO-FOUNDER',
        'role': 'Content',
      },
      {
        'id': 'COF-PRI-001',
        'name': 'Priyajit',
        'type': 'CO-FOUNDER',
        'role': 'Video Editor',
      },
    ];

    final clients = state.clients
        .where((c) => c.status == 'Active' || c.status == 'Retained')
        .toList();

    for (var c in clients) {
      _selectedClients.putIfAbsent(c.id, () => false);
      _clientInstructions.putIfAbsent(c.id, () => TextEditingController());
    }
    _selectedClients.putIfAbsent('OTHER', () => false);
    _clientInstructions.putIfAbsent('OTHER', () => TextEditingController());

    final allTasks = state.tasks;
    final selectedTasks = state.allTasksForDate(_selectedDate);

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // ── Calendar strip ──
        TerminalPanel(
          title:
              '${_monthName(_selectedDate.month)} ${_selectedDate.year}  //  TASK CALENDAR',
          glowColor: widget.glowColor,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _weekDays().map((day) {
                final isSelected =
                    day.day == _selectedDate.day &&
                    day.month == _selectedDate.month;
                final hasTask = allTasks.any(
                  (t) =>
                      t.deadline.day == day.day &&
                      t.deadline.month == day.month &&
                      t.deadline.year == day.year,
                );
                final isToday =
                    day.day == DateTime.now().day &&
                    day.month == DateTime.now().month;

                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 46,
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? widget.glowColor.withValues(alpha: 0.15)
                          : (isToday
                                ? widget.secondaryColor.withValues(alpha: 0.07)
                                : SageColors.surfaceContainerLowest),
                      border: Border.all(
                        color: isSelected
                            ? widget.glowColor
                            : (hasTask
                                  ? SageColors.tertiary
                                  : (isToday
                                        ? widget.secondaryColor
                                        : SageColors.outlineVariant)),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? SageColors.neonGlow(
                              widget.glowColor,
                              spread: 1,
                              blur: 8,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _dayName(day.weekday),
                          style: TextStyle(
                            fontSize: 9,
                            color: isSelected
                                ? widget.glowColor
                                : SageColors.outline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? widget.glowColor
                                : (isToday
                                      ? widget.secondaryColor
                                      : SageColors.onSurface),
                            shadows: isSelected
                                ? SageColors.neonTextGlow(widget.glowColor)
                                : (isToday
                                      ? SageColors.neonTextGlow(
                                              widget.secondaryColor,
                                            )
                                            .map(
                                              (s) => Shadow(
                                                color: s.color.withValues(
                                                  alpha: 0.5,
                                                ),
                                                blurRadius: s.blurRadius,
                                              ),
                                            )
                                            .toList()
                                      : null),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasTask
                                ? SageColors.tertiary
                                : Colors.transparent,
                            boxShadow: hasTask
                                ? SageColors.neonGlow(
                                    SageColors.tertiary,
                                    spread: 1,
                                    blur: 4,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: NeonText(
                text:
                    'TEAM TASKS  //  ${_selectedDate.toString().substring(0, 10)}',
                style: const TextStyle(fontSize: 10, letterSpacing: 2),
                glowColor: widget.glowColor,
              ),
            ),
            if (!widget.readOnly)
              _NeonActionButtonLocal(
                label: _showForm ? 'CANCEL' : '+ NEW TASK',
                color: widget.glowColor,
                onTap: () => setState(() => _showForm = !_showForm),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (_showForm && !widget.readOnly) ...[
          TerminalPanel(
            title: 'DISPATCH TASK',
            glowColor: widget.glowColor,
            headerColor: widget.glowColor.withValues(alpha: 0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _styledDropdown(
                  value: _selectedAssignee,
                  label: 'Assign To',
                  items: assignees,
                  onChanged: (v) => setState(() => _selectedAssignee = v),
                ),
                const SizedBox(height: 10),

                if (_isVideoEditor(assignees) ||
                    _isContentEditor(assignees)) ...[
                  Text(
                    'SELECT CLIENTS',
                    style: TextStyle(color: widget.glowColor, fontSize: 10),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView(
                      shrinkWrap: true,
                      children:
                          clients.map((c) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CheckboxListTile(
                                  title: Text(
                                    c.name,
                                    style: const TextStyle(
                                      color: SageColors.onSurface,
                                      fontSize: 12,
                                    ),
                                  ),
                                  value: _selectedClients[c.id],
                                  onChanged: (v) => setState(
                                    () => _selectedClients[c.id] = v ?? false,
                                  ),
                                  activeColor: widget.glowColor,
                                  dense: true,
                                ),
                                if (_selectedClients[c.id] == true &&
                                    _isContentEditor(assignees))
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 32,
                                      right: 16,
                                      bottom: 8,
                                    ),
                                    child: SageTextField(
                                      controller: _clientInstructions[c.id]!,
                                      label:
                                          'Instructions / Theme (e.g. Carousel)',
                                    ),
                                  ),
                              ],
                            );
                          }).toList()..add(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CheckboxListTile(
                                  title: const Text(
                                    'Other (Misc Task)',
                                    style: TextStyle(
                                      color: SageColors.onSurface,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  value: _selectedClients['OTHER'],
                                  onChanged: (v) => setState(
                                    () =>
                                        _selectedClients['OTHER'] = v ?? false,
                                  ),
                                  activeColor: widget.glowColor,
                                  dense: true,
                                ),
                                if (_selectedClients['OTHER'] == true)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 32,
                                      right: 16,
                                      bottom: 8,
                                    ),
                                    child: SageTextField(
                                      controller: _clientInstructions['OTHER']!,
                                      label:
                                          'Custom Task Description / Instructions',
                                    ),
                                  ),
                              ],
                            ),
                          ),
                    ),
                  ),
                ] else ...[
                  SageTextField(controller: _titleCtrl, label: 'Task Title'),
                  const SizedBox(height: 10),
                  SageTextField(
                    controller: _descCtrl,
                    label: 'Description',
                    maxLines: 3,
                  ),
                ],
                const SizedBox(height: 10),

                _datePicker(context),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: _NeonActionButtonLocal(
                    label: 'DISPATCH TASK',
                    color: widget.glowColor,
                    onTap: () async {
                      if (_selectedAssignee == null) return;
                      bool isVideo = _isVideoEditor(assignees);
                      bool isContent = _isContentEditor(assignees);

                      if (isVideo || isContent) {
                        for (var c in clients) {
                          if (_selectedClients[c.id] == true) {
                            String title = isVideo
                                ? 'Video for ${c.name}'
                                : 'Post/Carousel for ${c.name}';
                            String instructions =
                                _clientInstructions[c.id]?.text ?? '';

                            await context.read<AppState>().assignTask(
                              title: title,
                              description: instructions,
                              assignedTo: _selectedAssignee!,
                              deadline: _deadline,
                              clientId: c.id,
                              taskType: isVideo ? 'Video' : 'Content',
                              instructions: instructions,
                            );
                          }
                        }
                        if (_selectedClients['OTHER'] == true) {
                          String instructions =
                              _clientInstructions['OTHER']?.text ?? '';
                          if (instructions.isNotEmpty) {
                            await context.read<AppState>().assignTask(
                              title: 'Miscellaneous Task',
                              description: instructions,
                              assignedTo: _selectedAssignee!,
                              deadline: _deadline,
                              taskType: 'Misc',
                              instructions: instructions,
                            );
                          }
                        }
                      } else {
                        final err = await context.read<AppState>().assignTask(
                          title: _titleCtrl.text,
                          description: _descCtrl.text,
                          assignedTo: _selectedAssignee!,
                          deadline: _deadline,
                        );
                        if (err != null && mounted)
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(err)));
                      }

                      setState(() {
                        _showForm = false;
                        _selectedAssignee = null;
                        _selectedDate = _deadline;
                        for (var key in _selectedClients.keys) {
                          _selectedClients[key] = false;
                        }
                        for (var ctrl in _clientInstructions.values) {
                          ctrl.clear();
                        }
                      });
                      _titleCtrl.clear();
                      _descCtrl.clear();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        ...selectedTasks.map(
          (t) => _TaskTileLocal(task: t, assignees: assignees),
        ),
      ],
    );
  }

  Widget _datePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _deadline,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) setState(() => _deadline = picked);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SageColors.surfaceContainerLowest,
          border: Border.all(
            color: widget.glowColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: widget.glowColor,
              size: 14,
              shadows: SageColors.neonTextGlow(widget.glowColor)
                  .map((s) => Shadow(color: s.color, blurRadius: s.blurRadius))
                  .toList(),
            ),
            const SizedBox(width: 8),
            Text(
              'DEADLINE: ${_deadline.toString().substring(0, 10)}',
              style: TextStyle(
                color: widget.glowColor,
                fontSize: 12,
                shadows: SageColors.neonTextGlow(widget.glowColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _styledDropdown({
    required String? value,
    required String label,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      dropdownColor: SageColors.surfaceContainerHigh,
      style: const TextStyle(color: SageColors.onSurface, fontSize: 12),
      items: items
          .map(
            (a) => DropdownMenuItem(
              value: a['id'],
              child: Text(
                '${a['name']}  (${a['type']})',
                style: const TextStyle(
                  color: SageColors.onSurface,
                  fontSize: 12,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _NeonActionButtonLocal extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _NeonActionButtonLocal({
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    bool isPrimary =
        color == SageColors.secondary || color == SageColors.tertiary;
    Color bgColor = isPrimary ? color : Colors.transparent;
    Color textColor = isPrimary ? SageColors.background : color;
    Color borderColor = isPrimary ? Colors.transparent : color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _TaskTileLocal extends StatelessWidget {
  final Task task;
  final List<Map<String, String>> assignees;
  const _TaskTileLocal({required this.task, required this.assignees});

  @override
  Widget build(BuildContext context) {
    final t = task;
    final assigneeName =
        assignees.firstWhere(
          (a) => a['id'] == t.assignedTo,
          orElse: () => {'name': t.assignedTo},
        )['name'] ??
        t.assignedTo;
    final overdue = !t.isCompleted && t.deadline.isBefore(DateTime.now());
    final borderColor = overdue
        ? SageColors.error
        : (t.isCompleted ? SageColors.tertiary : SageColors.outlineVariant);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: SageColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: (overdue || t.isCompleted)
            ? SageColors.neonGlow(borderColor, spread: 1, blur: 6)
            : null,
      ),
      child: Row(
        children: [
          // Checkbox area
          Container(
            width: 48,
            alignment: Alignment.center,
            child: Checkbox(
              value: t.isCompleted,
              onChanged: (_) => context.read<AppState>().toggleTask(t.id),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: t.isCompleted
                          ? SageColors.outline
                          : SageColors.onSurface,
                      decoration: t.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      shadows: t.isCompleted
                          ? null
                          : SageColors.neonTextGlow(SageColors.onSurface)
                                .map(
                                  (s) => Shadow(
                                    color: s.color.withValues(alpha: 0.2),
                                    blurRadius: s.blurRadius,
                                  ),
                                )
                                .toList(),
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (t.description.isNotEmpty) ...[
                    Text(
                      t.description,
                      style: const TextStyle(
                        color: SageColors.outlineVariant,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                  Text(
                    '→ $assigneeName',
                    style: const TextStyle(
                      color: SageColors.primary,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    'DUE: ${t.deadline.toString().substring(0, 10)}',
                    style: TextStyle(
                      color: overdue ? SageColors.error : SageColors.outline,
                      fontSize: 10,
                      shadows: overdue
                          ? SageColors.neonTextGlow(SageColors.error)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: overdue
                ? StatusBadge(label: 'OVERDUE', color: SageColors.error)
                : (t.isCompleted
                      ? StatusBadge(label: 'DONE', color: SageColors.tertiary)
                      : const SizedBox()),
          ),
        ],
      ),
    );
  }
}

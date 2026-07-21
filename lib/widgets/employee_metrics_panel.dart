import 'package:sage_mainframe/widgets/sage_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../models/models.dart';

class EmployeeMetricsPanel extends StatelessWidget {
  final Employee employee;
  final AppState state;
  final bool isVideo;
  final bool isVideoEditorPerVideo;
  final bool isEcomExec;
  final bool isGraphicsEditor;
  final bool isME;
  const EmployeeMetricsPanel({
    Key? key,
    required this.employee,
    required this.state,
    required this.isVideo,
    required this.isVideoEditorPerVideo,
    required this.isEcomExec,
    required this.isGraphicsEditor,
    required this.isME,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the employee is salaried
    bool isSalary =
        employee.videoEditorPayType == 'Salary' || employee.monthlySalary > 0;

    // Roles
    bool roleGraphics = employee.hasRole('graphic');
    bool roleVideoEditor = employee.hasRole('video editor');
    bool roleVideographer =
        employee.hasRole('videographer') ||
        employee.hasRole('videographer/cinematographer');

    // Dual dashboard check
    bool isDual = roleVideoEditor && roleVideographer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (roleGraphics) _buildGraphicsEditorMetrics(context),
        if (roleVideoEditor) _buildVideoEditorMetrics(context),
        if (roleVideographer) _buildVideographerMetrics(context),

        // Render fallback legacy logic for other roles
        if (!roleGraphics && !roleVideoEditor && !roleVideographer)
          _buildLegacyMetrics(context),
      ],
    );
  }

  Widget _buildGraphicsEditorMetrics(BuildContext context) {
    final now = DateTime.now();
    DateTime actualStart = DateTime(now.year, now.month, 1);
    if (now.year == 2026 && now.month == 7) {
      actualStart = DateTime(2026, 7, 20);
    }

    List<Widget> dailyWidgets = [];
    double totalDeduction = 0;

    final today = DateTime(now.year, now.month, now.day);

    for (
      DateTime d = actualStart;
      d.isBefore(today.add(const Duration(days: 1)));
      d = d.add(const Duration(days: 1))
    ) {
      final tasksForDay = state.tasks
          .where(
            (t) =>
                t.assignedTo == employee.id &&
                (t.taskType?.toLowerCase() == 'design') &&
                t.deadline.year == d.year &&
                t.deadline.month == d.month &&
                t.deadline.day == d.day,
          )
          .toList();

      int rejectedOrManuallyMissed = tasksForDay.where((t) {
        if (t.isMissed == true || t.rejectedAt != null) return true;
        final deadlinePlus24 = t.deadline.add(const Duration(hours: 24));
        if (t.submittedAt != null) {
          return t.submittedAt!.isAfter(deadlinePlus24);
        } else {
          if (t.isCompleted) return false;
          return DateTime.now().isAfter(deadlinePlus24);
        }
      }).length;

      int totalMissedForDay = rejectedOrManuallyMissed;
      if (totalMissedForDay > 0) {
        double deductionForDay = totalMissedForDay * 20.0;
        totalDeduction += deductionForDay;

        dailyWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(d),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Missed: ${totalMissedForDay} (-₹${deductionForDay.toStringAsFixed(0)})",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return SageExpansionTile(
      title: const Text(
        "Graphics Editor Metrics",
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "TOTAL DEDUCTION",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            Text(
              "-₹${totalDeduction.toStringAsFixed(0)}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...dailyWidgets,
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: actualStart,
              lastDate: now,
            );
            if (selectedDate != null) {
              _showDeductionDialog(context, selectedDate);
            }
          },
          child: const Text("Add Deduction"),
        ),
      ],
    );
  }

  void _showDeductionDialog(BuildContext context, DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final tasks = state.tasks
                .where(
                  (t) =>
                      t.assignedTo == employee.id &&
                      (t.taskType?.toLowerCase() == 'design') &&
                      t.deadline.year == selectedDate.year &&
                      t.deadline.month == selectedDate.month &&
                      t.deadline.day == selectedDate.day,
                )
                .toList();

            return AlertDialog(
              title: Text(
                "Tasks for ${DateFormat('MMM dd, yyyy').format(selectedDate)}",
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: tasks.isEmpty
                    ? const Text("No tasks assigned for this date.")
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final t = tasks[index];
                          return CheckboxListTile(
                            title: Text(t.title),
                            subtitle: Text(
                              t.rejectedAt != null
                                  ? "Rejected by CEO"
                                  : "Assigned",
                            ),
                            value: t.isMissed || t.rejectedAt != null,
                            onChanged: t.rejectedAt != null
                                ? null
                                : (val) {
                                    FirebaseFirestore.instance
                                        .collection('tasks')
                                        .doc(t.id)
                                        .update({'isMissed': val == true});
                                    setState(() {
                                      t.isMissed = val == true;
                                    });
                                  },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildVideoEditorMetrics(BuildContext context) {
    List<Widget> children = [];

    if (!isVideoEditorPerVideo) {
      // Salaried: Show daily log
      final now = DateTime.now();
      final currentDay = now.day;

      List<Widget> dailyWidgets = [];
      for (int day = 1; day <= currentDay; day++) {
        final date = DateTime(now.year, now.month, day);
        final tasksForDay = state.tasks
            .where(
              (t) =>
                  t.assignedTo == employee.id &&
                  t.taskType == 'video' &&
                  t.isCompleted &&
                  t.completedAt != null &&
                  t.completedAt!.year == date.year &&
                  t.completedAt!.month == date.month &&
                  t.completedAt!.day == date.day,
            )
            .toList();

        if (tasksForDay.isNotEmpty) {
          dailyWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy').format(date),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Completed: ${tasksForDay.length}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }

      children.add(
        const Text(
          "DAILY LOG",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      );
      children.add(const SizedBox(height: 8));
      if (dailyWidgets.isEmpty) {
        children.add(
          const Text(
            "No completed videos this month.",
            style: const TextStyle(fontSize: 11),
          ),
        );
      } else {
        children.addAll(dailyWidgets);
      }
    } else {
      // Per Video: Show unpaid video edits with client name
      final unpaidEdits = state.tasks
          .where(
            (t) =>
                t.assignedTo == employee.id &&
                t.taskType == 'video' &&
                t.isCompleted &&
                !t.isPaidToVideoEditor,
          )
          .toList();

      children.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "UNPAID VIDEO EDITS",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            Text(
              "${unpaidEdits.length}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
      children.add(const SizedBox(height: 8));

      if (unpaidEdits.isEmpty) {
        children.add(
          const Text("No unpaid videos.", style: const TextStyle(fontSize: 11)),
        );
      } else {
        children.addAll(
          unpaidEdits.map((t) {
            final client = state.clients
                .where((c) => c.id == t.clientId)
                .firstOrNull;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(
                    Icons.video_library,
                    size: 12,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          client?.name ?? 'Unknown Client',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    t.completedAt != null
                        ? DateFormat('MMM dd').format(t.completedAt!)
                        : '',
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
            );
          }),
        );
      }
    }

    return SageExpansionTile(
      title: const Text(
        "Video Editor Metrics",
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: children,
    );
  }

  Widget _buildVideographerMetrics(BuildContext context) {
    // Pending sessions
    final pendingSessions = state.tasks
        .where(
          (t) =>
              t.assignedTo == employee.id &&
              (t.taskType == 'Session' ||
                  t.taskType == 'Miscellaneous Session' ||
                  t.taskType == 'session' ||
                  t.taskType == 'miscellaneous session') &&
              t.isCompleted &&
              !t.isPaidToVideographer,
        )
        .toList();

    double totalPayout = 0;

    List<Widget> sessionWidgets = pendingSessions.map((t) {
      final client = state.clients.where((c) => c.id == t.clientId).firstOrNull;
      final rate = client?.sessionRate ?? 0;
      totalPayout += rate;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client?.name ?? 'Unknown Client',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    DateFormat('dd MMM yyyy').format(t.deadline),
                    style: const TextStyle(fontSize: 9, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Text(
              "₹${rate.toStringAsFixed(0)}",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }).toList();

    return SageExpansionTile(
      title: const Text(
        "Videographer Metrics",
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "PENDING SESSIONS PAYMENTS",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            Text(
              "₹${totalPayout.toStringAsFixed(0)}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...sessionWidgets,
      ],
    );
  }

  Widget _buildLegacyMetrics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isEcomExec) ...[
          Text(
            "TOTAL SKUS PAID: ${employee.skusPaid}",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            "PER SKU RATE: ?${employee.perSkuRate.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (!isVideo &&
            !isVideoEditorPerVideo &&
            !isEcomExec &&
            !isGraphicsEditor) ...[
          if (isME) ...[
            const Text(
              "COMMISSION BASED",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              "Paid Till: ${employee.paidMonths.isEmpty ? 'None' : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'].lastWhere((m) => employee.paidMonths.contains(m), orElse: () => employee.paidMonths.last)}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ] else ...[
            Text(
              "SALARY: ?${employee.monthlySalary.toStringAsFixed(0)} / mo",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              "Paid Till: ${employee.paidMonths.isEmpty ? 'None' : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'].lastWhere((m) => employee.paidMonths.contains(m), orElse: () => employee.paidMonths.last)}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

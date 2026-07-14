import 'executive_profile_dashboard.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sage_mainframe/state/app_state.dart';
import 'package:sage_mainframe/theme/app_theme.dart';
import 'package:sage_mainframe/widgets/common_widgets.dart';
import 'package:sage_mainframe/models/models.dart';
import 'package:sage_mainframe/main.dart';
import 'package:sage_mainframe/screens/employee_dashboard.dart';
import 'package:sage_mainframe/widgets/income_combo_chart.dart';
import 'package:sage_mainframe/widgets/forecast_chart.dart';
import 'package:sage_mainframe/widgets/deficit_line_chart.dart';
import 'package:sage_mainframe/widgets/ecom_ledger_dialog.dart';
import 'package:sage_mainframe/services/invoice_service.dart';

class CeoDashboard extends StatefulWidget {
  const CeoDashboard({super.key});
  @override
  State<CeoDashboard> createState() => _CeoDashboardState();
}

class _CeoDashboardState extends State<CeoDashboard> {
  int _tab =
      0; // 0: Home, 1: Clients, 2: Personnel/Team, 3: Tasks/Activity, 4: Finance
  int _tabKeyCounter = 0;
  PageStorageBucket _bucket = PageStorageBucket();
  DateTime _selectedDate = DateTime.now();
  late PageController _pageController;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showPaymentDialog(BuildContext context, Client c, int month) {
    String paymentMethod = 'UPI';
    DateTime paymentDate = DateTime.now();
    TextEditingController skuCtrl = TextEditingController(text: "0");
    TextEditingController dupSkuCtrl = TextEditingController(text: "0");
    TextEditingController catCtrl = TextEditingController(text: "0");
    TextEditingController discountCtrl = TextEditingController(text: "0");

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: SageColors.background,
              title: Text(
                "Record Payment for ${c.name} - Month $month",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: paymentMethod,
                      items: ['UPI', 'Bank Transfer', 'Cash']
                          .map(
                            (m) => DropdownMenuItem(value: m, child: Text(m)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => paymentMethod = v!),
                      decoration: const InputDecoration(
                        labelText: "Payment Method",
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (d != null) setState(() => paymentDate = d);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: "Date",
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                paymentDate.toString().substring(0, 10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: discountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Discount Amount (\u20B9)",
                        hintText: "0",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (c.serviceType.toLowerCase().contains('commerce') &&
                        c.ecomPaymentType == 'Per SKU') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: skuCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Number of SKUs",
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: dupSkuCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Number of Duplicate SKUs",
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: catCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Number of Catalogues",
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Total Amount: \u20B9${((double.tryParse(skuCtrl.text) ?? 0) * c.clientSkuRate) + ((double.tryParse(dupSkuCtrl.text) ?? 0) * c.clientDuplicateSkuRate) + ((double.tryParse(catCtrl.text) ?? 0) * c.clientCatalogueRate)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    "CANCEL",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SageColors.primary,
                  ),
                  onPressed: () {
                    double? amountOverride;
                    if (c.serviceType.toLowerCase().contains('commerce') &&
                        c.ecomPaymentType == 'Per SKU') {
                      amountOverride =
                          ((double.tryParse(skuCtrl.text) ?? 0) *
                              c.clientSkuRate) +
                          ((double.tryParse(dupSkuCtrl.text) ?? 0) *
                              c.clientDuplicateSkuRate) +
                          ((double.tryParse(catCtrl.text) ?? 0) *
                              c.clientCatalogueRate);
                    }
                    double discountAmount =
                        double.tryParse(discountCtrl.text) ?? 0;
                    context.read<AppState>().toggleClientPaidMonth(
                      c.id,
                      month,
                      paymentMethod,
                      paymentDate,
                      amountOverride,
                      discountAmount,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text("SAVE PAYMENT"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddOnDialog(BuildContext context, Client c) {
    String selectedType = 'Video Production';
    final amountCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: SageColors.background,
          title: const Text(
            "Add New Add-On",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  items: ['Video Production', 'Website/App', 'Miscellaneous']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedType = v!),
                  decoration: const InputDecoration(labelText: "Type"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount (\u20B9)",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionCtrl,
                  decoration: const InputDecoration(
                    labelText: "Custom Description (Optional)",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "CANCEL",
                style: TextStyle(color: Colors.black54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SageColors.primary,
              ),
              onPressed: () {
                final double amount = double.tryParse(amountCtrl.text) ?? 0;
                if (amount <= 0) return;

                final addOn = ClientAddOn(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: selectedType,
                  amount: amount,
                  description: descriptionCtrl.text.trim(),
                  isBilled: false,
                  isPaid: false,
                );
                context.read<AppState>().addClientAddOn(c.id, addOn);
                Navigator.pop(ctx);
              },
              child: const Text("ADD"),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOnPaymentDialog(
    BuildContext context,
    Client c,
    ClientAddOn addOn,
  ) {
    String paymentMethod = 'UPI';
    DateTime paymentDate = DateTime.now();
    bool isPartial = false;
    final partialCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: SageColors.background,
          title: Text(
            "Pay Add-On: ${addOn.type}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: paymentMethod,
                  items: ['UPI', 'Bank Transfer', 'Cash']
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setState(() => paymentMethod = v!),
                  decoration: const InputDecoration(
                    labelText: "Payment Method",
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (d != null) setState(() => paymentDate = d);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Date",
                      border: OutlineInputBorder(),
                    ),
                    child: Text(paymentDate.toString().substring(0, 10)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Amount: \u20B9${addOn.amount.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        Switch(
                          value: isPartial,
                          onChanged: (val) {
                            setState(() => isPartial = val);
                          },
                          activeColor: SageColors.primary,
                        ),
                        const Text("Partial?", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                if (isPartial) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: partialCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Partial Amount (\u20B9)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "CANCEL",
                style: TextStyle(color: Colors.black54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SageColors.primary,
              ),
              onPressed: () {
                double? amt;
                if (isPartial) {
                  amt = double.tryParse(partialCtrl.text);
                  if (amt == null || amt <= 0) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text("Enter a valid amount")),
                    );
                    return;
                  }
                }
                
                context.read<AppState>().payClientAddOn(
                  c.id,
                  addOn.id,
                  paymentMethod,
                  paymentDate,
                  amountPaid: amt,
                );
                Navigator.pop(ctx);
              },
              child: const Text("SAVE PAYMENT"),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeadMeetingDialog(BuildContext context, String leadId) {
    List<String> assignees = [];
    bool isPhysical = true;
    final commentsCtrl = TextEditingController();
    DateTime? selectedDate = DateTime.now();
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final state = context.watch<AppState>();
          final lead = state.clients.where((c) => c.id == leadId).firstOrNull;
          if (lead == null) return const SizedBox();

          return Dialog(
            backgroundColor: SageColors.background,
            child: Container(
              padding: const EdgeInsets.all(20),
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "SCHEDULE LEAD MEETING",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "Lead: ${lead.name}",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  SageMultiSelectDropdown<Map<String, String>>(
                    selectedItems: (() {
                      final List<Map<String, String>> options = [
                        {'id': 'CEO-SOH-001', 'name': 'CEO Sohini'},
                        {'id': 'COF-PRI-001', 'name': 'CFO Priyajit'},
                        {'id': 'COF-RIT-001', 'name': 'CFO Ritam'},
                      ];
                      options.addAll(
                        state.employees
                            .where((e) => e.hasRole('marketing'))
                            .map((e) => {'id': e.id, 'name': e.name}),
                      );
                      return options
                          .where((e) => assignees.contains(e['id']))
                          .toList();
                    })(),
                    items: (() {
                      final List<Map<String, String>> options = [
                        {'id': 'CEO-SOH-001', 'name': 'CEO Sohini'},
                        {'id': 'COF-PRI-001', 'name': 'CFO Priyajit'},
                        {'id': 'COF-RIT-001', 'name': 'CFO Ritam'},
                      ];
                      options.addAll(
                        state.employees
                            .where((e) => e.hasRole('marketing'))
                            .map((e) => {'id': e.id, 'name': e.name}),
                      );
                      return options;
                    })(),
                    labelBuilder: (item) => item['name']!,
                    labelText: "Assign To (Select multiple)",
                    onChanged: (v) =>
                        setS(() => assignees = v.map((e) => e['id']!).toList()),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                            );
                            if (d != null) setS(() => selectedDate = d);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Date",
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              selectedDate?.toString().substring(0, 10) ??
                                  "Select Date",
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (t != null) setS(() => selectedTime = t);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: "Time",
                              border: OutlineInputBorder(),
                            ),
                            child: Text(selectedTime.format(context)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text(
                      isPhysical ? "Physical Meeting" : "Digital Meeting",
                      style: const TextStyle(fontSize: 14),
                    ),
                    value: isPhysical,
                    onChanged: (v) => setS(() => isPhysical = v),
                    activeColor: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  SageTextField(
                    controller: commentsCtrl,
                    label: "Comments",
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          "CANCEL",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SageColors.primary,
                        ),
                        onPressed: (assignees.isEmpty || selectedDate == null)
                            ? null
                            : () async {
                                final finalDeadline = DateTime(
                                  selectedDate!.year,
                                  selectedDate!.month,
                                  selectedDate!.day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                );
                                final meetingMode = isPhysical
                                    ? "[Physical]"
                                    : "[Digital]";

                                context.read<AppState>().addClientFollowUp(
                                  leadId,
                                  selectedDate!.toString().substring(0, 10),
                                );

                                for (final assignee in assignees) {
                                  await context.read<AppState>().assignTask(
                                    title: "Lead Meeting - ${lead.name}",
                                    description:
                                        "$meetingMode ${commentsCtrl.text}",
                                    assignedTo: assignee,
                                    deadline: finalDeadline,
                                    taskType: 'Lead Meeting',
                                    clientId: leadId,
                                  );
                                }
                                Navigator.pop(ctx);
                              },
                        child: const Text("SCHEDULE & FOLLOW-UP"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final persona = state.activePersona;

    return WillPopScope(
      onWillPop: () async {
        if (_tab != 0) {
          _switchTab(0);
          return false;
        }
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          // Reset calendar when tapping anywhere outside the calendar selection
          setState(() {
            _selectedCalendarDate = null;
            _calendarMonth = DateTime(
              DateTime.now().year,
              DateTime.now().month,
              1,
            );
          });
        },
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: SageColors.background,
          body: Stack(
            children: [
              // Header Background Color Block
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: _getHeaderColor(),
                    border: const Border(
                      bottom: BorderSide(color: Colors.black, width: 1.5),
                    ),
                  ),
                ),
              ),

              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Top Custom Header Row
                    _buildTopHeader(context, persona),

                    // Active Page Content
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          if (_tab != index) {
                            setState(() {
                              _tab = index;
                              _tabKeyCounter++;
                              _bucket = PageStorageBucket();
                              _clientExpControllers.clear();
                              _empExpControllers.clear();
                              _personaExpControllers.clear();
                              _clientSubTab = 'ACTIVE';
                              _taskSubTab = 'CALENDAR';
                              if (index == 3) {
                                _calendarMonth = DateTime.now();
                                _selectedCalendarDate = null;
                              }
                            });
                          }
                        },
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 100),
                            child: _buildHomeTab(),
                          ),
                          SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 100),
                            child: _buildClientsTab(),
                          ),
                          SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 100),
                            child: _buildPersonnelTab(),
                          ),
                          SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 100),
                            child: _buildTasksTab(),
                          ),
                          SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 100),
                            child: _buildFinanceTab(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Floating Bottom Navigation Bar (5 icons)
              Positioned(
                bottom: 20,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: SageColors.yellowAccent,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.black, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBottomIcon(0, Icons.home_outlined, Icons.home),
                      _buildBottomIcon(
                        1,
                        Icons.business_outlined,
                        Icons.business,
                        badgeCount: state.clients
                            .where((c) => !c.isApprovedByCeo)
                            .length,
                      ),
                      _buildBottomIcon(2, Icons.badge_outlined, Icons.badge),
                      _buildBottomIcon(
                        3,
                        Icons.assignment_outlined,
                        Icons.assignment,
                        badgeCount: _getNavTaskBadgeCount(state),
                      ),
                      _buildBottomIcon(
                        4,
                        Icons.account_balance_outlined,
                        Icons.account_balance,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getNavTaskBadgeCount(AppState state) {
    return state.tasks.where((t) {
      if (t.isCompleted) return false;
      if (t.assignedTo == state.activePersona.id) return true;
      if (t.isSubmitted || t.isPostponeRequested) return true;
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final isToday =
          t.deadline.year == now.year &&
          t.deadline.month == now.month &&
          t.deadline.day == now.day;
      final isOverdue = t.deadline.isBefore(todayStart);
      if (isToday || isOverdue) return true;
      return false;
    }).length;
  }

  Color _getHeaderColor() {
    switch (_tab) {
      case 0:
        return SageColors.yellowAccentContainer;
      case 1:
        return SageColors.primaryContainer; // Light green for clients
      case 2:
        return SageColors.secondaryContainer; // Coral for team
      case 3:
        return SageColors.primaryContainer; // Green for tasks
      case 4:
        return SageColors.tertiaryContainer; // Purple for finance
      default:
        return SageColors.background;
    }
  }

  Widget _buildTopHeader(BuildContext context, Persona persona) {
    String title = "HOME";
    if (_tab == 1) title = "CLIENTS";
    if (_tab == 2) title = "PERSONNEL";
    if (_tab == 3) title = "ACTIVITY";
    if (_tab == 4) title = "FINANCE";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Image.asset(
            'assets/logo/sage_logo.png',
            height: 32,
            width: 80,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          // Profile Button
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ExecutiveProfileDashboard()),
              );
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: SageColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          // Circular Logout Button
          GestureDetector(
            onTap: () {
              context.read<AppState>().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: SageColors.yellowAccent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: const Icon(
                Icons.power_settings_new,
                color: SageColors.error,
                size: 18,
              ),
            ),
          ),

          Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.black,
                ),
              ),
              Text(
                "${persona.name.toUpperCase()} // ${persona.roleLabel}",
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),

          const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _buildBottomIcon(
    int index,
    IconData outlineIcon,
    IconData filledIcon, {
    int badgeCount = 0,
  }) {
    final isSelected = _tab == index;
    Widget iconWidget = Icon(
      isSelected ? filledIcon : outlineIcon,
      color: isSelected ? SageColors.yellowAccent : Colors.black,
      size: 22,
    );

    if (badgeCount > 0) {
      iconWidget = Badge(label: Text('$badgeCount'), child: iconWidget);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _switchTab(index),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: isSelected
            ? const BoxDecoration(color: Colors.black, shape: BoxShape.circle)
            : null,
        child: iconWidget,
      ),
    );
  }

  void _switchTab(int index) {
    if (_tab == index) return;
    setState(() {
      _tab = index;
      _tabKeyCounter++;
      _bucket = PageStorageBucket();
      _clientExpControllers.clear();
      _empExpControllers.clear();
      _personaExpControllers.clear();
      _clientSubTab = 'ACTIVE';
      _taskSubTab = 'CALENDAR';
      _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
      _selectedCalendarDate = null;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildActiveTab() {
    Widget active;
    switch (_tab) {
      case 0:
        active = _buildHomeTab();
        break;
      case 1:
        active = _buildClientsTab();
        break;
      case 2:
        active = _buildPersonnelTab();
        break;
      case 3:
        active = _buildTasksTab();
        break;
      case 4:
        active = _buildFinanceTab();
        break;
      default:
        active = const SizedBox();
        break;
    }
    return KeyedSubtree(
      key: ValueKey('tab_${_tab}_$_tabKeyCounter'),
      child: active,
    );
  }

  // --- TAB 0: HOME ---
  Widget _buildHomeTab() {
    final state = context.watch<AppState>();
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final pendingTasks = state.tasks
        .where(
          (t) =>
              !t.isCompleted &&
              !(t.taskType ?? '').toLowerCase().contains('upload') &&
              !t.title.toLowerCase().contains('upload'),
        )
        .length;
    final overdueTasks = state.tasks
        .where((t) => !t.isCompleted && t.deadline.isBefore(todayStart))
        .toList();

    int ceoCount = AppState.personas
        .where((p) => p.role == PersonaRole.ceo)
        .length;
    int cfoCount = AppState.personas
        .where((p) => p.role == PersonaRole.ceo)
        .length;
    Map<String, int> roleCounts = {};
    for (var emp in state.employees) {
      roleCounts[emp.role] = (roleCounts[emp.role] ?? 0) + 1;
    }
    List<String> teamParts = [];
    if (ceoCount > 0) teamParts.add("$ceoCount CEO");
    if (cfoCount > 0) teamParts.add("$cfoCount CFO");
    roleCounts.forEach((role, count) => teamParts.add("$count $role"));
    String teamSubtitle = "${teamParts.join(', ')}\nManage your growing team";

    int activeClients = state.clients
        .where((c) => c.status != 'Lead' && c.isApprovedByCeo)
        .length;
    int leads = state.clients.where((c) => c.status == 'Lead').length;
    String clientsSubtitle =
        "$activeClients active, $leads leads\nManage your portfolio";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        const LiveClockWidget(),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: DashboardTile(
                title: "Team",
                subtitle: teamSubtitle,
                backgroundColor: const Color(0xFFFFE4CD),
                iconBackgroundColor: const Color(0xFFFFF0A0),
                icon: Icons.groups,
                onTap: () => _switchTab(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardTile(
                title: "Active Tasks",
                subtitle: "$pendingTasks tasks pending\nTrack pending work",
                backgroundColor: const Color(0xFFE0E0FF),
                iconBackgroundColor: const Color(0xFFC0F0E0),
                icon: Icons.assignment_late,
                onTap: () => _switchTab(3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DashboardTile(
                title: "Clients",
                subtitle: clientsSubtitle,
                backgroundColor: const Color(0xFFD1F2EB),
                iconBackgroundColor: const Color(0xFFA0C0D0),
                icon: Icons.business,
                onTap: () => _switchTab(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardTile(
                title: "Finances",
                subtitle:
                    "₹${state.netBalance.toStringAsFixed(0)}\nControl your revenue",
                backgroundColor: const Color(0xFFFFA09E),
                iconBackgroundColor: const Color(0xFFE07070),
                icon: Icons.account_balance_wallet,
                onTap: () => _switchTab(4),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        _buildNotificationsPanel(state),
        const SizedBox(height: 16),
        TerminalPanel(
          title: "PENDING LEAD TERMINATIONS",
          child: state.clients.any((c) => c.isTerminationRequested)
              ? Column(
                  children: state.clients
                      .where((c) => c.isTerminationRequested)
                      .map(
                        (c) => Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  c.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    state.approveLeadTermination(c.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                ),
                                child: const Text(
                                  "APPROVE",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () =>
                                    state.rejectLeadTermination(c.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                ),
                                child: const Text(
                                  "REJECT",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                )
              : const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "No pending termination requests.",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
        ),
        const SizedBox(height: 16),
        TerminalPanel(
          title: "PENDING PAYMENTS",
          child: _buildPendingPaymentsList(state),
        ),
      ],
    );
  }

  Widget _buildNotificationsPanel(AppState state) {
    final notifs = state.notifications;
    final unread = state.unreadNotificationCount;

    IconData _iconForType(String type) {
      switch (type) {
        case 'task_assigned':
          return Icons.assignment_turned_in;
        case 'client_added':
          return Icons.business;
        case 'client_updated':
          return Icons.edit_note;
        case 'client_removed':
          return Icons.business_center;
        case 'employee_added':
          return Icons.person_add;
        case 'employee_updated':
          return Icons.person;
        case 'employee_terminated':
          return Icons.person_remove;
        case 'finance':
          return Icons.account_balance_wallet;
        default:
          return Icons.notifications;
      }
    }

    Color _colorForType(String type) {
      switch (type) {
        case 'task_assigned':
          return SageColors.primary;
        case 'client_added':
        case 'client_updated':
          return SageColors.tertiary;
        case 'client_removed':
          return SageColors.error;
        case 'employee_added':
          return SageColors.secondary;
        case 'employee_updated':
          return Colors.blueGrey;
        case 'employee_terminated':
          return SageColors.error;
        case 'finance':
          return Colors.amber.shade800;
        default:
          return Colors.grey;
      }
    }

    return TerminalPanel(
      title: "NOTIFICATIONS${unread > 0 ? ' ($unread NEW)' : ''}",
      child: Column(
        children: [
          if (notifs.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (unread > 0)
                  TextButton(
                    onPressed: () => state.markAllNotificationsRead(),
                    child: const Text(
                      "MARK ALL READ",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: SageColors.primary,
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () => state.clearNotifications(),
                  child: const Text(
                    "CLEAR",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: SageColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: notifs.isEmpty
                ? const Center(
                    child: Text(
                      "NO NOTIFICATIONS YET",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: notifs.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: Colors.black12, height: 8),
                    itemBuilder: (context, index) {
                      final n = notifs[index];
                      final timeStr =
                          "${n.timestamp.hour.toString().padLeft(2, '0')}:${n.timestamp.minute.toString().padLeft(2, '0')}";
                      final dateStr = "${n.timestamp.day}/${n.timestamp.month}";
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (!n.isRead) state.markNotificationRead(n.id);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _colorForType(n.type).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _iconForType(n.type),
                                size: 14,
                                color: _colorForType(n.type),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n.message,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: n.isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      color: n.isRead
                                          ? Colors.black54
                                          : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "$dateStr $timeStr - by ${n.triggeredBy}",
                                    style: const TextStyle(
                                      fontSize: 8,
                                      color: Colors.black38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!n.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: SageColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingPaymentsList(AppState state) {
    final pendingClients = state.clients
        .where(
          (c) =>
              (c.status == 'Active' || c.status == 'Retained') &&
              c.dynamicPaymentsDue > 0,
        )
        .toList();
    final pendingEmployees = state.employees.where((e) {
      if (!e.isActive) return false;
      if (!e.paymentCleared) return true;
      final isVideo =
          (e.hasRole('videographer') ||
              e.hasRole('videographer/cinematographer')) &&
          (e.videoEditorPayType != 'Salary' && e.monthlySalary == 0);
      final isVideoEditorPerVideo =
          e.hasRole('video editor') &&
          (e.videoEditorPayType == 'Per Video Rate' && e.monthlySalary == 0);
      if (isVideo) {
        final unpaidSessionsCount = state.tasks
            .where(
              (t) =>
                  t.assignedTo == e.id &&
                  t.taskType == 'Session' &&
                  t.isCompleted &&
                  !t.isPaidToVideographer,
            )
            .length;
        if (unpaidSessionsCount > 0) return true;
      }
      if (isVideoEditorPerVideo) {
        final unpaidVideosCount = state.tasks
            .where(
              (t) =>
                  t.assignedTo == e.id &&
                  t.taskType != 'Session' &&
                  t.isCompleted &&
                  !t.isPaidToVideographer,
            )
            .length;
        if (unpaidVideosCount > 0) return true;
      }
      return false;
    }).toList();

    if (pendingClients.isEmpty && pendingEmployees.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: SageColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: const Center(
          child: Text(
            "NO PENDING PAYMENTS",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
      );
    }

    final totalClientsDue = pendingClients.fold<double>(
      0.0,
      (sum, c) => sum + c.totalAmountDue,
    );

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: SageColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (pendingClients.isNotEmpty) ...[
            Text(
              "CLIENTS DUE (₹${totalClientsDue.toStringAsFixed(0)})",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: SageColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            ...pendingClients.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        c.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "₹${c.totalAmountDue.toStringAsFixed(0)} (${c.dynamicPaymentsDue} mo)",
                      style: const TextStyle(
                        fontSize: 12,
                        color: SageColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.black26),
          ],
          if (pendingEmployees.isNotEmpty) ...[
            const Text(
              "EMPLOYEES DUE",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: SageColors.secondary,
              ),
            ),
            const SizedBox(height: 4),
            ...pendingEmployees.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        e.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      e.paymentApprovedByEmployee ? "APPROVED" : "WAITING",
                      style: TextStyle(
                        fontSize: 10,
                        color: e.paymentApprovedByEmployee
                            ? SageColors.primary
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // --- --- --- --- TAB 1: CLIENTS --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
  // Accordion controllers --- ensures only one card is open at a time
  final Map<String, ExpansionTileController> _clientExpControllers = {};
  final Map<String, ExpansionTileController> _empExpControllers = {};
  final Map<int, ExpansionTileController> _personaExpControllers = {};
  String _clientSubTab = 'ACTIVE';
  final _clientNameCtrl = TextEditingController();
  final _clientContactNameCtrl = TextEditingController();
  final _clientContactEmailCtrl = TextEditingController();
  final _clientContactPhoneCtrl = TextEditingController();
  final _clientContactAddressCtrl = TextEditingController();
  final _clientContactWebsiteCtrl = TextEditingController();
  final _clientPayableCtrl = TextEditingController();
  String _clientPackageType = 'Growth';
  String _clientServiceType = 'Marketing';
  bool _clientHasMarketingCommission = false;
  String? _clientMarketingExecutiveId;
  bool _showDetailedShares = false;
  String _clientContractPeriod = '3 Months';
  String _clientLeadProbability = 'Medium';
  final _clientLeadNoteCtrl = TextEditingController();
  final _clientLeadFollowupCtrl = TextEditingController();
  String? _clientAssignedVideographerId;
  final _clientSessionRateCtrl = TextEditingController();

  void _showSkuLogDetails(
    BuildContext context,
    Client client,
    int month,
    int year,
  ) {
    final logs = client.ecomSkuLogs
        .where(
          (log) => log.timestamp.month == month && log.timestamp.year == year,
        )
        .toList();
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: SageColors.background,
          title: Text(
            "SKU Logs - ${monthNames[month - 1]} $year",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 800,
            child: logs.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No SKUs logged for this month."),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          Colors.grey.shade200,
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              "Date & Time",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Added By",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "SKU",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Duplicate",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Catalogue",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Amount",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: logs.map((log) {
                          final amount =
                              (log.sku * client.clientSkuRate) +
                              (log.duplicate * client.clientDuplicateSkuRate) +
                              (log.catalogue * client.clientCatalogueRate);
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  "${log.timestamp.day}-${log.timestamp.month}-${log.timestamp.year} ${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}",
                                ),
                              ),
                              DataCell(
                                Text(
                                  log.addedBy.isEmpty ? 'Unknown' : log.addedBy,
                                ),
                              ),
                              DataCell(Text("${log.sku}")),
                              DataCell(Text("${log.duplicate}")),
                              DataCell(Text("${log.catalogue}")),
                              DataCell(Text("₹${amount.toStringAsFixed(0)}")),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "CLOSE",
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSkuLogDialog(BuildContext context, Client client) {
    final skuCtrl = TextEditingController();
    final dupCtrl = TextEditingController();
    final catCtrl = TextEditingController();
    int selectedMonth = DateTime.now().month;
    int selectedYear = DateTime.now().year;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Log SKUs for ${client.name}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<int>(
                          value: selectedMonth,
                          items: List.generate(
                            12,
                            (index) => DropdownMenuItem(
                              value: index + 1,
                              child: Text("Month ${index + 1}"),
                            ),
                          ),
                          onChanged: (val) {
                            if (val != null)
                              setDialogState(() => selectedMonth = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<int>(
                          value: selectedYear,
                          items:
                              [
                                    DateTime.now().year - 1,
                                    DateTime.now().year,
                                    DateTime.now().year + 1,
                                  ]
                                  .map(
                                    (y) => DropdownMenuItem(
                                      value: y,
                                      child: Text(y.toString()),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            if (val != null)
                              setDialogState(() => selectedYear = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: skuCtrl,
                    decoration: const InputDecoration(labelText: "SKUs"),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: dupCtrl,
                    decoration: const InputDecoration(
                      labelText: "Duplicate SKUs",
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: catCtrl,
                    decoration: const InputDecoration(labelText: "Catalogues"),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final sku = int.tryParse(skuCtrl.text) ?? 0;
                    final dup = int.tryParse(dupCtrl.text) ?? 0;
                    final cat = int.tryParse(catCtrl.text) ?? 0;
                    if (sku > 0 || dup > 0 || cat > 0) {
                      final log = EcomSkuLog(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        timestamp: DateTime(
                          selectedYear,
                          selectedMonth,
                          DateTime.now().day,
                          DateTime.now().hour,
                          DateTime.now().minute,
                        ),
                        sku: sku,
                        duplicate: dup,
                        catalogue: cat,
                        addedBy: context.read<AppState>().activePersona.name,
                      );
                      context.read<AppState>().addEcomSkuLog(client.id, log);
                    }
                    Navigator.pop(ctx);
                  },
                  child: const Text("LOG SKUs"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildClientDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthBadge(String health) {
    Color color;
    switch (health) {
      case 'Great':
        color = Colors.green;
        break;
      case 'Good':
        color = Colors.orange;
        break;
      case 'Bad':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return StatusBadge(label: health, color: color);
  }

  Widget _buildPaymentModeBadge(String mode) {
    Color color;
    switch (mode) {
      case 'Advance':
        color = Colors.green;
        break;
      case 'Running':
        color = Colors.blue;
        break;
      case 'Late':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return StatusBadge(label: mode.toUpperCase(), color: color);
  }

  Widget _buildProbabilityBadge(String prob) {
    Color color;
    switch (prob) {
      case 'High':
        color = Colors.green;
        break;
      case 'Medium':
        color = Colors.orange;
        break;
      case 'Low':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return StatusBadge(label: prob, color: color);
  }

  Widget _buildEcomLedgerView(AppState state) {
    final ecomClients = state.clients
        .where(
          (c) =>
              c.serviceType.toLowerCase().contains('commerce') &&
              c.ecomPaymentType == 'Per SKU',
        )
        .toList();

    if (ecomClients.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: const Center(
          child: Text(
            "NO E-COMMERCE CLIENTS FOUND",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: ecomClients.length,
      itemBuilder: (context, i) {
        final c = ecomClients[i];
        return InkWell(
          onTap: () {
            // Open full historical ledger for this client
            showDialog(
              context: context,
              builder: (ctx) => EcomLedgerDialog(client: c),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.amber.shade100, // Folder-like color
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade700, width: 1.5),
              boxShadow: const [
                BoxShadow(color: Colors.black12, offset: Offset(2, 2)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 48, color: Colors.amber.shade800),
                const SizedBox(height: 12),
                Text(
                  c.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "${c.ecomSkuLogs.length} Total Logs",
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClientsTab() {
    final state = context.watch<AppState>();

    final activeClients = state.clients
        .where((c) => c.status != 'Lead' && c.isApprovedByCeo)
        .toList();
    final leadClients = state.clients.where((c) => c.status == 'Lead').toList();
    final reviewClients = state.clients
        .where((c) => !c.isApprovedByCeo || c.isTerminationRequested)
        .toList();
    final displayedClients = _clientSubTab == 'ACTIVE'
        ? activeClients
        : (_clientSubTab == 'REVIEW' ? reviewClients : leadClients);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() => _clientSubTab = 'ACTIVE'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _clientSubTab == 'ACTIVE'
                      ? Colors.black
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  "ACTIVE (${activeClients.length})",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _clientSubTab == 'ACTIVE'
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => setState(() => _clientSubTab = 'LEADS'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _clientSubTab == 'LEADS' ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  "LEADS (${leadClients.length})",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _clientSubTab == 'LEADS'
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => setState(() => _clientSubTab = 'REVIEW'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _clientSubTab == 'REVIEW'
                      ? Colors.black
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Badge(
                  isLabelVisible: reviewClients.isNotEmpty,
                  label: Text(reviewClients.length.toString()),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Text(
                      "REVIEW",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _clientSubTab == 'REVIEW'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => setState(() => _clientSubTab = 'E-COM LEDGER'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _clientSubTab == 'E-COM LEDGER'
                      ? Colors.black
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  "E-COM LEDGER",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _clientSubTab == 'E-COM LEDGER'
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  _clientSubTab == 'ACTIVE'
                      ? "ACTIVE CLIENT CONTRACTS"
                      : (_clientSubTab == 'LEADS'
                            ? "LEADS DATABASE"
                            : (_clientSubTab == 'E-COM LEDGER'
                                  ? "E-COMMERCE SKU LEDGER"
                                  : "CLIENTS PENDING APPROVAL")),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: SageColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (_clientSubTab != 'REVIEW')
                  ElevatedButton(
                    onPressed: () => _showAddClientDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SageColors.primary,
                    ),
                    child: Text(
                      _clientSubTab == 'LEADS' ? "+ ADD LEAD" : "+ ADD CLIENT",
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_clientSubTab == 'E-COM LEDGER')
          _buildEcomLedgerView(state)
        else if (displayedClients.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Center(
              child: Text(
                _clientSubTab == 'ACTIVE'
                    ? "NO ACTIVE CLIENT CONTRACTS"
                    : (_clientSubTab == 'LEADS'
                          ? "NO LEADS FOUND"
                          : "NO CLIENTS PENDING APPROVAL"),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          ...displayedClients.map((c) {
            if (_clientSubTab == 'REVIEW') {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(3, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "Contact: ${c.contact.name} (${c.contact.phone})",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                    if (c.isTerminationRequested)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          "â€¢ Requested Termination",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          "â€¢ Requested Conversion to Active Client",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (c.isTerminationRequested) ...[
                          TextButton(
                            onPressed: () {
                              context.read<AppState>().rejectLeadTermination(
                                c.id,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Termination request rejected.",
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "REJECT",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              context.read<AppState>().approveLeadTermination(
                                c.id,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Termination request approved.",
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(
                              "APPROVE",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ] else ...[
                          TextButton(
                            onPressed: () {
                              context.read<AppState>().rejectClientConversion(
                                c.id,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Client conversion rejected."),
                                ),
                              );
                            },
                            child: const Text(
                              "REJECT",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              context.read<AppState>().approveClientConversion(
                                c.id,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Client conversion approved."),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(
                              "APPROVE",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                image: const DecorationImage(
                  image: AssetImage('assets/logo/5l.png'),
                  fit: BoxFit.scaleDown,
                  opacity: 0.35,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: ExpansionTile(
                controller: _clientExpControllers.putIfAbsent(
                  c.id,
                  () => ExpansionTileController(),
                ),
                onExpansionChanged: (expanded) {
                  if (expanded) {
                    _clientExpControllers.forEach((key, controller) {
                      if (key != c.id && controller.isExpanded)
                        controller.collapse();
                    });
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  c.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  "Contact: ${c.contact.name} (${c.contact.phone})",
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_clientSubTab == 'ACTIVE' ||
                        _clientSubTab == 'REVIEW') ...[
                      _buildPaymentModeBadge(c.paymentMode),
                      const SizedBox(width: 8),
                    ],
                    _clientSubTab == 'LEADS'
                        ? _buildProbabilityBadge(c.conversionProbability)
                        : _buildHealthBadge(c.retentionHealth ?? 'Unknown'),
                  ],
                ),
                childrenPadding: const EdgeInsets.all(16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildClientDetailRow("Contact Name", c.contact.name),
                  _buildClientDetailRow("Contact Email", c.contact.email),
                  _buildClientDetailRow("Contact Phone", c.contact.phone),
                  if (c.contact.address.isNotEmpty)
                    _buildClientDetailRow("Address", c.contact.address),
                  if (c.contact.website.isNotEmpty)
                    _buildClientDetailRow("Website", c.contact.website),
                  _buildClientDetailRow(
                    "Starting Date",
                    c.contractDate.toString().substring(0, 10),
                  ),
                  const Divider(color: Colors.black26),

                  if (_clientSubTab == 'LEADS') ...[
                    _buildClientDetailRow(
                      "Conversion Probability",
                      c.conversionProbability,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "ASSIGN TO ME",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: SageColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String?>(
                      value: c.marketingExecutiveId,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      dropdownColor: Colors.white,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text("None", style: TextStyle(fontSize: 12)),
                        ),
                        ...state.employees
                            .where((e) => e.hasRole('marketing'))
                            .map(
                              (e) => DropdownMenuItem<String?>(
                                value: e.id,
                                child: Text(
                                  e.name,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                      ],
                      onChanged: (v) {
                        context.read<AppState>().updateClient(
                          c.id,
                          marketingExecutiveId: v,
                          hasMarketingCommission: v != null,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "FOLLOW-UP DATES",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: SageColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (c.followUpDates.isEmpty)
                      const Text(
                        "No follow-ups scheduled",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black38,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      ...c.followUpDates.map(
                        (d) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: SageColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                d,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _showLeadMeetingDialog(context, c.id),
                            icon: const Icon(Icons.add, size: 14),
                            label: const Text(
                              "ADD FOLLOW-UP",
                              style: TextStyle(fontSize: 10),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SageColors.primaryContainer,
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "NOTES / COMMENTS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: SageColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (c.notes.isEmpty)
                      const Text(
                        "No notes yet",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black38,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      ...c.notes
                          .take(5)
                          .map(
                            (n) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                "- $n",
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: SageTextField(
                            controller: TextEditingController(),
                            label: "Add a note...",
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty) {
                                context.read<AppState>().addClientNote(
                                  c.id,
                                  val,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_clientSubTab == 'ACTIVE' ||
                      _clientSubTab == 'REVIEW') ...[
                    _buildClientDetailRow("Payment Mode", c.paymentMode),
                    _buildClientDetailRow(
                      "Starting Date",
                      c.contractDate.toString().substring(0, 10),
                    ),
                    _buildClientDetailRow(
                      "Due Date",
                      "${c.dueDateDay}th of month",
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "2026 Payment Tracker",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 6,
                                  childAspectRatio: 2.0,
                                  crossAxisSpacing: 6,
                                  mainAxisSpacing: 6,
                                ),
                            itemCount: 12,
                            itemBuilder: (context, i) {
                              final month = i + 1;
                              final isPaid = c.paidMonths.contains(month);
                              final currentMonth = DateTime.now().month;
                              final currentYear = DateTime.now().year;
                              final monthNames = [
                                'Jan',
                                'Feb',
                                'Mar',
                                'Apr',
                                'May',
                                'Jun',
                                'Jul',
                                'Aug',
                                'Sep',
                                'Oct',
                                'Nov',
                                'Dec',
                              ];

                              bool isBeforeJoinDate = false;
                              if (c.contractDate.year == currentYear &&
                                  month < c.contractDate.month) {
                                isBeforeJoinDate = true;
                              } else if (c.contractDate.year > currentYear) {
                                isBeforeJoinDate = true;
                              }

                              Color bgColor;
                              if (isBeforeJoinDate) {
                                bgColor = Colors.grey.shade300;
                              } else if (isPaid) {
                                bgColor = const Color(
                                  0xFFC5E1A5,
                                ); // Pastel Green
                              } else if (c.isMonthDue(month)) {
                                bgColor = const Color(0xFFEF9A9A); // Pastel Red
                              } else {
                                bgColor = const Color(
                                  0xFFF48FB1,
                                ); // Pastel Pink
                              }

                              return ElevatedButton(
                                onPressed: isBeforeJoinDate
                                    ? null
                                    : () {
                                        if (isPaid) {
                                          context
                                              .read<AppState>()
                                              .toggleClientPaidMonth(
                                                c.id,
                                                month,
                                              );
                                        } else {
                                          _showPaymentDialog(context, c, month);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: bgColor,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: const BorderSide(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  monthNames[i],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    _buildClientDetailRow(
                      "Payments Due",
                      "${c.dynamicPaymentsDue} Months",
                    ),
                    c.serviceType.toLowerCase().contains('commerce')
                        ? _buildClientDetailRow(
                            "Deliverables",
                            "Listing, Catalogue, A+ Content",
                          )
                        : _buildClientDetailRow(
                            "Weekly Deliverables",
                            "${c.weeklyReels} Reels, ${c.weeklyPosts} Posts, ${c.weeklyCarousels} Carousels, ${c.weeklyStories} Stories",
                          ),
                    _buildClientDetailRow(
                      "On Track End Deadline",
                      c.contractDate
                          .add(
                            Duration(
                              days: c.contractPeriod.contains('3')
                                  ? 90
                                  : (c.contractPeriod.contains('6')
                                        ? 180
                                        : 365),
                            ),
                          )
                          .toString()
                          .substring(0, 10),
                    ),
                    _buildClientDetailRow("Package Type", c.packageType),
                    _buildClientDetailRow("Contract Tenure", c.contractPeriod),
                    
                    if (c.isWebsiteHandlingActive)
                      _buildClientDetailRow(
                        "Website Handling",
                        "₹${c.websiteHandlingFee.toStringAsFixed(0)}",
                      ),
                    c.ecomPaymentType == 'Per SKU'
                        ? _buildClientDetailRow(
                            "Base Monthly Fee",
                            "₹${c.getPayableForMonth(DateTime.now().month, DateTime.now().year).toStringAsFixed(0)} (Actual varies by SKU logs)",
                          )
                        : _buildClientDetailRow(
                            "Monthly Fee",
                            "₹${(c.monthlyPayable + (c.isWebsiteHandlingActive ? c.websiteHandlingFee : 0)).toStringAsFixed(0)}",
                          ),
                    _buildClientDetailRow("Service Type", c.serviceType),
                    if (c.serviceType.toLowerCase().contains('commerce')) ...[
                      _buildClientDetailRow("SKU Rate", "\u20B9${c.clientSkuRate.toStringAsFixed(0)}"),
                      _buildClientDetailRow("Duplicate SKU Rate", "\u20B9${c.clientDuplicateSkuRate.toStringAsFixed(0)}"),
                      _buildClientDetailRow("Catalogue Rate", "\u20B9${c.clientCatalogueRate.toStringAsFixed(0)}"),
                    ],
                    _buildClientDetailRow(
                      "Marketing Commission",
                      c.hasMarketingCommission ? "Yes (20%)" : "No",
                    ),
                    if (c.hasMarketingCommission &&
                        c.marketingExecutiveId != null)
                      _buildClientDetailRow(
                        "Marketing Executive",
                        context
                                .read<AppState>()
                                .employees
                                .where((e) => e.id == c.marketingExecutiveId)
                                .firstOrNull
                                ?.name ??
                            "Unknown",
                      ),
                    if (c.assignedVideographerId != null &&
                        c.assignedVideographerId != 'COF-PRI-001') ...[
                      _buildClientDetailRow(
                        "Assigned Videographer",
                        (context
                                .read<AppState>()
                                .employees
                                .where((e) => e.id == c.assignedVideographerId)
                                .isNotEmpty
                            ? context
                                  .read<AppState>()
                                  .employees
                                  .where(
                                    (e) => e.id == c.assignedVideographerId,
                                  )
                                  .first
                                  .name
                            : 'Unknown'),
                      ),
                      _buildClientDetailRow(
                        "Session Rate",
                        "₹${c.sessionRate.toStringAsFixed(0)}",
                      ),
                    ],
                    if (c.packageType == 'Performance') ...[
                      _buildClientDetailRow("Campaigns", "${c.campaigns}"),
                      _buildClientDetailRow("Campaign Reach", c.campaignReach),
                    ],
                    if (c.serviceType.toLowerCase().contains('commerce') &&
                        c.ecomPaymentType == 'Per SKU') ...[
                      const SizedBox(height: 10),
                      const Text(
                        "2026 SKU Tracker",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              childAspectRatio: 1.5,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                            ),
                        itemCount: 12,
                        itemBuilder: (context, i) {
                          final month = i + 1;
                          final monthNames = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun',
                            'Jul',
                            'Aug',
                            'Sep',
                            'Oct',
                            'Nov',
                            'Dec',
                          ];
                          final currentYear = DateTime.now().year;
                          double totalForMonth = c.getPayableForMonth(
                            month,
                            currentYear,
                          );
                          int totalSkus = 0;
                          for (var log in c.ecomSkuLogs) {
                            if (log.timestamp.month == month &&
                                log.timestamp.year == currentYear) {
                              totalSkus +=
                                  log.sku + log.duplicate + log.catalogue;
                            }
                          }

                          bool isBeforeContract =
                              (currentYear < c.contractDate.year) ||
                              (currentYear == c.contractDate.year &&
                                  month < c.contractDate.month);
                          Color bgColor = Colors.grey.shade200;
                          if (!isBeforeContract) {
                            if (totalSkus > 0) {
                              bgColor = const Color(0xFFC8E6C9); // Pastel Green
                            } else if (month <= DateTime.now().month ||
                                currentYear < DateTime.now().year) {
                              bgColor = const Color(0xFFFFCDD2); // Pastel Red
                            }
                          }

                          return InkWell(
                            onTap: isBeforeContract
                                ? null
                                : () => _showSkuLogDetails(
                                    context,
                                    c,
                                    month,
                                    currentYear,
                                  ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.black12),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    monthNames[i],
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isBeforeContract
                                          ? Colors.black38
                                          : Colors.black87,
                                    ),
                                  ),
                                  if (totalSkus > 0)
                                    Text(
                                      "₹${totalForMonth.toStringAsFixed(0)}",
                                      style: const TextStyle(
                                        fontSize: 8,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  if (totalSkus > 0)
                                    Text(
                                      "$totalSkus items",
                                      style: const TextStyle(
                                        fontSize: 7,
                                        color: Colors.black54,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _showSkuLogDialog(context, c),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D0E0E),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Log Daily SKUs"),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: SageColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SwitchListTile(
                        title: const Text("Website Handling Service", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                        value: c.isWebsiteHandlingActive,
                        activeColor: SageColors.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) async {
                          if (val) {
                            final ok = await showConfirmDialog(context, "Enable Website Handling", "Are you sure you want to enable the Website Handling Service for ${c.name}?");
                            if (!ok || !context.mounted) return;
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                final feeCtrl = TextEditingController(text: c.websiteHandlingFee.toString());
                                return AlertDialog(
                                  title: const Text("Website Handling Fee"),
                                  content: TextField(controller: feeCtrl, keyboardType: TextInputType.number),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
                                    TextButton(
                                      onPressed: () {
                                        context.read<AppState>().updateClient(c.id, isWebsiteHandlingActive: true, websiteHandlingFee: double.tryParse(feeCtrl.text) ?? 0.0);
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text("SAVE"),
                                    ),
                                  ],
                                );
                              }
                            );
                          } else {
                            final ok = await showConfirmDialog(context, "Disable Website Handling", "Are you sure you want to disable the Website Handling Service for ${c.name}?");
                            if (!ok || !context.mounted) return;
                            context.read<AppState>().updateClient(c.id, isWebsiteHandlingActive: false, websiteHandlingFee: 0.0);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Add-Ons",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (c.addOns.isNotEmpty)
                      ...c.addOns.map(
                        (addOn) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${addOn.type} ${addOn.description != null && addOn.description!.isNotEmpty ? '- ${addOn.description}' : ''}",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "(+\u20B9${addOn.amount.toStringAsFixed(0)})",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (!addOn.isPaid)
                                  TextButton(
                                    onPressed: () => _showAddOnPaymentDialog(
                                      context,
                                      c,
                                      addOn,
                                    ),
                                    child: const Text(
                                      "Pay",
                                      style: TextStyle(
                                        color: SageColors.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                else
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      "Paid",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final ok = await showConfirmDialog(context, "Delete Add-On", "Are you sure you want to delete this Add-On?");
                                    if (!ok || !context.mounted) return;
                                    context.read<AppState>().deleteClientAddOn(c.id, addOn.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => _showAddOnDialog(context, c),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text(
                          "Add New Add-On",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const Divider(color: Colors.black26),
                    if (c.postRequirements.isNotEmpty &&
                        c.postRequirements != 'TBD')
                      _buildClientDetailRow(
                        "Description / Requirements",
                        c.postRequirements,
                      )
                    else
                      _buildClientDetailRow(
                        "Description / Requirements",
                        "Not provided",
                      ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_clientSubTab == 'LEADS')
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: SageColors.background,
                                title: const Text(
                                  "CONFIRM CONVERSION",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                content: Text(
                                  "Are you sure you want to convert ${c.name} into an Active Client?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text("CANCEL"),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: SageColors.primary,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      context
                                          .read<AppState>()
                                          .updateClientStatus(c.id, 'Active');
                                    },
                                    child: const Text(
                                      "CONVERT",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SageColors.primary,
                          ),
                          child: const Text("CONVERT TO ACTIVE"),
                        ),
                      if (_clientSubTab == 'REVIEW') ...[
                        if (c.isTerminationRequested) ...[
                          TextButton(
                            onPressed: () {
                              context.read<AppState>().rejectLeadTermination(
                                c.id,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Termination request rejected.",
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "REJECT TERMINATION",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              context.read<AppState>().approveLeadTermination(
                                c.id,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Termination request approved.",
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(
                              "APPROVE TERMINATION",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ] else ...[
                          TextButton(
                            onPressed: () {
                              context.read<AppState>().rejectClientConversion(
                                c.id,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Client conversion rejected."),
                                ),
                              );
                            },
                            child: const Text(
                              "REJECT",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              context.read<AppState>().approveClientConversion(
                                c.id,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Client conversion approved."),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(
                              "APPROVE",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                      if (_clientSubTab == 'LEADS') const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_clientSubTab == 'ACTIVE')
                            TextButton(
                              onPressed: () {
                                _showInvoiceMonthDialog(context, c);
                              },
                              child: const Text(
                                "GENERATE INVOICE",
                                style: TextStyle(
                                  color: SageColors.secondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          TextButton(
                            onPressed: () => _showEditClientDialog(context, c),
                            child: const Text(
                              "EDIT",
                              style: TextStyle(
                                color: SageColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final ok = await showConfirmDialog(
                                context,
                                "REMOVE CLIENT",
                                "Are you sure you want to delete ${c.name}?",
                              );
                              if (ok && context.mounted) {
                                context.read<AppState>().removeClient(c.id);
                              }
                            },
                            child: const Text(
                              "TERMINATE",
                              style: TextStyle(
                                color: SageColors.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  final _employeeNameCtrl = TextEditingController();
  final _employeeDeptCtrl = TextEditingController();
  final _employeeSalaryCtrl = TextEditingController();
  final _employeeRateCtrl = TextEditingController();
  final _employeeSessionsCtrl = TextEditingController();
  String _employeeRole = 'Video Editor';
  String _videoEditorPaymentStructure = 'Salary';

  void _showPaySessionsDialog(
    BuildContext context,
    AppState state,
    Employee e,
    int unpaidItemsCount,
    bool isForSessions,
  ) {
    final isVideoEditor = e.hasRole('video editor');
    final typeStr = isForSessions ? "Sessions" : "Videos";
    final sessionsCtrl = TextEditingController(
      text: unpaidItemsCount.toString(),
    );
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: SageColors.background,
          title: Text(
            "PAY ${e.name.toUpperCase()}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Unpaid Completed $typeStr: $unpaidItemsCount",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SageTextField(
                controller: sessionsCtrl,
                label: "Number of $typeStr to Pay",
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SageColors.primary,
              ),
              onPressed: () {
                final count = int.tryParse(sessionsCtrl.text) ?? 0;
                if (count > 0 && count <= unpaidItemsCount) {
                  // Reusing the same backend function as both use isPaidToVideographer on tasks
                  context.read<AppState>().payVideographerSessions(
                    e.id,
                    count,
                    isForSessions,
                  );
                  Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Invalid $typeStr count!")),
                  );
                }
              },
              child: Text("PAY $typeStr".toUpperCase()),
            ),
          ],
        );
      },
    );
  }

  void _showPayEmployeeDialog(
    BuildContext context,
    AppState state,
    Employee e,
  ) {
    final isME = e.hasRole('marketing');
    List<String> selectedMonths = [];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final activeClients = isME
        ? state.clients
              .where(
                (c) =>
                    c.marketingExecutiveId == e.id &&
                    c.status == 'Active' &&
                    c.hasMarketingCommission,
              )
              .toList()
        : [];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: SageColors.background,
              title: Text(
                isME
                    ? "CLEAR PAYMENT FOR ${e.name.toUpperCase()}"
                    : "PAY ${e.name.toUpperCase()}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Select month(s) to pay for:"),
                    const SizedBox(height: 10),
                    ...months.asMap().entries.map((entry) {
                      final mIndex = entry.key + 1;
                      final m = entry.value;
                      bool isPaidByEmployee = e.paidMonths.contains(m);

                      List<String> blockingClients = [];
                      if (isME && activeClients.isNotEmpty) {
                        for (var c in activeClients) {
                          // If client contracted after this month, they don't block this month
                          if (c.contractDate.month <= mIndex &&
                              !c.paidMonths.contains(mIndex)) {
                            blockingClients.add(c.name.trim());
                          }
                        }
                      }
                      bool isBlockedForME = blockingClients.isNotEmpty;

                      return CheckboxListTile(
                        title: Row(
                          children: [
                            Text(m),
                            if (isBlockedForME && !isPaidByEmployee)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    "(Blocked by: ${blockingClients.join(', ')})",
                                    style: const TextStyle(
                                      color: SageColors.error,
                                      fontSize: 10,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        value: selectedMonths.contains(m) || isPaidByEmployee,
                        onChanged: (isPaidByEmployee || isBlockedForME)
                            ? null
                            : (val) {
                                setDialogState(() {
                                  if (val == true)
                                    selectedMonths.add(m);
                                  else
                                    selectedMonths.remove(m);
                                });
                              },
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SageColors.primary,
                  ),
                  onPressed: () {
                    if (selectedMonths.isNotEmpty) {
                      if (isME) {
                        double totalCommission =
                            e.monthlySalary * selectedMonths.length;
                        for (String m in selectedMonths) {
                          int mIdx = months.indexOf(m) + 1;
                          for (var c in activeClients) {
                            if (c.contractDate.month <= mIdx) {
                              totalCommission += c.monthlyPayable * 0.20;
                            }
                          }
                        }
                        context.read<AppState>().clearMarketingCommission(
                          e.id,
                          selectedMonths.join(', '),
                          totalCommission,
                        );
                      } else {
                        context.read<AppState>().payEmployeeSalary(
                          e.id,
                          selectedMonths,
                          e.monthlySalary * selectedMonths.length,
                        );
                      }
                      Navigator.pop(ctx);
                    } else {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Error: You must check at least one month box first! If the box is disabled, you cannot clear payment for it.",
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } catch (e) {}
                    }
                  },
                  child: Text(isME ? "CLEAR PAYMENT" : "PAY SALARY"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPaySkusDialog(BuildContext context, AppState state, Employee e) {
    final skusCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: SageColors.background,
          title: Text(
            "PAY ${e.name.toUpperCase()}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Total SKUs Paid Previously: ${e.skusPaid}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("Per SKU Rate: ,1${e.perSkuRate.toStringAsFixed(0)}"),
              const SizedBox(height: 12),
              SageTextField(
                controller: skusCtrl,
                label: "Number of SKUs to Pay",
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SageColors.primary,
              ),
              onPressed: () {
                final count = int.tryParse(skusCtrl.text) ?? 0;
                if (count > 0) {
                  final totalPayout = count * e.perSkuRate;
                  context.read<AppState>().payEcomExecutiveSkus(
                    e.id,
                    count,
                    totalPayout,
                  );
                  Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid SKU count!")),
                  );
                }
              },
              child: const Text("PAY SKUS"),
            ),
          ],
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    final r = role.toLowerCase();
    if (r.contains('ceo')) return const Color(0xFFFFB3BA);
    if (r.contains('founder') || r.contains('cfo'))
      return const Color(0xFFFFDFBA);
    if (r.contains('videographer')) return const Color(0xFFBAE1FF);
    if (r.contains('video editor')) return const Color(0xFFE6B3FF);
    if (r.contains('marketing')) return const Color(0xFFBAFFC9);
    return const Color(0xFFFFFFBA);
  }

  Widget _buildPersonnelTab() {
    final state = context.watch<AppState>();
    final pastelColors = [
      Color(0xFFFFB3BA),
      Color(0xFFFFDFBA),
      Color(0xFFFFFFBA),
      Color(0xFFBAFFC9),
      Color(0xFFBAE1FF),
      Color(0xFFE6B3FF),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "REGISTERED TEAM MEMBERS",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: SageColors.onSurfaceVariant,
              ),
            ),
            ElevatedButton(
              onPressed: () => _showAddMemberDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: SageColors.secondary,
              ),
              child: const Text("+ ADD MEMBER"),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...AppState.personas.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          final color = _getRoleColor(p.roleLabel);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: color,
              image: const DecorationImage(
                image: AssetImage('assets/logo/2l.png'),
                fit: BoxFit.scaleDown,
                opacity: 0.35,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: ExpansionTile(
              controller: _personaExpControllers.putIfAbsent(
                i,
                () => ExpansionTileController(),
              ),
              onExpansionChanged: (expanded) {
                if (expanded) {
                  _personaExpControllers.forEach((key, controller) {
                    if (key != i && controller.isExpanded)
                      controller.collapse();
                  });
                }
              },
              shape: const RoundedRectangleBorder(
                side: BorderSide(color: Colors.transparent),
              ),
              collapsedShape: const RoundedRectangleBorder(
                side: BorderSide(color: Colors.transparent),
              ),
              title: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: Image.asset(
                        availableAvatars[p.avatar % availableAvatars.length],
                        fit: BoxFit.cover,
                        width: 72,
                        height: 72,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (p.preferredName.isNotEmpty
                                  ? p.preferredName
                                  : p.name)
                              .toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          p.roleLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            p.phone.isNotEmpty ? p.phone : 'Not Provided',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.email,
                            size: 14,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            p.email.isNotEmpty ? p.email : 'Not Provided',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              p.address.isNotEmpty ? p.address : 'Not Provided',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.description,
                            size: 14,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Bio: ${p.professionalBio.isNotEmpty ? p.professionalBio : 'Not Provided'}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (p.keySkills.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.build,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Skills: ${p.keySkills.join(', ')}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.black, width: 1.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "System Core Persona",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "ACCESS: FULL",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),

        ...state.employees.asMap().entries.map((entry) {
          final i = entry.key + AppState.personas.length;
          final employee = entry.value;
          final color = _getRoleColor(employee.role);
          final isVideo =
              (employee.hasRole('videographer') ||
                  employee.hasRole('videographer/cinematographer')) &&
              (employee.videoEditorPayType != 'Salary' &&
                  employee.monthlySalary == 0);
          final isVideoEditorPerVideo =
              employee.hasRole('video editor') &&
              (employee.videoEditorPayType == 'Per Video Rate' &&
                  employee.monthlySalary == 0);
          final isEcomExec = employee.hasRole('ecom executive');
          final isVideoEditor = employee.hasRole('video editor');
          final isME =
              employee.hasRole('marketing executive') ||
              employee.hasRole('marketing') ||
              employee.hasRole('page management executive');

          double pendingVideoPayout = 0;
          int unpaidVideosCount = 0;
          double pendingSessionPayout = 0;
          int unpaidSessionsCount = 0;

          if (isVideo) {
            final unpaidSessions = state.tasks
                .where(
                  (t) =>
                      t.assignedTo == employee.id &&
                      t.taskType == 'Session' &&
                      t.isCompleted &&
                      !t.isPaidToVideographer,
                )
                .toList();
            unpaidSessionsCount = unpaidSessions.length;
            for (final t in unpaidSessions) {
              final c = state.clients
                  .where((c) => c.id == t.clientId)
                  .firstOrNull;
              if (c != null) pendingSessionPayout += c.sessionRate;
            }
          }
          if (isVideoEditorPerVideo) {
            final unpaidVideos = state.tasks
                .where(
                  (t) =>
                      t.assignedTo == employee.id &&
                      t.taskType != 'Session' &&
                      t.isCompleted &&
                      !t.isPaidToVideographer,
                )
                .toList();
            unpaidVideosCount = unpaidVideos.length;
            pendingVideoPayout = unpaidVideosCount * employee.perVideoRate;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: color,
              image: const DecorationImage(
                image: AssetImage('assets/logo/1l.png'),
                fit: BoxFit.scaleDown,
                opacity: 0.15,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: ExpansionTile(
              controller: _empExpControllers.putIfAbsent(
                employee.id,
                () => ExpansionTileController(),
              ),
              onExpansionChanged: (expanded) {
                if (expanded) {
                  _empExpControllers.forEach((key, controller) {
                    if (key != employee.id && controller.isExpanded)
                      controller.collapse();
                  });
                }
              },
              shape: const RoundedRectangleBorder(
                side: BorderSide(color: Colors.transparent),
              ),
              collapsedShape: const RoundedRectangleBorder(
                side: BorderSide(color: Colors.transparent),
              ),
              title: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: ClipOval(
                      child: Image.asset(
                        availableAvatars[employee.avatar %
                            availableAvatars.length],
                        fit: BoxFit.cover,
                        width: 72,
                        height: 72,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.preferredName.isNotEmpty
                              ? employee.preferredName
                              : employee.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "${employee.role}",
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            employee.phone.isNotEmpty
                                ? employee.phone
                                : 'Not Provided',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.email,
                            size: 14,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            employee.email.isNotEmpty
                                ? employee.email
                                : 'Not Provided',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              employee.address.isNotEmpty
                                  ? employee.address
                                  : 'Not Provided',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (employee.preferredName.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Preferred Name: ${employee.preferredName}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (employee.workLocation.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.business,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Work Location: ${employee.workLocation}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (employee.emergencyContact.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.warning,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Emergency Contact: ${employee.emergencyContact}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (employee.professionalBio.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.description,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Bio: ${employee.professionalBio}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (employee.keySkills.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.build,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Skills: ${employee.keySkills.join(', ')}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (employee.strengths.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.fitness_center,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Strengths: ${employee.strengths.join(', ')}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (employee.workStylePreference.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.track_changes,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Work Style: ${employee.workStylePreference}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (employee.interests.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Interests: ${employee.interests}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.black, width: 1.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isVideo) ...[
                        Text(
                          "PENDING SESSION PAYOUT: ₹${pendingSessionPayout.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "UNPAID SESSIONS: $unpaidSessionsCount",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (isVideoEditorPerVideo) ...[
                        Text(
                          "PENDING VIDEO PAYOUT: ₹${pendingVideoPayout.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "UNPAID VIDEOS: $unpaidVideosCount",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
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
                          "PER SKU RATE: ,1${employee.perSkuRate.toStringAsFixed(0)}",
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
                          !isEcomExec) ...[
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
                            "SALARY: ₹${employee.monthlySalary.toStringAsFixed(0)} / mo",
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
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (isVideo)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                    ),
                                    onPressed: () {
                                      _showPaySessionsDialog(
                                        context,
                                        state,
                                        employee,
                                        unpaidSessionsCount,
                                        true,
                                      );
                                    },
                                    child: const Text(
                                      "PAY SESSIONS",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              if (isVideoEditorPerVideo)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                    ),
                                    onPressed: () {
                                      _showPaySessionsDialog(
                                        context,
                                        state,
                                        employee,
                                        unpaidVideosCount,
                                        false,
                                      );
                                    },
                                    child: const Text(
                                      "PAY VIDEOS",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              if (isEcomExec)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                    ),
                                    onPressed: () {
                                      _showPaySkusDialog(
                                        context,
                                        state,
                                        employee,
                                      );
                                    },
                                    child: const Text(
                                      "PAY SKUS",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              if (!isVideo &&
                                  !isVideoEditorPerVideo &&
                                  !isEcomExec)
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                  ),
                                  onPressed: () {
                                    _showPayEmployeeDialog(
                                      context,
                                      state,
                                      employee,
                                    );
                                  },
                                  child: Text(
                                    isME ? "CLEAR PAYMENT" : "PAY SALARY",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.black,
                                ),
                                onPressed: () =>
                                    _showEditEmployeeDialog(context, employee),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: SageColors.error,
                                ),
                                onPressed: () async {
                                  final ok = await showConfirmDialog(
                                    context,
                                    "TERMINATE EMPLOYEE",
                                    "Are you sure you want to terminate ${employee.name}?",
                                  );
                                  if (ok && context.mounted) {
                                    context.read<AppState>().terminateEmployee(
                                      employee.id,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _taskSubTab = 'CALENDAR'; // 'CALENDAR', 'TEAM'
  String? _selectedPersonnelId;

  String _newTaskType = 'Daily Video';
  List<String> _newTaskAssigneeIds = [];
  String? _dailyVideoAssigneeId;
  List<String> _newTaskClients = [];
  final TextEditingController _newTaskTitleCtrl = TextEditingController();
  final TextEditingController _newTaskDescCtrl = TextEditingController();
  TimeOfDay _newTaskTime = const TimeOfDay(hour: 17, minute: 0);
  bool _isAddTaskExpanded = false;
  // Session booking state
  String? _sessionVideographerId;
  List<String> _sessionClientIds = [];
  bool _meetingIsPhysical = true;

  DateTime _calendarMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  DateTime? _selectedCalendarDate;

  final Map<String, String> _holidays = {
    '01-01': 'New Year\'s Day',
    '26-01': 'Republic Day',
    '14-02': 'Valentine\'s Day',
    '08-03': 'Maha Shivaratri',
    '25-03': 'Holi',
    '29-03': 'Good Friday',
    '09-04': 'Ugadi / Gudi Padwa',
    '11-04': 'Eid al-Fitr',
    '17-04': 'Rama Navami',
    '01-05': 'Labour Day',
    '17-06': 'Eid al-Adha',
    '17-07': 'Muharram',
    '15-08': 'Independence Day',
    '26-08': 'Janmashtami',
    '07-09': 'Ganesh Chaturthi',
    '02-10': 'Gandhi Jayanti',
    '11-10': 'Dussehra',
    '31-10': 'Diwali',
    '25-12': 'Christmas',
  };

  Map<String, String> _googleHolidays = {};
  bool _isLoadingHolidays = false;

  @override
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _tab);
    _fetchGoogleHolidays();
  }

  Future<void> _fetchGoogleHolidays() async {
    setState(() => _isLoadingHolidays = true);
    setState(() {
      _googleHolidays = {
        '2025-01-01': 'New Year\'s Day',
        '2025-01-06': 'Guru Govind Singh Jayanti',
        '2025-01-14': 'Pongal',
        '2025-01-26': 'Republic Day',
        '2025-02-02': 'Vasant Panchami',
        '2025-02-12': 'Guru Ravidas Jayanti',
        '2025-02-19': 'Shivaji Jayanti',
        '2025-02-23': 'Maharishi Dayanand Saraswati Jayanti',
        '2025-02-26': 'Maha Shivaratri',
        '2025-03-02': 'Ramadan Start',
        '2025-03-13': 'Holika Dahana',
        '2025-03-14': 'Dolyatra',
        '2025-03-28': 'Jamat Ul-Vida',
        '2025-03-30': 'Ugadi',
        '2025-03-31': 'Ramzan Id',
        '2025-04-06': 'Rama Navami',
        '2025-04-10': 'Mahavir Jayanti',
        '2025-04-13': 'Vaisakhi',
        '2025-04-14': 'Mesadi',
        '2025-04-15': 'Bahag Bihu',
        '2025-04-18': 'Good Friday',
        '2025-04-20': 'Easter Day',
        '2025-05-09': 'Birthday of Rabindranath',
        '2025-05-12': 'Buddha Purnima',
        '2025-06-07': 'Bakrid',
        '2025-06-27': 'Rath Yatra',
        '2025-07-06': 'Muharram/Ashura',
        '2025-08-09': 'Raksha Bandhan',
        '2025-08-15': 'Parsi New Year',
        '2025-08-16': 'Janmashtami',
        '2025-08-27': 'Ganesh Chaturthi',
        '2025-09-05': 'Milad un-Nabi',
        '2025-09-22': 'First Day of Sharad Navratri',
        '2025-09-28': 'First Day of Durga Puja Festivities',
        '2025-09-29': 'Maha Saptami',
        '2025-09-30': 'Maha Ashtami',
        '2025-10-01': 'Maha Navami',
        '2025-10-02': 'Mahatma Gandhi Jayanti',
        '2025-10-07': 'Maharishi Valmiki Jayanti',
        '2025-10-10': 'Karaka Chaturthi',
        '2025-10-20': 'Naraka Chaturdasi',
        '2025-10-22': 'Govardhan Puja',
        '2025-10-23': 'Bhai Duj',
        '2025-10-28': 'Chhat Puja (Pratihar Sashthi/Surya Sashthi)',
        '2025-11-05': 'Guru Nanak Jayanti',
        '2025-11-24': 'Guru Tegh Bahadur\'s Martyrdom Day',
        '2025-12-24': 'Christmas Eve',
        '2025-12-25': 'Christmas',
        '2026-01-01': 'New Year\'s Day',
        '2026-01-03': 'Hazarat Ali\'s Birthday',
        '2026-01-14': 'Makar Sankranti',
        '2026-01-23': 'Vasant Panchami',
        '2026-01-26': 'Republic Day',
        '2026-02-01': 'Guru Ravidas Jayanti',
        '2026-02-12': 'Maharishi Dayanand Saraswati Jayanti',
        '2026-02-15': 'Maha Shivaratri',
        '2026-02-19': 'Ramadan Start',
        '2026-03-03': 'Holika Dahana',
        '2026-03-04': 'Holi',
        '2026-03-19': 'Ugadi',
        '2026-03-20': 'Jamat Ul-Vida',
        '2026-03-21': 'Ramzan Id',
        '2026-03-26': 'Rama Navami',
        '2026-03-31': 'Mahavir Jayanti',
        '2026-04-03': 'Good Friday',
        '2026-04-05': 'Easter Day',
        '2026-04-14': 'Ambedkar Jayanti',
        '2026-04-15': 'Bahag Bihu',
        '2026-05-01': 'Buddha Purnima',
        '2026-05-09': 'Birthday of Rabindranath',
        '2026-05-28': 'Bakrid',
        '2026-06-26': 'Muharram/Ashura (tentative)',
        '2026-07-16': 'Rath Yatra',
        '2026-08-15': 'Independence Day',
        '2026-08-26': 'Milad un-Nabi (tentative)',
        '2026-08-28': 'Raksha Bandhan',
        '2026-09-04': 'Janmashtami (Smarta)',
        '2026-09-14': 'Ganesh Chaturthi',
        '2026-10-02': 'Mahatma Gandhi Jayanti',
        '2026-10-11': 'First Day of Sharad Navratri',
        '2026-10-17': 'First Day of Durga Puja Festivities',
        '2026-10-18': 'Maha Saptami',
        '2026-10-19': 'Maha Ashtami',
        '2026-10-20': 'Dussehra',
        '2026-10-26': 'Maharishi Valmiki Jayanti',
        '2026-10-29': 'Karaka Chaturthi',
        '2026-11-08': 'Naraka Chaturdasi',
        '2026-11-09': 'Govardhan Puja',
        '2026-11-11': 'Bhai Duj',
        '2026-11-15': 'Chhat Puja (Pratihar Sashthi/Surya Sashthi)',
        '2026-11-24': 'Guru Nanak Jayanti',
        '2026-12-23': 'Hazarat Ali\'s Birthday',
        '2026-12-24': 'Christmas Eve',
        '2026-12-25': 'Christmas',
        '2027-01-01': 'New Year\'s Day',
        '2027-01-15': 'Makar Sankranti',
        '2027-01-26': 'Republic Day',
        '2027-02-09': 'Ramadan Start (tentative)',
        '2027-02-11': 'Vasant Panchami',
        '2027-02-19': 'Shivaji Jayanti',
        '2027-03-06': 'Maha Shivaratri',
        '2027-03-10': 'Ramzan Id (tentative)',
        '2027-03-22': 'Holi',
        '2027-03-26': 'Good Friday',
        '2027-03-28': 'Easter Day',
        '2027-04-07': 'Gudi Padwa',
        '2027-04-14': 'Ambedkar Jayanti',
        '2027-04-15': 'Rama Navami',
        '2027-05-17': 'Bakrid (tentative)',
        '2027-06-16': 'Muharram/Ashura (tentative)',
        '2027-07-05': 'Rath Yatra',
        '2027-08-15': 'Independence Day',
        '2027-08-17': 'Raksha Bandhan',
        '2027-08-25': 'Janmashtami',
        '2027-09-04': 'Ganesh Chaturthi',
        '2027-09-12': 'Onam',
        '2027-09-30': 'First Day of Sharad Navratri',
        '2027-10-02': 'Mahatma Gandhi Jayanti',
        '2027-10-05': 'First Day of Durga Puja Festivities',
        '2027-10-09': 'Dussehra',
        '2027-10-18': 'Karaka Chaturthi',
        '2027-10-29': 'Diwali/Deepavali',
        '2027-10-31': 'Bhai Duj',
        '2027-11-04': 'Chhat Puja (Pratihar Sashthi/Surya Sashthi)',
        '2027-11-24': 'Guru Tegh Bahadur\'s Martyrdom Day',
        '2027-12-12': 'Hazarat Ali\'s Birthday',
        '2027-12-24': 'Christmas Eve',
        '2027-12-25': 'Christmas',
        '2028-01-01': 'New Year\'s Day',
        '2028-01-15': 'Makar Sankranti',
        '2028-01-26': 'Republic Day',
        '2028-01-29': 'Ramadan Start (tentative)',
        '2028-01-31': 'Vasant Panchami',
        '2028-02-19': 'Shivaji Jayanti',
        '2028-02-23': 'Maha Shivaratri',
        '2028-02-27': 'Ramzan Id (tentative)',
        '2028-03-11': 'Holi',
        '2028-03-27': 'Ugadi',
        '2028-04-03': 'Rama Navami',
        '2028-04-14': 'Good Friday',
        '2028-04-16': 'Easter Day',
        '2028-05-06': 'Bakrid (tentative)',
        '2028-06-04': 'Muharram/Ashura (tentative)',
        '2028-06-24': 'Rath Yatra',
        '2028-08-05': 'Raksha Bandhan',
        '2028-08-13': 'Janmashtami',
        '2028-08-15': 'Independence Day',
        '2028-08-23': 'Ganesh Chaturthi',
        '2028-09-01': 'Onam',
        '2028-09-19': 'First Day of Sharad Navratri',
        '2028-09-24': 'First Day of Durga Puja Festivities',
        '2028-09-27': 'Dussehra',
        '2028-10-02': 'Mahatma Gandhi Jayanti',
        '2028-10-07': 'Karaka Chaturthi',
        '2028-10-17': 'Diwali/Deepavali',
        '2028-10-19': 'Bhai Duj',
        '2028-10-23': 'Chhat Puja (Pratihar Sashthi/Surya Sashthi)',
        '2028-11-24': 'Guru Tegh Bahadur\'s Martyrdom Day',
        '2028-12-01': 'Hazarat Ali\'s Birthday',
        '2028-12-24': 'Christmas Eve',
        '2028-12-25': 'Christmas',
      };
    });
    if (mounted) setState(() => _isLoadingHolidays = false);
  }

  Widget _buildTaskSubTabBtn(String title, {int badgeCount = 0}) {
    final isSelected = _taskSubTab == title;
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() {
        _taskSubTab = title;
        if (title == 'CALENDAR') {
          _calendarMonth = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            1,
          );
          _selectedCalendarDate = null;
        }
      }),
      child: badgeCount > 0
          ? Badge(label: Text(badgeCount.toString()), child: child)
          : child,
    );
  }

  Widget _buildTasksTab() {
    final state = context.watch<AppState>();
    final int pendingCount = state.tasks.where((t) {
      if (t.isCompleted) return false;
      if ((t.taskType ?? '').toLowerCase().contains('upload') ||
          t.title.toLowerCase().contains('upload'))
        return false;
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final isToday =
          t.deadline.year == now.year &&
          t.deadline.month == now.month &&
          t.deadline.day == now.day;
      final isOverdue = t.deadline.isBefore(todayStart);
      return isToday || isOverdue;
    }).length;
    final int myTasksCount = state.tasks
        .where((t) => t.assignedTo == state.activePersona.id && !t.isCompleted)
        .length;
    final int reviewCount = state.tasks
        .where(
          (t) => (t.isSubmitted && !t.isCompleted) || t.isPostponeRequested,
        )
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTaskSubTabBtn('CALENDAR'),
              const SizedBox(width: 4),
              _buildTaskSubTabBtn('MY TASKS', badgeCount: myTasksCount),
              const SizedBox(width: 4),
              _buildTaskSubTabBtn('PENDING', badgeCount: pendingCount),
              const SizedBox(width: 4),
              _buildTaskSubTabBtn('REVIEW', badgeCount: reviewCount),
              const SizedBox(width: 4),
              _buildTaskSubTabBtn('COMPLETED'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_taskSubTab == 'CALENDAR') _buildTaskCalendarSubTab(),
        if (_taskSubTab == 'MY TASKS') _buildTaskMyTasksSubTab('CFO'),
        if (_taskSubTab == 'PENDING') _buildTaskPendingSubTab(),
        if (_taskSubTab == 'REVIEW') _buildTaskReviewSubTab(),
        if (_taskSubTab == 'COMPLETED') _buildTaskCompletedSubTab(),
      ],
    );
  }

  Widget _buildTaskCalendarSubTab() {
    final state = context.watch<AppState>();
    final now = DateTime.now();
    final firstDay = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final daysInMonth = DateTime(
      _calendarMonth.year,
      _calendarMonth.month + 1,
      0,
    ).day;
    final startOffset = firstDay.weekday % 7;

    final allTasks = state.tasks.where((t) {
      final title = t.title.toLowerCase();
      final typeStr = (t.taskType ?? '').toLowerCase();
      return !title.contains('upload') && !typeStr.contains('upload');
    }).toList();
    final monthNames = [
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
    ];

    List<Task> selectedTasks = [];
    if (_selectedCalendarDate != null) {
      selectedTasks = allTasks
          .where(
            (t) =>
                t.deadline.day == _selectedCalendarDate!.day &&
                t.deadline.month == _selectedCalendarDate!.month &&
                t.deadline.year == _selectedCalendarDate!.year,
          )
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SageCalendar(
          currentMonth: _calendarMonth,
          onPreviousMonth: () => setState(
            () => _calendarMonth = DateTime(
              _calendarMonth.year,
              _calendarMonth.month - 1,
              1,
            ),
          ),
          onNextMonth: () => setState(
            () => _calendarMonth = DateTime(
              _calendarMonth.year,
              _calendarMonth.month + 1,
              1,
            ),
          ),
          legend: Wrap(
            spacing: 12,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withOpacity(0.2),
                      border: Border.all(color: Colors.deepOrange),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "#",
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Video",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.2),
                      border: Border.all(color: Colors.teal),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "#",
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Design/Post",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.2),
                      border: Border.all(color: Colors.indigo),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "#",
                      style: TextStyle(
                        color: Colors.indigo,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Active Client",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      border: Border.all(color: Colors.purple),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "#",
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Lead Mtg",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withOpacity(0.2),
                      border: Border.all(color: Colors.blueGrey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "#",
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Other",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.8,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          cellBuilder: (context, date) {
            final day = date.day;
            final dateStr =
                "${date.year}-${date.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
            final holiday = _googleHolidays[dateStr];

            final isWeekend =
                date.weekday == DateTime.saturday ||
                date.weekday == DateTime.sunday;
            final isToday =
                day == now.day &&
                date.month == now.month &&
                date.year == now.year;
            final isSelected =
                _selectedCalendarDate?.day == day &&
                _selectedCalendarDate?.month == date.month &&
                _selectedCalendarDate?.year == date.year;

            final dayTasks = allTasks
                .where(
                  (t) =>
                      t.deadline.day == day &&
                      t.deadline.month == date.month &&
                      t.deadline.year == date.year,
                )
                .toList();

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCalendarDate = null;
                  } else {
                    _selectedCalendarDate = date;
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: isSelected ? 2.5 : 1.0,
                  ),
                  color: isSelected
                      ? const Color(0xFFFFF9C4)
                      : (isToday
                            ? SageColors.primaryContainer
                            : (holiday != null
                                  ? SageColors.secondaryContainer
                                  : (isWeekend
                                        ? const Color(0xFFEEEEEE)
                                        : Colors.white))),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      "$day",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: holiday != null
                            ? SageColors.secondary
                            : Colors.black,
                        fontSize: 12,
                      ),
                    ),
                    if (holiday != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Text(
                          holiday,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 8,
                            color: SageColors.secondary,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                      ),
                    const SizedBox(height: 2),
                    Builder(
                      builder: (ctx) {
                        int vCount = 0;
                        int pCount = 0;
                        int aCount = 0;
                        int lCount = 0;
                        int oCount = 0;
                        for (var t in dayTasks) {
                          final title = t.title.toLowerCase();
                          if (title.contains('video'))
                            vCount++;
                          else if (title.contains('post') ||
                              title.contains('design'))
                            pCount++;
                          else if (title.contains('active client'))
                            aCount++;
                          else if (title.contains('lead') ||
                              title.contains('marketing'))
                            lCount++;
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange.withOpacity(0.2),
                                  border: Border.all(color: Colors.deepOrange),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  vCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.deepOrange,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (pCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withOpacity(0.2),
                                  border: Border.all(color: Colors.teal),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  pCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.teal,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (aCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.withOpacity(0.2),
                                  border: Border.all(color: Colors.indigo),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  aCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.indigo,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (lCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.2),
                                  border: Border.all(color: Colors.purple),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  lCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.purple,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (oCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.withOpacity(0.2),
                                  border: Border.all(color: Colors.blueGrey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  oCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (_selectedCalendarDate != null) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {}, // Consume taps so the global unselect doesn't fire
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5E1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(3, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "TASKS FOR ${_selectedCalendarDate!.day}/${_selectedCalendarDate!.month}/${_selectedCalendarDate!.year}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => setState(
                          () => _isAddTaskExpanded = !_isAddTaskExpanded,
                        ),
                        icon: Icon(
                          _isAddTaskExpanded ? Icons.close : Icons.add,
                          size: 16,
                        ),
                        label: Text(_isAddTaskExpanded ? "CLOSE" : "ADD TASK"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isAddTaskExpanded) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _newTaskType,
                            decoration: const InputDecoration(
                              labelText: "Type of Task",
                            ),
                            dropdownColor: Colors.white,
                            items:
                                [
                                      'Daily Video',
                                      'Daily Post',
                                      'Miscellaneous',
                                      'Session',
                                      'Lead Meeting',
                                      'Active Client Meeting',
                                      'Product Listing',
                                      'Photo Generation',
                                    ]
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) => setState(() {
                              _newTaskType = v!;
                              _newTaskAssigneeIds = [];
                              _newTaskClients = [];
                              _sessionVideographerId = null;
                              _dailyVideoAssigneeId = null;
                              _sessionClientIds = [];
                              _meetingIsPhysical = true;
                            }),
                          ),
                          const SizedBox(height: 12),

                          if (_newTaskType == 'Session') ...[
                            DropdownButtonFormField<String>(
                              value: _sessionVideographerId,
                              decoration: const InputDecoration(
                                labelText: "Select Videographer",
                              ),
                              dropdownColor: Colors.white,
                              items: [
                                const DropdownMenuItem(
                                  value: 'COF-PRI-001',
                                  child: Text("CFO Priyajit"),
                                ),
                                ...state.employees
                                    .where((e) => e.hasRole('videographer'))
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e.id,
                                        child: Text(e.name),
                                      ),
                                    ),
                              ],
                              onChanged: (v) => setState(() {
                                _sessionVideographerId = v;
                                _sessionClientIds = [];
                              }),
                            ),
                            const SizedBox(height: 10),
                            if (_sessionVideographerId != null) ...[
                              Builder(
                                builder: (ctx) {
                                  final videographerClients = state.clients
                                      .where((c) {
                                        if (c.status.toLowerCase() == 'lead')
                                          return false;
                                        if (_sessionVideographerId ==
                                            'COF-PRI-001')
                                          return true;
                                        return c.assignedVideographerId ==
                                            _sessionVideographerId;
                                      })
                                      .toList();
                                  final dateKey =
                                      _selectedCalendarDate
                                          ?.toString()
                                          .substring(0, 10) ??
                                      '';
                                  final existingSessionsOnDate = state.tasks
                                      .where(
                                        (t) =>
                                            t.taskType == 'Session' &&
                                            t.assignedTo ==
                                                _sessionVideographerId &&
                                            t.deadline.toString().substring(
                                                  0,
                                                  10,
                                                ) ==
                                                dateKey,
                                      )
                                      .length;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (existingSessionsOnDate >= 3)
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.red,
                                            ),
                                          ),
                                          child: const Text(
                                            "• Max 3 clients already booked on this date.",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        )
                                      else ...[
                                        Text(
                                          "Select Clients (max ${3 - existingSessionsOnDate} more allowed)",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        if (videographerClients.isEmpty)
                                          const Text(
                                            "No clients assigned to this videographer.",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          )
                                        else
                                          ...videographerClients.map((c) {
                                            final isSelected = _sessionClientIds
                                                .contains(c.id);
                                            return CheckboxListTile(
                                              dense: true,
                                              contentPadding: EdgeInsets.zero,
                                              title: Text(
                                                _sessionVideographerId ==
                                                        'COF-PRI-001'
                                                    ? c.name
                                                    : "${c.name} - ₹${c.sessionRate.toStringAsFixed(0)}/session",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              value: isSelected,
                                              onChanged: (val) {
                                                setState(() {
                                                  if (val == true &&
                                                      _sessionClientIds.length <
                                                          (3 -
                                                              existingSessionsOnDate)) {
                                                    _sessionClientIds.add(c.id);
                                                  } else if (val == false) {
                                                    _sessionClientIds.remove(
                                                      c.id,
                                                    );
                                                  }
                                                });
                                              },
                                            );
                                          }),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.deepPurple,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: _sessionClientIds.isEmpty
                                                ? null
                                                : () async {
                                                    final deadline = DateTime(
                                                      _selectedCalendarDate!
                                                          .year,
                                                      _selectedCalendarDate!
                                                          .month,
                                                      _selectedCalendarDate!
                                                          .day,
                                                      9,
                                                      0,
                                                    );
                                                    for (final clientId
                                                        in _sessionClientIds) {
                                                      final clientName = state
                                                          .clients
                                                          .firstWhere(
                                                            (c) =>
                                                                c.id ==
                                                                clientId,
                                                          )
                                                          .name;
                                                      await context.read<AppState>().assignTask(
                                                        title:
                                                            'Session - $clientName',
                                                        description:
                                                            'Videography session for $clientName on ${_selectedCalendarDate!.toString().substring(0, 10)}',
                                                        assignedTo:
                                                            _sessionVideographerId!,
                                                        deadline: deadline,
                                                        clientId: clientId,
                                                        taskType: 'Session',
                                                        sessionClientIds: [
                                                          clientId,
                                                        ],
                                                        isApprovedByVideographer:
                                                            _sessionVideographerId ==
                                                            'COF-PRI-001',
                                                      );
                                                    }
                                                    setState(() {
                                                      _isAddTaskExpanded =
                                                          false;
                                                      _sessionVideographerId =
                                                          null;
                                                      _sessionClientIds = [];
                                                    });
                                                  },
                                            child: const Text(
                                              "BOOK SESSION (PENDING APPROVAL)",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ],
                          ] else if (_newTaskType == 'Miscellaneous') ...[
                            SageMultiSelectDropdown<Map<String, String>>(
                              selectedItems: (() {
                                final options = _getAssigneesForRole(
                                  'General',
                                  state,
                                );
                                return options
                                    .where(
                                      (e) =>
                                          _newTaskAssigneeIds.contains(e['id']),
                                    )
                                    .toList();
                              })(),
                              items: _getAssigneesForRole('General', state),
                              labelBuilder: (item) => item['name']!,
                              labelText: "Assign To",
                              onChanged: (v) => setState(
                                () => _newTaskAssigneeIds = v
                                    .map((e) => e['id']!)
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: SageTextField(
                                    controller: _newTaskTitleCtrl,
                                    label: "Title",
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: _newTaskTime,
                                      );
                                      if (time != null)
                                        setState(() => _newTaskTime = time);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Deadline Time"),
                                          Text(
                                            _newTaskTime.format(context),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SageTextField(
                              controller: _newTaskDescCtrl,
                              label: "Description (Optional)",
                              maxLines: 2,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_newTaskAssigneeIds.isEmpty ||
                                      _newTaskTitleCtrl.text.isEmpty)
                                    return;
                                  final finalDeadline = DateTime(
                                    _selectedCalendarDate!.year,
                                    _selectedCalendarDate!.month,
                                    _selectedCalendarDate!.day,
                                    _newTaskTime.hour,
                                    _newTaskTime.minute,
                                  );
                                  for (final assigneeId
                                      in _newTaskAssigneeIds) {
                                    context.read<AppState>().assignTask(
                                      title: _newTaskTitleCtrl.text,
                                      description: _newTaskDescCtrl.text,
                                      assignedTo: assigneeId,
                                      deadline: finalDeadline,
                                      taskType: 'Miscellaneous',
                                    );
                                  }
                                  setState(() {
                                    _isAddTaskExpanded = false;
                                    _newTaskTitleCtrl.clear();
                                    _newTaskDescCtrl.clear();
                                    _newTaskAssigneeIds = [];
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SageColors.primary,
                                  foregroundColor: Colors.black,
                                ),
                                child: const Text(
                                  "CREATE TASK",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ] else ...[
                            if (_newTaskType != 'Lead Meeting' &&
                                _newTaskType != 'Active Client Meeting') ...[
                              SageMultiSelectDropdown<Client>(
                                selectedItems: state.clients
                                    .where(
                                      (c) => _newTaskClients.contains(c.name),
                                    )
                                    .toList(),
                                items: state.clients
                                    .where(
                                      (c) =>
                                          c.status != 'Lead' &&
                                          c.isApprovedByCeo,
                                    )
                                    .toList(),
                                labelBuilder: (c) => c.name,
                                labelText: "Select Clients",
                                emptyText: "Select active clients",
                                onChanged: (v) => setState(
                                  () => _newTaskClients = v
                                      .map((c) => c.name)
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: _newTaskTime,
                                      );
                                      if (time != null)
                                        setState(() => _newTaskTime = time);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Deadline Time"),
                                          Text(
                                            _newTaskTime.format(context),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_newTaskType == 'Daily Video')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: _dailyVideoAssigneeId,
                                    decoration: const InputDecoration(
                                      labelText: "Select Video Editor",
                                    ),
                                    dropdownColor: Colors.white,
                                    items: [
                                      const DropdownMenuItem(
                                        value: 'COF-PRI-001',
                                        child: Text("CFO Priyajit"),
                                      ),
                                      ...state.employees
                                          .where(
                                            (e) => e.hasRole('video editor'),
                                          )
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e.id,
                                              child: Text(e.name),
                                            ),
                                          ),
                                    ],
                                    onChanged: (v) => setState(
                                      () => _dailyVideoAssigneeId = v,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: SageColors.primary,
                                      foregroundColor: Colors.black,
                                    ),
                                    onPressed:
                                        _dailyVideoAssigneeId == null ||
                                            _newTaskClients.isEmpty
                                        ? null
                                        : () {
                                            final finalDeadline = DateTime(
                                              _selectedCalendarDate!.year,
                                              _selectedCalendarDate!.month,
                                              _selectedCalendarDate!.day,
                                              _newTaskTime.hour,
                                              _newTaskTime.minute,
                                            );
                                            for (final client
                                                in _newTaskClients) {
                                              context.read<AppState>().assignTask(
                                                title: 'Daily Video - $client',
                                                description:
                                                    'Automatically assigned daily video task for $client.',
                                                assignedTo:
                                                    _dailyVideoAssigneeId!,
                                                deadline: finalDeadline,
                                                taskType: 'Daily Video',
                                              );
                                            }
                                            setState(() {
                                              _isAddTaskExpanded = false;
                                              _newTaskClients = [];
                                              _dailyVideoAssigneeId = null;
                                            });
                                          },
                                    child: const Text(
                                      "ASSIGN TASK",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else if (_newTaskType == 'Lead Meeting' ||
                                _newTaskType == 'Active Client Meeting') ...[
                              // Assignee Selection
                              SageMultiSelectDropdown<Map<String, String>>(
                                selectedItems: (() {
                                  final List<Map<String, String>> options = [
                                    {'id': 'CEO-SOH-001', 'name': 'CEO Sohini'},
                                    {
                                      'id': 'COF-PRI-001',
                                      'name': 'CFO Priyajit',
                                    },
                                    {'id': 'COF-RIT-001', 'name': 'CFO Ritam'},
                                  ];
                                  if (_newTaskType == 'Lead Meeting') {
                                    options.addAll(
                                      state.employees
                                          .where((e) => e.hasRole('marketing'))
                                          .map(
                                            (e) => {'id': e.id, 'name': e.name},
                                          ),
                                    );
                                  }
                                  return options
                                      .where(
                                        (e) => _newTaskAssigneeIds.contains(
                                          e['id'],
                                        ),
                                      )
                                      .toList();
                                })(),
                                items: (() {
                                  final List<Map<String, String>> options = [
                                    {'id': 'CEO-SOH-001', 'name': 'CEO Sohini'},
                                    {
                                      'id': 'COF-PRI-001',
                                      'name': 'CFO Priyajit',
                                    },
                                    {'id': 'COF-RIT-001', 'name': 'CFO Ritam'},
                                  ];
                                  if (_newTaskType == 'Lead Meeting') {
                                    options.addAll(
                                      state.employees
                                          .where((e) => e.hasRole('marketing'))
                                          .map(
                                            (e) => {'id': e.id, 'name': e.name},
                                          ),
                                    );
                                  }
                                  return options;
                                })(),
                                labelBuilder: (item) => item['name']!,
                                labelText: "Assign To (Select multiple)",
                                onChanged: (v) => setState(
                                  () => _newTaskAssigneeIds = v
                                      .map((e) => e['id']!)
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Client Selection
                              DropdownButtonFormField<String>(
                                value: _newTaskClients.isNotEmpty
                                    ? _newTaskClients.first
                                    : null,
                                decoration: InputDecoration(
                                  labelText: _newTaskType == 'Lead Meeting'
                                      ? "Select Lead"
                                      : "Select Active Client",
                                ),
                                dropdownColor: Colors.white,
                                items: state.clients
                                    .where((c) {
                                      if (_newTaskType == 'Lead Meeting')
                                        return c.status == 'Lead';
                                      return c.status != 'Lead' &&
                                          c.isApprovedByCeo;
                                    })
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c.id,
                                        child: Text(c.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _newTaskClients = [v!]),
                              ),
                              const SizedBox(height: 12),
                              // Mode toggle
                              SwitchListTile(
                                title: Text(
                                  _meetingIsPhysical
                                      ? "Physical Meeting"
                                      : "Digital Meeting",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                value: _meetingIsPhysical,
                                onChanged: (v) =>
                                    setState(() => _meetingIsPhysical = v),
                                activeColor: Colors.green,
                              ),
                              const SizedBox(height: 12),
                              // Comments
                              SageTextField(
                                controller: _newTaskDescCtrl,
                                label: "Comments",
                                maxLines: 3,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SageColors.primary,
                                ),
                                onPressed:
                                    (_newTaskAssigneeIds.isEmpty ||
                                        _newTaskClients.isEmpty)
                                    ? null
                                    : () {
                                        final finalDeadline = DateTime(
                                          _selectedCalendarDate!.year,
                                          _selectedCalendarDate!.month,
                                          _selectedCalendarDate!.day,
                                          _newTaskTime.hour,
                                          _newTaskTime.minute,
                                        );
                                        final clientName = state.clients
                                            .firstWhere(
                                              (c) =>
                                                  c.id == _newTaskClients.first,
                                            )
                                            .name;
                                        final meetingMode = _meetingIsPhysical
                                            ? "[Physical]"
                                            : "[Digital]";
                                        final title =
                                            "${_newTaskType} - $clientName";
                                        final desc =
                                            "$meetingMode ${_newTaskDescCtrl.text}";

                                        for (final assignee
                                            in _newTaskAssigneeIds) {
                                          context.read<AppState>().assignTask(
                                            title: title,
                                            description: desc,
                                            assignedTo: assignee,
                                            deadline: finalDeadline,
                                            taskType: _newTaskType,
                                            clientId: _newTaskClients.first,
                                          );
                                        }
                                        setState(() {
                                          _isAddTaskExpanded = false;
                                          _newTaskClients = [];
                                          _newTaskAssigneeIds = [];
                                          _newTaskDescCtrl.clear();
                                        });
                                      },
                                child: const Text("SCHEDULE MEETING"),
                              ),
                            ] else if (_newTaskType == 'Daily Post')
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            SageColors.secondaryContainer,
                                        foregroundColor: Colors.black,
                                      ),
                                      onPressed: () {
                                        if (_newTaskClients.isEmpty) return;
                                        final ritam = AppState.personas
                                            .where((p) => p.id == 'COF-RIT-001')
                                            .firstOrNull;
                                        if (ritam == null) return;
                                        final finalDeadline = DateTime(
                                          _selectedCalendarDate!.year,
                                          _selectedCalendarDate!.month,
                                          _selectedCalendarDate!.day,
                                          _newTaskTime.hour,
                                          _newTaskTime.minute,
                                        );
                                        for (final client in _newTaskClients) {
                                          context.read<AppState>().assignTask(
                                            title: 'Daily Post - $client',
                                            description:
                                                'Automatically assigned daily post task for $client.',
                                            assignedTo: ritam.id,
                                            deadline: finalDeadline,
                                            taskType: 'Daily Post',
                                          );
                                        }
                                        setState(() {
                                          _isAddTaskExpanded = false;
                                          _newTaskClients = [];
                                        });
                                      },
                                      child: const Text(
                                        "ASSIGN TO RITAM (CFO)",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            SageColors.tertiaryContainer,
                                        foregroundColor: Colors.black,
                                      ),
                                      onPressed: () {
                                        if (_newTaskClients.isEmpty) return;
                                        // Assign to Graphic Designer (Assume Subhajit or any graphic designer)
                                        final designer = state.employees
                                            .where(
                                              (e) =>
                                                  e.hasRole('graphic') ||
                                                  e.name.toLowerCase().contains(
                                                    'subhajit',
                                                  ),
                                            )
                                            .firstOrNull;
                                        if (designer == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'No Graphic Designer found in employees!',
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        final finalDeadline = DateTime(
                                          _selectedCalendarDate!.year,
                                          _selectedCalendarDate!.month,
                                          _selectedCalendarDate!.day,
                                          _newTaskTime.hour,
                                          _newTaskTime.minute,
                                        );
                                        for (final client in _newTaskClients) {
                                          context.read<AppState>().assignTask(
                                            title: 'Daily Post - $client',
                                            description:
                                                'Automatically assigned daily post task for $client.',
                                            assignedTo: designer.id,
                                            deadline: finalDeadline,
                                            taskType: 'Daily Post',
                                          );
                                        }
                                        setState(() {
                                          _isAddTaskExpanded = false;
                                          _newTaskClients = [];
                                        });
                                      },
                                      child: const Text(
                                        "ASSIGN TO GRAPHIC DESIGNER",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else if (_newTaskType == 'Product Listing' ||
                                _newTaskType == 'Photo Generation')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: _newTaskAssigneeIds.isNotEmpty
                                        ? _newTaskAssigneeIds.first
                                        : null,
                                    decoration: const InputDecoration(
                                      labelText: "Select Ecom Executive",
                                    ),
                                    dropdownColor: Colors.white,
                                    items: [
                                      ...state.employees
                                          .where(
                                            (e) => e.hasRole('ecom executive'),
                                          )
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e.id,
                                              child: Text(e.name),
                                            ),
                                          ),
                                    ],
                                    onChanged: (v) => setState(() {
                                      if (v != null) _newTaskAssigneeIds = [v];
                                    }),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: SageColors.primary,
                                      foregroundColor: Colors.black,
                                    ),
                                    onPressed:
                                        _newTaskAssigneeIds.isEmpty ||
                                            _newTaskClients.isEmpty
                                        ? null
                                        : () {
                                            final finalDeadline = DateTime(
                                              _selectedCalendarDate!.year,
                                              _selectedCalendarDate!.month,
                                              _selectedCalendarDate!.day,
                                              _newTaskTime.hour,
                                              _newTaskTime.minute,
                                            );
                                            for (final client
                                                in _newTaskClients) {
                                              context.read<AppState>().assignTask(
                                                title:
                                                    '$_newTaskType - $client',
                                                description:
                                                    '$_newTaskType task for $client.',
                                                assignedTo:
                                                    _newTaskAssigneeIds.first,
                                                deadline: finalDeadline,
                                                taskType: _newTaskType,
                                              );
                                            }
                                            setState(() {
                                              _isAddTaskExpanded = false;
                                              _newTaskClients = [];
                                              _newTaskAssigneeIds = [];
                                            });
                                          },
                                    child: const Text(
                                      "ASSIGN TASK",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (selectedTasks.isEmpty)
                    const Text(
                      "No tasks scheduled.",
                      style: TextStyle(
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    ...selectedTasks.map((t) {
                      final typeStr = (t.taskType ?? '').toLowerCase();
                      Color typeColor = Colors.black;
                      if (typeStr.contains('video'))
                        typeColor = Colors.blue;
                      else if (typeStr.contains('post') ||
                          typeStr.contains('photo'))
                        typeColor = Colors.orange;
                      else if (typeStr.contains('session') ||
                          typeStr.contains('meeting'))
                        typeColor = Colors.purple;
                      else if (typeStr.contains('product'))
                        typeColor = Colors.brown;
                      else if (typeStr.contains('upload'))
                        typeColor = Colors.orange;
                      else if (typeStr.contains('misc'))
                        typeColor = Colors.grey;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: typeColor == Colors.black
                              ? Colors.white
                              : typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: typeColor == Colors.black
                                ? Colors.black12
                                : typeColor,
                          ),
                        ),
                        child: ExpansionTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          tilePadding: const EdgeInsets.only(right: 12),
                          title: Row(
                            children: [
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        decoration: t.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    if (t.description.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          t.description,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.black54,
                                            decoration: t.isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: t.isCompleted
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: t.isCompleted
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                                child: Text(
                                  t.isCompleted ? "FINISHED" : "PENDING",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: t.isCompleted
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (t.description.isNotEmpty) ...[
                                    Text(
                                      t.description,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        size: 14,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Assigned To: ${_getAssigneeName(t.assignedTo, state)}",
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.assignment_ind,
                                        size: 14,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Assigned By: ${_getAssigneeName(t.assignedBy, state)}",
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Deadline: ${t.deadline.day.toString().padLeft(2, '0')}/${t.deadline.month.toString().padLeft(2, '0')}/${t.deadline.year} at ${t.deadline.hour.toString().padLeft(2, '0')}:${t.deadline.minute.toString().padLeft(2, '0')}",
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.category,
                                        size: 14,
                                        color: Colors.black54,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Type: ${t.taskType ?? 'General Task'}",
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () => context
                                          .read<AppState>()
                                          .approveAndDeleteTask(t.id),
                                      tooltip: 'Delete Task',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // --- Popup Dialog: Add Client / Lead ---
  void _showAddClientDialog(BuildContext context) {
    final state = context.read<AppState>();
    final isLead = _clientSubTab == 'LEADS';
    String localPkg = _clientPackageType;
    String localPeriod = _clientContractPeriod;
    String localLeadProb = _clientLeadProbability;
    String localPaymentMode = 'Running';
    final dueDateDayCtrl = TextEditingController(text: "10");
    String? localVidId;
    String localServiceType = 'Marketing';
    String localEcomPaymentType = 'Monthly';
    final _clientSkuRateCtrl = TextEditingController();
    final _clientDuplicateSkuRateCtrl = TextEditingController();
    final _clientCatalogueRateCtrl = TextEditingController();
    _clientNameCtrl.clear();
    _clientContactNameCtrl.clear();
    _clientContactEmailCtrl.clear();
    _clientContactPhoneCtrl.clear();
    _clientPayableCtrl.clear();
    _clientContactAddressCtrl.clear();
    _clientContactWebsiteCtrl.clear();
    _clientLeadNoteCtrl.clear();
    _clientLeadFollowupCtrl.clear();
    _clientSessionRateCtrl.clear();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: SageColors.background,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: TerminalPanel(
              title: isLead ? "INITIALIZE NEW LEAD" : "INITIALIZE NEW CLIENT",
              child: Column(
                children: [
                  SageTextField(
                    controller: _clientNameCtrl,
                    label: "Company Name",
                  ),
                  const SizedBox(height: 10),
                  SageTextField(
                    controller: _clientContactNameCtrl,
                    label: "Contact Person",
                  ),
                  const SizedBox(height: 10),
                  SageTextField(
                    controller: _clientContactEmailCtrl,
                    label: "Contact Email",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  SageTextField(
                    controller: _clientContactPhoneCtrl,
                    label: "Contact Phone",
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  if (isLead) ...[
                    SageTextField(
                      controller: _clientContactAddressCtrl,
                      label: "Address",
                    ),
                    const SizedBox(height: 10),
                    SageTextField(
                      controller: _clientContactWebsiteCtrl,
                      label: "Website",
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: localLeadProb,
                      decoration: const InputDecoration(
                        labelText: "Conversion Probability",
                      ),
                      dropdownColor: Colors.white,
                      items: ['High', 'Medium', 'Low']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setS(() => localLeadProb = v ?? 'Medium'),
                    ),
                    const SizedBox(height: 10),
                    SageTextField(
                      controller: _clientLeadNoteCtrl,
                      label: "Initial Note / Comment",
                    ),
                    const SizedBox(height: 10),
                    SageTextField(
                      controller: _clientLeadFollowupCtrl,
                      label: "Follow-up Date (YYYY-MM-DD)",
                      hint: "e.g. 2026-07-01",
                    ),
                  ] else ...[
                    SageTextField(
                      controller: _clientPayableCtrl,
                      label: "Monthly Payable (₹)",
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: localPkg,
                      decoration: const InputDecoration(
                        labelText: "Package Type",
                      ),
                      dropdownColor: Colors.white,
                      items: ['Growth', 'Performance']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) => setS(() => localPkg = v ?? 'Growth'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: localPeriod,
                      decoration: const InputDecoration(
                        labelText: "Contract Period",
                      ),
                      dropdownColor: Colors.white,
                      items: ['3 Months', '6 Months', '1 Year']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setS(() => localPeriod = v ?? '3 Months'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String?>(
                      value:
                          state.employees.any(
                            (e) =>
                                e.id == localVidId && e.hasRole('videographer'),
                          )
                          ? localVidId
                          : null,
                      decoration: const InputDecoration(
                        labelText: "Assigned Videographer",
                      ),
                      dropdownColor: Colors.white,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text("None"),
                        ),
                        const DropdownMenuItem<String?>(
                          value: 'COF-PRI-001',
                          child: Text("CFO Priyajit"),
                        ),
                        ...state.employees
                            .where((e) => e.hasRole('videographer'))
                            .map(
                              (e) => DropdownMenuItem<String?>(
                                value: e.id,
                                child: Text(e.name),
                              ),
                            ),
                      ],
                      onChanged: (v) => setS(() => localVidId = v),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: localPaymentMode,
                      decoration: const InputDecoration(
                        labelText: "Payment Mode",
                      ),
                      dropdownColor: Colors.white,
                      items: ['Advance', 'Running', 'Late']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setS(() => localPaymentMode = v ?? 'Running'),
                    ),
                    const SizedBox(height: 10),
                    SageTextField(
                      controller: dueDateDayCtrl,
                      label: "Due Date (1-31)",
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    SageTextField(
                      controller: _clientSessionRateCtrl,
                      label: "Session Rate (₹)",
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: localServiceType,
                      decoration: const InputDecoration(
                        labelText: "Service Type",
                      ),
                      dropdownColor: Colors.white,
                      items: ['Marketing', 'E-Commerce', 'Video Production']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setS(() => localServiceType = v ?? 'Marketing'),
                    ),
                    if (localServiceType.toLowerCase().contains(
                      'commerce',
                    )) ...[
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: localEcomPaymentType,
                        decoration: const InputDecoration(
                          labelText: "Ecom Payment Type",
                        ),
                        dropdownColor: Colors.white,
                        items: ['Monthly', 'Per SKU']
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setS(() => localEcomPaymentType = v ?? 'Monthly'),
                      ),
                      if (localEcomPaymentType == 'Per SKU') ...[
                        const SizedBox(height: 10),
                        SageTextField(
                          controller: _clientSkuRateCtrl,
                          label: "Per SKU Rate (₹)",
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        SageTextField(
                          controller: _clientDuplicateSkuRateCtrl,
                          label: "Per Duplicate SKU Rate (₹)",
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        SageTextField(
                          controller: _clientCatalogueRateCtrl,
                          label: "Per Catalogue Rate (₹)",
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ],
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_clientNameCtrl.text.trim().isEmpty) return;
                        final c = Client(
                          id: 'CL-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                          name: _clientNameCtrl.text,
                          contact: ClientContact(
                            name: _clientContactNameCtrl.text,
                            email: _clientContactEmailCtrl.text,
                            phone: _clientContactPhoneCtrl.text,
                            address: isLead
                                ? _clientContactAddressCtrl.text
                                : '',
                            website: isLead
                                ? _clientContactWebsiteCtrl.text
                                : '',
                          ),
                          monthlyPayable: isLead
                              ? 0.0
                              : (double.tryParse(_clientPayableCtrl.text) ??
                                    0.0),
                          packageType: isLead ? 'Growth' : localPkg,
                          contractPeriod: isLead ? '3 Months' : localPeriod,
                          contractDate: DateTime.now(),
                          status: isLead ? 'Lead' : 'Active',
                          conversionProbability: isLead
                              ? localLeadProb
                              : 'Medium',
                          notes: isLead && _clientLeadNoteCtrl.text.isNotEmpty
                              ? [_clientLeadNoteCtrl.text]
                              : [],
                          followUpDates:
                              isLead && _clientLeadFollowupCtrl.text.isNotEmpty
                              ? [_clientLeadFollowupCtrl.text]
                              : [],
                          assignedVideographerId: isLead ? null : localVidId,
                          paymentMode: isLead ? 'Running' : localPaymentMode,
                          dueDateDay: isLead
                              ? 10
                              : (int.tryParse(dueDateDayCtrl.text) ?? 10),
                          sessionRate: isLead
                              ? 0
                              : (double.tryParse(_clientSessionRateCtrl.text) ??
                                    0.0),
                          serviceType: localServiceType,
                          ecomPaymentType: localEcomPaymentType,
                          clientSkuRate:
                              double.tryParse(_clientSkuRateCtrl.text) ?? 0.0,
                          clientDuplicateSkuRate:
                              double.tryParse(
                                _clientDuplicateSkuRateCtrl.text,
                              ) ??
                              0.0,
                          clientCatalogueRate:
                              double.tryParse(_clientCatalogueRateCtrl.text) ??
                              0.0,
                        );
                        state.addClient(c);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SageColors.yellowAccent,
                      ),
                      child: Text(isLead ? "SAVE LEAD" : "INITIALIZE CONTRACT"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, String>> _getAssigneesForRole(String? role, AppState state) {
    if (role == null) return [];
    List<Map<String, String>> list = [];
    if (role == 'Video Editor') {
      list.add({'id': 'COF-PRI-001', 'name': 'Priyajit (CFO)'});
      final debjit = state.employees
          .where((e) => e.name.toLowerCase().contains('debjit'))
          .firstOrNull;
      if (debjit != null) list.add({'id': debjit.id, 'name': debjit.name});
    } else if (role == 'Videographer') {
      list.add({'id': 'COF-PRI-001', 'name': 'Priyajit (CFO)'});
      final poulom = state.employees
          .where((e) => e.name.toLowerCase().contains('poulom'))
          .firstOrNull;
      if (poulom != null) list.add({'id': poulom.id, 'name': poulom.name});
    } else if (role == 'Marketing Executive') {
      list.add({'id': 'CEO-SOH-001', 'name': 'Sohini (CEO)'});
      list.add({'id': 'COF-PRI-001', 'name': 'Priyajit (CFO)'});
      list.add({'id': 'COF-RIT-001', 'name': 'Ritam (CFO)'});
    } else {
      list.addAll(
        AppState.personas.map(
          (p) => {'id': p.id, 'name': "${p.name} (${p.roleLabel})"},
        ),
      );
      list.addAll(state.employees.map((e) => {'id': e.id, 'name': e.name}));
    }
    return list;
  }

  String _getAssigneeName(String id, AppState state) {
    final p = AppState.personas.where((p) => p.id == id).firstOrNull;
    if (p != null) return p.name;
    final e = state.employees.where((e) => e.id == id).firstOrNull;
    if (e != null) return e.name;
    return id;
  }

  Widget _buildTaskMyTasksSubTab(String personaPrefix) {
    final state = context.watch<AppState>();
    final myTasks = state.tasks
        .where((t) => t.assignedTo == state.activePersona.id && !t.isCompleted)
        .toList();
    myTasks.sort((a, b) => a.deadline.compareTo(b.deadline));

    if (myTasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: const Center(
          child: Text(
            'NO PENDING TASKS FOR YOU',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: SageColors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: myTasks.map((t) {
        final typeStr = (t.taskType ?? '').toLowerCase();
        Color typeColor = Colors.black;
        if (typeStr.contains('video'))
          typeColor = Colors.blue;
        else if (typeStr.contains('post') || typeStr.contains('photo'))
          typeColor = Colors.orange;
        else if (typeStr.contains('session') || typeStr.contains('meeting'))
          typeColor = Colors.purple;
        else if (typeStr.contains('product'))
          typeColor = Colors.brown;
        else if (typeStr.contains('upload'))
          typeColor = Colors.orange;
        else if (typeStr.contains('misc'))
          typeColor = Colors.grey;

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: typeColor == Colors.black ? Colors.white : typeColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2.0),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              unselectedWidgetColor: typeColor == Colors.black
                  ? Colors.black54
                  : Colors.white70,
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 0,
              ),
              iconColor: typeColor == Colors.black
                  ? Colors.black54
                  : Colors.white,
              collapsedIconColor: typeColor == Colors.black
                  ? Colors.black54
                  : Colors.white,
              leading: Theme(
                data: ThemeData(
                  unselectedWidgetColor: typeColor == Colors.black
                      ? Colors.black54
                      : Colors.white70,
                ),
                child: Checkbox(
                  value: t.isSubmitted,
                  activeColor: typeColor == Colors.black
                      ? SageColors.primary
                      : Colors.white,
                  checkColor: typeColor == Colors.black
                      ? Colors.white
                      : typeColor,
                  onChanged:
                      DateTime.now().isBefore(
                        DateTime(
                          t.deadline.year,
                          t.deadline.month,
                          t.deadline.day,
                        ),
                      )
                      ? null
                      : (val) {
                          if (val == true) {
                            context.read<AppState>().submitTask(t.id);
                          } else {
                            context.read<AppState>().unsubmitTask(t.id);
                          }
                        },
                ),
              ),
              title: Text(
                t.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: typeColor == Colors.black
                      ? Colors.black
                      : Colors.white,
                ),
              ),
              subtitle: Text(
                "Deadline: ${t.deadline.day}/${t.deadline.month} \u2022 ${(t.taskType ?? 'Task').toUpperCase()}",
                style: TextStyle(
                  color: typeColor == Colors.black
                      ? Colors.black54
                      : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                if (t.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        t.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: typeColor == Colors.black
                              ? Colors.black87
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTaskPendingSubTab() {
    final state = context.watch<AppState>();
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final pendingTasks = state.tasks.where((t) {
      if (t.isCompleted) return false;
      if ((t.taskType ?? '').toLowerCase().contains('upload') ||
          t.title.toLowerCase().contains('upload'))
        return false;
      final isToday =
          t.deadline.year == now.year &&
          t.deadline.month == now.month &&
          t.deadline.day == now.day;
      final isOverdue = t.deadline.isBefore(todayStart);
      return isToday || isOverdue;
    }).toList();
    pendingTasks.sort((a, b) => a.deadline.compareTo(b.deadline));

    if (pendingTasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: const Center(
          child: Text(
            'NO PENDING WORKS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: SageColors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: pendingTasks.map((t) {
        final typeStr = (t.taskType ?? '').toLowerCase();
        Color typeColor = Colors.black;
        if (typeStr.contains('video'))
          typeColor = Colors.blue;
        else if (typeStr.contains('post') || typeStr.contains('photo'))
          typeColor = Colors.orange;
        else if (typeStr.contains('session') || typeStr.contains('meeting'))
          typeColor = Colors.purple;
        else if (typeStr.contains('product'))
          typeColor = Colors.brown;
        else if (typeStr.contains('upload'))
          typeColor = Colors.orange;
        else if (typeStr.contains('misc'))
          typeColor = Colors.grey;

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: typeColor == Colors.black ? Colors.white : typeColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: typeColor == Colors.black
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                    if (t.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          t.description,
                          style: TextStyle(
                            fontSize: 11,
                            color: typeColor == Colors.black
                                ? Colors.black54
                                : Colors.white70,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    (t.taskType ?? 'Task').toUpperCase(),
                    style: TextStyle(
                      color: typeColor == Colors.black
                          ? Colors.grey
                          : Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${_getAssigneeName(t.assignedTo, state)} | ${t.deadline.day}/${t.deadline.month}",
                    style: TextStyle(
                      color: typeColor == Colors.black
                          ? Colors.red.shade700
                          : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTaskReviewSubTab() {
    final state = context.watch<AppState>();
    final pendingTasks = state.tasks
        .where(
          (t) => (t.isSubmitted && !t.isCompleted) || t.isPostponeRequested,
        )
        .toList();

    // Sort tasks by deadline (oldest first)
    pendingTasks.sort((a, b) => a.deadline.compareTo(b.deadline));

    if (pendingTasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: const Center(
          child: Text(
            'NO TASKS PENDING REVIEW',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: SageColors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: pendingTasks.map((t) {
        Color typeColor = Colors.black;
        final submissionDateStr = t.submittedAt != null
            ? "${t.submittedAt!.day.toString().padLeft(2, '0')}/${t.submittedAt!.month.toString().padLeft(2, '0')} at ${t.submittedAt!.hour.toString().padLeft(2, '0')}:${t.submittedAt!.minute.toString().padLeft(2, '0')}"
            : "Unknown";
        final deadlineStr =
            "${t.deadline.day.toString().padLeft(2, '0')}/${t.deadline.month.toString().padLeft(2, '0')}";

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: typeColor == Colors.black
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                        if (t.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              t.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: typeColor == Colors.black
                                    ? Colors.black54
                                    : Colors.white70,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    "${_getAssigneeName(t.assignedTo, state)}",
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Deadline: $deadlineStr",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Submitted: $submissionDateStr",
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
              if (t.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  t.description,
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                ),
              ],
              if (t.isPostponeRequested) ...[
                const SizedBox(height: 6),
                Text(
                  'REQUESTED POSTPONE: ${t.deadline.day}/${t.deadline.month} -> ${t.postponeRequestedDate?.day}/${t.postponeRequestedDate?.month}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.deepOrange,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 6),
                const Text(
                  'REQUESTED COMPLETION',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: SageColors.primary,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      if (t.isPostponeRequested) {
                        context.read<AppState>().rejectPostponeTask(t.id);
                      } else {
                        context.read<AppState>().rejectTask(t.id);
                      }
                    },
                    child: const Text(
                      'REJECT',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Builder(
                    builder: (ctx) {
                      bool canApprove = true;
                      if (t.uploadTaskId != null) {
                        try {
                          final uTask = state.tasks.firstWhere(
                            (x) => x.id == t.uploadTaskId,
                          );
                          if (!uTask.isSubmitted && !uTask.isCompleted) {
                            canApprove = false;
                          }
                        } catch (_) {}
                      }
                      return ElevatedButton(
                        onPressed: canApprove
                            ? () {
                                if (t.isPostponeRequested) {
                                  context.read<AppState>().approvePostponeTask(
                                    t.id,
                                  );
                                } else {
                                  context.read<AppState>().approveTask(t.id);
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canApprove
                              ? Colors.green
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 0,
                          ),
                        ),
                        child: Text(
                          canApprove ? 'APPROVE' : 'AWAITING UPLOAD',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTaskCompletedSubTab() {
    final state = context.watch<AppState>();
    final completedTasks = state.tasks.where((t) => t.isCompleted).toList();
    completedTasks.sort((a, b) => b.deadline.compareTo(a.deadline));
    // Sort completed tasks to show newest first, though we don't have completedAt, we can sort by deadline for now.
    completedTasks.sort((a, b) => b.deadline.compareTo(a.deadline));

    if (completedTasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: const Center(
          child: Text(
            'NO COMPLETED TASKS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: SageColors.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: completedTasks.take(50).map((t) {
        // Limit to 50 for performance
        Color typeColor = Colors.black;
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    if (t.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          t.description,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                "${_getAssigneeName(t.assignedTo, state)}",
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- --- --- --- TAB 4: FINANCE --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

  String _cfFinanceChartTab = 'WEEKLY';
  final _cfFinLabelCtrl = TextEditingController();
  final _cfFinAmountCtrl = TextEditingController();
  bool _cfFinIsIncome = true;
  String _cfFinCategory = 'Consulting';
  String _cfFinServiceType = 'Marketing';
  String? _cfFinMEId;

  Widget _buildDetailedShareRow(String title, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            "₹${value.toStringAsFixed(0)}",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: value >= 0 ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceTab() {
    final state = context.watch<AppState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main balance box - tappable accordion
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () =>
              setState(() => _showDetailedShares = !_showDetailedShares),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _showDetailedShares
                  ? const Color(0xFFF5F0E6)
                  : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "₹${state.netBalance.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "TOTAL NET RUNNING BALANCE",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: SageColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 6),
                            AnimatedRotation(
                              turns: _showDetailedShares ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                size: 16,
                                color: SageColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _showAddLedgerDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SageColors.tertiary,
                      ),
                      child: const Text("+ LEDGER"),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Segmented Purple progress bar
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _showDetailedShares
                        ? Colors.white12
                        : SageColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _showDetailedShares
                          ? Colors.white24
                          : Colors.black,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: (state.totalIncome > 0
                        ? (state.netBalance / state.totalIncome).clamp(0.0, 1.0)
                        : 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: SageColors.tertiary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                // --- Profit share accordion ---
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _showDetailedShares
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Builder(
                    builder: (context) {
                      final shares = state.profitShares;
                      final ritam = shares['ritam'] ?? 0.0;
                      final priyajit = shares['priyajit'] ?? 0.0;
                      final mktEx = shares['marketingEx'] ?? 0.0;
                      final total = ritam + priyajit + mktEx;
                      Widget shareRow(
                        String name,
                        double amount,
                        Color color,
                        IconData icon,
                      ) {
                        final pct = total > 0 ? (amount / total * 100) : 0.0;
                        return Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          icon,
                                          color: color,
                                          size: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "₹${(amount == amount.truncateToDouble() ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2))}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 6,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: total > 0
                                      ? (amount / total).clamp(0.0, 1.0)
                                      : 0.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Divider(color: Colors.black12),
                          const Text(
                            "PROFIT SHARE BREAKDOWN",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              letterSpacing: 1.5,
                            ),
                          ),
                          shareRow(
                            "Ritam Ghosh",
                            ritam,
                            const Color(0xFF00796B),
                            Icons.person,
                          ),
                          shareRow(
                            "Priyajit Bhowmik",
                            priyajit,
                            Colors.blue,
                            Icons.person,
                          ),
                          if (mktEx > 0)
                            shareRow(
                              "Marketing Executive",
                              mktEx,
                              const Color(0xFFCE93D8),
                              Icons.campaign,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Income / Expenses Stat Grid
        Row(
          children: [
            Expanded(
              child: StatChip(
                label: "INFLOW",
                value: "₹${state.totalIncome.toStringAsFixed(0)}",
                valueColor: SageColors.primary,
                icon: Icons.trending_up,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatChip(
                label: "OUTFLOW",
                value: "₹${state.totalExpenses.toStringAsFixed(0)}",
                valueColor: SageColors.secondary,
                icon: Icons.trending_down,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 6-Month Income & Clients Chart
        Builder(
          builder: (context) {
            final now = DateTime.now();
            final monthNames = [
              'Jan',
              'Feb',
              'Mar',
              'Apr',
              'May',
              'Jun',
              'Jul',
              'Aug',
              'Sep',
              'Oct',
              'Nov',
              'Dec',
            ];
            List<String> labels = [];
            List<double> values = [];
            List<double> lineValues = [];
            List<String> keys = [];

            for (int i = 5; i >= 0; i--) {
              int m = now.month - i;
              int y = now.year;
              if (m <= 0) {
                m += 12;
                y -= 1;
              }
              labels.add(monthNames[m - 1]);
              String key = '$y-${m.toString().padLeft(2, '0')}';
              keys.add(key);

              bool isDynamic = y > 2026 || (y == 2026 && m >= 7);
              if (isDynamic) {
                double dynamicInflow = state.finances
                    .where(
                      (f) =>
                          f.isIncome && f.date.year == y && f.date.month == m,
                    )
                    .fold(0.0, (sum, f) => sum + f.amount);
                values.add(dynamicInflow);

                if (y == now.year && m == now.month) {
                  int currentActive = state.clients
                      .where((c) => c.status != 'Lead' && c.isApprovedByCeo)
                      .length;
                  lineValues.add(currentActive.toDouble());
                  if (state.monthlyActiveClients[key] != currentActive) {
                    Future.microtask(
                      () =>
                          state.updateMonthlyActiveClients(key, currentActive),
                    );
                  }
                } else {
                  lineValues.add(
                    (state.monthlyActiveClients[key] ?? 0).toDouble(),
                  );
                }
              } else {
                values.add(state.netRunningBalance[key] ?? 0.0);
                lineValues.add(
                  (state.monthlyActiveClients[key] ?? 0).toDouble(),
                );
              }
            }

            double maxVal = values.isEmpty
                ? 1000
                : values.reduce((a, b) => a > b ? a : b);
            if (maxVal == 0) maxVal = 1000;

            double maxLineVal = lineValues.isEmpty
                ? 10
                : lineValues.reduce((a, b) => a > b ? a : b);
            if (maxLineVal == 0) maxLineVal = 10;

            double expectedMonthlyFees = state.clients
                .where((c) => c.status != 'Lead' && c.isApprovedByCeo)
                .fold(
                  0.0,
                  (sum, c) => sum + c.getPayableForMonth(now.month, now.year),
                );

            double currentMonthInflow = state.finances
                .where(
                  (f) =>
                      f.isIncome &&
                      f.date.year == now.year &&
                      f.date.month == now.month,
                )
                .fold(0.0, (sum, f) => sum + f.amount);

            double deficit = expectedMonthlyFees - currentMonthInflow;

            int currentActiveCount = state.clients
                .where((c) => c.status != 'Lead' && c.isApprovedByCeo)
                .length;
            double avgFee = currentActiveCount > 0
                ? expectedMonthlyFees / currentActiveCount
                : 0.0;

            final List<String> projLabels = [];
            final List<double> projValues = [];
            for (int i = 0; i <= 5; i++) {
              int m = now.month + i;
              int y = now.year;
              if (m > 12) {
                m -= 12;
                y += 1;
              }
              projLabels.add(DateFormat('MMM yyyy').format(DateTime(y, m)));

              if (i == 0) {
                projValues.add(deficit > 0 ? deficit : 0.0);
              } else {
                projValues.add(0.0);
              }
            }
            double maxProjVal = projValues.isEmpty
                ? 10
                : projValues.reduce(max);
            if (maxProjVal == 0) maxProjVal = 100;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "Expected: \u20B9${expectedMonthlyFees.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: deficit > 20000
                            ? Colors.redAccent.withOpacity(0.2)
                            : (deficit > 0
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1)),
                        border: Border.all(
                          color: deficit > 20000
                              ? Colors.redAccent
                              : (deficit > 0 ? Colors.red : Colors.green),
                          width: deficit > 20000 ? 2.0 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (deficit > 20000)
                            const Padding(
                              padding: EdgeInsets.only(right: 4.0),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.redAccent,
                                size: 14,
                              ),
                            ),
                          Text(
                            deficit > 20000
                                ? "HIGH DEFICIT: \u20B9${deficit.toStringAsFixed(0)}"
                                : "Deficit: \u20B9${deficit.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: deficit > 20000
                                  ? Colors.redAccent
                                  : (deficit > 0 ? Colors.red : Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "6-MONTH INFLOW & CLIENTS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: SageColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                IncomeComboChart(
                  values: values,
                  lineValues: lineValues,
                  labels: labels,
                  barColor: SageColors.tertiaryContainer,
                  maxValue: maxVal,
                  maxLineValue: maxLineVal,
                  onEditClick: () {
                    final editableKeys = keys.where((k) {
                      final parts = k.split('-');
                      int y = int.parse(parts[0]);
                      int m = int.parse(parts[1]);
                      return y < 2026 || (y == 2026 && m < 7);
                    }).toList();

                    if (editableKeys.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No editable months in the current view.',
                          ),
                        ),
                      );
                      return;
                    }

                    String selectedKey = editableKeys.last;
                    final inflowCtrl = TextEditingController(
                      text: (state.netRunningBalance[selectedKey] ?? 0.0)
                          .toStringAsFixed(0),
                    );
                    final clientsCtrl = TextEditingController(
                      text: (state.monthlyActiveClients[selectedKey] ?? 0)
                          .toString(),
                    );

                    showDialog(
                      context: context,
                      builder: (ctx) => StatefulBuilder(
                        builder: (context, setStateSB) {
                          return AlertDialog(
                            title: const Text('Edit Historical Data'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownButtonFormField<String>(
                                  value: selectedKey,
                                  decoration: const InputDecoration(
                                    labelText: 'Month',
                                  ),
                                  items: editableKeys.map((k) {
                                    int mIdx = int.parse(k.split('-')[1]) - 1;
                                    return DropdownMenuItem(
                                      value: k,
                                      child: Text(
                                        '${monthNames[mIdx]} ${k.split('-')[0]}',
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setStateSB(() {
                                        selectedKey = v;
                                        inflowCtrl.text =
                                            (state.netRunningBalance[selectedKey] ??
                                                    0.0)
                                                .toStringAsFixed(0);
                                        clientsCtrl.text =
                                            (state.monthlyActiveClients[selectedKey] ??
                                                    0)
                                                .toString();
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: inflowCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Total Inflow (\u20B9)',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: clientsCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Active Clients',
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('CANCEL'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final inflowVal = double.tryParse(
                                    inflowCtrl.text,
                                  );
                                  final clientsVal = int.tryParse(
                                    clientsCtrl.text,
                                  );
                                  if (inflowVal != null) {
                                    state.updateNetRunningBalance(
                                      selectedKey,
                                      inflowVal,
                                    );
                                  }
                                  if (clientsVal != null) {
                                    state.updateMonthlyActiveClients(
                                      selectedKey,
                                      clientsVal,
                                    );
                                  }
                                  Navigator.pop(ctx);
                                },
                                child: const Text('SAVE'),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  "6-MONTH PROJECTED DEFICIT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: SageColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                DeficitLineChart(
                  values: projValues,
                  labels: projLabels,
                  maxValue: maxProjVal,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),

        const Text(
          "LEDGER TRANSACTION JOURNAL",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: SageColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),

        if (state.finances.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: const Center(
              child: Text(
                "NO TRANSACTIONS RECORDED",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          ...state.finances.reversed.map((f) {
            String clientName = '';
            if (f.clientId != null && f.clientId!.isNotEmpty) {
              try {
                clientName = state.clients
                    .firstWhere((c) => c.id == f.clientId)
                    .name;
              } catch (_) {
                clientName = f.clientId!;
              }
            }
            String empName = '';
            if (f.employeeId != null && f.employeeId!.isNotEmpty) {
              try {
                empName = state.employees
                    .firstWhere((e) => e.id == f.employeeId)
                    .name;
              } catch (_) {
                empName = f.employeeId!;
              }
            }

            Widget buildDetailChip(String label, String value) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: Text(
                  "$label: $value",
                  style: const TextStyle(fontSize: 10, color: Colors.black87),
                ),
              );
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  childrenPadding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: 12,
                  ),
                  leading: Icon(
                    f.isIncome ? Icons.trending_up : Icons.trending_down,
                    color: f.isIncome
                        ? SageColors.primary
                        : SageColors.secondary,
                    size: 20,
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "${f.category} // ${f.date.toString().substring(0, 10)}",
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${f.isIncome ? '+' : '-'}₹${f.amount.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: f.isIncome
                              ? SageColors.primary
                              : SageColors.secondary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: SageColors.outline,
                        ),
                        onPressed: () async {
                          final ok = await showConfirmDialog(
                            context,
                            "DELETE ENTRY",
                            "Are you sure you want to remove this ledger entry?",
                          );
                          if (ok && context.mounted) {
                            context.read<AppState>().removeFinance(f.id);
                          }
                        },
                      ),
                      const Icon(
                        Icons.expand_more,
                        size: 18,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                  children: [
                    const Divider(color: Colors.black12, height: 1),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
                        if (f.incomeType != null && f.incomeType!.isNotEmpty)
                          buildDetailChip("Type", f.incomeType!),
                        if (f.expenseType != null && f.expenseType!.isNotEmpty)
                          buildDetailChip("Type", f.expenseType!),
                        if (f.paymentMonth != null &&
                            f.paymentMonth!.isNotEmpty)
                          buildDetailChip("Month", f.paymentMonth!),
                        if (f.paymentMethod != null &&
                            f.paymentMethod!.isNotEmpty)
                          buildDetailChip("Method", f.paymentMethod!),
                        if (f.discount > 0)
                          buildDetailChip(
                            "Discount",
                            "₹${f.discount.toStringAsFixed(0)}",
                          ),
                        if (clientName.isNotEmpty)
                          buildDetailChip("Client", clientName),
                        if (empName.isNotEmpty)
                          buildDetailChip("Employee", empName),
                        if (f.sessionCount != null && f.sessionCount! > 0)
                          buildDetailChip("Sessions", "${f.sessionCount}"),
                        if (f.isAdvance)
                          buildDetailChip("Status", "Advance Payment"),
                        if (f.isLate) buildDetailChip("Status", "Late Payment"),
                        if (f.serviceType != null && f.serviceType!.isNotEmpty)
                          buildDetailChip("Service", f.serviceType!),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  void _showEditEmployeeDialog(BuildContext context, Employee e) {
    final rolesList = e.role.split(',').map((s) => s.trim()).toList();
    List<String> selectedRoles = rolesList.isNotEmpty
        ? List.from(rolesList)
        : ['Video Editor'];
    final nameCtrl = TextEditingController(text: e.name);
    final salaryCtrl = TextEditingController(text: e.monthlySalary.toString());
    final rateCtrl1 = TextEditingController(text: e.perVideoRate.toString());
    final rateCtrl2 = TextEditingController(text: e.perSessionRate.toString());
    final rateCtrl3 = TextEditingController(text: e.perSkuRate.toString());
    final rateCtrl4 = TextEditingController(text: e.perDesignRate.toString());

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: SageColors.background,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: TerminalPanel(
              title: "EDIT TEAM RECORD",
              child: Column(
                children: [
                  SageTextField(controller: nameCtrl, label: "Full Name"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select Roles",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      if (selectedRoles.length >= 2)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: SageColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: SageColors.error,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            "MAX 2 ROLES",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: SageColors.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 6,
                    runSpacing: -8,
                    children:
                        [
                          'Video Editor',
                          'Graphics Editor',
                          'Videographer',
                          'Marketing Executive',
                          'Page Management Executive',
                          'Ecom Executive',
                        ].map((role) {
                          final isSelected = selectedRoles.contains(role);
                          final isDisabled =
                              !isSelected && selectedRoles.length >= 2;
                          return FilterChip(
                            label: Text(
                              role,
                              style: TextStyle(
                                fontSize: 10,
                                color: isDisabled ? Colors.grey : Colors.black,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: isDisabled
                                ? null
                                : (val) {
                                    setS(() {
                                      if (val) {
                                        if (selectedRoles.length < 2)
                                          selectedRoles.add(role);
                                      } else {
                                        selectedRoles.remove(role);
                                        if (selectedRoles.isEmpty)
                                          selectedRoles.add('Video Editor');
                                      }
                                    });
                                  },
                            selectedColor: SageColors.yellowAccent,
                            checkmarkColor: Colors.black,
                            disabledColor: Colors.grey.shade200,
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 10),
                  SageTextField(
                    controller: salaryCtrl,
                    label: "Fixed Monthly Salary (₹)",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  SageTextField(
                    controller: rateCtrl1,
                    label: "Per Video/Reel Rate (₹)",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  SageTextField(
                    controller: rateCtrl2,
                    label: "Per Session Rate (₹)",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  SageTextField(
                    controller: rateCtrl3,
                    label: "Per SKU Rate (₹)",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  SageTextField(
                    controller: rateCtrl4,
                    label: "Per Design Rate (₹)",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          context.read<AppState>().terminateEmployee(e.id);
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          "TERMINATE",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              "CANCEL",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SageColors.primary,
                            ),
                            onPressed: () {
                              context.read<AppState>().updateEmployee(
                                e.id,
                                name: nameCtrl.text,
                                role: selectedRoles.join(', '),
                                monthlySalary: double.tryParse(salaryCtrl.text),
                                perSessionRate: double.tryParse(rateCtrl2.text),
                                perSkuRate: double.tryParse(rateCtrl3.text),
                                perDesignRate: double.tryParse(rateCtrl4.text),
                                perVideoRate: double.tryParse(rateCtrl1.text),
                              );
                              Navigator.pop(ctx);
                            },
                            child: const Text("SAVE"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showInvoiceMonthDialog(BuildContext context, Client c) {
    final pendingMonths = c.pendingMonths;
    if (pendingMonths.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: SageColors.surface,
          title: const Text(
            "No Pending Invoices",
            style: TextStyle(color: SageColors.onSurface),
          ),
          content: const Text(
            "This client has no pending months to generate an invoice for. They have either paid for all active months, or they just joined.",
            style: TextStyle(color: SageColors.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(color: SageColors.primary),
              ),
            ),
          ],
        ),
      );
      return;
    }

    int selectedMonth = pendingMonths.first;
    List<ClientAddOn> unbilledAddOns = c.addOns
        .where((a) => !a.isBilled && !a.isPaid)
        .toList();
    List<String> selectedAddOnIds = [];
    Map<String, bool> partialPaymentToggles = {};
    Map<String, TextEditingController> partialPaymentControllers = {};

    for (var a in unbilledAddOns) {
      partialPaymentToggles[a.id] = false;
      partialPaymentControllers[a.id] = TextEditingController();
    }

    // Helper to get month string
    String getMonthName(int m) {
      return DateFormat('MMMM').format(DateTime(2000, m, 1));
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: SageColors.surface,
              title: const Text(
                "Select Pending Month",
                style: TextStyle(color: SageColors.onSurface),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Choose which pending month to generate the invoice for:",
                      style: TextStyle(color: SageColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedMonth,
                      dropdownColor: SageColors.surface,
                      style: const TextStyle(color: SageColors.onSurface),
                      items: pendingMonths.map((m) {
                        return DropdownMenuItem<int>(
                          value: m,
                          child: Text(getMonthName(m)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => selectedMonth = val);
                        }
                      },
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: SageColors.background,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (unbilledAddOns.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        "Include Add-Ons in this invoice:",
                        style: TextStyle(
                          color: SageColors.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...unbilledAddOns.map((addOn) {
                        bool isSelected = selectedAddOnIds.contains(addOn.id);
                        bool isPartial = partialPaymentToggles[addOn.id] ?? false;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CheckboxListTile(
                              title: Text(
                                "${addOn.type} - \u20B9${addOn.amount.toStringAsFixed(0)}",
                                style: const TextStyle(fontSize: 12),
                              ),
                              subtitle:
                                  addOn.description != null &&
                                          addOn.description!.isNotEmpty
                                      ? Text(
                                          addOn.description!,
                                          style: const TextStyle(fontSize: 10),
                                        )
                                      : null,
                              value: isSelected,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    selectedAddOnIds.add(addOn.id);
                                  } else {
                                    selectedAddOnIds.remove(addOn.id);
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              activeColor: SageColors.primary,
                            ),
                            if (isSelected)
                              Padding(
                                padding: const EdgeInsets.only(left: 32.0, bottom: 8.0),
                                child: Row(
                                  children: [
                                    Switch(
                                      value: isPartial,
                                      onChanged: (val) {
                                        setState(() {
                                          partialPaymentToggles[addOn.id] = val;
                                        });
                                      },
                                      activeColor: SageColors.primary,
                                    ),
                                    const Text("Partial Payment", style: TextStyle(fontSize: 11, color: SageColors.onSurfaceVariant)),
                                    if (isPartial) ...[
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextField(
                                          controller: partialPaymentControllers[addOn.id],
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(color: SageColors.onSurface, fontSize: 12),
                                          decoration: const InputDecoration(
                                            hintText: "Amount (\u20B9)",
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          ),
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                          ],
                        );
                      }),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "CANCEL",
                    style: TextStyle(color: SageColors.onSurfaceVariant),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Generating Invoice...")),
                    );
                    try {
                      DateTime invoiceDate = DateTime(
                        DateTime.now().year,
                        selectedMonth,
                      );

                      Map<String, double> partialPayments = {};
                      List<ClientAddOn> selectedAddOnsForInvoice = [];
                      List<String> fullyBilledAddOnIds = [];

                      for (var addOn in c.addOns) {
                        if (selectedAddOnIds.contains(addOn.id)) {
                          bool isPartial = partialPaymentToggles[addOn.id] ?? false;
                          double partialAmt = double.tryParse(partialPaymentControllers[addOn.id]?.text ?? '') ?? 0.0;

                          if (isPartial && partialAmt > 0 && partialAmt < addOn.amount) {
                            partialPayments[addOn.id] = partialAmt;
                            selectedAddOnsForInvoice.add(
                              ClientAddOn(
                                id: addOn.id,
                                type: addOn.type,
                                description: "${addOn.description ?? ''} (Partial Payment)".trim(),
                                amount: partialAmt,
                                isBilled: false,
                                isPaid: false,
                                dateAdded: addOn.dateAdded,
                              ),
                            );
                          } else {
                            fullyBilledAddOnIds.add(addOn.id);
                            selectedAddOnsForInvoice.add(addOn);
                          }
                        }
                      }

                      await InvoiceService.generateAndShareInvoice(
                        c,
                        invoiceDate,
                        selectedAddOns: selectedAddOnsForInvoice,
                      );
                      
                      if (fullyBilledAddOnIds.isNotEmpty || partialPayments.isNotEmpty) {
                        context.read<AppState>().processAddOnPayments(
                          c.id,
                          fullyBilledAddOnIds,
                          partialPayments,
                        );
                      }

                      if (context.mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Invoice Generated")),
                        );
                    } catch (e) {
                      if (context.mounted)
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  },
                  child: const Text(
                    "GENERATE",
                    style: TextStyle(
                      color: SageColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditClientDialog(BuildContext context, Client c) {
    final nameCtrl = TextEditingController(text: c.name);
    final contactNameCtrl = TextEditingController(text: c.contact.name);
    final contactEmailCtrl = TextEditingController(text: c.contact.email);
    final contactPhoneCtrl = TextEditingController(text: c.contact.phone);
    final contactAddressCtrl = TextEditingController(text: c.contact.address);
    final contactWebsiteCtrl = TextEditingController(text: c.contact.website);
    final payableCtrl = TextEditingController(
      text: c.monthlyPayable.toString(),
    );
    final dueDateDayCtrl = TextEditingController(text: c.dueDateDay.toString());
    String paymentMode = c.paymentMode;
    final pendingMonthsCtrl = TextEditingController(
      text: c.dynamicPaymentsDue.toString(),
    );
    final reelsCtrl = TextEditingController(text: c.weeklyReels.toString());
    final postsCtrl = TextEditingController(text: c.weeklyPosts.toString());
    final carouselsCtrl = TextEditingController(
      text: c.weeklyCarousels.toString(),
    );
    final storiesCtrl = TextEditingController(text: c.weeklyStories.toString());
    final campaignsCtrl = TextEditingController(text: c.campaigns.toString());
    final campaignReachCtrl = TextEditingController(text: c.campaignReach);
    final guidelinesCtrl = TextEditingController(text: c.postRequirements);
    String packageType = c.packageType;
    String contractPeriod = c.contractPeriod;
    String conversionProbability = c.conversionProbability;
    String retentionHealth = c.retentionHealth;
    String serviceType = c.serviceType.toLowerCase().contains('commerce')
        ? 'E-Commerce'
        : c.serviceType;
    String ecomPaymentType = c.ecomPaymentType;
    final clientSkuRateCtrl = TextEditingController(
      text: c.clientSkuRate.toString(),
    );
    final clientDuplicateSkuRateCtrl = TextEditingController(
      text: c.clientDuplicateSkuRate.toString(),
    );
    final clientCatalogueRateCtrl = TextEditingController(
      text: c.clientCatalogueRate.toString(),
    );
    bool hasMarketingCommission = c.hasMarketingCommission;
    bool isWebsiteHandlingActive = c.isWebsiteHandlingActive;
    final websiteHandlingFeeCtrl = TextEditingController(
      text: c.websiteHandlingFee.toString(),
    );
    String? marketingExecutiveId = c.marketingExecutiveId;
    String? assignedVideographerId = c.assignedVideographerId;
    final sessionRateCtrl = TextEditingController(
      text: c.sessionRate.toString(),
    );
    DateTime selectedContractDate = c.contractDate;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: SageColors.background,
              title: const Text(
                "EDIT CLIENT",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SageTextField(controller: nameCtrl, label: "Company Name"),
                    const SizedBox(height: 10),
                    SageTextField(
                      controller: contactEmailCtrl,
                      label: "Contact Email",
                    ),
                    const SizedBox(height: 10),
                    SageTextField(
                      controller: contactPhoneCtrl,
                      label: "Contact Phone",
                    ),
                    const SizedBox(height: 10),
                    if (c.status == 'Lead') ...[
                      DropdownButtonFormField<String>(
                        value: conversionProbability,
                        decoration: const InputDecoration(
                          labelText: "Conversion Probability",
                        ),
                        dropdownColor: Colors.white,
                        items: ['High', 'Medium', 'Low']
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(
                          () => conversionProbability = v ?? 'Medium',
                        ),
                      ),
                      const SizedBox(height: 10),
                    ] else ...[
                      SageTextField(
                        controller: contactNameCtrl,
                        label: "Contact Name",
                      ),
                      const SizedBox(height: 10),
                      SageTextField(
                        controller: contactAddressCtrl,
                        label: "Address",
                      ),
                      const SizedBox(height: 10),
                      SageTextField(
                        controller: contactWebsiteCtrl,
                        label: "Website",
                      ),
                      const SizedBox(height: 10),
                      SageTextField(
                        controller: payableCtrl,
                        label: "Monthly Payable (₹)",
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: paymentMode,
                        decoration: const InputDecoration(
                          labelText: "Payment Mode",
                        ),
                        dropdownColor: Colors.white,
                        items: ['Advance', 'Running', 'Late']
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => paymentMode = v ?? 'Running'),
                      ),
                      const SizedBox(height: 10),
                      SageTextField(
                        controller: dueDateDayCtrl,
                        label: "Due Date (1-31)",
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: serviceType,
                        decoration: const InputDecoration(
                          labelText: "Service Type",
                        ),
                        dropdownColor: Colors.white,
                        items: ['Marketing', 'E-Commerce', 'Video Production']
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => serviceType = v ?? 'Marketing'),
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        title: Text(
                          "Marketing Commission (20%)",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: marketingExecutiveId == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        value:
                            hasMarketingCommission &&
                            marketingExecutiveId != null,
                        onChanged: marketingExecutiveId == null
                            ? null
                            : (v) => setState(() => hasMarketingCommission = v),
                        activeColor: SageColors.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value:
                            context.read<AppState>().employees.any(
                              (e) =>
                                  e.id == marketingExecutiveId &&
                                  e.hasRole('marketing'),
                            )
                            ? marketingExecutiveId
                            : null,
                        decoration: const InputDecoration(
                          labelText: "Assigned Marketing Exec",
                        ),
                        dropdownColor: Colors.white,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text("None", style: TextStyle(fontSize: 12)),
                          ),
                          ...context
                              .read<AppState>()
                              .employees
                              .where((e) => e.hasRole('marketing'))
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.id,
                                  child: Text(
                                    e.name,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                        ],
                        onChanged: (v) => setState(() {
                          marketingExecutiveId = v;
                          if (v == null) hasMarketingCommission = false;
                        }),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            "Starting Date:",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedContractDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() => selectedContractDate = picked);
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 14),
                            label: Text(
                              selectedContractDate.toString().substring(0, 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: packageType,
                        decoration: const InputDecoration(
                          labelText: "Package Type",
                        ),
                        dropdownColor: Colors.white,
                        items: ['Growth', 'Performance']
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => packageType = v ?? 'Growth'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: contractPeriod,
                        decoration: const InputDecoration(
                          labelText: "Contract Period",
                        ),
                        dropdownColor: Colors.white,
                        items: ['3 Months', '6 Months', '1 Year']
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => contractPeriod = v ?? '3 Months'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value:
                            context.read<AppState>().employees.any(
                              (e) =>
                                  e.id == assignedVideographerId &&
                                  e.hasRole('videographer'),
                            )
                            ? assignedVideographerId
                            : null,
                        decoration: const InputDecoration(
                          labelText: "Assigned Videographer",
                        ),
                        dropdownColor: Colors.white,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text("None", style: TextStyle(fontSize: 12)),
                          ),
                          const DropdownMenuItem(
                            value: 'COF-PRI-001',
                            child: Text(
                              "CFO Priyajit",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          ...context
                              .read<AppState>()
                              .employees
                              .where((e) => e.hasRole('videographer'))
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e.id,
                                  child: Text(
                                    e.name,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                        ],
                        onChanged: (v) =>
                            setState(() => assignedVideographerId = v),
                      ),
                      const SizedBox(height: 10),
                      SageTextField(
                        controller: sessionRateCtrl,
                        label: "Session Rate (₹)",
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: retentionHealth,
                        decoration: const InputDecoration(
                          labelText: "Retention Health",
                        ),
                        dropdownColor: Colors.white,
                        items: ['Great', 'Good', 'Bad']
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  s,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => retentionHealth = v ?? 'Good'),
                      ),
                      const SizedBox(height: 10),
                      SageTextField(
                        controller: pendingMonthsCtrl,
                        label: "Pending Months of Payment",
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      if (serviceType.toLowerCase().contains('commerce')) ...[
                        DropdownButtonFormField<String>(
                          value: ecomPaymentType,
                          decoration: const InputDecoration(
                            labelText: "Ecom Payment Type",
                          ),
                          dropdownColor: Colors.white,
                          items: ['Monthly', 'Per SKU']
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => ecomPaymentType = v ?? 'Monthly'),
                        ),
                        if (ecomPaymentType == 'Per SKU') ...[
                          const SizedBox(height: 10),
                          SageTextField(
                            controller: clientSkuRateCtrl,
                            label: "Per SKU Rate (₹)",
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                          SageTextField(
                            controller: clientDuplicateSkuRateCtrl,
                            label: "Per Duplicate SKU Rate (₹)",
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                          SageTextField(
                            controller: clientCatalogueRateCtrl,
                            label: "Per Catalogue Rate (₹)",
                            keyboardType: TextInputType.number,
                          ),
                        ],
                        const SizedBox(height: 10),
                      ] else ...[
                        const Text(
                          "DELIVERABLES",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SageTextField(
                          controller: reelsCtrl,
                          label: "Reels/wk",
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        SageTextField(
                          controller: postsCtrl,
                          label: "Posts/wk",
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        SageTextField(
                          controller: carouselsCtrl,
                          label: "Carousels",
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        SageTextField(
                          controller: storiesCtrl,
                          label: "Stories",
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        if (packageType == 'Performance') ...[
                          SageTextField(
                            controller: campaignsCtrl,
                            label: "Campaigns",
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                          SageTextField(
                            controller: campaignReachCtrl,
                            label: "Reach",
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                      SageTextField(
                        controller: guidelinesCtrl,
                        label: "Description / Requirements",
                        maxLines: 3,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SageColors.primary,
                  ),
                  onPressed: () {
                    context.read<AppState>().updateClient(
                      c.id,
                      name: nameCtrl.text,
                      contactName: contactNameCtrl.text,
                      contactEmail: contactEmailCtrl.text,
                      contactPhone: contactPhoneCtrl.text,
                      contactAddress: contactAddressCtrl.text,
                      contactWebsite: contactWebsiteCtrl.text,
                      monthlyPayable: double.tryParse(payableCtrl.text),
                      serviceType: serviceType,
                      hasMarketingCommission: hasMarketingCommission,
                      marketingExecutiveId: marketingExecutiveId,
                      packageType: packageType,
                      contractPeriod: contractPeriod,
                      conversionProbability: conversionProbability,
                      retentionHealth: retentionHealth,
                      paymentMode: paymentMode,
                      dueDateDay: int.tryParse(dueDateDayCtrl.text),
                      paymentsDue: int.tryParse(pendingMonthsCtrl.text),
                      weeklyReels: int.tryParse(reelsCtrl.text),
                      weeklyPosts: int.tryParse(postsCtrl.text),
                      weeklyCarousels: int.tryParse(carouselsCtrl.text),
                      weeklyStories: int.tryParse(storiesCtrl.text),
                      campaigns: int.tryParse(campaignsCtrl.text),
                      campaignReach: campaignReachCtrl.text,
                      assignedVideographerId: assignedVideographerId,
                      sessionRate: double.tryParse(sessionRateCtrl.text),
                      postRequirements: guidelinesCtrl.text,
                      contractDate: selectedContractDate,
                      ecomPaymentType: ecomPaymentType,
                      clientSkuRate: double.tryParse(clientSkuRateCtrl.text),
                      clientDuplicateSkuRate: double.tryParse(
                        clientDuplicateSkuRateCtrl.text,
                      ),
                      clientCatalogueRate: double.tryParse(
                        clientCatalogueRateCtrl.text,
                      ),
                      isWebsiteHandlingActive: isWebsiteHandlingActive,
                      websiteHandlingFee:
                          double.tryParse(websiteHandlingFeeCtrl.text) ?? 0,
                    );
                    context.read<AppState>().updateClientVideographer(
                      c.id,
                      assignedVideographerId,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text("SAVE"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // --- Popup Dialog: Add Member ---

  void _showAddMemberDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final salaryCtrl = TextEditingController(text: "0");
    final rateCtrl1 = TextEditingController(text: "0");
    final rateCtrl2 = TextEditingController(text: "0");
    final rateCtrl3 = TextEditingController(text: "0");
    final rateCtrl4 = TextEditingController(text: "0");
    List<String> selectedRoles = ['Video Editor'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: SageColors.background,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: TerminalPanel(
              title: "ADD TEAM MEMBER",
              child: Column(
                children: [
                  SageTextField(controller: nameCtrl, label: "Full Name"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select Roles",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      if (selectedRoles.length >= 2)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: SageColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: SageColors.error,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            "MAX 2 ROLES",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: SageColors.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 6,
                    runSpacing: -8,
                    children:
                        [
                          'Video Editor',
                          'Graphics Editor',
                          'Videographer',
                          'Marketing Executive',
                          'Page Management Executive',
                          'Ecom Executive',
                        ].map((role) {
                          final isSelected = selectedRoles.contains(role);
                          final isDisabled =
                              !isSelected && selectedRoles.length >= 2;
                          return FilterChip(
                            label: Text(
                              role,
                              style: TextStyle(
                                fontSize: 10,
                                color: isDisabled ? Colors.grey : Colors.black,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: isDisabled
                                ? null
                                : (val) {
                                    setS(() {
                                      if (val) {
                                        if (selectedRoles.length < 2)
                                          selectedRoles.add(role);
                                      } else {
                                        selectedRoles.remove(role);
                                        if (selectedRoles.isEmpty)
                                          selectedRoles.add('Video Editor');
                                      }
                                    });
                                  },
                            selectedColor: SageColors.yellowAccent,
                            checkmarkColor: Colors.black,
                            disabledColor: Colors.grey.shade200,
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 10),
                  SageTextField(
                    controller: salaryCtrl,
                    label: "Fixed Monthly Salary (₹)",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  SageTextField(
                    controller: rateCtrl1,
                    label: "Per Video/Reel Rate (₹)",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  SageTextField(
                    controller: rateCtrl2,
                    label: "Per Session Rate (₹)",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  SageTextField(
                    controller: rateCtrl3,
                    label: "Per SKU Rate (₹)",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  SageTextField(
                    controller: rateCtrl4,
                    label: "Per Design Rate (₹)",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          "CANCEL",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SageColors.primary,
                        ),
                        onPressed: () {
                          context.read<AppState>().addEmployee(
                            name: nameCtrl.text,
                            role: selectedRoles.join(', '),
                            department: 'Operations',
                            monthlySalary:
                                double.tryParse(salaryCtrl.text) ?? 0.0,
                            perSessionRate:
                                double.tryParse(rateCtrl2.text) ?? 0.0,
                            perSkuRate: double.tryParse(rateCtrl3.text) ?? 0.0,
                            perDesignRate: double.tryParse(rateCtrl4.text) ?? 0.0,
                            perVideoRate:
                                double.tryParse(rateCtrl1.text) ?? 0.0,
                          );
                          Navigator.pop(ctx);
                        },
                        child: const Text("SAVE"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddLedgerDialog(BuildContext context) {
    final labelCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final otherClientCtrl = TextEditingController();
    final pageController = PageController();
    bool isIncome = true;
    String transactionCategory = 'Miscellaneous';
    String? selectedClientId;
    String paymentMode = 'UPI';
    String? paidToId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final state = context.watch<AppState>();

          final activeClientsForType = state.clients.where((c) {
            if (c.status == 'Lead' || !c.isApprovedByCeo) return false;
            if (transactionCategory == 'Website') return true;
            return c.serviceType == transactionCategory;
          }).toList();

          void nextPage() {
            pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }

          void prevPage() {
            pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }

          final categoryOptions = isIncome
              ? [
                  'Marketing',
                  'E-commerce',
                  'Video Production',
                  'Website',
                  'Miscellaneous',
                ]
              : ['Miscellaneous', 'Ads', 'Fuel', 'Travel'];

          return Dialog(
            backgroundColor: SageColors.background,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: Container(
              height: 520,
              padding: const EdgeInsets.all(20),
              child: TerminalPanel(
                title: "NEW LEDGER ENTRY",
                child: Expanded(
                  child: PageView(
                    controller: pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // STEP 1: Type Selection
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "TRANSACTION TYPE",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SwitchListTile(
                            title: Text(
                              isIncome
                                  ? "Incoming (Credit)"
                                  : "Outgoing (Debit)",
                              style: const TextStyle(fontSize: 14),
                            ),
                            value: isIncome,
                            onChanged: (v) => setS(() {
                              isIncome = v;
                              transactionCategory = 'Miscellaneous';
                              selectedClientId = null;
                            }),
                            activeColor: Colors.green,
                            inactiveTrackColor: Colors.red.withOpacity(0.5),
                            inactiveThumbColor: Colors.red,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            isIncome ? "INFLOW CATEGORY" : "OUTFLOW CATEGORY",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: categoryOptions
                                .map(
                                  (type) => ChoiceChip(
                                    label: Text(type),
                                    selected: transactionCategory == type,
                                    onSelected: (sel) {
                                      if (sel) {
                                        setS(() {
                                          transactionCategory = type;
                                          selectedClientId = null;
                                          paidToId = null;
                                        });
                                      }
                                    },
                                    selectedColor: SageColors.primary,
                                    backgroundColor:
                                        SageColors.surfaceContainerLow,
                                    labelStyle: TextStyle(
                                      color: transactionCategory == type
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text(
                                  "CANCEL",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SageColors.primary,
                                ),
                                onPressed: () {
                                  if (isIncome &&
                                      (transactionCategory == 'Marketing' ||
                                          transactionCategory == 'E-commerce' ||
                                          transactionCategory == 'Website')) {
                                    nextPage();
                                  } else {
                                    pageController.animateToPage(
                                      2,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                child: const Text("NEXT >"),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // STEP 2: Client Selection
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "SELECT ${transactionCategory.toUpperCase()} CLIENT",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 30),
                          DropdownButtonFormField<String?>(
                            value: selectedClientId,
                            menuMaxHeight: 300,
                            decoration: const InputDecoration(
                              labelText: "Client (Optional)",
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text(
                                  "None",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              ...activeClientsForType.map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    c.name,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                              if (transactionCategory == 'Website')
                                const DropdownMenuItem<String?>(
                                  value: 'others',
                                  child: Text(
                                    "Others",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                            ],
                            onChanged: (val) =>
                                setS(() => selectedClientId = val),
                          ),
                          if (selectedClientId == 'others') ...[
                            const SizedBox(height: 15),
                            SageTextField(
                              controller: otherClientCtrl,
                              label: "Client Name / Description",
                            ),
                          ],
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: prevPage,
                                child: const Text(
                                  "< BACK",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SageColors.primary,
                                ),
                                onPressed: () {
                                  if (selectedClientId == 'others' &&
                                      otherClientCtrl.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Please provide a description for Others.",
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  nextPage();
                                },
                                child: const Text("NEXT >"),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // STEP 3: Details
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "TRANSACTION DETAILS",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SageTextField(
                            controller: labelCtrl,
                            label: "Description",
                          ),
                          const SizedBox(height: 15),
                          SageTextField(
                            controller: amountCtrl,
                            label: "Amount (₹)",
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 15),
                          DropdownButtonFormField<String>(
                            value: paymentMode,
                            decoration: const InputDecoration(
                              labelText: "Payment Mode",
                              border: OutlineInputBorder(),
                            ),
                            items: ['UPI', 'Cash', 'Cheque']
                                .map(
                                  (pm) => DropdownMenuItem(
                                    value: pm,
                                    child: Text(
                                      pm,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) => setS(() => paymentMode = val!),
                          ),
                          if (!isIncome &&
                              (transactionCategory == 'Fuel' ||
                                  transactionCategory == 'Travel')) ...[
                            const SizedBox(height: 15),
                            DropdownButtonFormField<String?>(
                              value: paidToId,
                              menuMaxHeight: 300,
                              decoration: const InputDecoration(
                                labelText: "Paid To Whom",
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text(
                                    "Select Team Member",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                ...state.employees.map(
                                  (e) => DropdownMenuItem(
                                    value: e.id,
                                    child: Text(
                                      e.name,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (val) => setS(() => paidToId = val),
                            ),
                          ],
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  if (isIncome &&
                                      (transactionCategory == 'Marketing' ||
                                          transactionCategory == 'E-commerce' ||
                                          transactionCategory == 'Website')) {
                                    prevPage();
                                  } else {
                                    pageController.animateToPage(
                                      0,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                child: const Text(
                                  "< BACK",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () {
                                  if (amountCtrl.text.isEmpty ||
                                      labelCtrl.text.isEmpty)
                                    return;
                                  if (!isIncome &&
                                      (transactionCategory == 'Fuel' ||
                                          transactionCategory == 'Travel') &&
                                      paidToId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Please select who was paid.",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  String? finalMeId;
                                  String? finalClientId = selectedClientId;
                                  String finalLabel = labelCtrl.text;

                                  if (isIncome &&
                                      finalClientId != null &&
                                      finalClientId != 'others') {
                                    final c = state.clients
                                        .where((cl) => cl.id == finalClientId)
                                        .firstOrNull;
                                    if (c != null)
                                      finalMeId = c.marketingExecutiveId;
                                  }

                                  if (finalClientId == 'others') {
                                    finalLabel =
                                        "$finalLabel [Client: ${otherClientCtrl.text}]";
                                    finalClientId = null;
                                  }

                                  context.read<AppState>().addFinance(
                                    FinanceEntry(
                                      id: DateTime.now().millisecondsSinceEpoch
                                          .toString(),
                                      label: finalLabel,
                                      amount:
                                          double.tryParse(amountCtrl.text) ??
                                          0.0,
                                      isIncome: isIncome,
                                      date: DateTime.now(),
                                      category: transactionCategory,
                                      serviceType: isIncome
                                          ? transactionCategory
                                          : null,
                                      clientId: finalClientId,
                                      marketingExecutiveId: finalMeId,
                                      paymentMethod: paymentMode,
                                      employeeId: paidToId,
                                      expenseType: !isIncome && paidToId != null
                                          ? 'Expense'
                                          : null,
                                    ),
                                  );
                                  Navigator.pop(ctx);
                                },
                                child: const Text("SAVE"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

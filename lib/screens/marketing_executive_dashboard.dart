import 'package:flutter/material.dart';
import 'package:sage_mainframe/widgets/team_members_view.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import '../main.dart'; // For LoginScreen

class MarketingExecutiveDashboard extends StatefulWidget {
  const MarketingExecutiveDashboard({super.key});

  @override
  State<MarketingExecutiveDashboard> createState() => _MarketingExecutiveDashboardState();
}

class _MarketingExecutiveDashboardState extends State<MarketingExecutiveDashboard> {
  int _tab = 0;
  late PageController _pageController; // 0: Home, 1: Finance, 2: Profile
  int _tabKeyCounter = 0;
  PageStorageBucket _bucket = PageStorageBucket();
  String _leadSubTab = 'MY_LEADS'; // 'MY_LEADS', 'ASSIGNED'

  // Lead Form controllers
  final _companyNameCtrl = TextEditingController();
  final _contactNameCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _contactEmailCtrl = TextEditingController();
  bool _showAddLeadForm = false;

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _contactNameCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _contactEmailCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final persona = state.activePersona;

    // Find matching employee details
    final emp = state.employees.firstWhere((e) => e.id == persona.id, orElse: () => Employee(
      id: persona.id,
      name: persona.name,
      role: 'Marketing Executive',
      department: 'Marketing',
      password: persona.password,
    ));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_tab != 0) {
          _switchTab(0);
        }
      },
      child: Scaffold(
      backgroundColor: SageColors.background,
      body: Stack(
        children: [
          // Header Background color block
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: _getHeaderColor(),
                border: const Border(bottom: BorderSide(color: Colors.black, width: 1.5)),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Custom Header Row
                _buildTopHeader(context, persona, emp),

                // Active Page Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 100),
                    child: _buildActiveTab(context, state, emp),
                  ),
                ),
              ],
            ),
          ),

          // Floating Bottom Navigation Bar
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                  _buildBottomIcon(1, Icons.payments_outlined, Icons.payments),
                  _buildBottomIcon(2, Icons.person_outline, Icons.person),
                    _buildBottomIcon(3, Icons.group_outlined, Icons.group),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Color _getHeaderColor() {
    switch (_tab) {
      case 0: return SageColors.yellowAccentContainer;
      case 1: return SageColors.primaryContainer;
      case 2: return SageColors.secondaryContainer;
      default: return SageColors.background;
    }
  }

  Widget _buildTopHeader(BuildContext context, Persona persona, Employee emp) {
    String title = "MARKETING HOME";
    if (_tab == 1) title = "COMMISSIONS";
    if (_tab == 2) title = "PROFILE";
    if (_tab == 3) title = "TEAM";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
              child: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
            ),
          ),

          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.black,
            ),
          ),

          if (_tab == 2)
            GestureDetector(
              onTap: () {
                _showEditPersonalDetailsDialog(context, emp);
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: SageColors.yellowAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: const Icon(Icons.edit, color: Colors.black, size: 18),
              ),
            )
          else
            Container(width: 38),
        ],
      ),
    );
  }

  Widget _buildBottomIcon(int index, IconData outlineIcon, IconData filledIcon) {
    final isSelected = _tab == index;
    return GestureDetector(
      onTap: () => _switchTab(index),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: isSelected
            ? const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(
          isSelected ? filledIcon : outlineIcon,
          color: isSelected ? SageColors.yellowAccent : Colors.black,
          size: 24,
        ),
      ),
    );
  }


  void _switchTab(int index) {
    if (_tab == index) return;
    setState(() {
      _tab = index;
      _tabKeyCounter++;
      _bucket = PageStorageBucket();
      _leadSubTab = 'MY_LEADS';
    });
  }

  Widget _buildActiveTab(BuildContext context, AppState state, Employee emp) {
    switch (_tab) {
      case 0: return _buildHomeTab(context, state, emp);
      case 1: return _buildFinanceTab(context, state, emp);
      case 2: return _buildProfileTab(context, state, emp);
      case 3: return TeamMembersView();
      default: return const SizedBox();
    }
  }

  Widget _buildMeetingCard(BuildContext context, AppState state, Task task) {
    final bool isPhysical = task.description.contains('[Physical]');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isPhysical ? const Color(0xFFFFEBEE) : const Color(0xFFE3F2FD),
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isPhysical ? Icons.location_on : Icons.videocam, size: 20, color: Colors.black),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.description,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    state.submitTask(task.id);
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text("MARK COMPLETE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showPostponeDialog(context, state, task.id);
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text("POSTPONE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPostponeDialog(BuildContext context, AppState state, String taskId) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (pickedDate != null && context.mounted) {
      state.requestPostponeTask(taskId, pickedDate);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Postpone request sent to CEO for approval."),
        backgroundColor: Colors.green,
      ));
    }
  }

  // ---- TAB 0: HOME ----
  Widget _buildHomeTab(BuildContext context, AppState state, Employee emp) {
    final activeConverted = state.clients.where((c) => c.marketingExecutiveId == emp.id && c.status == 'Active').toList();
    final myLeads = state.clients.where((c) => c.marketingExecutiveId == emp.id && c.status == 'Lead' && c.source == 'my_lead').toList();
    final assignedLeads = state.clients.where((c) => c.marketingExecutiveId == emp.id && c.status == 'Lead' && c.source != 'my_lead').toList();

    // Query pending scheduled meetings
    final scheduledMeetings = state.tasks.where((t) => 
      t.assignedTo == emp.id && 
      !t.isCompleted &&
      !t.isSubmitted &&
      !t.isPostponeRequested &&
      (t.taskType == 'Lead Meeting' || t.taskType == 'Active Client Meeting')
    ).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SageColors.secondaryContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.black, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "WELCOME BACK, ${emp.name}!",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Keep pushing your daily targets.",
                      style: TextStyle(fontSize: 10, color: SageColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (scheduledMeetings.isNotEmpty) ...[
          const Text("SCHEDULED MEETINGS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: SageColors.onSurfaceVariant)),
          const SizedBox(height: 10),
          ...scheduledMeetings.map((t) => _buildMeetingCard(context, state, t)),
          const SizedBox(height: 20),
        ],

        const Text("ACTIVE CONVERTED CLIENTS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: SageColors.onSurfaceVariant)),
        const SizedBox(height: 10),
        if (activeConverted.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Text("NO CONVERTED CLIENTS YET", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12))),
          )
        else
          ...activeConverted.map((c) => _buildClientCard(context, state, c, true)),

        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() => _leadSubTab = 'MY_LEADS'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _leadSubTab == 'MY_LEADS' ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  "MY LEADS (${myLeads.length})",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _leadSubTab == 'MY_LEADS' ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => setState(() => _leadSubTab = 'ASSIGNED'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _leadSubTab == 'ASSIGNED' ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Text(
                  "ASSIGNED LEADS (${assignedLeads.length})",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _leadSubTab == 'ASSIGNED' ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_leadSubTab == 'MY_LEADS' ? "MY LEADS DATABASE" : "ASSIGNED LEADS BY CEO/CFO", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: SageColors.onSurfaceVariant)),
            if (_leadSubTab == 'MY_LEADS')
              ElevatedButton(
                onPressed: () => setState(() => _showAddLeadForm = !_showAddLeadForm),
                style: ElevatedButton.styleFrom(backgroundColor: SageColors.primary),
                child: Text(_showAddLeadForm ? "CANCEL" : "+ ADD LEAD", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (_showAddLeadForm && _leadSubTab == 'MY_LEADS') ...[
          TerminalPanel(
            title: "ADD NEW LEAD",
            child: Column(
              children: [
                SageTextField(controller: _companyNameCtrl, label: "Company Name"),
                const SizedBox(height: 10),
                SageTextField(controller: _contactNameCtrl, label: "Contact Person"),
                const SizedBox(height: 10),
                SageTextField(controller: _contactPhoneCtrl, label: "Contact Phone", keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                SageTextField(controller: _contactEmailCtrl, label: "Contact Email", keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_companyNameCtrl.text.trim().isEmpty) return;
                      final c = Client(
                        id: 'CL-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                        name: _companyNameCtrl.text,
                        contact: ClientContact(
                          name: _contactNameCtrl.text,
                          email: _contactEmailCtrl.text,
                          phone: _contactPhoneCtrl.text,
                        ),
                        contractDate: DateTime.now(),
                        status: 'Lead',
                        marketingExecutiveId: emp.id,
                        source: 'my_lead',
                        isApprovedByCeo: true,
                      );
                      state.addClient(c);
                      setState(() {
                        _showAddLeadForm = false;
                      });
                      _companyNameCtrl.clear();
                      _contactNameCtrl.clear();
                      _contactPhoneCtrl.clear();
                      _contactEmailCtrl.clear();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: SageColors.yellowAccent),
                    child: const Text("SAVE LEAD"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        Builder(builder: (context) {
          final list = _leadSubTab == 'MY_LEADS' ? myLeads : assignedLeads;
          if (list.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Text("NO LEADS FOUND", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12))),
            );
          }
          return Column(
            children: list.map((c) => _buildClientCard(context, state, c, false)).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildClientCard(BuildContext context, AppState state, Client c, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0)],
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Expanded(child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black))),
            if (isActive && !c.isApprovedByCeo)
              const StatusBadge(label: "AWAITING CEO", color: Colors.red)
            else if (isActive)
              const StatusBadge(label: "ACTIVE", color: Colors.green),
          ],
        ),
        subtitle: Text("Contact: ${c.contact.name} (${c.contact.phone})", style: const TextStyle(fontSize: 10, color: Colors.black54)),
        childrenPadding: const EdgeInsets.all(12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow("Contact Name", c.contact.name),
          _buildDetailRow("Contact Email", c.contact.email),
          _buildDetailRow("Contact Phone", c.contact.phone),
          if (isActive) ...[
            _buildDetailRow("Monthly Payable", "\u20B9${c.monthlyPayable.toStringAsFixed(0)}"),
            _buildDetailRow("Calculated Share (20%)", "\u20B9${(c.monthlyPayable * 0.20).toStringAsFixed(0)}"),
          ],
          if (!isActive) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (c.isTerminationRequested)
                  const StatusBadge(label: "TERMINATION PENDING", color: Colors.orange)
                else
                  ElevatedButton(
                    onPressed: () {
                      state.requestLeadTermination(c.id);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                    child: const Text("REQUEST TERMINATION", style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ElevatedButton(
                  onPressed: () => _showConvertToActiveDialog(context, state, c),
                  style: ElevatedButton.styleFrom(backgroundColor: SageColors.primary, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                  child: const Text("CONVERT TO ACTIVE", style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black))),
        ],
      ),
    );
  }

  void _showConvertToActiveDialog(BuildContext context, AppState state, Client c) {
    final feeCtrl = TextEditingController(text: "15000");
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: SageColors.background,
          title: Text("CONVERT ${c.name.toUpperCase()} TO ACTIVE", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Specify monthly contract fee (in \u20B9). After conversion, this will wait for CEO approval.", style: TextStyle(fontSize: 11)),
              const SizedBox(height: 12),
              SageTextField(controller: feeCtrl, label: "Monthly Payable Fee", keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: SageColors.primary),
              onPressed: () {
                final fee = double.tryParse(feeCtrl.text) ?? 10000.0;
                state.updateClient(
                  c.id,
                  status: 'Active',
                  monthlyPayable: fee,
                  hasMarketingCommission: true,
                  isApprovedByCeo: false,
                  previousStatus: 'Lead',
                );
                Navigator.pop(ctx);
              },
              child: const Text("REQUEST ACTIVATION"),
            ),
          ],
        );
      },
    );
  }

  // â”€â”€â”€ TAB 1: FINANCE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildFinanceTab(BuildContext context, AppState state, Employee emp) {
    final activeClients = state.clients
        .where((c) => c.marketingExecutiveId == emp.id && c.status == 'Active')
        .toList();
    final commissionEst = activeClients.fold(0.0, (s, c) => s + c.monthlyPayable * 0.20);
    final now = DateTime.now();
    final currentMonth = now.month;

    // Clients with commission enabled whose current-month payment is NOT yet recorded
    final pendingClients = activeClients
        .where((c) => c.hasMarketingCommission && !c.paidMonths.contains(currentMonth))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),

        // â”€â”€ CEO PAYOUT CLEARANCE BANNER â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        if (emp.paymentCleared && !emp.paymentApprovedByEmployee) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.shade900, width: 1.5),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.payment, color: Colors.amber.shade900),
                    const SizedBox(width: 10),
                    const Expanded(child: Text("COMMISSION CLEARANCE PENDING", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "The CEO has cleared a commission payment of \u20B9${emp.pendingPayAmount.toStringAsFixed(0)} for Month ${emp.pendingPayMonth}. Please confirm to update the ledger.",
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final ok = await showConfirmDialog(context, "APPROVE COMMISSION PAYOUT",
                        "I acknowledge that I received \u20B9${emp.pendingPayAmount.toStringAsFixed(0)} for ${emp.pendingPayMonth}.");
                    if (ok && context.mounted) {
                      state.approveMarketingCommission(emp.id);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("CONFIRM & APPROVE PAYOUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // â”€â”€ PENDING PAYMENTS â€” CURRENT MONTH â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        if (pendingClients.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE57373), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFB71C1C), size: 18),
                const SizedBox(width: 8),
                Text(
                  "${pendingClients.length} client${pendingClients.length > 1 ? 's' : ''} pending payment this month",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFFB71C1C)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ...pendingClients.map((c) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE57373), width: 1.5),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0)],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFCDD2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.hourglass_top, color: Color(0xFFC62828), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
                      Text(
                        "\u20B9${(c.monthlyPayable * 0.20).toStringAsFixed(0)} commission not yet received this month",
                        style: const TextStyle(fontSize: 10, color: Color(0xFFC62828)),
                      ),
                    ],
                  ),
                ),
                const StatusBadge(label: "UNPAID", color: Color(0xFFE53935)),
              ],
            ),
          )),
          const SizedBox(height: 16),
        ],

        // â”€â”€ EARNINGS SUMMARY CARD â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black, width: 1.5),
            boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "\u20B9${commissionEst.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const Text(
                "TOTAL ACTIVE MONTHLY COMMISSION ESTIMATE",
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: SageColors.onSurfaceVariant),
              ),
              if (pendingClients.isEmpty && activeClients.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 14),
                    SizedBox(width: 4),
                    Text("All clients paid this month", style: TextStyle(fontSize: 10, color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // â”€â”€ COLLECTION RATE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        Builder(builder: (context) {
          final commissioned = activeClients.where((c) => c.hasMarketingCommission).toList();
          if (commissioned.isEmpty) return const SizedBox.shrink();
          final paidCount = commissioned.where((c) => c.paidMonths.contains(currentMonth)).length;
          final total = commissioned.length;
          final pct = total > 0 ? (paidCount / total * 100) : 0.0;
          final allPaid = paidCount == total;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: allPaid ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: allPaid ? const Color(0xFF4CAF50) : Colors.amber.shade700, width: 1.5),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "THIS MONTH COLLECTION RATE",
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: allPaid ? const Color(0xFF2E7D32) : Colors.amber.shade900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$paidCount of $total clients paid",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: allPaid ? const Color(0xFF1B5E20) : Colors.black87),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: allPaid ? const Color(0xFF4CAF50) : Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Text(
                    "${pct.toStringAsFixed(0)}%",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),


        // â”€â”€ ACTIVE COMMISSION SHARES â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        const Text("ACTIVE COMMISSION SHARES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: SageColors.onSurfaceVariant)),
        const SizedBox(height: 10),
        if (activeClients.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Text("NO ACTIVE SHARING CLIENTS", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12))),
          )
        else
          ...activeClients.map((c) {
            final isPaid = c.paidMonths.contains(currentMonth);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isPaid ? const Color(0xFF4CAF50) : Colors.black, width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0)],
              ),
              child: Row(
                children: [
                  Icon(
                    isPaid ? Icons.check_circle : Icons.trending_up,
                    color: isPaid ? const Color(0xFF4CAF50) : SageColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text("Monthly Fee: \u20B9${c.monthlyPayable.toStringAsFixed(0)}", style: const TextStyle(fontSize: 9, color: Colors.black54)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "\u20B9${(c.monthlyPayable * 0.20).toStringAsFixed(0)}",
                        style: TextStyle(fontWeight: FontWeight.bold, color: isPaid ? const Color(0xFF4CAF50) : SageColors.primary),
                      ),
                      if (isPaid)
                        const Text("PAID âœ“", style: TextStyle(fontSize: 8, color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            );
          }),

        const SizedBox(height: 24),

        // â”€â”€ PAID TILL TRACKER â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_month, size: 14, color: Color(0xFF1565C0)),
            ),
            const SizedBox(width: 8),
            const Text("PAID TILL TRACKER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: SageColors.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 4),
        const Text("Record up to which month the client's payment has been confirmed.", style: TextStyle(fontSize: 10, color: SageColors.onSurfaceVariant)),
        const SizedBox(height: 10),
        if (activeClients.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Text("NO ACTIVE CLIENTS", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12))),
          )
        else
          ...activeClients.map((c) => _buildPaidTillCard(context, state, c)),
      ],
    );
  }

  Widget _buildPaidTillCard(BuildContext context, AppState state, Client c) {
    final hasRecord = c.paidTill.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasRecord ? const Color(0xFFE8F5E9) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              hasRecord ? Icons.event_available : Icons.calendar_today_outlined,
              color: hasRecord ? const Color(0xFF388E3C) : Colors.black54,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
                const SizedBox(height: 2),
                Text(
                  hasRecord ? "Paid till: ${c.paidTill}" : "Not recorded yet",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: hasRecord ? const Color(0xFF388E3C) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€ TAB 2: PROFILE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildProfileTab(BuildContext context, AppState state, Employee emp) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        TerminalPanel(
          title: "ACCOUNT DATA",
          child: Column(
            children: [
              Center(
                  child: ClipOval(
                    child: Image.asset(availableAvatars[emp.avatar % availableAvatars.length], fit: BoxFit.cover, width: 140, height: 140),
                  ),
                ),
              const SizedBox(height: 16),
              _profileRow("NAME", emp.name),
              _profileRow("ROLE", emp.role),
              _profileRow("DEPARTMENT", emp.department),
              _profileRow("ID CODE", emp.id),
              _profileRow("ADDRESS", emp.address.isNotEmpty ? emp.address : '---'),
              _profileRow("PHONE", emp.phone.isNotEmpty ? emp.phone : '---'),
              _profileRow("EMAIL", emp.email.isNotEmpty ? emp.email : '---'),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditPersonalDetailsDialog(BuildContext context, Employee emp) {
    final nameCtrl = TextEditingController(text: emp.name);
    final addressCtrl = TextEditingController(text: emp.address);
    final phoneCtrl = TextEditingController(text: emp.phone);
    final emailCtrl = TextEditingController(text: emp.email);

    final prefNameCtrl = TextEditingController(text: emp.preferredName);
    final emergencyCtrl = TextEditingController(text: emp.emergencyContact);
    final bioCtrl = TextEditingController(text: emp.professionalBio);
    final interestsCtrl = TextEditingController(text: emp.interests);
    
    String selectedWorkLocation = emp.workLocation.isEmpty ? 'Office' : emp.workLocation;
    String selectedWorkStyle = emp.workStylePreference.isEmpty ? 'Independent thinker' : emp.workStylePreference;
    List<String> selectedSkills = List.from(emp.keySkills);
    List<String> selectedStrengths = List.from(emp.strengths);

    int selectedAvatar = emp.avatar;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: SageColors.background,
              title: const Text("EDIT PERSONAL DETAILS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SageTextField(controller: nameCtrl, label: "Name"),
                    const SizedBox(height: 10),
                    SageTextField(controller: addressCtrl, label: "Address"),
                    const SizedBox(height: 10),
                    SageTextField(controller: phoneCtrl, label: "Phone"),
                    const SizedBox(height: 10),
                    SageTextField(controller: emailCtrl, label: "Email"),
                    const SizedBox(height: 10),
                    SageTextField(controller: prefNameCtrl, label: "Preferred Name"),
                    const SizedBox(height: 10),
                    SageTextField(controller: emergencyCtrl, label: "Emergency Contact"),
                    const SizedBox(height: 10),
                    SageTextField(controller: bioCtrl, label: "Professional Bio", maxLines: 3),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedWorkLocation,
                      decoration: const InputDecoration(labelText: "Work Location"),
                      items: ['Office', 'Remote', 'Hybrid'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => selectedWorkLocation = v ?? 'Office'),
                      dropdownColor: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedWorkStyle,
                      decoration: const InputDecoration(labelText: "Work Style Preference"),
                      items: ['Independent thinker', 'Team collaborator', 'Detail-oriented', 'Fast executor', 'Strategic planner'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => selectedWorkStyle = v ?? 'Independent thinker'),
                      dropdownColor: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    SageTextField(controller: interestsCtrl, label: "Interests / Hobbies"),
                    const SizedBox(height: 10),
                    const Text("KEY SKILLS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: ['Editing', 'Sales', 'Design', 'Marketing', 'Coding'].map((skill) {
                        final isSelected = selectedSkills.contains(skill);
                        return FilterChip(
                          label: Text(skill, style: const TextStyle(fontSize: 10)),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                selectedSkills.add(skill);
                              } else {
                                selectedSkills.remove(skill);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text("STRENGTHS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: ['Leadership', 'Problem Solving', 'Creativity', 'Communication'].map((strength) {
                        final isSelected = selectedStrengths.contains(strength);
                        return FilterChip(
                          label: Text(strength, style: const TextStyle(fontSize: 10)),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                selectedStrengths.add(strength);
                              } else {
                                selectedStrengths.remove(strength);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text("CHOOSE AVATAR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: List.generate(availableAvatars.length, (index) {
                        final isSelected = selectedAvatar == index;
                        return GestureDetector(
                          onTap: () => setState(() => selectedAvatar = index),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? SageColors.primary : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: ClipOval(child: Image.asset(availableAvatars[index], fit: BoxFit.cover, width: 48, height: 48)),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: SageColors.primary),
                  onPressed: () {
                    context.read<AppState>().updateEmployee(
                      emp.id,
                      name: nameCtrl.text,
                      address: addressCtrl.text,
                      phone: phoneCtrl.text,
                      email: emailCtrl.text,
                      avatar: selectedAvatar,
                      preferredName: prefNameCtrl.text,
                      emergencyContact: emergencyCtrl.text,
                      professionalBio: bioCtrl.text,
                      workLocation: selectedWorkLocation,
                      workStylePreference: selectedWorkStyle,
                      interests: interestsCtrl.text,
                      keySkills: selectedSkills,
                      strengths: selectedStrengths,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text("SAVE"),
                ),
              ],
            );
          }
        );
      },
    ).then((_) {
      nameCtrl.dispose();
      addressCtrl.dispose();
      phoneCtrl.dispose();
      emailCtrl.dispose();
      prefNameCtrl.dispose();
      emergencyCtrl.dispose();
      bioCtrl.dispose();
      interestsCtrl.dispose();
    });
  }

  Widget _profileRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: SageColors.onSurfaceVariant)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
        ],
      ),
    );
  }
}




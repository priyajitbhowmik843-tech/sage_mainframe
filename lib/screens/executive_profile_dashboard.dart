import 'package:sage_mainframe/widgets/sage_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/common_widgets.dart';
import '../theme/app_theme.dart';

class ExecutiveProfileDashboard extends StatefulWidget {
  const ExecutiveProfileDashboard({super.key});

  @override
  State<ExecutiveProfileDashboard> createState() =>
      _ExecutiveProfileDashboardState();
}

class _ExecutiveProfileDashboardState extends State<ExecutiveProfileDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _genderCtrl;
  late TextEditingController _prefNameCtrl;
  late TextEditingController _emergencyCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _interestsCtrl;

  late String selectedWorkLocation;
  late String selectedWorkStyle;
  late List<String> selectedSkills;
  late List<String> selectedStrengths;
  late int selectedAvatar;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    final p = context.read<AppState>().activePersona;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _phoneCtrl = TextEditingController(text: p?.phone ?? '');
    _emailCtrl = TextEditingController(text: p?.email ?? '');
    _addressCtrl = TextEditingController(text: p?.address ?? '');
    _dobCtrl = TextEditingController(text: p?.dob ?? '');
    _genderCtrl = TextEditingController(text: p?.gender ?? '');
    _prefNameCtrl = TextEditingController(text: p?.preferredName ?? '');
    _emergencyCtrl = TextEditingController(text: p?.emergencyContact ?? '');
    _bioCtrl = TextEditingController(text: p?.professionalBio ?? '');
    _interestsCtrl = TextEditingController(text: p?.interests ?? '');

    selectedWorkLocation = p?.workLocation ?? 'Office';
    selectedWorkStyle = p?.workStylePreference ?? 'Independent thinker';
    selectedSkills = List<String>.from(p?.keySkills ?? []);
    selectedStrengths = List<String>.from(p?.strengths ?? []);
    selectedAvatar = p?.avatar ?? 0;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _dobCtrl.dispose();
    _genderCtrl.dispose();
    _prefNameCtrl.dispose();
    _emergencyCtrl.dispose();
    _bioCtrl.dispose();
    _interestsCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final p = context.read<AppState>().activePersona;
      if (p != null) {
        p.name = _nameCtrl.text;
        p.phone = _phoneCtrl.text;
        p.email = _emailCtrl.text;
        p.address = _addressCtrl.text;
        p.dob = _dobCtrl.text;
        p.gender = _genderCtrl.text;
        p.preferredName = _prefNameCtrl.text;
        p.emergencyContact = _emergencyCtrl.text;
        p.professionalBio = _bioCtrl.text;
        p.interests = _interestsCtrl.text;
        p.workLocation = selectedWorkLocation;
        p.workStylePreference = selectedWorkStyle;
        p.keySkills = selectedSkills;
        p.strengths = selectedStrengths;
        p.avatar = selectedAvatar;

        context.read<AppState>().updatePersona(p);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile saved.')));
      }
    }
  }

  void _confirmArchiveLedger() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive Current Ledger'),
        content: const Text(
          'Are you sure you want to archive all active ledger logs? They will be moved to the archive folder.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final month = DateFormat('MMMM yyyy').format(DateTime.now());
              context.read<AppState>().archiveCurrentLedger(month);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Archived as $month')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SageColors.secondaryContainer,
            ),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _confirmArchiveNotifications() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive Notifications'),
        content: const Text(
          'Are you sure you want to archive all notifications?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final month = DateFormat('MMMM yyyy').format(DateTime.now());
              context.read<AppState>().archiveNotifications(month);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Archived as $month')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SageColors.secondaryContainer,
            ),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          decoration: SageColors.brutalistDecoration(
            backgroundColor: Colors.white,
            borderRadius: 24,
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Update your contact and demographic details.',
                    style: TextStyle(color: SageColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.badge, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _prefNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Preferred Name',
                      prefixIcon: Icon(Icons.person, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.home, color: Colors.black),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dobCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth',
                            prefixIcon: Icon(
                              Icons.calendar_today,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _genderCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emergencyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Emergency Contact',
                      prefixIcon: Icon(Icons.warning, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Professional Bio',
                      prefixIcon: Icon(Icons.description, color: Colors.black),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedWorkLocation,
                    decoration: const InputDecoration(
                      labelText: 'Work Location',
                    ),
                    items: ['Office', 'Remote', 'Hybrid']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => selectedWorkLocation = v ?? 'Office'),
                    dropdownColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedWorkStyle,
                    decoration: const InputDecoration(
                      labelText: 'Work Style Preference',
                    ),
                    items:
                        [
                              'Independent thinker',
                              'Team collaborator',
                              'Detail-oriented',
                              'Fast executor',
                              'Strategic planner',
                            ]
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                    onChanged: (v) => setState(
                      () => selectedWorkStyle = v ?? 'Independent thinker',
                    ),
                    dropdownColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _interestsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Interests / Hobbies',
                      prefixIcon: Icon(Icons.star, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'KEY SKILLS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        [
                          'Editing',
                          'Sales',
                          'Design',
                          'Marketing',
                          'Coding',
                          'Strategy',
                          'Finance',
                        ].map((skill) {
                          final isSelected = selectedSkills.contains(skill);
                          return ChoiceChip(
                            label: Text(
                              skill,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.black
                                    : Colors.black87,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: SageColors.yellowAccent,
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected)
                                  selectedSkills.add(skill);
                                else
                                  selectedSkills.remove(skill);
                              });
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'STRENGTHS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        [
                          'Leadership',
                          'Problem Solving',
                          'Creativity',
                          'Communication',
                          'Negotiation',
                          'Vision',
                        ].map((strength) {
                          final isSelected = selectedStrengths.contains(
                            strength,
                          );
                          return ChoiceChip(
                            label: Text(
                              strength,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.black
                                    : Colors.black87,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: SageColors.primaryContainer,
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.black,
                              width: 1.5,
                            ),
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected)
                                  selectedStrengths.add(strength);
                                else
                                  selectedStrengths.remove(strength);
                              });
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'CHOOSE AVATAR',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: List.generate(availableAvatars.length, (index) {
                      final isSelected = selectedAvatar == index;
                      return GestureDetector(
                        onTap: () => setState(() => selectedAvatar = index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: SageColors.brutalistDecoration(
                            backgroundColor: isSelected
                                ? SageColors.yellowAccent
                                : Colors.white,
                            borderRadius: 50,
                            borderWidth: isSelected ? 2.0 : 1.5,
                            hasShadow: isSelected,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              availableAvatars[index],
                              fit: BoxFit.cover,
                              width: 56,
                              height: 56,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 48),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save, color: Colors.black),
                      label: const Text(
                        'Save Profile',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: _saveProfile,
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

  Widget _buildLedgerArchivesTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              const Text(
                'Ledger Archives',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.archive, color: Colors.black),
                label: const Text(
                  'Archive Current',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: _confirmArchiveLedger,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SageColors.tertiaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('archived_finances')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  );

                final docs = snapshot.data!.docs;
                if (docs.isEmpty)
                  return const Center(
                    child: Text(
                      'No archived ledgers found.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  );

                final Map<String, List<QueryDocumentSnapshot>> folders = {};
                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final month = data['archiveMonth'] ?? 'Unknown';
                  if (!folders.containsKey(month)) folders[month] = [];
                  folders[month]!.add(doc);
                }

                return ListView(
                  children: folders.entries.map((entry) {
                    final monthName = entry.key;
                    final items = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: SageColors.brutalistDecoration(
                        backgroundColor: Colors.white,
                      ),
                      child: SageExpansionTile(
                        leading: const Icon(
                          Icons.folder_special,
                          color: SageColors.tertiary,
                          size: 36,
                        ),
                        shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.transparent),
                        ),
                        collapsedShape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.transparent),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                monthName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: SageColors.error,
                              ),
                              onPressed: () async {
                                final ok = await showConfirmDialog(
                                  context,
                                  "DELETE ARCHIVE",
                                  "Are you sure you want to delete all ledger logs for $monthName?",
                                );
                                if (ok && context.mounted) {
                                  context.read<AppState>().deleteLedgerArchive(
                                    monthName,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '${items.length} records',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        children: items.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final label = data['label'] ?? 'Unknown';
                          final amount = data['amount'] ?? 0;
                          final date =
                              (data['date'] as Timestamp?)?.toDate() ??
                              DateTime.now();
                          final isIncome = data['isIncome'] ?? false;
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: SageColors.brutalistDecoration(
                              backgroundColor: SageColors.surfaceContainerLow,
                              borderRadius: 12,
                              shadowOffset: 2,
                            ),
                            child: ListTile(
                              leading: Icon(
                                isIncome
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: isIncome
                                    ? SageColors.primary
                                    : SageColors.error,
                              ),
                              title: Text(
                                label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat(
                                  'MMM dd, yyyy - hh:mm a',
                                ).format(date),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                              trailing: Text(
                                '\u20B9$amount',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isIncome
                                      ? SageColors.primary
                                      : SageColors.error,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationArchivesTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              const Text(
                'Notification Archives',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.archive, color: Colors.black),
                label: const Text(
                  'Archive All',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: _confirmArchiveNotifications,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SageColors.secondaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('archived_notifications')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  );

                final docs = snapshot.data!.docs;
                if (docs.isEmpty)
                  return const Center(
                    child: Text(
                      'No archived notifications found.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  );

                final Map<String, List<QueryDocumentSnapshot>> folders = {};
                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final month = data['archiveMonth'] ?? 'Unknown';
                  if (!folders.containsKey(month)) folders[month] = [];
                  folders[month]!.add(doc);
                }

                return ListView(
                  children: folders.entries.map((entry) {
                    final monthName = entry.key;
                    final items = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: SageColors.brutalistDecoration(
                        backgroundColor: Colors.white,
                      ),
                      child: SageExpansionTile(
                        leading: const Icon(
                          Icons.notifications_paused,
                          color: SageColors.secondary,
                          size: 36,
                        ),
                        shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.transparent),
                        ),
                        collapsedShape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.transparent),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                monthName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: SageColors.error,
                              ),
                              onPressed: () async {
                                final ok = await showConfirmDialog(
                                  context,
                                  "DELETE ARCHIVE",
                                  "Are you sure you want to delete all notifications for $monthName?",
                                );
                                if (ok && context.mounted) {
                                  context
                                      .read<AppState>()
                                      .deleteNotificationArchive(monthName);
                                }
                              },
                            ),
                          ],
                        ),
                        subtitle: Text(
                          '${items.length} records',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        children: items.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final text = data['message'] ?? 'Unknown';
                          final type = data['type'] ?? 'general';
                          final date =
                              (data['timestamp'] as Timestamp?)?.toDate() ??
                              DateTime.now();
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: SageColors.brutalistDecoration(
                              backgroundColor: SageColors.surfaceContainerLow,
                              borderRadius: 12,
                              shadowOffset: 2,
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.circle,
                                color: SageColors.secondary,
                                size: 12,
                              ),
                              title: Text(
                                text,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat(
                                  'MMM dd, yyyy - hh:mm a',
                                ).format(date),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: SageColors.brutalistDecoration(
                                  backgroundColor:
                                      SageColors.secondaryContainer,
                                  borderRadius: 8,
                                  shadowOffset: 1,
                                  borderWidth: 1,
                                ),
                                child: Text(
                                  type.replaceAll('_', ' ').toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SageColors.background,
      appBar: AppBar(
        backgroundColor: SageColors.background,
        title: const Text(
          'Executive Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: SageColors.primary,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Personal Info'),
            Tab(icon: Icon(Icons.folder_special), text: 'Ledger Archives'),
            Tab(
              icon: Icon(Icons.notifications_paused),
              text: 'Notification Archives',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalInfoTab(),
          _buildLedgerArchivesTab(),
          _buildNotificationArchivesTab(),
        ],
      ),
    );
  }
}

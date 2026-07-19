import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sage_mainframe/state/app_state.dart';
import 'package:sage_mainframe/models/models.dart';
import 'package:sage_mainframe/theme/app_theme.dart';
import 'package:sage_mainframe/widgets/common_widgets.dart';

class _TeamMemberData {
  final String name;
  final String preferredName;
  final String role;
  final String department;
  final String email;
  final String phone;
  final String interests;
  final int avatarIndex;

  _TeamMemberData({
    required this.name,
    required this.preferredName,
    required this.role,
    required this.department,
    required this.email,
    required this.phone,
    required this.interests,
    required this.avatarIndex,
  });
}

class TeamMembersView extends StatelessWidget {
  const TeamMembersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    final List<_TeamMemberData> allMembers = [];
    
    // Add Employees
    for (var emp in state.employees) {
      if (emp.isActive) {
        allMembers.add(_TeamMemberData(
          name: emp.name,
          preferredName: emp.preferredName,
          role: emp.role,
          department: emp.department,
          email: emp.email,
          phone: emp.phone,
          interests: emp.interests,
          avatarIndex: emp.avatar,
        ));
      }
    }
    
    // Add Leadership
    for (var p in AppState.personas) {
      allMembers.add(_TeamMemberData(
        name: p.name,
        preferredName: p.preferredName,
        role: p.role.toString().split('.').last.replaceAll('_', ' ').toUpperCase(),
        department: 'Leadership',
        email: p.email,
        phone: p.phone,
        interests: p.interests,
        avatarIndex: p.avatar,
      ));
    }

    allMembers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (allMembers.isEmpty) {
      return const Center(child: Text("No team members found.", style: TextStyle(color: Colors.black54)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text("OUR TEAM", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.black)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allMembers.length,
          itemBuilder: (context, index) {
            final emp = allMembers[index];
            final displayName = emp.preferredName.isNotEmpty 
                ? "${emp.preferredName.toUpperCase()} (${emp.name.toUpperCase()})"
                : emp.name.toUpperCase();
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TerminalPanel(
                title: displayName,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      margin: const EdgeInsets.only(right: 16, top: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
                      ),
                      child: ClipOval(
                          child: Transform.scale(
                            scale: 1.7,
                            child: Image.asset(
                              availableAvatars[emp.avatarIndex % availableAvatars.length],
                              fit: BoxFit.cover,
                              width: 64,
                              height: 64,
                            ),
                          ),
                      ),
                    ),
                    
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(Icons.work_outline, "Role", emp.role),
                          if (emp.department.isNotEmpty)
                            _buildDetailRow(Icons.business_outlined, "Department", emp.department),
                          if (emp.email.isNotEmpty)
                            _buildDetailRow(Icons.email_outlined, "Email", emp.email),
                          if (emp.phone.isNotEmpty)
                            _buildDetailRow(Icons.phone_outlined, "Phone", emp.phone),
                          if (emp.interests.isNotEmpty)
                            _buildDetailRow(Icons.favorite_outline, "Hobbies", emp.interests),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: SageColors.primary),
          const SizedBox(width: 6),
          SizedBox(
            width: 75,
            child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

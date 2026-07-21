import 'package:sage_mainframe/widgets/sage_expansion_tile.dart';
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
  final String address;
  final String workLocation;
  final String emergencyContact;
  final String professionalBio;
  final List<String> keySkills;
  final List<String> strengths;
  final String workStylePreference;

  _TeamMemberData({
    required this.name,
    required this.preferredName,
    required this.role,
    required this.department,
    required this.email,
    required this.phone,
    required this.interests,
    required this.avatarIndex,
    required this.address,
    required this.workLocation,
    required this.emergencyContact,
    required this.professionalBio,
    required this.keySkills,
    required this.strengths,
    required this.workStylePreference,
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
          address: emp.address,
          workLocation: emp.workLocation,
          emergencyContact: emp.emergencyContact,
          professionalBio: emp.professionalBio,
          keySkills: emp.keySkills,
          strengths: emp.strengths,
          workStylePreference: emp.workStylePreference,
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
        address: p.address,
        workLocation: p.workLocation,
        emergencyContact: p.emergencyContact,
        professionalBio: p.professionalBio,
        keySkills: p.keySkills,
        strengths: p.strengths,
        workStylePreference: p.workStylePreference,
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
                ? "${emp.name.toUpperCase()} (${emp.preferredName})"
                : emp.name.toUpperCase();
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TerminalPanel(
                title: displayName,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        Container(
                          margin: const EdgeInsets.only(right: 16, top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                        
                        // Basic Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(Icons.work_outline, "Role", emp.role),

                              if (emp.email.isNotEmpty)
                                _buildDetailRow(Icons.email_outlined, "Email", emp.email),
                              if (emp.phone.isNotEmpty)
                                _buildDetailRow(Icons.phone_outlined, "Phone", emp.phone),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: SageExpansionTile(
                        title: const Text("Personal Details", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        children: [
                          if (emp.address.isNotEmpty)
                            _buildDetailRow(Icons.location_on, "Address", emp.address),
                          if (emp.workLocation.isNotEmpty)
                            _buildDetailRow(Icons.business, "Work Location", emp.workLocation),
                          if (emp.emergencyContact.isNotEmpty)
                            _buildDetailRow(Icons.warning, "Emergency Contact", emp.emergencyContact),
                          if (emp.professionalBio.isNotEmpty)
                            _buildDetailRow(Icons.description, "Bio", emp.professionalBio),
                          if (emp.keySkills.isNotEmpty)
                            _buildDetailRow(Icons.build, "Skills", emp.keySkills.join(', ')),
                          if (emp.strengths.isNotEmpty)
                            _buildDetailRow(Icons.fitness_center, "Strengths", emp.strengths.join(', ')),
                          if (emp.workStylePreference.isNotEmpty)
                            _buildDetailRow(Icons.track_changes, "Work Style", emp.workStylePreference),
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
            width: 110,
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

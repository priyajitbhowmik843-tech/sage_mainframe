import re

def fix_ceo_cfo_dashboards(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()

    # Fix videographer role check
    content = content.replace("e.role.toLowerCase() == 'videographer'", "e.role.toLowerCase().contains('videographer')")

    # In ceo_dashboard, the updateClient call was broken by me, let's restore it
    if 'ceo_dashboard.dart' in filename:
        broken_button = """                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: SageColors.primary),
              );
            },
          );"""
        
        fixed_button = """                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: SageColors.primary),
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
                      packageType: packageType,
                      contractPeriod: contractPeriod,
                      conversionProbability: conversionProbability,
                      retentionHealth: retentionHealth,
                      nextDueDate: dueDateCtrl.text,
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
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text("SAVE"),
                ),
              ],
            );
          },
        );"""
        content = content.replace(broken_button, fixed_button)

    with open(filename, 'w', encoding='utf-8') as f:
        f.write(content)

def fix_video_dashboard(filename):
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    content = re.sub(r"final dStr = '--';\s*final sessions = mySessionTasks\.where\(\(t\) \{\s*final dd = t\.deadline;\s*return '--' == dStr;\s*\}\)\.toList\(\);",
                     r"final sessions = mySessionTasks.where((t) {\n                final dd = t.deadline;\n                return dd.year == date.year && dd.month == date.month && dd.day == date.day;\n              }).toList();", content)
    
    content = re.sub(r"final dStr = '--';\s*final sessions = state\.tasks\.where\(\(t\) \{\s*if \(t\.assignedTo != persona\.id \|\| t\.taskType != 'Session'\) return false;\s*final dd = t\.deadline;\s*return '--' == dStr;\s*\}\)\.toList\(\);",
                     r"final sessions = state.tasks.where((t) {\n      if (t.assignedTo != persona.id || t.taskType != 'Session') return false;\n      final dd = t.deadline;\n      return dd.year == d.year && dd.month == d.month && dd.day == d.day;\n    }).toList();", content)

    content = content.replace("final dateLabel = '  ';", "final dateLabel = '${d.day} ${months[d.month-1]} ${d.year}';")

    with open(filename, 'w', encoding='utf-8') as f:
        f.write(content)

fix_ceo_cfo_dashboards('lib/screens/ceo_dashboard.dart')
fix_ceo_cfo_dashboards('lib/screens/cofounder_dashboard.dart')
fix_ceo_cfo_dashboards('lib/screens/cofounder_dashboard_recovered.dart')
fix_video_dashboard('lib/screens/videographer_dashboard.dart')
print('Done!')

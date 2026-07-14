import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/models.dart';

class ClientResourcesScreen extends StatelessWidget {
  final bool readOnly;
  const ClientResourcesScreen({super.key, this.readOnly = false});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final activePersona = state.activePersona;
    final isVideoStaff = state.employees.any((e) => e.id == activePersona.id && e.hasRole(''));
    
    final clients = state.clients.where((c) => c.status != 'Lead' && c.isApprovedByCeo).toList();

    if (clients.isEmpty) {
      return const Center(
        child: Text(
          'NO ACTIVE CLIENTS FOUND',
          style: TextStyle(color: SageColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(14),
      itemCount: clients.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) => _ClientResourceCard(key: ValueKey(clients[i].id), client: clients[i], readOnly: readOnly, isVideoStaff: isVideoStaff),
    );
  }
}

class _ClientResourceCard extends StatefulWidget {
  final Client client;
  final bool readOnly;
  final bool isVideoStaff;
  const _ClientResourceCard({super.key, required this.client, required this.readOnly, this.isVideoStaff = false});
  @override
  State<_ClientResourceCard> createState() => _ClientResourceCardState();
}

class _ClientResourceCardState extends State<_ClientResourceCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.client;
    
    if (widget.isVideoStaff) {
      return Container(
        margin: const EdgeInsets.only(bottom: 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: SageColors.primary.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
            const SizedBox(height: 16),
            const Text('DESCRIPTION / REQUIREMENTS', style: TextStyle(color: SageColors.tertiary, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SageColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SageColors.tertiary.withValues(alpha: 0.3)),
              ),
              child: Text(
                c.postRequirements == 'TBD'
                    ? 'Not provided'
                    : c.postRequirements,
                style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.6),
              ),
            ),
          ],
        ),
      );
    }

    return TerminalPanel(
      title: c.name,
      glowColor: _expanded ? SageColors.tertiary : SageColors.primaryDim,
      trailing: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Icon(
          _expanded ? Icons.expand_less : Icons.expand_more,
          color: SageColors.tertiary,
          size: 16,
        ),
      ),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              // removed StatusBadge for postTheme
              if (c.discountPercent > 0 && !widget.readOnly)
                StatusBadge(label: '${c.discountPercent.toStringAsFixed(0)}% DISC', color: SageColors.tertiary),
              StatusBadge(label: '${c.resourceLinks.length} LINKS', color: SageColors.outline, glow: false),
            ]),
          ),
          if (_expanded) ...[
            NeonDivider(color: SageColors.primaryDim),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Requirements
                  const Text('DESCRIPTION / REQUIREMENTS', style: TextStyle(color: SageColors.tertiary, fontSize: 9, letterSpacing: 2)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SageColors.surfaceContainerLowest,
                      border: Border(left: BorderSide(color: SageColors.tertiary, width: 2)),
                    ),
                    child: Text(
                      c.postRequirements == 'TBD'
                          ? 'Not provided'
                          : c.postRequirements,
                      style: const TextStyle(color: SageColors.onSurface, fontSize: 12, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Resource Links
                  const Text('RESOURCE LINKS', style: TextStyle(color: SageColors.secondary, fontSize: 9, letterSpacing: 2)),
                  const SizedBox(height: 6),
                  ...c.resourceLinks.map((link) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: SageColors.surfaceContainerLowest,
                      border: Border.all(color: SageColors.secondaryDim, width: 1),
                      boxShadow: SageColors.neonGlow(SageColors.secondary, spread: 0, blur: 5),
                    ),
                    child: Row(children: [
                      Icon(Icons.open_in_new, color: SageColors.secondary, size: 13,
                          shadows: SageColors.neonTextGlow(SageColors.secondary).map((s) => Shadow(color: s.color, blurRadius: s.blurRadius)).toList()),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            try {
                              await Clipboard.setData(ClipboardData(text: link));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('Copied link: $link', style: const TextStyle()),
                                  backgroundColor: SageColors.secondary,
                                ));
                              }
                            } catch (_) {}
                          },
                          child: Text(
                            link,
                            style: TextStyle(
                              color: SageColors.secondary,
                              fontSize: 11,
                              decoration: TextDecoration.underline,
                              shadows: SageColors.neonTextGlow(SageColors.secondary).map((s) => Shadow(color: s.color.withValues(alpha: 0.4), blurRadius: s.blurRadius)).toList(),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: SageColors.secondary, size: 14),
                        onPressed: () async {
                          try {
                            await Clipboard.setData(ClipboardData(text: link));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Copied to clipboard!', style: TextStyle()),
                                backgroundColor: SageColors.secondary,
                              ));
                            }
                          } catch (_) {}
                        },
                      ),
                    ]),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

export 'sage_calendar.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── NEON GLOW HELPERS ────────────────────────────────────────────────────────
/// Wraps text with a neo-brutalist bold look
class NeonText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color glowColor;
  final TextAlign textAlign;

  const NeonText({
    super.key,
    required this.text,
    required this.style,
    required this.glowColor,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: style.copyWith(
        color: SageColors.onSurface,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

/// A neo-brutalist outlined container box
class NeonBox extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final EdgeInsets padding;
  final Color? fillColor;
  final double borderWidth;

  const NeonBox({
    super.key,
    required this.child,
    required this.glowColor,
    this.padding = const EdgeInsets.all(12),
    this.fillColor,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fillColor ?? SageColors.surface,
        border: Border.all(color: Colors.black, width: borderWidth),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: child,
    );
  }
}

class TerminalPanel extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  final Color? headerColor;
  final Color? glowColor;
  final EdgeInsets padding;

  const TerminalPanel({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.headerColor,
    this.glowColor,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    final contentBg = headerColor ?? SageColors.surface;

    return Container(
      decoration: BoxDecoration(
        color: contentBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: SageColors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

// ─── DASHBOARD TILE (SMOOTH PASTEL) ───────────────────────────────────────────
class DashboardTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final IconData icon;
  final VoidCallback? onTap;

  const DashboardTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black, width: 1.5),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.black87, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Check",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  color: Colors.black87,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── STAT CHIP ────────────────────────────────────────────────────────────────
Color _getPastelColor(Color color) {
  if (color == SageColors.primary) return SageColors.primaryContainer;
  if (color == SageColors.secondary) return SageColors.secondaryContainer;
  if (color == SageColors.tertiary) return SageColors.tertiaryContainer;
  if (color == SageColors.error) return SageColors.errorContainer;
  return color.withValues(alpha: 0.15);
}

class StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;
  final bool showBadge;

  const StatChip({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getPastelColor(valueColor),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: SageColors.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Badge(
                isLabelVisible: showBadge,
                child: Icon(icon, color: valueColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SAGE TEXT FIELD ─────────────────────────────────────────────────────────
/// Modern rounded text field
class SageTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final TextInputType keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const SageTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: SageColors.onSurface, fontSize: 14),
      cursorColor: SageColors.primary,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: SageColors.onSurface),
        hintStyle: const TextStyle(color: SageColors.onSurfaceVariant),
        filled: true,
        fillColor: SageColors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.black, width: 2.0),
        ),
      ),
    );
  }
}

// ─── STATUS BADGE ─────────────────────────────────────────────────────────────
/// Pill-shaped status badge
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? bgColor;
  final bool glow;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.bgColor,
    this.glow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor ?? _getPastelColor(color),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.2),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color == SageColors.primary
              ? SageColors.primaryDim
              : (color == SageColors.secondary
                    ? SageColors.secondaryDim
                    : color),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── BLINKING CURSOR ──────────────────────────────────────────────────────────
class BlinkingCursor extends StatefulWidget {
  final Color? color;
  const BlinkingCursor({super.key, this.color});

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? SageColors.primary;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _ctrl.value > 0.5 ? 1.0 : 0.0,
        child: Container(
          width: 9,
          height: 16,
          decoration: BoxDecoration(color: c),
        ),
      ),
    );
  }
}

// ─── SCANLINE OVERLAY ─────────────────────────────────────────────────────────
/// CRT scanline + vignette overlay (Disabled for light neo-brutalist theme)
class ScanlineOverlay extends StatelessWidget {
  final Widget child;
  const ScanlineOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

// ─── NEON DIVIDER ─────────────────────────────────────────────────────────────
class NeonDivider extends StatelessWidget {
  final Color? color;
  const NeonDivider({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(height: 1.5, color: Colors.black);
  }
}

// ─── DIALOGS ──────────────────────────────────────────────────────────────────
Future<bool> showConfirmDialog(
  BuildContext context,
  String title,
  String message,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(
        message,
        style: const TextStyle(
          color: SageColors.onSurfaceVariant,
          fontSize: 13,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text(
            'CANCEL',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('CONFIRM'),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<bool> showAdminPinDialog(
  BuildContext context,
  bool Function(String) verifyPin,
) async {
  final pinCtrl = TextEditingController();
  String? error;
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx2, setState) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.black, size: 16),
            const SizedBox(width: 8),
            const Text('ADMIN SECURITY CHECK'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ENTER ADMIN PIN TO PROCEED',
              style: TextStyle(
                color: SageColors.onSurfaceVariant,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                letterSpacing: 12,
              ),
              decoration: InputDecoration(
                labelText: 'PIN',
                counterText: '',
                errorText: error,
                errorStyle: const TextStyle(
                  color: SageColors.error,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx2, false),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (verifyPin(pinCtrl.text)) {
                Navigator.pop(ctx2, true);
              } else {
                setState(() => error = '⚠ INVALID PIN. ACCESS DENIED.');
              }
            },
            child: const Text('VERIFY'),
          ),
        ],
      ),
    ),
  );
  return result ?? false;
}

// ─── LIVE CLOCK WIDGET ───────────────────────────────────────────────────────
class LiveClockWidget extends StatefulWidget {
  const LiveClockWidget({super.key});

  @override
  State<LiveClockWidget> createState() => _LiveClockWidgetState();
}

class _LiveClockWidgetState extends State<LiveClockWidget> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _currentTime = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatDate(DateTime dt) {
    const months = [
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
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: SageColors.yellowAccentContainer,
        borderRadius: BorderRadius.circular(16),
        /* border removed for pastel style */
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.black, size: 18),
              const SizedBox(width: 8),
              Text(
                _formatDate(_currentTime),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Text(
            _formatTime(_currentTime),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class SageMultiSelectDropdown<T> extends StatelessWidget {
  final List<T> items;
  final List<T> selectedItems;
  final String Function(T) labelBuilder;
  final void Function(List<T>) onChanged;
  final String labelText;
  final String emptyText;
  final bool Function(T, T)? compareFn;

  const SageMultiSelectDropdown({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.labelBuilder,
    required this.onChanged,
    required this.labelText,
    this.emptyText = 'Select options',
    this.compareFn,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final List<T>? result = await showDialog<List<T>>(
          context: context,
          builder: (context) {
            return _MultiSelectDialog<T>(
              items: items,
              initialSelectedItems: selectedItems,
              labelBuilder: labelBuilder,
              title: labelText,
              compareFn: compareFn,
            );
          },
        );
        if (result != null) {
          onChanged(result);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          fillColor: Colors.white,
          filled: true,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          selectedItems.isEmpty
              ? emptyText
              : selectedItems.map((e) => labelBuilder(e)).join(', '),
          style: const TextStyle(color: Colors.black87),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _MultiSelectDialog<T> extends StatefulWidget {
  final List<T> items;
  final List<T> initialSelectedItems;
  final String Function(T) labelBuilder;
  final String title;
  final bool Function(T, T)? compareFn;

  const _MultiSelectDialog({
    required this.items,
    required this.initialSelectedItems,
    required this.labelBuilder,
    required this.title,
    this.compareFn,
  });

  @override
  State<_MultiSelectDialog<T>> createState() => _MultiSelectDialogState<T>();
}

class _MultiSelectDialogState<T> extends State<_MultiSelectDialog<T>> {
  late List<T> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.initialSelectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: widget.items.map((item) {
            final isSelected = widget.compareFn != null
                ? _selectedItems.any((e) => widget.compareFn!(e, item))
                : _selectedItems.contains(item);
            return CheckboxListTile(
              title: Text(widget.labelBuilder(item)),
              value: isSelected,
              activeColor: SageColors.primary,
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedItems.add(item);
                  } else {
                    if (widget.compareFn != null) {
                      _selectedItems.removeWhere(
                        (e) => widget.compareFn!(e, item),
                      );
                    } else {
                      _selectedItems.remove(item);
                    }
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedItems),
          style: ElevatedButton.styleFrom(
            backgroundColor: SageColors.primary,
            foregroundColor: Colors.black,
          ),
          child: const Text(
            'CONFIRM',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

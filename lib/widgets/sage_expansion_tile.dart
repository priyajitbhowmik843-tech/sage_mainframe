import 'package:flutter/material.dart';

class SageExpansionTile extends StatefulWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget> children;
  final ExpansionTileController? controller;
  final EdgeInsetsGeometry? tilePadding;
  final EdgeInsetsGeometry? childrenPadding;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final Color? iconColor;
  final Color? collapsedIconColor;
  final CrossAxisAlignment? expandedCrossAxisAlignment;
  final Alignment? expandedAlignment;
  final ShapeBorder? shape;
  final ShapeBorder? collapsedShape;
  final Color? backgroundColor;
  final Color? collapsedBackgroundColor;
  final Color? textColor;
  final Color? collapsedTextColor;

  const SageExpansionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.children = const <Widget>[],
    this.controller,
    this.tilePadding,
    this.childrenPadding,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.iconColor,
    this.collapsedIconColor,
    this.expandedCrossAxisAlignment,
    this.expandedAlignment,
    this.shape,
    this.collapsedShape,
    this.backgroundColor,
    this.collapsedBackgroundColor,
    this.textColor,
    this.collapsedTextColor,
  });

  @override
  State<SageExpansionTile> createState() => _SageExpansionTileState();
}

class _SageExpansionTileState extends State<SageExpansionTile> {
  final GlobalKey _key = GlobalKey();

  void _scrollToSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_key.currentContext != null) {
        Scrollable.ensureVisible(
          _key.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: _key,
      title: widget.title,
      subtitle: widget.subtitle,
      leading: widget.leading,
      trailing: widget.trailing,
      children: widget.children,
      controller: widget.controller,
      tilePadding: widget.tilePadding,
      childrenPadding: widget.childrenPadding,
      initiallyExpanded: widget.initiallyExpanded,
      iconColor: widget.iconColor,
      collapsedIconColor: widget.collapsedIconColor,
      expandedCrossAxisAlignment: widget.expandedCrossAxisAlignment,
      expandedAlignment: widget.expandedAlignment,
      shape: widget.shape,
      collapsedShape: widget.collapsedShape,
      backgroundColor: widget.backgroundColor,
      collapsedBackgroundColor: widget.collapsedBackgroundColor,
      textColor: widget.textColor,
      collapsedTextColor: widget.collapsedTextColor,
      onExpansionChanged: (expanded) {
        if (expanded) {
          _scrollToSelected();
        }
        if (widget.onExpansionChanged != null) {
          widget.onExpansionChanged!(expanded);
        }
      },
    );
  }
}

import 'package:flutter/material.dart';

class Collapsable extends StatefulWidget{
  final String name;
  final Widget child;
  final bool initialCollapsed;
  const Collapsable({
    super.key,
    required this.child,
    this.initialCollapsed = true,
    this.name = "Section",
  });

  @override
  State<Collapsable> createState() => _CollapsableState();
}

class _CollapsableState extends State<Collapsable> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sizeAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = !widget.initialCollapsed;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: widget.initialCollapsed? 0 : 1, // Start collapsed.
    );
    _sizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header that toggles the expansion.
        GestureDetector(
          onTap: _toggleExpand,
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 10, bottom: 5),
            child: Row(
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        ),
        // Animated collapse/expand effect while keeping PlaylistTiles mounted.
        ClipRect(
          child: SizeTransition(
            sizeFactor: _sizeAnimation,
            axisAlignment: -1.0, // Aligns the animation to the top edge.
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
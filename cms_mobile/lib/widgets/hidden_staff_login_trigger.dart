import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_constants.dart';

class HiddenStaffLoginTrigger extends StatefulWidget {
  final Widget child;

  const HiddenStaffLoginTrigger({
    super.key,
    required this.child,
  });

  @override
  State<HiddenStaffLoginTrigger> createState() => _HiddenStaffLoginTriggerState();
}

class _HiddenStaffLoginTriggerState extends State<HiddenStaffLoginTrigger> {
  Timer? _timer;

  void _handleTapDown(TapDownDetails details) {
    _timer?.cancel();
    _timer = Timer(AppConstants.hiddenLoginPressDuration, () {
      if (mounted) {
        Navigator.pushNamed(context, '/login');
      }
    });
  }

  void _handleTapUp(TapUpDetails details) {
    _timer?.cancel();
  }

  void _handleTapCancel() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: widget.child,
    );
  }
}

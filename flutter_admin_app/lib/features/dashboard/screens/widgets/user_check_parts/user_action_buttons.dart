import 'package:flutter/material.dart';

class UserActionButtons extends StatelessWidget {
  final String status;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final Color primaryColor;

  const UserActionButtons({
    super.key,
    required this.status,
    required this.onApprove,
    required this.onReject,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (status == 'pending') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NeoScaleButton(
            onPressed: onReject,
            isTextButton: true,
            label: '거절',
            color: Colors.redAccent,
          ),
          const SizedBox(width: 8),
          _NeoScaleButton(
            onPressed: onApprove,
            label: '승인',
            color: primaryColor,
            textColor: Colors.black,
          ),
        ],
      );
    } else if (status == 'rejected') {
      return _NeoScaleButton(
        onPressed: onApprove,
        isTextButton: true,
        label: '재승인',
        color: primaryColor,
      );
    } else {
      return _NeoScaleButton(
        onPressed: onReject,
        isTextButton: true,
        label: '활동 정지',
        color: Colors.redAccent,
      );
    }
  }
}

class _NeoScaleButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final Color color;
  final Color? textColor;
  final bool isTextButton;

  const _NeoScaleButton({
    required this.onPressed,
    required this.label,
    required this.color,
    this.textColor,
    this.isTextButton = false,
  });

  @override
  State<_NeoScaleButton> createState() => _NeoScaleButtonState();
}

class _NeoScaleButtonState extends State<_NeoScaleButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) => setState(() => _scale = 0.95);
  void _onTapUp(TapUpDetails details) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.isTextButton
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.textColor ?? Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
      ),
    );
  }
}


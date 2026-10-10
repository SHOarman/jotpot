import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

class FilterInputField extends StatefulWidget {
  final String label;
  final String hint;
  final String? value;
  final ValueChanged<String> onChanged;

  const FilterInputField({
    super.key,
    required this.label,
    required this.hint,
    this.value,
    required this.onChanged,
  });

  @override
  State<FilterInputField> createState() => _FilterInputFieldState();
}

class _FilterInputFieldState extends State<FilterInputField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant FilterInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isFocused ? AppColors.primaryOrange : AppColors.border,
              width: isFocused ? 1.5 : 1.0,
            ),
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            style: const TextStyle(fontSize: 13, color: AppColors.textDark),
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.hint,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}

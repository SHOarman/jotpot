import 'package:flutter/material.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/app_theme.dart';

class FilterDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final bool isEnabled;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final active = isEnabled && items.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
            color: active ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: active && items.contains(value) ? value : null,
              isDense: true,
              hint: Text(
                hint,
                style: TextStyle(
                  fontSize: 13,
                  color: active ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: active ? AppColors.textMuted : const Color(0xFFCBD5E1),
                size: 20,
              ),
              items: active
                  ? [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          AppStrings.of(context).isBn
                              ? 'সকল $label'
                              : 'All $label',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textDark),
                        ),
                      ),
                      ...items.map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                          ),
                        );
                      }),
                    ]
                  : null,
              onChanged: active ? onChanged : null,
            ),
          ),
        ),
      ],
    );
  }
}



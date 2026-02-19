import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DistanceSelectorWidget extends StatelessWidget {
  final int selectedKm;
  final ValueChanged<int> onChanged;

  const DistanceSelectorWidget({
    super.key,
    required this.selectedKm,
    required this.onChanged,
  });

  static const List<int> _options = [5, 10, 15, 20, 25];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 120;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 8 : 12,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                LucideIcons.mapPin,
                color: Colors.blueAccent,
                size: isCompact ? 16 : 20,
              ),
              SizedBox(width: isCompact ? 4 : 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedKm,
                    isDense: true,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(20),
                    items: _options
                        .map(
                          (km) => DropdownMenuItem(
                            value: km,
                            child: Text(
                              '$km km',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) onChanged(value);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

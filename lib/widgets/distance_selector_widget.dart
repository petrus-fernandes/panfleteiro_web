import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DistanceSelectorWidget extends StatelessWidget {
  final int selectedKm;
  final ValueChanged<int> onChanged;

  const DistanceSelectorWidget({
    Key? key,
    required this.selectedKm,
    required this.onChanged,
  }) : super(key: key);

  static const List<int> _options = [5, 10, 15, 20, 25];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
        mainAxisSize: MainAxisSize.min,
        children: [
        const Icon(
        LucideIcons.mapPin,
        color: Colors.blueAccent,
        size: 20,
      ),
      const SizedBox(width: 8),
      DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedKm,
          borderRadius: BorderRadius.circular(20),
          items: _options
              .map((km) => DropdownMenuItem(
              value: km,
              child: Text("$km km"),
              )
          ).toList(),
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        ),
        ],
      ),
    );
  }
}

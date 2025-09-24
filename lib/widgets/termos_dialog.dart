import 'package:flutter/material.dart';
import 'termo_formal_widget.dart';

class TermosDialog extends StatelessWidget {
  final VoidCallback onAccepted;

  const TermosDialog({super.key, required this.onAccepted});

  @override
  Widget build(BuildContext context) {
    bool tempAccepted = false;

    return StatefulBuilder(
      builder: (context, setStateDialog) {
        return AlertDialog(
          title: Text(
            "Termo de Conscientização",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red[800],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const TermoFormalWidget(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: tempAccepted,
                      onChanged: (value) {
                        setStateDialog(() {
                          tempAccepted = value ?? false;
                        });
                        if (value == true) {
                          Navigator.of(context).pop();
                          onAccepted();
                        }
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "Li e aceito os termos",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

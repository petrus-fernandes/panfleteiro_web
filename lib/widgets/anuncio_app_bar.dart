import 'package:flutter/material.dart';

class AnuncioAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AnuncioAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/main');
            },
            child: Image.asset(
              'assets/logo.png',
              height: 65,
            ),
          ),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Text(
              'Mercadão',
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD32F2F),
              ),
            ),
          ),
        ],
      ),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: TextButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/login');
            },
            icon: const Icon(Icons.login),
            label: const Text('Login'),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

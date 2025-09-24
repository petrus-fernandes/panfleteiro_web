import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final Function(String) onSubmitted;
  final Function(String) onChanged;

  const SearchBarWidget({
    super.key,
    required this.onSubmitted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      hintText: 'Digite o nome do produto',
      leading: const Icon(Icons.search),
      elevation: MaterialStateProperty.all(1),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}

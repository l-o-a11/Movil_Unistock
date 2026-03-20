import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AppSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String hint;

  const AppSearchBar({
    super.key,
    required this.onChanged,
    this.hint = 'Buscar...',
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (value) {
        setState(() {}); // rebuild to show/hide clear button
        widget.onChanged(value);
      },
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded,
                    size: 18, color: AppColors.textHint),
                onPressed: () {
                  _controller.clear();
                  setState(() {});
                  widget.onChanged('');
                },
              )
            : null,
      ),
    );
  }
}

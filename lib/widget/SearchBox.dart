import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String> onSubmit;
  final VoidCallback? onClear;

  const SearchBox({
    super.key,
    required this.controller,
    this.focusNode,
    required this.onSubmit,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmit,
              decoration: const InputDecoration(
                hintText: 'Search movies',
                border: InputBorder.none,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            InkWell(
              onTap: onClear,
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.close, size: 18, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }
}

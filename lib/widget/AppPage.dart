import 'package:flutter/material.dart';

class AppPage extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? action;

  const AppPage({
    super.key,
    this.title,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title!,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                    if (action != null) action!,
                  ],
                ),
                const SizedBox(height: 18),
              ],
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
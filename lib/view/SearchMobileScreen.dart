import 'package:flutter/material.dart' hide SearchController;
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:insanity_labs/controller/SearchController.dart';
import 'package:insanity_labs/view/DetailMobileScreen.dart';
import 'package:insanity_labs/view/ResultMobileScreen.dart';
import 'package:insanity_labs/widget/SearchBox.dart';
import 'package:insanity_labs/widget/AppPage.dart';

class SearchMobileScreen extends StatefulWidget {
  const SearchMobileScreen({super.key});

  @override
  State<SearchMobileScreen> createState() => _SearchMobileScreenState();
}

class _SearchMobileScreenState extends State<SearchMobileScreen> {
  final controller = TextEditingController();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.removeListener(_onTextChanged);
    controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
    timer?.cancel();
    final text = controller.text.trim();
    if (text.isEmpty) {
      context.read<SearchController>().add(Clear());
      return;
    }

    timer = Timer(const Duration(milliseconds: 450), () {
      context.read<SearchController>().add(Search(text));
    });
  }

  void open(String text) {
    final value = text.trim();
    if (value.isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultMobileScreen(text: value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: "Search",
      child: Column(
        children: [
          SearchBox(
            controller: controller,
            onSubmit: open,
            onClear: () {
              controller.clear();
              context.read<SearchController>().add(Clear());
            },
          ),
          const SizedBox(height: 14),
          Expanded(
            child: BlocBuilder<SearchController, SearchState>(
              builder: (context, state) {
                if (controller.text.trim().isEmpty) {
                  return const SizedBox();
                }

                if (state is Loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SearchError) {
                  return Center(
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                if (state is Loaded) {
                  final list = state.movies.take(8).toList();
                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        'No suggestions',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withValues(alpha: 0.65),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                    itemBuilder: (_, i) {
                      final m = list[i];
                      return InkWell(
                        onTap: () {
                          final id = m.id?.trim() ?? '';
                          if (id.isEmpty) {
                            open(m.title ?? controller.text);
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailMobileScreen(movie: m),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 34,
                                width: 34,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.black.withValues(alpha: 0.06),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.movie_outlined,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.title ?? '-',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${m.year ?? ''}  •  ${m.type ?? ''}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black.withValues(alpha: 0.6),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart' hide SearchController;
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:insanity_labs/controller/SearchController.dart';
import 'package:insanity_labs/controller/FavController.dart';
import 'package:insanity_labs/view/DetailMobileScreen.dart';
import 'package:insanity_labs/model/MovieModel.dart';
import 'package:insanity_labs/widget/AppPage.dart';
import 'package:insanity_labs/widget/MovieCard.dart';
import 'package:insanity_labs/widget/Loading.dart';
import 'package:insanity_labs/widget/ErrorView.dart';
import 'package:insanity_labs/widget/SearchBox.dart';

class ResultMobileScreen extends StatefulWidget {
  final String text;

  const ResultMobileScreen({super.key, required this.text});

  @override
  State<ResultMobileScreen> createState() => _ResultMobileScreenState();
}

class _ResultMobileScreenState extends State<ResultMobileScreen> {
  late TextEditingController controller;
  late final ScrollController scrollController;
  late final TextEditingController yearController;
  final focusNode = FocusNode();
  Timer? timer;
  bool isEditing = false;
  String typeValue = '';

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.text);
    yearController = TextEditingController();
    scrollController = ScrollController()..addListener(_onScroll);

    controller.addListener(_onTextChanged);
    focusNode.addListener(() {
      if (isEditing != focusNode.hasFocus) {
        setState(() {
          isEditing = focusNode.hasFocus;
        });
      }
    });

    context.read<SearchController>().add(Search(widget.text));
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.removeListener(_onTextChanged);
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    controller.dispose();
    yearController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!mounted) return;
    timer?.cancel();
    final text = controller.text.trim();
    if (text.isEmpty) {
      context.read<SearchController>().add(Clear());
      setState(() {});
      return;
    }

    timer = Timer(const Duration(milliseconds: 450), () {
      search(text);
    });

    setState(() {});
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final max = scrollController.position.maxScrollExtent;
    final current = scrollController.position.pixels;
    if (max <= 0) return;
    if (current >= (max - 320)) {
      context.read<SearchController>().add(LoadMore());
    }
  }

  void search(String text) {
    context.read<SearchController>().add(
          Search(
            text,
            type: typeValue.isEmpty ? null : typeValue,
            year: yearController.text.trim().isEmpty
                ? null
                : yearController.text.trim(),
          ),
        );
  }

  void _applyFiltersFromLoaded(Loaded state) {
    final nextType = state.type ?? '';
    if (typeValue != nextType) {
      typeValue = nextType;
    }

    final nextYear = state.year ?? '';
    if (yearController.text != nextYear) {
      yearController.text = nextYear;
    }
  }

  void open(MovieModel movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailMobileScreen(movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: SearchBox(
                  controller: controller,
                  focusNode: focusNode,
                  onSubmit: search,
                  onClear: () {
                    controller.clear();
                    yearController.clear();
                    setState(() {
                      typeValue = '';
                      isEditing = false;
                    });
                    focusNode.unfocus();
                    context.read<SearchController>().add(Clear());
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: typeValue,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: '', child: Text('All types')),
                        DropdownMenuItem(value: 'movie', child: Text('Movie')),
                        DropdownMenuItem(value: 'series', child: Text('Series')),
                        DropdownMenuItem(value: 'episode', child: Text('Episode')),
                      ],
                      onChanged: (v) {
                        setState(() {
                          typeValue = v ?? '';
                        });
                        search(controller.text);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 110,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: TextField(
                    controller: yearController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Year',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (v) => search(controller.text),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<SearchController, SearchState>(
              builder: (context, state) {
                final showSuggestions =
                    isEditing && controller.text.trim().isNotEmpty;
                if (state is Loading) {
                  return const Center(child: Loader());
                }

                if (state is SearchError) {
                  return ErrorView(
                    message: state.message,
                    onTap: () => search(controller.text),
                  );
                }

                if (state is Loaded) {
                  _applyFiltersFromLoaded(state);

                  if (showSuggestions) {
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
                            focusNode.unfocus();
                            setState(() {
                              isEditing = false;
                            });
                            open(m);
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
                                      color:
                                          Colors.black.withValues(alpha: 0.06),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          color:
                                              Colors.black.withValues(alpha: 0.6),
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

                  return BlocBuilder<FavController, FavState>(
                    builder: (context, fav) {
                      return GridView.builder(
                        controller: scrollController,
                        itemCount:
                            state.movies.length + (state.isLoadingMore ? 1 : 0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.62,
                        ),
                        itemBuilder: (_, i) {
                          if (i >= state.movies.length) {
                            return const Center(child: Loader());
                          }
                          final movie = state.movies[i];
                          final isFav = fav is FavLoaded
                              ? fav.has(movie.id ?? '')
                              : false;

                          return MovieCard(
                            movie: movie,
                            isFav: isFav,
                            onTap: () => open(movie),
                            onFav: () {
                              if (isFav) {
                                context
                                    .read<FavController>()
                                    .add(Remove(movie.id ?? ''));
                              } else {
                                context
                                    .read<FavController>()
                                    .add(Add(movie));
                              }
                            },
                          );
                        },
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
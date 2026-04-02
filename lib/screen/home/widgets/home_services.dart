import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_bloc.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_state.dart';
import 'package:onecharge/logic/blocs/issue_category/issue_category_event.dart';
import 'package:onecharge/const/onebtn.dart';

class HomeServices extends StatefulWidget {
  final String searchQuery;
  final Function(String) onServiceSelected;

  const HomeServices({
    super.key,
    required this.searchQuery,
    required this.onServiceSelected,
  });

  @override
  State<HomeServices> createState() => _HomeServicesState();
}

class _HomeServicesState extends State<HomeServices> {

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Our Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lufga',
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<IssueCategoryBloc, IssueCategoryState>(
          builder: (context, state) {
            if (state is IssueCategoryLoading) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final double cardWidth = (constraints.maxWidth - 13) / 2;
                  return Wrap(
                    spacing: 13,
                    runSpacing: 13,
                    children: List.generate(4, (index) {
                      return _buildShimmerServiceCard(cardWidth);
                    }),
                  );
                },
              );
            } else if (state is IssueCategoryError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 40,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Couldn't load services",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lufga',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Please check your internet connection",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: 'Lufga',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 120,
                      child: OneBtn(
                        text: "Retry",
                        onPressed: () {
                          context.read<IssueCategoryBloc>().add(
                                FetchIssueCategories(),
                              );
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is IssueCategoryLoaded) {
              var categories =
                  state.categories.where((c) => c.name != null).toList();

              if (widget.searchQuery.isNotEmpty) {
                categories = categories
                    .where(
                      (c) => (c.name ?? '').toLowerCase().contains(
                            widget.searchQuery,
                          ),
                    )
                    .toList();
              }

              final displayCategories = categories;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final double cardWidth = (constraints.maxWidth - 13) / 2;
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Wrap(
                      spacing: 13,
                      runSpacing: 13,
                      children: [
                        ...List.generate(displayCategories.length, (index) {
                          final category = displayCategories[index];
                          final categoryName = category.name ?? 'Unknown';
                          return _ServiceCard(
                            title: categoryName,
                            imagePath: _getCategoryIcon(categoryName),
                            width: cardWidth,
                            imageUrl: category.imageUrl,
                            onTap: () => widget.onServiceSelected(categoryName),
                          );
                        }),
                      ],
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  String _getCategoryIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('station') || lowerName.contains('charge')) {
      return 'assets/home/chargingsation.png';
    }
    if (lowerName.contains('battery')) return 'assets/home/lowbattery.png';
    if (lowerName.contains('mechanical') || lowerName.contains('engine')) {
      return 'assets/home/mechanicalisuue.png';
    }
    if (lowerName.contains('tire') || lowerName.contains('tyre')) {
      return 'assets/home/falttyre.png';
    }
    if (lowerName.contains('tow') || lowerName.contains('pickup')) {
      return 'assets/home/pickupreqiure.png';
    }
    return '';
  }

  Widget _buildShimmerServiceCard(double width) {
    return Shimmer.fromColors(
      baseColor: const Color(0xffE0E0E0),
      highlightColor: Colors.white,
      child: Container(
        width: width,
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final String? imageUrl;
  final double width;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.title,
    required this.imagePath,
    this.imageUrl,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isOther = title == 'Other';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            if (!isOther)
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lufga',
                    height: 1.2,
                  ),
                ),
              ),
            if (!isOther && (imagePath.isNotEmpty || imageUrl != null))
              (title.toLowerCase().contains('tow') ||
                      title.toLowerCase().contains('pickup'))
                  ? Positioned(
                      right: -10,
                      top: 40,
                      bottom: 0,
                      child: imageUrl != null && imageUrl!.isNotEmpty
                          ? Image.network(
                              imageUrl!,
                              width: 110,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  imagePath.isNotEmpty
                                      ? Image.asset(
                                          imagePath,
                                          width: 110,
                                          fit: BoxFit.contain,
                                        )
                                      : const SizedBox(),
                            )
                          : imagePath.isNotEmpty
                              ? Image.asset(
                                  imagePath,
                                  width: 110,
                                  fit: BoxFit.contain,
                                )
                              : const SizedBox(),
                    )
                  : Positioned.fill(
                      top: 30,
                      child: Center(
                        child: imageUrl != null && imageUrl!.isNotEmpty
                            ? Image.network(
                                imageUrl!,
                                width: title.contains('Station') ? 60 : 120,
                                height: title.contains('Station') ? 90 : 80,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    imagePath.isNotEmpty
                                        ? Image.asset(
                                            imagePath,
                                            width: title.contains('Station')
                                                ? 60
                                                : 120,
                                            height: title.contains('Station')
                                                ? 90
                                                : 80,
                                            fit: BoxFit.contain,
                                          )
                                        : const SizedBox(),
                              )
                            : imagePath.isNotEmpty
                                ? Image.asset(
                                    imagePath,
                                    width: title.contains('Station') ? 60 : 120,
                                    height: title.contains('Station') ? 90 : 80,
                                    fit: BoxFit.contain,
                                  )
                                : const SizedBox(),
                      ),
                    ),
            if (isOther)
              const Center(
                child: Text(
                  'Other',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lufga',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

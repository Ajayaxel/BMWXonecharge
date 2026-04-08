import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:onecharge/logic/blocs/service_group/service_group_bloc.dart';
import 'package:onecharge/logic/blocs/service_group/service_group_state.dart';
import 'package:onecharge/logic/blocs/service_group/service_group_event.dart';
import 'package:onecharge/const/onebtn.dart';
import 'package:onecharge/models/service_group_model.dart';

class HomeServiceGroups extends StatefulWidget {
  final String searchQuery;
  final Function(String categoryName, int categoryId) onServiceSelected;

  const HomeServiceGroups({
    super.key,
    required this.searchQuery,
    required this.onServiceSelected,
  });

  @override
  State<HomeServiceGroups> createState() => _HomeServiceGroupsState();
}

class _HomeServiceGroupsState extends State<HomeServiceGroups> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceGroupBloc, ServiceGroupState>(
      builder: (context, state) {
        if (state is ServiceGroupLoading) {
          return _buildShimmerLoading();
        } else if (state is ServiceGroupError) {
          return _buildError(context);
        } else if (state is ServiceGroupLoaded) {
          final groups = state.serviceGroups;
          if (groups.isEmpty) return const SizedBox();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: groups.map((group) => _buildGroup(group)).toList(),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildGroup(ServiceGroup group) {
    var categories = group.issueCategories;

    if (widget.searchQuery.isNotEmpty) {
      categories = categories
          .where((c) =>
              (c.name ?? '').toLowerCase().contains(widget.searchQuery.toLowerCase()))
          .toList();
    }

    if (categories.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            group.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Lufga',
              color: Colors.black,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth = (constraints.maxWidth - 13) / 2;
            return Wrap(
              spacing: 13,
              runSpacing: 13,
              children: categories.map((category) {
                final categoryName = category.name ?? 'Unknown';
                return _ServiceCard(
                  title: categoryName,
                  width: cardWidth,
                  imageUrl: category.imageUrl,
                  onTap: () => widget.onServiceSelected(categoryName, category.id),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth - 13) / 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Shimmer.fromColors(
              baseColor: Colors.grey[200]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 140,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 13,
              runSpacing: 13,
              children: List.generate(4, (index) => _buildShimmerCard(cardWidth)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerCard(double width) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                width: width * 0.7,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 40, color: Colors.grey),
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
          const SizedBox(height: 16),
          SizedBox(
            width: 120,
            child: OneBtn(
              text: "Retry",
              onPressed: () {
                context.read<ServiceGroupBloc>().add(const FetchServiceGroups(forceRefresh: true));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final double width;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.title,
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
            if (!isOther && imageUrl != null)
              _buildImage(),
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

  Widget _buildImage() {
    final bool isTow = title.toLowerCase().contains('tow') || title.toLowerCase().contains('pickup');
    
    return Positioned(
      right: isTow ? -10 : 0,
      left: isTow ? null : 0,
      top: isTow ? 40 : 30,
      bottom: 0,
      child: Center(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                width: isTow ? 110 : (title.contains('Station') ? 60 : 120),
                height: isTow ? null : (title.contains('Station') ? 90 : 80),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              )
            : const SizedBox(),
      ),
    );
  }
}

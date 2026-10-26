import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/driver_provider.dart';
import '../../general_widget/marquee_notice_widget.dart';
import '../../utils/app_theme.dart';
import 'widgets/driver_card.dart';
import 'widgets/empty_driver_widget.dart';
import 'widgets/filter_section_widget.dart';
import 'widgets/hero_header_widget.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/home_chat_fab.dart';
import 'widgets/home_footer_widget.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/renew_license_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HomeAppBar(),
      floatingActionButton: const HomeChatFab(),
      body: Consumer<DriverProvider>(
        builder: (context, provider, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWeb = constraints.maxWidth > 768;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Red Marquee Notice Bar (Centered container on Web)
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: MarqueeNoticeWidget(text: provider.noticeText),
                      ),
                    ),

                    // 2. Main Content Container
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWeb ? 32.0 : 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),

                              // 3. Hero Header & Renew License Button
                              if (isWeb)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Expanded(child: HeroHeaderWidget()),
                                    const SizedBox(width: 24),
                                    const SizedBox(
                                      width: 200,
                                      child: RenewLicenseButton(),
                                    ),
                                  ],
                                )
                              else ...[
                                const HeroHeaderWidget(),
                                const SizedBox(height: 18),
                                const RenewLicenseButton(),
                              ],

                              const SizedBox(height: 18),

                              // 4. Search Bar (Left-aligned on Web, full width on Mobile)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: isWeb ? 460 : double.infinity,
                                  child: HomeSearchBar(
                                    onChanged: (val) =>
                                        provider.setSearchQuery(val),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // 5. Filter Dropdowns Section (1 Row on Web, 3 Rows on Mobile)
                              const FilterSectionWidget(),

                              const SizedBox(height: 24),

                              // 6. Driver Directory Results List (Grid on Web, ListView on Mobile)
                              _buildDriverList(provider, isWeb, constraints),

                              const SizedBox(height: 36),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 7. Footer Section (3 Columns on Web, Stacked on Mobile)
                    const HomeFooterWidget(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDriverList(
    DriverProvider provider,
    bool isWeb,
    BoxConstraints constraints,
  ) {
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 4.0,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
            ),
          ),
        ),
      );
    }

    if (provider.filteredDrivers.isEmpty) {
      return EmptyDriverWidget(
        onReset: () => provider.resetFilters(),
      );
    }

    if (isWeb) {
      // Web View: 2-column responsive layout matching screenshot
      final totalWidth = constraints.maxWidth.clamp(0.0, 1200.0);
      final padding = 64.0; // 32 each side
      final spacing = 20.0;
      final cardWidth = ((totalWidth - padding - spacing) / 2).clamp(340.0, 560.0);

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: provider.filteredDrivers.map((driver) {
          return SizedBox(
            width: cardWidth,
            child: DriverCard(driver: driver),
          );
        }).toList(),
      );
    }

    // Mobile View: Single-column vertical list
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.filteredDrivers.length,
      itemBuilder: (context, index) {
        return DriverCard(driver: provider.filteredDrivers[index]);
      },
    );
  }
}

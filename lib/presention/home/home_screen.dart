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
    return Consumer<DriverProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return _buildFullScreenLoading(provider);
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const HomeAppBar(),
          floatingActionButton: const HomeChatFab(),
          body: LayoutBuilder(
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

                              if (provider.hasMoreDrivers) ...[
                                const SizedBox(height: 16),
                                Center(
                                  child: OutlinedButton.icon(
                                    onPressed: provider.isLoadingMoreDrivers
                                        ? null
                                        : provider.loadMoreDrivers,
                                    icon: provider.isLoadingMoreDrivers
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Icon(Icons.expand_more),
                                    label: Text(provider.isLoadingMoreDrivers
                                        ? (provider.isBengali ? 'লোড হচ্ছে...' : 'Loading...')
                                        : (provider.isBengali ? 'আরও ৫০ জন দেখুন' : 'Load 50 more')),
                                  ),
                                ),
                              ],

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
          ),
        );
      },
    );
  }

  Widget _buildFullScreenLoading(DriverProvider provider) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/splash_logo.png',
              width: 150,
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'JOT',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF000000),
                      letterSpacing: 1.2,
                    ),
                  ),
                  TextSpan(
                    text: 'POT',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryOrange,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              provider.isBengali
                  ? 'ভাড়ায় চালিত গাড়ির ডিরেক্টরি'
                  : 'Rental Vehicle Directory',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textBody,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                backgroundColor: Color(0xFFFFF2E8),
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverList(
    DriverProvider provider,
    bool isWeb,
    BoxConstraints constraints,
  ) {
    if (provider.hasError && provider.drivers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 12),
              Text(
                provider.isBengali
                    ? 'তথ্য লোড করতে সাময়িক সমস্যা হয়েছে।'
                    : 'Unable to load data at the moment.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => provider.refreshData(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(provider.isBengali ? 'পুনরায় চেষ্টা করুন' : 'Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
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

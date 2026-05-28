import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:litera2/l10n/app_localizations.dart';

import '../core/app_colors.dart';
import '../providers/navigation_provider.dart';
import '../widgets/profile_avatar.dart';
import '../services/user_service.dart';
import 'dashboard_page.dart';
import 'explore_page.dart';
import 'library_page.dart';
import 'profile_page.dart';
import 'admin/admin_dashboard_page.dart';
import 'admin/book_management_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return StreamBuilder(
      stream: UserService.watchProfile(),
      builder: (context, snapshot) {
        final isAdmin = snapshot.data?.isAdmin == true;

        final pages = isAdmin 
            ? const [
                AdminDashboardPage(),
                BookManagementPage(),
                ProfilePage(),
              ]
            : const [
                DashboardPage(),
                ExplorePage(),
                LibraryPage(),
                ProfilePage(),
              ];

        return Consumer<NavigationProvider>(
          builder: (context, nav, _) {
            // Safety check in case nav index is out of bounds after switching from user to admin
            final currentIndex = nav.selectedIndex >= pages.length ? 0 : nav.selectedIndex;

            return Scaffold(
              extendBody: true, // Crucial for floating navbar effect
              body: IndexedStack(
                index: currentIndex,
                children: pages,
              ),
              bottomNavigationBar: isAdmin
                  ? _buildAdminNavBar(context, nav, currentIndex)
                  : _buildFloatingNavBar(context, nav, currentIndex, l10n, isDark, cs),
            );
          },
        );
      },
    );
  }

  Widget _buildAdminNavBar(BuildContext context, NavigationProvider nav, int currentIndex) {
    return Container(
      height: 75,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Deep Slate for Admin Nav
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),  
        ],
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Theme(
          data: ThemeData(brightness: Brightness.dark),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: nav.setIndex,
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: const Color(0xFF38BDF8).withValues(alpha: 0.2),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined, color: Color(0xFF94A3B8)),
                selectedIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF38BDF8)),
                label: 'Command',
              ),
              const NavigationDestination(
                icon: Icon(Icons.library_books_outlined, color: Color(0xFF94A3B8)),
                selectedIcon: Icon(Icons.library_books_rounded, color: Color(0xFF38BDF8)),
                label: 'Library',
              ),
              NavigationDestination(
                icon: const Padding(
                  padding: EdgeInsets.all(2),
                  child: SmallProfileAvatar(radius: 11),
                ),
                selectedIcon: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                  ),
                  child: const SmallProfileAvatar(radius: 11),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNavBar(
    BuildContext context, 
    NavigationProvider nav, 
    int currentIndex,
    AppLocalizations l10n, 
    bool isDark, 
    ColorScheme cs
  ) {
    return Container(
      height: 75,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navBackgroundDark : AppColors.navBackground,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: nav.setIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: Colors.white.withValues(alpha: 0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l10n.dashboardTitle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: const Icon(Icons.explore_rounded),
              label: l10n.exploreTitle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.bookmark_outline_rounded),
              selectedIcon: const Icon(Icons.bookmark_rounded),
              label: l10n.myCollection,
            ),
            NavigationDestination(
              icon: const Padding(
                padding: EdgeInsets.all(2),
                child: SmallProfileAvatar(radius: 11),
              ),
              selectedIcon: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const SmallProfileAvatar(radius: 11),
              ),
              label: l10n.profileTitle,
            ),
          ],
        ),
      ),
    );
  }
}

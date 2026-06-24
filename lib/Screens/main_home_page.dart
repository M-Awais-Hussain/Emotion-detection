import 'package:emotioneye/Screens/home_page_carousel/dashboard_page.dart';
import 'package:emotioneye/Screens/mood_improvement_dashboard.dart';
import 'package:emotioneye/Screens/main_camera.dart';
import 'package:flutter/material.dart';
import '../config/app_info.dart';
import '../theme/app_theme.dart';
import '/Screens/about_app.dart';
import '/Screens/guide.dart';
import 'activities_screen.dart';
import 'download_app_screen.dart';
import 'exercises_screen.dart';
import 'mood_chat_screen.dart';
import 'study_performance_screen.dart';

class MainHomePage extends StatefulWidget {
  final int pageNumber;

  const MainHomePage({super.key, required this.pageNumber});

  @override
  MainHomePageState createState() => MainHomePageState();
}

class MainHomePageState extends State<MainHomePage> with SingleTickerProviderStateMixin {
  final GlobalKey<MoodChatScreenState> chatKey = GlobalKey<MoodChatScreenState>();
  late PageController pageController;
  late AnimationController _animationController;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.pageNumber);
    currentPage = widget.pageNumber;

    // Setup animation for hamburger/drawer icon
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Method to handle navigation and state updates
  void _navigateToPage(int index) {
    if (pageController.hasClients) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Drawer item widget for consistency
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingS, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryMedium.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: isActive ? Border.all(
                color: AppTheme.primaryMedium.withValues(alpha: 0.3),
                width: 1,
              ) : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppTheme.primaryMedium).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? (isActive ? AppTheme.primaryMedium : AppTheme.textSecondary),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      color: isActive ? AppTheme.primaryMedium : AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (isActive)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppTheme.primaryMedium,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color.fromARGB(255, 0, 31, 84);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        elevation: 10,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.visibility,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Emotion Eye',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Detect and Analyze Emotions',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                children: <Widget>[
                  _buildDrawerItem(
                    icon: Icons.home,
                    title: "Home",
                    isActive: currentPage == 0,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MainHomePage(pageNumber: 0)),
                            (route) => false,
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.smart_toy,
                    title: "Chat With AI",
                    iconColor: Colors.deepPurple,  // Purple for AI/tech feel
                    isActive: currentPage == 1,
                    onTap: () {
                      Navigator.of(context).pop();
                      _navigateToPage(1);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.camera_alt_rounded,
                    title: "Detect Mood",
                    iconColor: Colors.teal,  // Already perfect
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MainCamera()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.fitness_center,
                    title: "Exercises",
                    iconColor: Colors.orange,  // Orange for energy/activity
                    isActive: currentPage == 2,
                    onTap: () {
                      Navigator.of(context).pop();
                      _navigateToPage(2);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.local_activity,
                    title: "Activities",
                    iconColor: Colors.green,  // Green for wellness/growth
                    isActive: currentPage == 3,
                    onTap: () {
                      Navigator.of(context).pop();
                      _navigateToPage(3);
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons.school,
                    title: "Study Performance",
                    iconColor: Colors.indigo,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudyPerformanceScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(),
                  _buildDrawerItem(
                    icon: Icons.dashboard,
                    title: "Mood Improvement Dashboard",
                    iconColor: Colors.purple,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MoodImprovementDashboard(initialMood: "happy")),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.info_outline,
                    title: "About App",
                    iconColor: Colors.deepPurple,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutApp()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.help_outline,
                    title: "Guide",
                    iconColor: Colors.green,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Guide()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.download_rounded,
                    title: "Download App",
                    iconColor: Colors.teal,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DownloadAppScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Footer for drawer
            Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'v${AppInfo.appVersion}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
        title: const Text(
          'Emotion Eye',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          // Add the streak widget - always visible

          // Keep the refresh button for chat page
          if (currentPage == 1)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text('Clear Chat History'),
                    content: const Text('Are you sure you want to clear all messages?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => chatKey.currentState?.clearChatHistory(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],

      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // PageView for main content
          Positioned(
            child: PageView(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              children: [
                const DashboardPage(),
                MoodChatScreen(key: chatKey),
                const ExercisePage(),
                ActivitiesPage(),
              ],
            ),
          ),

          // The bottom bar
          Positioned(
            left: AppTheme.spacingM,
            right: AppTheme.spacingM,
            bottom: AppTheme.spacingS,
            child: Container(
                height: 70,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: AppTheme.elevatedShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: _buildNavItem(Icons.home_rounded, "Home", 0)),
                    Expanded(child: _buildNavItem(Icons.smart_toy_rounded, "AI Chat", 1)),
                    const SizedBox(width: 72), // Space for the floating action button,
                    Expanded(child: _buildNavItem(Icons.fitness_center_rounded, "Exercise", 2)),
                    Expanded(child: _buildNavItem(Icons.local_activity_rounded, "Activities", 3)),
                  ],
                )

            ),
          ),

          // The floating button
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            bottom: currentPage == 1 ? 6 : 30, // Slide down when on 2nd page
            left: MediaQuery.of(context).size.width / 2 - 34, // Center FAB
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.elevatedShadow,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainCamera(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(34),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for navigation items
  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isActive = currentPage == index;

    return InkWell(
      onTap: () => _navigateToPage(index),
      borderRadius: BorderRadius.circular(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive
                ? Colors.white
                : Color.fromRGBO(255, 255, 255, 0.6),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              color: isActive
                  ? Colors.white
                  : Color.fromRGBO(255, 255, 255, 0.6),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
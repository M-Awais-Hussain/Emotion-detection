// import 'package:flutter/material.dart';
//
// import '../screens/about_app.dart';
// import '../screens/about_us.dart';
// import '../screens/contact_us.dart';
// import '../screens/guide.dart';
// import '../screens/main_home_page.dart';
//
// class AppBottomNavBar extends StatelessWidget {
//   final int selectedIndex;
//   final int? selectedSettingIndex;
//
//   const AppBottomNavBar({
//     super.key,
//     this.selectedSettingIndex,
//     required this.selectedIndex,
//   });
//
//   void _onItemTapped(BuildContext context, int index) {
//     if (index == 0) {
//       if (selectedIndex == 0) {
//         return;
//       }
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const HomePage()),
//       );
//     } else if (index == 1) {
//       _showSettingsDrawer(context);
//     }
//   }
//
//   void _showSettingsDrawer(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(43),
//         ),
//       ),
//       builder: (BuildContext context) {
//         return Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 Colors.white,       // White color
//                 Color(0x97C3ECFF),  // Light Blue color
//               ],
//             ),
//             borderRadius: BorderRadius.vertical(
//               top: Radius.circular(43),
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.only(top: 10, bottom: 10),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildListTile(
//                   context,
//                   icon: Icons.contact_mail,
//                   title: 'Contact Us',
//                   navigateTo: const ContactUs(),
//                   settingIndex: 1,
//                 ),
//                 _buildListTile(
//                   context,
//                   icon: Icons.group,
//                   title: 'About Us',
//                   navigateTo: const AboutUs(),
//                   settingIndex: 2,
//                 ),
//                 _buildListTile(
//                   context,
//                   icon: Icons.info,
//                   title: 'About App',
//                   navigateTo: const AboutApp(),
//                   settingIndex: 3,
//                 ),
//                 _buildListTile(
//                   context,
//                   icon: Icons.help,
//                   title: 'Guide',
//                   navigateTo: const Guide(),
//                   settingIndex: 4,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   ListTile _buildListTile(BuildContext context, {
//     required IconData icon,
//     required String title,
//     required Widget navigateTo,
//     required int settingIndex
//   }) {
//     return ListTile(
//       leading: Icon(icon),
//       title: Text(title),
//       onTap: () {
//         Navigator.pop(context);
//         if (selectedSettingIndex != settingIndex) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => navigateTo),
//           );
//         }
//       },
//       selected: false,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.blue,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(50.0)),
//       ),
//       child: ClipRRect(
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(50.0)),
//         child: BottomNavigationBar(
//           onTap: (index) => _onItemTapped(context, index),
//           currentIndex: selectedIndex,
//           backgroundColor: Colors.blue,
//           selectedItemColor: Colors.blue[50],
//           unselectedItemColor: Colors.white,
//           showSelectedLabels: false,
//           showUnselectedLabels: false,
//           items: const <BottomNavigationBarItem>[
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home, size: 33),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.settings, size: 33),
//               label: 'Settings',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
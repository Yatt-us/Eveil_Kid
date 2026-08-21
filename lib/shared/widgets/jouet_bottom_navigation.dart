// // import 'package:flutter/material.dart';
// // import 'package:eveilkid/core/constants/app_colors.dart';
// // import 'package:go_router/go_router.dart';

// // class JouetBottomNavigation extends StatelessWidget {
// //   final int currentIndex;
// //   final ValueChanged<int> onTap;

// //   const JouetBottomNavigation({
// //     super.key,
// //     required this.currentIndex,
// //     required this.onTap,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: 65,
// //       decoration: BoxDecoration(
// //         color: AppColors.surface,
// //         border: Border(
// //           top: BorderSide(
// //             color: AppColors.border,
// //             width: 0.8,
// //           ),
// //         ),
// //       ),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceAround,
// //         children: [
// //           _BottomItem(
// //             icon: Icons.home_outlined,
// //             activeIcon: Icons.home,
// //             label: 'Accueil',
// //             selected: currentIndex == 0,
// //             onTap: () => context.go('/home'),
// //           ),

// //           _BottomItem(
// //             icon: Icons.shopping_bag_outlined,
// //             activeIcon: Icons.shopping_bag,
// //             label: 'Boutique',
// //             selected: currentIndex == 1,
// //             onTap: () => context.go('/jouets-screen'),
// //           ),

// //           _BottomItem(
// //             icon: Icons.lightbulb_outline,
// //             activeIcon: Icons.lightbulb,
// //             label: 'Tutoriels',
// //             selected: currentIndex == 2,
// //             onTap: () => context.go('/tutoriels'),
// //           ),

// //           _BottomItem(
// //             icon: Icons.person_outline,
// //             activeIcon: Icons.person,
// //             label: 'Profil',
// //             selected: currentIndex == 3,
// //             onTap: () => context.go('/profil'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class _BottomItem extends StatelessWidget {
// //   final IconData icon;
// //   final IconData activeIcon;
// //   final String label;
// //   final bool selected;
// //   final VoidCallback onTap;

// //   const _BottomItem({
// //     required this.icon,
// //     required this.activeIcon,
// //     required this.label,
// //     required this.selected,
// //     required this.onTap,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     final Color color = selected
// //         ? AppColors.primary
// //         : AppColors.textSecondary;

// //     return Expanded(
// //       child: InkWell(
// //         onTap: onTap,
// //         child: SizedBox(
// //           height: 58,
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(
// //                 selected ? activeIcon : icon,
// //                 size: 24,
// //                 color: color,
// //               ),

// //               const SizedBox(height: 3),

// //               Text(
// //                 label,
// //                 style: TextStyle(
// //                   fontSize: 9,
// //                   color: color,
// //                   fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';

// import 'package:eveilkid/core/constants/app_colors.dart';
// import 'package:eveilkid/core/router/app_routes.dart';

// class JouetBottomNavigation extends ConsumerWidget {
//   final int currentIndex;
//   final ValueChanged<int>? onTap;

//   const JouetBottomNavigation({
//     super.key,
//     required this.currentIndex,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Container(
//       height: 65,
//       decoration: const BoxDecoration(
//         color: AppColors.surface,
//         border: Border(
//           top: BorderSide(
//             color: AppColors.border,
//             width: 0.8,
//           ),
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _BottomItem(
//             icon: Icons.home_outlined,
//             activeIcon: Icons.home,
//             label: 'Accueil',
//             selected: currentIndex == 0,
//             onTap: () {
//               onTap?.call(0);
//               if (currentIndex != 0) {
//                 context.go(AppRoutes.home);
//               }
//             },
//           ),
//           _BottomItem(
//             icon: Icons.shopping_bag_outlined,
//             activeIcon: Icons.shopping_bag,
//             label: 'Boutique',
//             selected: currentIndex == 1,
//             onTap: () {
//               onTap?.call(1);
//               if (currentIndex != 1) {
//                 context.go(AppRoutes.jouetscreen);
//               }
//             },
//           ),
//           _BottomItem(
//             icon: Icons.lightbulb_outline,
//             activeIcon: Icons.lightbulb,
//             label: 'Tutoriels',
//             selected: currentIndex == 2,
//             onTap: () {
//               onTap?.call(2);
//               if (currentIndex != 2) {
//                 context.go(AppRoutes.tutoriels);
//               }
//             },
//           ),
//           _BottomItem(
//             icon: Icons.person_outline,
//             activeIcon: Icons.person,
//             label: 'Activités',
//             selected: currentIndex == 3,
//             onTap: () {
//               onTap?.call(3);
//               if (currentIndex != 3) {
//                 context.go(AppRoutes.activites);
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _BottomItem extends StatelessWidget {
//   final IconData icon;
//   final IconData activeIcon;
//   final String label;
//   final bool selected;
//   final VoidCallback onTap;

//   const _BottomItem({
//     required this.icon,
//     required this.activeIcon,
//     required this.label,
//     required this.selected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final Color color = selected
//         ? AppColors.primary
//         : AppColors.textSecondary;

//     return Expanded(
//       child: InkWell(
//         onTap: onTap,
//         child: SizedBox(
//           height: 58,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 selected ? activeIcon : icon,
//                 size: 24,
//                 color: color,
//               ),
//               const SizedBox(height: 3),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 10,
//                   color: color,
//                   fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
//
// class MLectureDescriptionOverlay {
//   OverlayEntry? _overlayEntry;
//
//   void show(BuildContext context) {
//     if (_overlayEntry != null) return;
//
//     final overlay = Overlay.of(context);
//     _overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         top: MediaQuery.of(context).padding.top + kToolbarHeight,
//         left: 0,
//         right: 0,
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             color: Colors.amber[100],
//             child: const Text(
//               '이 화면에서는 문제를 선생님과 함께 풀 수 있어요!',
//               style: TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ),
//       ),
//     );
//
//     overlay.insert(_overlayEntry!);
//
//     Future.delayed(const Duration(seconds: 3), () {
//       hide();
//     });
//   }
//
//   void hide() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//   }
// }

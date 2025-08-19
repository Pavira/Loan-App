// import 'package:flutter/material.dart';

// class HomeCardWidget extends StatelessWidget {
//   final String title;
//   final String content;
//   final List<Color> color;
//   final double height;
//   final double width;
//   final IconData? icon;

//   const HomeCardWidget({
//     Key? key,
//     required this.title,
//     required this.content,
//     required this.color,
//     this.height = 80,
//     this.width = double.infinity,
//     this.icon,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width,
//       height: height,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: color,
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: color.last.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// 🔹 Title
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 12,
//               color: Colors.white70,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           if (icon != null) ...[
//             Icon(icon, color: Colors.white, size: 12),
//             // const SizedBox(width: 8),
//           ],
//           // const Spacer(),

//           /// 🔸 Centered Main Content
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // if (icon != null) ...[
//               //   Icon(icon, color: Colors.white, size: 28),
//               //   const SizedBox(width: 8),
//               // ],
//               Text(
//                 content,
//                 style: const TextStyle(
//                   fontSize: 28,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class HomeCardWidget extends StatelessWidget {
  final String title;
  final String content;
  final List<Color> color;
  final IconData? icon;

  const HomeCardWidget({
    Key? key,
    required this.title,
    required this.content,
    required this.color,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: color,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.last.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title + Optional Icon
          Row(
            children: [
              // if (icon != null) const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (icon != null) Icon(icon, color: Colors.white70, size: 16),
            ],
          ),

          // const Spacer(),
          const SizedBox(height: 6),

          /// Centered Number
          Center(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? subtitleSize; // New parameter for top left text
  final String? belowSubtitle; // New parameter for below subtitle
  final String? topRightText; // New parameter for top right text
  final IconData? topRightIcon;
  final VoidCallback? onIconTap;
  final String? bottomRightText; // New parameter for bottom right text
  final VoidCallback? onTap; // Optional button action
  final String? buttonText; // Optional button text
  final Color? color; // Optional color parameter
  final bool shouldRemoveSizedBox;

  const CustomCard({
    Key? key,
    required this.title,
    required this.subtitle,
    this.subtitleSize,
    this.belowSubtitle,
    this.topRightText,
    this.topRightIcon,
    this.onIconTap,
    this.bottomRightText,
    this.onTap,
    this.buttonText,
    this.color,
    this.shouldRemoveSizedBox = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Section: Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.raleway(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  if (!shouldRemoveSizedBox)
                    const SizedBox(height: 20), // Conditionally remove
                  Text(
                    subtitle,
                    style: GoogleFonts.lato(
                      fontSize:
                          subtitleSize != null
                              ? double.parse(subtitleSize!)
                              : 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    belowSubtitle ?? '',
                    style: GoogleFonts.lato(
                      fontSize:
                          subtitleSize != null
                              ? double.parse(subtitleSize!)
                              : 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            // Right Section: Top and Bottom Text
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Right Text
                if (topRightText != null)
                  Text(
                    topRightText!,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                if (topRightIcon != null)
                  Material(
                    color:
                        Colors
                            .transparent, // Make sure background stays transparent
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        20,
                      ), // Optional: rounded tap effect
                      onTap: onIconTap, // Your function here
                      child: Padding(
                        padding: const EdgeInsets.all(
                          4.0,
                        ), // Add some space around the icon
                        child: Icon(topRightIcon, color: Colors.red, size: 20),
                      ),
                    ),
                  ),

                const SizedBox(
                  height: 24,
                ), // Spacing between top and bottom text
                // Bottom Right Text
                if (bottomRightText != null)
                  Text(
                    bottomRightText!,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kaarya/app/theme/app_colors.dart';

class AuthPageShell extends StatelessWidget {
  const AuthPageShell({super.key, required this.child, this.maxWidth = 460});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFF8FBFD)),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final horizontalPadding = width >= 640 ? 28.0 : 18.0;
              final verticalPadding = width >= 640 ? 24.0 : 16.0;

              return Stack(
                children: [
                  Positioned(
                    top: -110,
                    right: -70,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withAlpha(18),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 120,
                    left: -80,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bgSecondary,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Container(
                          padding: EdgeInsets.fromLTRB(
                            width >= 640 ? 28 : 18,
                            18,
                            width >= 640 ? 28 : 18,
                            24,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(248),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.borderStroke2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14091E42),
                                blurRadius: 24,
                                offset: Offset(0, 14),
                              ),
                            ],
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

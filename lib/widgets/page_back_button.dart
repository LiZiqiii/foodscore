import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';
import '../config/page_layout.dart';

class PageBackButton extends StatelessWidget {
  const PageBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 2.h, 8.w, 2.h),
          child: Text(
            PageLayout.backLabel,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: PageLayout.backColor,
              letterSpacing: 0.2,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

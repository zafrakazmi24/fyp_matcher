import 'package:flutter/material.dart';
import '../core/theme.dart';

class GeoArt extends StatelessWidget {
  const GeoArt({super.key});

  Widget _tile(Color c, {BorderRadius? r, bool circle = false}) {
    return Container(
      decoration: BoxDecoration(
        color: c,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : r,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const big = Radius.circular(200);
    final tiles = <Widget>[
      _tile(AppColors.primary,
          r: const BorderRadius.only(topRight: big)),
      _tile(AppColors.accent, circle: true),
      _tile(AppColors.navy,
          r: const BorderRadius.only(topLeft: big, topRight: big)),
      _tile(AppColors.navy, circle: true),
      _tile(AppColors.grey,
          r: const BorderRadius.only(bottomRight: big)),
      _tile(AppColors.primary, circle: true),
      _tile(AppColors.grey, circle: true),
      _tile(AppColors.primary,
          r: const BorderRadius.only(bottomLeft: big)),
      _tile(AppColors.accent,
          r: const BorderRadius.only(topLeft: big)),
    ];
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(120),
        bottomRight: Radius.circular(120),
      ),
      child: GridView.count(
        crossAxisCount: 3,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: tiles,
      ),
    );
  }
}
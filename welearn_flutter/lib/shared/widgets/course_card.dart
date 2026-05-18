import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../core/models/course_model.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final double? progressPercent;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.course,
    this.progressPercent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: course.thumbnail != null
                  ? CachedNetworkImage(
                      imageUrl: course.thumbnail!,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ColoredBox(
                        color: Color(0xFFEFF6FF),
                        child: SizedBox(height: 140),
                      ),
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (course.categoryName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        course.categoryName!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (course.instructorName != null)
                    Text(
                      course.instructorName!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (progressPercent != null)
                    LinearPercentIndicator(
                      percent: (progressPercent! / 100).clamp(0, 1),
                      lineHeight: 6,
                      backgroundColor: const Color(0xFFE2E8F0),
                      progressColor: const Color(0xFF2563EB),
                      barRadius: const Radius.circular(4),
                      padding: EdgeInsets.zero,
                      trailing: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '${progressPercent!.toInt()}%',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF2563EB)),
                        ),
                      ),
                    ),
                  if (progressPercent == null) ...
                    [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFF59E0B), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            course.rating.toStringAsFixed(1),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Text(
                            course.price == 0
                                ? 'Free'
                                : '₹${course.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        height: 140,
        color: const Color(0xFFEFF6FF),
        child: const Center(
          child: Icon(Icons.school_outlined,
              size: 48, color: Color(0xFF93C5FD)),
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class _Slide {
  const _Slide(this.title, this.body);
  final String title;
  final String body;
}

const _slides = [
  _Slide(
    'Đặt lịch khám trong 1 phút',
    'Chọn chuyên khoa, bác sĩ và khung giờ phù hợp — không cần xếp hàng từ sáng sớm.',
  ),
  _Slide(
    'Biết chính xác khi nào đến lượt',
    'Check-in bằng QR và theo dõi số thứ tự trực tiếp ngay trên điện thoại.',
  ),
  _Slide(
    'Kết quả và đơn thuốc trong tay',
    'Nhận kết quả khám, xét nghiệm và nhắc uống thuốc đúng giờ cho cả gia đình.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _index = 0;

  bool get _isLast => _index == _slides.length - 1;

  void _next() {
    if (_isLast) {
      context.push(AppRoutes.login);
      return;
    }
    setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.onboardingGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
            child: Column(
              children: [
                Column(
                  children: [
                    Container(
                      width: 132,
                      height: 132,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset('assets/images/logo.jpg',
                          fit: BoxFit.cover),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('NACare', style: AppTypography.brand),
                    const SizedBox(height: 4),
                    Text(
                      'Bệnh viện Hữu Nghị Đa Khoa Nghệ An',
                      style: AppTypography.body.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 15),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: AppTypography.title
                              .copyWith(color: Colors.white, height: 1.35),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          slide.body,
                          textAlign: TextAlign.center,
                          style: AppTypography.body.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                              height: 1.55),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(_slides.length, (i) {
                            final active = i == _index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: active ? 22 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: active
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryDark,
                        ),
                        child: Text(_isLast ? 'Bắt đầu' : 'Tiếp tục'),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.login),
                      style: TextButton.styleFrom(
                          foregroundColor:
                              Colors.white.withValues(alpha: 0.85)),
                      child: const Text('Bỏ qua'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

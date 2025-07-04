import 'package:flutter/material.dart';
import 'package:personalized_travel_recommendations/core/theme/app_colors.dart';
import 'package:personalized_travel_recommendations/presentation/widgets/mypage_header.dart';
import 'package:personalized_travel_recommendations/presentation/widgets/settings_list_item.dart';
import 'package:personalized_travel_recommendations/presentation/widgets/custom_divider.dart';
import 'package:personalized_travel_recommendations/presentation/widgets/reusable_prompt_card.dart';
import 'package:personalized_travel_recommendations/presentation/pages/mypage/my_page_notice_screen.dart';
import 'package:personalized_travel_recommendations/presentation/pages/mypage/my_page_support_center_screen.dart';
import 'package:personalized_travel_recommendations/presentation/pages/main_screen.dart';

class GuestMyPageScreen extends StatelessWidget {
  const GuestMyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MyPageHeader(),
            const SizedBox(height: 12), // 로그인 카드 위 여백

            // 🔹 로그인 유도 카드
            ReusablePromptCard(
              title: '로그인을 해주세요.',
              subtitle: '계정이 없다면? 가입하기',
              buttonText: '로그인하기',
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainScreen(initialIndex: 2, isLoggedIn: true),
                  ),
                );
              },
            ),

            const SizedBox(height: 0), // 로그인 ↔ 공지사항

            // 🔹 설정 항목
            SettingsListItem(
              leadingIcon: Image.asset(
                'assets/icons/Outline/png/clipboard-check.png',
                width: 24,
                height: 24,
                color: AppColors.neutral60,
              ),
              label: '공지 사항',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyPageNoticeScreen(),
                  ),
                );
              },
            ),
            const CustomDivider(),


            SettingsListItem(
              leadingIcon: Image.asset(
                'assets/icons/Outline/png/alert-circle.png',
                width: 24,
                height: 24,
                color: AppColors.neutral60,
              ),
              label: '고객 센터',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupportCenterScreen(),
                  ),
                );
              },
            ),
            const CustomDivider(),
          ],
        ),
      ),
    );
  }
}

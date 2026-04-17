import 'package:flutter/material.dart';
import 'dart:math';

// 팝업 데이터 모델
class PopupData {
  final String title;
  final String subtitle;
  final String content;
  final Color titleColor;

  const PopupData({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.titleColor,
  });
}

// 5가지 랜덤 팝업 데이터
const List<PopupData> kCandidatePopups = [
  PopupData(
    title: '다시 뛰는 김태성,\n오직 신안만 보겠습니다',
    subtitle: '변함없는 지지와 성원,\n확실한 발전으로 보답하겠습니다.',
    content:
        '아쉽게 발걸음을 멈춰야 했던 지난 시간, 저는 군민 여러분의 삶 속으로 더 깊이 들어갔습니다. 이제 아쉬움은 뒤로하고 신안의 내일만 보겠습니다.',
    titleColor: Color(0xFF1E3A5F),
  ),
  PopupData(
    title: '공정한 신안,\n당당한 김태성',
    subtitle: '누구에게나 평등한 혜택이\n돌아가는 신안을 만들겠습니다.',
    content:
        '특정 소수가 아닌 모든 군민이 웃는 군정을 펼치겠습니다. 공정과 상식을 원칙으로, 신안의 모든 이익이 온전히 군민 여러분께 돌아가게 하겠습니다.',
    titleColor: Color(0xFF1F2937),
  ),
  PopupData(
    title: '신안군민의\n지갑을 두껍게!',
    subtitle: '김태성이 약속하는 핵심 정책\n6가지를 확인해 보세요.',
    content:
        '일자리, 관광, 복지... 신안을 바꿀 구체적인 청사진이 준비되어 있습니다. 지금 바로 핵심 정책을 확인하시고, 소중한 의견을 들려주십시오.',
    titleColor: Color(0xFF312E81),
  ),
  PopupData(
    title: '변함없는 진심,\n더 단단해진 김태성',
    subtitle: '군민을 하늘처럼 섬기는\n든든한 군수가 되겠습니다.',
    content:
        '어떤 시련에도 군민 여러분을 향한 제 마음은 흔들리지 않았습니다. 더 낮은 자세로 다가가, 군민의 목소리에 귀 기울이는 진실된 일꾼이 되겠습니다.',
    titleColor: Color(0xFF1E40AF),
  ),
  PopupData(
    title: '군민을 향한 발걸음,\n멈추지 않겠습니다',
    subtitle: '신안의 도약과 번영을 위해\n모든 열정을 바치겠습니다.',
    content:
        '신안의 더 큰 미래를 향한 여정은 이제 시작입니다. 군민 여러분과 맞잡은 손 놓지 않고, 더 살기 좋은 신안을 향해 힘차게 전진하겠습니다.',
    titleColor: Color(0xFF1E3A5F),
  ),
];

/// 앱 시작 시 또는 원하는 시점에 호출하면 랜덤 팝업을 표시한다.
void showRandomCandidatePopup(BuildContext context) {
  final data = kCandidatePopups[Random().nextInt(kCandidatePopups.length)];
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => CandidatePopupDialog(data: data),
  );
}

// ─────────────────────────────────────────────────────────────
// 팝업 다이얼로그 위젯
// ─────────────────────────────────────────────────────────────
class CandidatePopupDialog extends StatelessWidget {
  final PopupData data;

  const CandidatePopupDialog({super.key, required this.data});

  static const _navy = Color(0xFF1E3A5F);
  static const _gold = Color(0xFFC68C46);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  // 상단 네이비 헤더 바
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: _navy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.anchor, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text(
                '신안군수 예비후보 김태성',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // 팝업 본문: 곡선 배경 + 후보자 사진 + 텍스트
  Widget _buildBody() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // 네이비 곡선 배경
        ClipPath(
          clipper: _CurveClipper(),
          child: Container(height: 100, color: _navy),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 40, bottom: 20, left: 24, right: 24),
          child: Column(
            children: [
              // 후보자 투명 배경 사진 (원형 클리핑)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const ColoredBox(color: Colors.white),
                      Image.asset(
                        'assets/images/candidate_face.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 메인 제목
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: data.titleColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),

              // 소제목 (골드)
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _gold,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),

              // 본문 설명 박스
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  data.content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 네이비 배경 하단 곡선 클리퍼
class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 40)
      ..quadraticBezierTo(
        size.width / 2, size.height + 20, size.width, size.height - 40,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

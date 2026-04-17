import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/contact_data.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

// ──────────────────────────────────────────────────────────
// 앱스토어 정책 준수 (CLAUDE.md):
//   위치 데이터를 서버에 전송하지 않음
//   캠프 고정 좌표만 표시 — 사용자 위치 수집 없음
//
// [API 키 설정 방법]
//   Android: android/app/src/main/AndroidManifest.xml
//     <meta-data android:name="com.google.android.geo.API_KEY"
//                android:value="YOUR_API_KEY"/>
//   iOS: ios/Runner/AppDelegate.swift
//     GMSServices.provideAPIKey("YOUR_API_KEY")
// ──────────────────────────────────────────────────────────
class CampMapWidget extends StatefulWidget {
  const CampMapWidget({super.key});

  @override
  State<CampMapWidget> createState() => _CampMapWidgetState();
}

class _CampMapWidgetState extends State<CampMapWidget> {
  static const _campPosition = LatLng(
    CampContact.campLatitude,
    CampContact.campLongitude,
  );

  GoogleMapController? _mapController;
  final bool _mapError = false;

  Set<Marker> get _markers => {
        Marker(
          markerId: const MarkerId('camp'),
          position: _campPosition,
          infoWindow: const InfoWindow(
            title: '김태성 선거캠프',
            snippet: CampContact.campAddress,
          ),
        ),
      };

  Future<void> _openInMaps() async {
    final uri = Uri.parse(
      'https://maps.google.com/?q=${CampContact.campLatitude},${CampContact.campLongitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_mapError) return _MapErrorFallback(onTap: _openInMaps);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 160,
        child: Stack(
          children: [
            // ── Google Map ────────────────────────────
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _campPosition,
                zoom: 14,
              ),
              markers: _markers,
              myLocationEnabled: false,       // 사용자 위치 수집 금지
              myLocationButtonEnabled: false, // 위치 버튼 숨김
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
                // 마커 InfoWindow 자동 표시
                Future.delayed(const Duration(milliseconds: 500), () {
                  _mapController?.showMarkerInfoWindow(
                    const MarkerId('camp'),
                  );
                });
              },
              onCameraMove: (_) {},
            ),

            // ── 지도 앱으로 열기 버튼 ─────────────────
            Positioned(
              right: 10,
              bottom: 10,
              child: GestureDetector(
                onTap: _openInMaps,
                child: Container(
                  // WCAG 2.1 AA: 최소 터치 48×48dp 보장
                  constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.open_in_new,
                          color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        '지도 앱으로 열기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppTypography.sizeXs,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

// ── 지도 로드 실패 시 폴백 UI ──────────────────────────────
class _MapErrorFallback extends StatelessWidget {
  final VoidCallback onTap;

  const _MapErrorFallback({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFC8DBC8),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 32, color: Color(0xFF5A7A5A)),
            SizedBox(height: 6),
            Text(
              '지도 앱으로 캠프 위치 보기',
              style: TextStyle(
                color: Color(0xFF5A7A5A),
                fontSize: AppTypography.sizeSm,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:dio/dio.dart';
import '../models/news_model.dart';

// ──────────────────────────────────────────────────────────
// 뉴스 저장소 — Dio 기반 RSS/API 호출
//
// [현재 상태] 목업 데이터 반환 (API URL 미확정)
// [연동 방법]
//   1. 실제 RSS URL을 _rssUrls에 추가
//   2. fetchNews()에서 _fetchRss() 호출로 교체
//   3. XML 파싱: xml 패키지 또는 서버 측 JSON API 권장
// ──────────────────────────────────────────────────────────
class NewsRepository {
  static final NewsRepository _instance = NewsRepository._internal();
  factory NewsRepository() => _instance;
  NewsRepository._internal();

  late final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'User-Agent': 'KimTaeSung-SinanjusoApp/1.0',
        'Accept': 'application/rss+xml, application/xml, text/xml',
      },
    ),
  );

  // TODO: 실제 RSS URL 목록으로 교체
  // static const List<String> _rssUrls = [
  //   'https://www.mdilbo.com/rss/allArticle.xml',   // 무등일보
  //   'https://campaign.kimtaesung.com/rss/news',    // 캠프 공식 보도자료
  // ];

  /// 뉴스 목록 가져오기
  /// [category] null 이면 전체 반환
  Future<List<NewsItem>> fetchNews({NewsCategory? category}) async {
    // TODO: API 준비 완료 시 _fetchRss()로 교체
    await Future.delayed(const Duration(milliseconds: 800)); // 네트워크 지연 시뮬레이션

    final all = MockNewsData.items;
    if (category == null || category == NewsCategory.all) {
      return all;
    }
    return all.where((item) => item.category == category).toList();
  }

  // ── 실제 RSS 파싱 메서드 (연동 준비 완료) ──────────────
  // Future<List<NewsItem>> _fetchRss(String url) async {
  //   try {
  //     final response = await _dio.get<String>(url);
  //     if (response.statusCode != 200 || response.data == null) return [];
  //     // xml 패키지로 파싱:
  //     // final doc = XmlDocument.parse(response.data!);
  //     // final items = doc.findAllElements('item');
  //     // return items.map((e) => _parseRssItem(e)).toList();
  //     return [];
  //   } on DioException catch (e) {
  //     // 네트워크 오류: 캐시 데이터 반환
  //     debugPrint('[NewsRepository] DioException: ${e.message}');
  //     return MockNewsData.items;
  //   }
  // }

  /// Dio 인스턴스 외부 접근 (인터셉터 추가 등)
  Dio get dio => _dio;
}

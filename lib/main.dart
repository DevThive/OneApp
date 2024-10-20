import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '요가 영상 앱',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: VideoListScreen(),
    );
  }
}

class VideoListScreen extends StatefulWidget {
  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List<dynamic> videos = [];
  final String apiKey = 'AIzaSyC9iPSWkK6UwNJK5fPkBdgf1k1I1WDE7pc'; // 여기에 API 키를 입력하세요.
  String? nextPageToken; // nextPageToken을 String으로 선언

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos({String? pageToken}) async {
    final url = 'https://www.googleapis.com/youtube/v3/search?part=snippet&q=요가&type=video&key=$apiKey&pageToken=${pageToken ?? ''}';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        videos.addAll(data['items']);
        nextPageToken = data['nextPageToken'] ?? null; // nextPageToken을 문자열로 저장
      });
    } else {
      throw Exception('YouTube API 요청 실패');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      videos.clear();
      nextPageToken = null; // 새로 고침 시 nextPageToken 초기화
    });
    await fetchVideos();
  }

  Future<void> _loadMore() async {
    if (nextPageToken != null && nextPageToken!.isNotEmpty) { // null 체크 및 비어있지 않은지 확인
      await fetchVideos(pageToken: nextPageToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('요가 영상 리스트')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          itemCount: videos.length + 1, // 추가 아이템을 위한 공간
          itemBuilder: (context, index) {
            if (index == videos.length) {
              // 로딩 인디케이터
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final video = videos[index];
            final title = video['snippet']['title'];
            final thumbnailUrl = video['snippet']['thumbnails']['high']['url'];
            final videoId = video['id']['videoId'];

            return Card(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: ListTile(
                contentPadding: EdgeInsets.all(10),
                leading: CachedNetworkImage(
                  imageUrl: thumbnailUrl,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
                title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  // 유튜브 링크를 여는 코드 추가 가능
                },
              ),
            );
          },
          // 스크롤 시 추가 데이터 로드
          controller: ScrollController()..addListener(() {
            if (ScrollController().position.pixels ==
                ScrollController().position.maxScrollExtent) {
              _loadMore();
            }
          }),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library), label: '영상'),
        ],
      ),
    );
  }
}

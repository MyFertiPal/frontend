import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/api_service.dart';
import '../../theme/app_colors.dart';

class ReadingScreen extends StatefulWidget {
  final int articleId;
  final String language;

  const ReadingScreen({
    super.key,
    required this.articleId,
    required this.language,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final ApiService _api = ApiService();

  Map<String, dynamic>? _article;

  bool _loading = true;

  String _language = "en";

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    try {
      final article = await _api.getArticleById(
        articleId: widget.articleId,
        lang: _language,
      );

      setState(() {
        _article = article;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error loading article: $e");

      setState(() {
        _loading = false;
      });
    }
  }
    @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_article == null) {
      return Scaffold(
        backgroundColor: AppColors.cardBackground,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryDark,
        ),
        body: const Center(
          child: Text(
            "Article not found",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final String formattedDate = DateFormat.yMMMMd().format(
      DateTime.parse(_article!["created_at"]),
    );

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.network(
                    _article!["cover_image_url"] ?? "",
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        width: double.infinity,
                        height: 260,
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.image,
                          size: 70,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),

                  Positioned(
                    top: 16,
                    left: 16,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.primaryDark,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [                    Text(
                      _article!["title"] ?? "",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Divider(),

                    const SizedBox(height: 20),

                    Text(
                      _article!["content"] ?? "",
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black87,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.justify,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
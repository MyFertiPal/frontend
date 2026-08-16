import 'package:flutter/material.dart';
import '/theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/analytics_service.dart';
import '../educational/reading_screen.dart';
import '../../generated/l10n/app_localizations.dart';

class EducationHubScreen extends StatefulWidget {
  const EducationHubScreen({super.key});

  @override
  State<EducationHubScreen> createState() => _EducationHubScreenState();
}

class _EducationHubScreenState extends State<EducationHubScreen> {
  final ApiService _api = ApiService();

  List<dynamic> _articles = [];
  Map<String, dynamic>? _featuredArticle;

  bool _loading = true;

  final TextEditingController _searchController =
      TextEditingController();

  // Always has a valid language.
  String _language = 'en';

  // Prevents didChangeDependencies from loading multiple times
  // on the first build.
  bool _languageInitialized = false;

  @override
  void initState() {
    super.initState();

    AnalyticsService.logScreenView(
      screenName: 'EducationHubScreen',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final language =
        Localizations.localeOf(context).languageCode;

    if (!_languageInitialized || language != _language) {
      _languageInitialized = true;
      _language = language;

      _loadArticles();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal:
                MediaQuery.of(context).size.width < 360
                    ? 15
                    : 20,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Center(
                child: Text(
                  AppLocalizations.of(context).explore,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              _buildSearch(),

              const SizedBox(height: 30),

              _buildArticleHeader(),

              const SizedBox(height: 15),

              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_articles.isEmpty)
                _buildEmptyState()
              else
                ..._articles.map(
                  (article) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: 18),
                    child: _buildArticleCard(
                      context,
                      article:
                          Map<String, dynamic>.from(article),
                    ),
                  ),
                ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------

  Widget _buildSearch() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            blurRadius: 15,
            color: Colors.black.withOpacity(.08),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _searchArticle(),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _searchArticle,
          ),
          hintText:
              AppLocalizations.of(context).searchArticles,
          hintStyle:
              const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.grey,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // LOAD ARTICLES
  // ---------------------------------------------------------

  Future<void> _loadArticles() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
    });

    try {
      debugPrint(
        "LOADING ARTICLES - language: $_language",
      );

      final articles = await _api.getArticles(
        lang: _language,
      );

      debugPrint(
        "ARTICLES LOADED: ${articles.length}",
      );

      if (!mounted) return;

      setState(() {
        _articles = articles;

        _featuredArticle =
            articles.isNotEmpty
                ? Map<String, dynamic>.from(
                    articles.first,
                  )
                : null;

        _loading = false;
      });
    } catch (e, stackTrace) {
      debugPrint(
        "LOAD ARTICLES ERROR: $e",
      );

      debugPrint(
        "$stackTrace",
      );

      if (!mounted) return;

      setState(() {
        _articles = [];
        _featuredArticle = null;
        _loading = false;
      });
    }
  }

  // ---------------------------------------------------------
  // SEARCH ARTICLES
  // ---------------------------------------------------------

  Future<void> _searchArticle() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      await _loadArticles();
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    try {
      debugPrint(
        "SEARCHING ARTICLES",
      );

      debugPrint(
        "Query: $query",
      );

      debugPrint(
        "Language: $_language",
      );

      final results = await _api.searchArticles(
        query: query,
        lang: _language,
      );

      debugPrint(
        "SEARCH RESULTS: ${results.length}",
      );

      await AnalyticsService.logArticleSearched(
        query: query,
        language: _language,
      );

      if (!mounted) return;

      setState(() {
        _articles = results;

        _featuredArticle =
            results.isNotEmpty
                ? Map<String, dynamic>.from(
                    results.first,
                  )
                : null;

        _loading = false;
      });
    } catch (e, stackTrace) {
      debugPrint(
        "ARTICLE SEARCH ERROR: $e",
      );

      debugPrint(
        "$stackTrace",
      );

      if (!mounted) return;

      setState(() {
        _articles = [];
        _featuredArticle = null;
        _loading = false;
      });
    }
  }

  // ---------------------------------------------------------
  // ARTICLE HEADER
  // ---------------------------------------------------------

  Widget _buildArticleHeader() {
    return Text(
      AppLocalizations.of(context).articles,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryDark,
      ),
    );
  }

  // ---------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 40,
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.article_outlined,
              size: 50,
              color: Colors.grey,
            ),

            const SizedBox(height: 12),

            Text(
              _searchController.text.trim().isNotEmpty
                  ? 'No articles found'
                  : 'No articles available',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // ARTICLE CARD
  // ---------------------------------------------------------

  Widget _buildArticleCard(
    BuildContext context, {
    required Map<String, dynamic> article,
  }) {
    final width =
        MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        final articleId = article['id'];

        AnalyticsService.logArticleOpened(
          articleId:
              articleId?.toString() ?? 'unknown',
          category:
              article['category']?.toString() ??
                  'general',
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReadingScreen(
              articleId: articleId,
              language: _language,
            ),
          ),
        );
      },
      child: Container(
        height:
            width < 380 ? 130 : 145,
        padding:
            const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset:
                  const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(18),
                child: Image.network(
                  article[
                          'cover_image_url']
                      ?.toString() ??
                      '',
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) =>
                          const Icon(
                    Icons.image,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    (article['language'] ??
                            _language)
                        .toString()
                        .toUpperCase(),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color:
                          Color(0xff16A6A6),
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    article['title']
                            ?.toString() ??
                        '',
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color:
                          AppColors.primaryDark,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    article['summary']
                            ?.toString() ??
                        '',
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
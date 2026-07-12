import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../services/analytics_service.dart';
import '../../theme.dart';
import '../../utils/responsive_utils.dart';
import 'article_reading_screen.dart';

const Color _primaryTeal = Color(0xFF0EA5A4);
const Color _darkGreenText = Color(0xFF064B23);

class EducationalHubScreen extends StatefulWidget {
  const EducationalHubScreen({super.key});

  @override
  State<EducationalHubScreen> createState() => _EducationalHubScreenState();
}

class _EducationalHubScreenState extends State<EducationalHubScreen> {
  late AudioPlayer _audioPlayer;
  String selectedCategory = '';

  List<Map<String, String>> get allArticles {
    final l10n = AppLocalizations.of(context);
    return [
      {
        'category': l10n.fertilityBasics,
        'title': l10n.article1Title,
        'excerpt': l10n.article1Excerpt,
        'image': 'assets/images/article_1.jpeg',
        'audioUrl': '',
        'content': l10n.article1Content,
      },
      {
        'category': l10n.fertilityBasics,
        'title': l10n.article2Title,
        'excerpt': l10n.article2Excerpt,
        'image': 'assets/images/article_2.jpeg',
        'audioUrl': '',
        'content': l10n.article2Content,
      },
      {
        'category': l10n.mythsFacts,
        'title': l10n.article3Title,
        'excerpt': l10n.article3Excerpt,
        'image': 'assets/images/article_3.jpeg',
        'audioUrl': '',
        'content': l10n.article3Content,
      },
    ];
  }

  List<String> get categories {
    final l10n = AppLocalizations.of(context);
    return [
      l10n.fertilityBasics,
      l10n.mythsFacts,
    ];
  }

  @override
  void initState() {
    super.initState();

     AnalyticsService.logScreenView(
    screenName:"Educational Hub",
  );
    _audioPlayer = AudioPlayer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final updatedCategories = categories;
    if (updatedCategories.isNotEmpty &&
        (selectedCategory.isEmpty ||
            !updatedCategories.contains(selectedCategory))) {
      selectedCategory = updatedCategories.first;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _showAudioModal(BuildContext context, Map<String, String> article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AudioPlayerModal(
        audioPlayer: _audioPlayer,
        article: article,
      ),
    ).then((_) {
      // Stop audio when modal is dismissed
      _audioPlayer.stop();
    });
  }

  Widget _buildCategoryBubble(String category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _darkGreenText : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _darkGreenText, width: 1),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : _darkGreenText,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildArticleCard(Map<String, String> article) {
    return Builder(builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
            bottom: ResponsiveUtils.getResponsiveSpacing(context) * 2),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ArticleReadingScreen(
                  imageUrl: article['image'] ?? '',
                  title: article['title'] ?? '',
                  articleText: article['content'] ?? article['excerpt'] ?? '',
                  audioUrl: article['audioUrl'],
                ),
              ),
            );
          },
          child: Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.asset(
                    article['image']!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: ResponsiveUtils.isSmallScreen(context) ? 150 : 180,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height:
                            ResponsiveUtils.isSmallScreen(context) ? 150 : 180,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(
                      ResponsiveUtils.getResponsivePadding(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  ResponsiveUtils.getResponsiveSpacing(context),
                              vertical: ResponsiveUtils.getResponsiveSpacing(
                                    context,
                                  ) *
                                  0.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: _primaryTeal, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              article['category'] ?? '',
                              style: TextStyle(
                                color: _darkGreenText,
                                fontWeight: FontWeight.w600,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                    context,
                                    baseSize: 12),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            AppLocalizations.of(context).minsRead,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context,
                                  baseSize: 12),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                          height:
                              ResponsiveUtils.getResponsiveSpacing(context)),
                      Text(
                        article['title'] ?? '',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              baseSize: 18),
                          fontWeight: FontWeight.bold,
                          color: _darkGreenText,
                        ),
                      ),
                      SizedBox(
                          height:
                              ResponsiveUtils.getResponsiveSpacing(context) *
                                  0.75),
                      Text(
                        article['excerpt'] ?? '',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              baseSize: 14),
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                          height:
                              ResponsiveUtils.getResponsiveSpacing(context)),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _showAudioModal(context, article),
                            child: Container(
                              height: 32,
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    ResponsiveUtils.getResponsiveSpacing(
                                        context),
                              ),
                              decoration: BoxDecoration(
                                color: _darkGreenText,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.play_arrow,
                                      color: Colors.white, size: 18),
                                  SizedBox(
                                    width: ResponsiveUtils.getResponsiveSpacing(
                                            context) *
                                        0.5,
                                  ),
                                  Text(
                                    AppLocalizations.of(context).listen,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize:
                                          ResponsiveUtils.getResponsiveFontSize(
                                              context,
                                              baseSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width:
                                ResponsiveUtils.getResponsiveSpacing(context),
                          ),
                          Container(
                            height: 32,
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  ResponsiveUtils.getResponsiveSpacing(context),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: _primaryTeal, width: 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context).english,
                                style: TextStyle(
                                  color: _darkGreenText,
                                  fontWeight: FontWeight.w600,
                                  fontSize:
                                      ResponsiveUtils.getResponsiveFontSize(
                                          context,
                                          baseSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveCategory = selectedCategory.isEmpty && categories.isNotEmpty
        ? categories.first
        : selectedCategory;
    final filteredArticles = allArticles
        .where((article) => article['category'] == effectiveCategory)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0EA5A4),
        title: Text(AppLocalizations.of(context).educationalHub,
            style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Category selector
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal:
                  ResponsiveUtils.getResponsiveHorizontalPadding(context),
              vertical: ResponsiveUtils.getResponsivePadding(context),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsivePadding(context),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: categories
                    .map((category) => _buildCategoryBubble(
                          category,
                          category == effectiveCategory,
                        ))
                    .toList(),
              ),
            ),
          ),
          // Articles list
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: filteredArticles
                    .map((article) => _buildArticleCard(article))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AudioPlayerModal extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final Map<String, String> article;

  const AudioPlayerModal({
    Key? key,
    required this.audioPlayer,
    required this.article,
  }) : super(key: key);

  @override
  State<AudioPlayerModal> createState() => _AudioPlayerModalState();
}


class _AudioPlayerModalState extends State<AudioPlayerModal> {

  bool _isPlaying = false;
  bool _isLoading = false;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  String? _errorMessage;


  @override
  void initState() {
    super.initState();


    widget.audioPlayer.onDurationChanged.listen((duration) {

      if(mounted){
        setState(() {
          _duration = duration;
        });
      }

    });


    widget.audioPlayer.onPositionChanged.listen((position) {

      if(mounted){
        setState(() {
          _position = position;
        });
      }

    });


    widget.audioPlayer.onPlayerStateChanged.listen((state){

      if(mounted){
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }

    });


    widget.audioPlayer.onPlayerComplete.listen((event){

      if(mounted){
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }

    });

  }



  Future<void> _togglePlayPause() async {

    try {


      if(_isPlaying){

        await widget.audioPlayer.pause();

        return;

      }



      setState(() {

        _isLoading = true;
        _errorMessage = null;

      });



      final text = widget.article['content'] ?? '';



      if(text.isEmpty){

        throw Exception(
          "Article content missing"
        );

      }




      final response = await ApiService().post(

        '/user/api/v1/audio/generate-tts',

        {

          "text": text,

          "voice": "Idera",

          "language": "en",

        },

      );



      debugPrint(
        "TTS Response: $response"
      );



      final audioUrl = response['audio_url'];



      if(audioUrl == null){

        throw Exception(
          "Audio URL missing"
        );

      }




    await widget.audioPlayer.play(UrlSource(audioUrl));


      setState(() {

        _isLoading = false;

      });



    } catch(e){


      debugPrint(
        "Audio error: $e"
      );



      setState(() {

        _isLoading = false;

        _errorMessage =
            "Unable to generate audio";

      });


    }

  }




  String _formatDuration(Duration duration){

    String twoDigits(int n) =>
        n.toString().padLeft(2,'0');


    final minutes =
        duration.inMinutes.remainder(60);


    final seconds =
        duration.inSeconds.remainder(60);


    return "${twoDigits(minutes)}:${twoDigits(seconds)}";

  }




  @override
  Widget build(BuildContext context) {


    return Container(

      color: Colors.white,

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [


            Row(

              children: [

                Expanded(

                  child: Text(

                    widget.article['title'] ?? '',

                    style: const TextStyle(

                      fontSize:18,

                      fontWeight:FontWeight.bold,

                      color:_darkGreenText,

                    ),

                  ),

                ),



                IconButton(

                  icon: const Icon(Icons.close),

                  onPressed: () {

                    Navigator.pop(context);

                  },

                )

              ],

            ),



            const SizedBox(height:20),



            Slider(

              activeColor:_primaryTeal,

              min:0,

              max:_duration.inSeconds == 0
                  ? 1
                  : _duration.inSeconds.toDouble(),


              value:_position.inSeconds
                  .toDouble()
                  .clamp(

                    0,

                    _duration.inSeconds == 0
                        ? 1
                        : _duration.inSeconds.toDouble(),

                  ),


              onChanged:null,

            ),



            Row(

              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,


              children:[


                Text(
                  _formatDuration(_position),
                ),


                Text(
                  _formatDuration(_duration),
                ),


              ],

            ),



            const SizedBox(height:20),




            Container(

              decoration: const BoxDecoration(

                shape:BoxShape.circle,

                color:_primaryTeal,

              ),



              child:_isLoading

              ? const SizedBox(

                  width:60,

                  height:60,

                  child:Center(

                    child:CircularProgressIndicator(

                      color:Colors.white,

                    ),

                  ),

                )


              : IconButton(

                  icon:Icon(

                    _isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,


                    color:Colors.white,

                  ),


                  iconSize:35,


                  onPressed:_togglePlayPause,

                ),

            ),




            if(_errorMessage != null)

              Padding(

                padding:
                    const EdgeInsets.only(top:15),


                child:Text(

                  _errorMessage!,

                  style:const TextStyle(

                    color:Colors.red,

                  ),

                ),

              ),



          ],

        ),

      ),

    );

  }

}
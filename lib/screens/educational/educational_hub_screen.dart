import 'package:flutter/material.dart';
import '/theme/app_colors.dart';
import '../../services/api_service.dart';
import "../educational/reading_screen.dart";
import '../../generated/l10n/app_localizations.dart';


class EducationHubScreen extends StatefulWidget {
  const EducationHubScreen({super.key});

  @override
  State<EducationHubScreen> createState() =>
      _EducationHubScreenState();
}

class _EducationHubScreenState
    extends State<EducationHubScreen> {
      final ApiService _api = ApiService();

List<dynamic> _articles = [];

Map<String, dynamic>? _featuredArticle;

bool _loading = true;

final TextEditingController _searchController =
    TextEditingController();

String _language = "en";

@override
void initState() {
  super.initState();
}
@override
void didChangeDependencies() {
  super.didChangeDependencies();

  final language = Localizations.localeOf(context).languageCode;

  if (language != _language) {
    _language = language;
    _loadArticles();
  }
}


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor:
      AppColors.cardBackground,


      body: SafeArea(

        child: SingleChildScrollView(

         padding: EdgeInsets.symmetric(
horizontal: MediaQuery.of(context).size.width < 360 ? 15 : 20,
),


          child:Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,


            children:[



              const SizedBox(height:20),



              Center(

                child:Text(

                  AppLocalizations.of(context).explore,

                  style:TextStyle(

                    color:
                    AppColors.textPrimary,

                    fontSize:32,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),

              ),



              const SizedBox(height:35),



              _buildSearch(),




              const SizedBox(height:30),



              _buildArticleHeader(),

              if (_loading)
  const Center(
    child: CircularProgressIndicator(),
  )
else
  ..._articles.map(
    (article) => Padding(
      padding:
          const EdgeInsets.only(bottom: 18),
      child: _buildArticleCard(
        context,
        article: article,
      ),
    ),
  ),


              const SizedBox(height:100),


            ],

          ),

        ),

      ),

    );

  }
  Widget _buildSearch(){

return Container(

height:58,

decoration:BoxDecoration(

color:
Colors.white,

borderRadius:
BorderRadius.circular(30),

boxShadow:[

BoxShadow(

blurRadius:15,

color:
Colors.black.withOpacity(.08),

)

],

),


child: TextField(
  controller: _searchController,
  textInputAction: TextInputAction.search,
  onSubmitted: (_) => _searchArticle(),

decoration:InputDecoration(
  suffixIcon: IconButton(
  icon: const Icon(Icons.arrow_forward),
  onPressed: _searchArticle,
),

hintText:
AppLocalizations.of(context).searchArticles,


hintStyle:
const TextStyle(

color:
Colors.grey,

),


prefixIcon:
const Icon(

Icons.search,

color:
Colors.grey,

),


border:
InputBorder.none,


contentPadding:
const EdgeInsets.symmetric(
vertical:18,
),


),

),

);

}

Future<void> _loadArticles() async {
  setState(() {
    _loading = true;
  });

  try {
    final articles = await _api.getArticles(lang: _language);

    if (!mounted) return;

    setState(() {
      _articles = articles;
      _featuredArticle =
          articles.isNotEmpty ? articles.first : null;
      _loading = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }
}
Future<void> _searchArticle() async {
  if (_searchController.text.trim().isEmpty) return;

  try {
    final article = await _api.getArticleBySlug(
      slug: _searchController.text.trim(),
      lang: _language,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReadingScreen(
          articleId: article["id"],
        ),
      ),
    );
  } catch (_) {}
}


Widget _buildArticleHeader(){

return Text(
  AppLocalizations.of(context).articles,
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryDark,
  ),
);

}
Widget _buildArticleCard(
BuildContext context,{
required Map<String,dynamic> article,
}){


final width =
MediaQuery.of(context).size.width;

return GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReadingScreen(
          articleId: article["id"],
        ),
      ),
    );
  },
  child: Container(

height: width < 380 ? 130 : 145,


padding:
const EdgeInsets.all(12),


decoration:
BoxDecoration(

color:
Colors.white,

borderRadius:
BorderRadius.circular(25),


boxShadow:[

BoxShadow(

color:
Colors.black.withOpacity(0.06),

blurRadius:12,

offset:
const Offset(0,6),

),

],

),



child:Row(

children:[


/// IMAGE

AspectRatio(

aspectRatio:1,


child:ClipRRect(

borderRadius:
BorderRadius.circular(18),


child:Image.network(
article["cover_image_url"] ?? "",
 fit: BoxFit.cover,
  errorBuilder: (_, __, ___) => const Icon(Icons.image),

),

),

),




const SizedBox(width:12),




/// TEXT

Expanded(

child:Column(

mainAxisAlignment:
MainAxisAlignment.center,


crossAxisAlignment:
CrossAxisAlignment.start,


children:[



Text(

article["language"].toUpperCase(),

maxLines:1,

overflow:
TextOverflow.ellipsis,


style:
const TextStyle(

color:
Color(0xff16A6A6),

fontWeight:
FontWeight.bold,

fontSize:12,

),

),




const SizedBox(height:6),




Text(

article["title"] ?? "",

maxLines:2,
overflow: TextOverflow.ellipsis,




style:
const TextStyle(

color:
AppColors.primaryDark,

fontSize:16,

fontWeight:
FontWeight.bold,

),

),




const SizedBox(height:6),




Text(

article["summary"] ?? "",

maxLines:2,
overflow: TextOverflow.ellipsis,

style:
const TextStyle(

color:
Colors.grey,

fontSize:13,

),

),



],

),

),



],

),


)
);

}
}

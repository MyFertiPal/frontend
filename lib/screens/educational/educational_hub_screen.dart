import 'package:flutter/material.dart';
import '/theme/app_colors.dart';


class EducationHubScreen extends StatelessWidget {

  const EducationHubScreen({super.key});


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

                  "Explore & Learn",

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



              const SizedBox(height:45),



              _buildFeatured(context),



              const SizedBox(height:30),



              _buildArticleHeader(),



              const SizedBox(height:20),



              _buildArticleCard(
                context,
              

                image:
                "assets/images/cycle.png",

                category:
                "MENSTRUAL HEALTH",

                title:
                "Understanding Your Cycle Phases",

                duration:
                "6 min read",

              ),



              const SizedBox(height:18),



              _buildArticleCard(
                 context,

                image:
                "assets/images/pregnancy.png",

                category:
                "MENSTRUAL HEALTH",

                title:
                "Understanding Your Cycle Phases",

                duration:
                "6 min read",

              ),



              const SizedBox(height:18),



              _buildArticleCard(
                context,

                image:
                "assets/images/nutrition.png",

                category:
                "NUTRITION",

                title:
                "Foods That Support Fertility",

                duration:
                "4 min read",

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


child:TextField(

decoration:InputDecoration(

hintText:
"Search articles, topics, videos...",


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

Widget _buildFeatured(context){

final screenWidth = MediaQuery.of(context).size.width;


return Container(

height: screenWidth < 380 ? 230 : 250,

padding: EdgeInsets.all(
screenWidth < 380 ? 18 : 22,
),


decoration: BoxDecoration(

color: AppColors.primaryDark,

borderRadius:
BorderRadius.circular(25),

),


child: Row(

crossAxisAlignment:
CrossAxisAlignment.center,


children:[


/// TEXT SECTION

Expanded(

flex:3,


child:Column(

mainAxisAlignment:
MainAxisAlignment.center,


crossAxisAlignment:
CrossAxisAlignment.start,


children:[


const Text(

"FEATURED",

style: TextStyle(

color: Colors.white,

fontSize:12,

fontWeight:
FontWeight.bold,

),

),



const SizedBox(height:12),



Text(

"Pregnancy",

maxLines:1,

overflow:
TextOverflow.ellipsis,


style: TextStyle(

color:Colors.white,

fontSize:
screenWidth < 380 ? 22 : 26,

fontWeight:
FontWeight.bold,

),

),



const SizedBox(height:8),



Text(

"Expert-backed guides\non fertility,\ncycles & wellness.",


maxLines:3,


style: TextStyle(

color:Colors.white70,

fontSize:
screenWidth < 380 ? 13 : 15,

height:1.3,

),

),



const SizedBox(height:12),



SizedBox(

height:36,


child:ElevatedButton(

style:
ElevatedButton.styleFrom(

backgroundColor:
const Color(0xffff5964),


padding:
const EdgeInsets.symmetric(
horizontal:16,
),


shape:
RoundedRectangleBorder(

borderRadius:
BorderRadius.circular(25),

),

),



onPressed:(){},



child:
const Text(

"Read Now",

style:TextStyle(

color:Colors.white,

fontSize:13,

fontWeight:
FontWeight.bold,

),

),


),

),


],

),

),




const SizedBox(width:8),



/// IMAGE SECTION

Expanded(

flex:2,


child:SizedBox(

height:
screenWidth < 380 ? 150 : 180,


child:Transform.scale(

scale:
screenWidth < 380 ? 1.15 : 1.3,


child:Image.asset(

"assets/images/pregnancy_fetus.png",

fit:
BoxFit.contain,

),

),

),

),



],

),


);

}

Widget _buildArticleHeader(){

return Row(

mainAxisAlignment:
MainAxisAlignment.spaceBetween,

children:[


const Text(

"Articles",

style:
TextStyle(

fontSize:24,

fontWeight:
FontWeight.bold,

color:
AppColors.primaryDark,

),

),



TextButton(

onPressed:(){

},


child:
const Text(

"See all",

style:
TextStyle(

color:
Color(0xff16A6A6),

fontWeight:
FontWeight.bold,

),

),

)

],

);

}
Widget _buildArticleCard(
BuildContext context, {

required String image,
required String category,
required String title,
required String duration,

}){


final width =
MediaQuery.of(context).size.width;


return Container(

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


child:Image.asset(

image,

fit:
BoxFit.cover,

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

category,

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

title,

maxLines:2,

overflow:
TextOverflow.ellipsis,


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

duration,

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


);

}
}
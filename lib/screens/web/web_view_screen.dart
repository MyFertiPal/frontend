import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../theme/app_colors.dart';

class WebViewScreen extends StatefulWidget {

  final String title;
  final String url;

  const WebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });


  @override
  State<WebViewScreen> createState() => _WebViewScreenState();

}


class _WebViewScreenState extends State<WebViewScreen> {

  late final WebViewController controller;

  bool loading = true;


  @override
  void initState() {
    super.initState();

    controller = WebViewController()

      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )

      ..setNavigationDelegate(
        NavigationDelegate(

          onPageStarted: (_) {
            setState(() {
              loading = true;
            });
          },


          onPageFinished: (_) {
            setState(() {
              loading = false;
            });
          },

        ),
      )

      ..loadRequest(
        Uri.parse(widget.url),
      );

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
      ),


      body: Stack(
        children: [

          WebViewWidget(
            controller: controller,
          ),


          if(loading)
            const Center(
              child: CircularProgressIndicator(),
            ),

        ],
      ),

    );

  }
}
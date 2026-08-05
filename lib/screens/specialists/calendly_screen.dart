import 'package:flutter/material.dart';
import "../../theme/app_colors.dart";
import 'package:webview_flutter/webview_flutter.dart';
import '../../generated/l10n/app_localizations.dart';

class CalendlyScreen extends StatefulWidget {
  final String calendlyUrl;

  const CalendlyScreen({
    super.key,
    required this.calendlyUrl,
  });

  @override
  State<CalendlyScreen> createState() => _CalendlyScreenState();
}

class _CalendlyScreenState extends State<CalendlyScreen> {

  late final WebViewController controller;

  bool isLoading = true;


  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)

      ..setNavigationDelegate(
        NavigationDelegate(

          onPageStarted: (url){
            setState(() {
              isLoading = true;
            });
          },

          onPageFinished: (url){
            setState(() {
              isLoading = false;
            });
          },

        ),
      )

      ..loadRequest(
        Uri.parse(widget.calendlyUrl),
      );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:  Text(
          AppLocalizations.of(context).bookConsultation,
        ),
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
      ),


      body: Stack(
        children: [

          WebViewWidget(
            controller: controller,
          ),


          if(isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import "../../theme/app_colors.dart";
import 'package:webview_flutter/webview_flutter.dart';

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

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(widget.calendlyUrl),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Consultation"),
        backgroundColor: AppColors.teal,
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
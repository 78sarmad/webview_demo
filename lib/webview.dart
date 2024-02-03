import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen({super.key});

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  WebViewController? webViewController;
  bool isLoading = true;

  String urlToLoad = 'https://google.com/';
  String urlToIgnore = 'https://dev.meemcolart.com/';

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(ThemeData().scaffoldBackgroundColor)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (request) {
              if (request.url.startsWith(urlToIgnore)) {
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(urlToLoad));

      if (mounted) setState(() => isLoading = false);
    });
  }

  Future onRefresh() async {
    setState(() => isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      webViewController?.reload();
    });
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // final minVerticalDrag = MediaQuery.sizeOf(context).height / 5;

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'GoTaxi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading) const LinearProgressIndicator(),
          if (webViewController != null)
            Expanded(
              child: GestureDetector(
                onVerticalDragEnd: (details) async {
                  if (details.velocity ==
                      const Velocity(pixelsPerSecond: Offset(0, 50))) {
                    await onRefresh();
                  }
                },
                child: WebViewWidget(
                  controller: webViewController!,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white, // Set status bar color to white
    statusBarBrightness: Brightness.dark, // Set status bar icons to dark
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OxyManager',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      debugShowCheckedModeBanner: false,
      home:  SplashScreen(),
    );
  }
}
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 2 seconds, then navigate to the WebView screen
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OxyManagerWebView()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network('https://oxymanager.com/static/images/logo.png', width: 250, height: 150),
            const SizedBox(height: 20), // Loading indicator
          ],
        ),
      ),
    );
  }
}

class OxyManagerWebView extends StatefulWidget {
  const OxyManagerWebView({super.key});

  @override
  _OxyManagerWebViewState createState() => _OxyManagerWebViewState();
}

class _OxyManagerWebViewState extends State<OxyManagerWebView> {
  late WebViewController _controller;
  bool _isLoadingPage = true;

  var canPop=false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvoked: (bool) async {
        if (_controller != null && await _controller.canGoBack()) {
          _controller.goBack();
          setState(() {
            canPop= false;
          });
        }else{
         setState(() {
           canPop= true;
         });

        }
      },
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              WebView(
                initialUrl: 'https://oxymanager.com/dashboard/overview',
                javascriptMode: JavascriptMode.unrestricted,
                onPageFinished: (String url) {
                  setState(() {
                    _isLoadingPage = false;
                  });
                  // Inject JavaScript to set initial scale to 100%
                  String script = 'document.querySelector(\'meta[name="viewport"]\').setAttribute("content", "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no");';
                  _controller.evaluateJavascript(script);

                },
                onWebViewCreated: (WebViewController webViewController) {
                  _controller = webViewController;
                },
              ),
              if (_isLoadingPage)
                const Center(
                  child: CircularProgressIndicator(color: Colors.orange,),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

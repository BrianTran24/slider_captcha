import 'package:example/slider_captcha_circle_verify.dart';
import 'package:example/slider_captcha_client_verify.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Slider Captcha Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SliderCaptchaClientVerify(
                      title: 'Puzzle Captcha',
                    ),
                  ),
                );
              },
              child: const Text('Puzzle Mode Example'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SliderCaptchaCircleVerify(
                      title: 'Circle Rotate Captcha',
                    ),
                  ),
                );
              },
              child: const Text('Circle Mode Example (TikTok style)'),
            ),
          ],
        ),
      ),
    );
  }
}

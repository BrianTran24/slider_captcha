import 'package:flutter/material.dart';
import 'package:slider_captcha/slider_captcha.dart';

class SliderCaptchaClientVerify extends StatefulWidget {
  const SliderCaptchaClientVerify({Key? key, required this.title})
      : super(key: key);
  final String title;

  @override
  State<SliderCaptchaClientVerify> createState() =>
      _SliderCaptchaClientVerifyState();
}

class _SliderCaptchaClientVerifyState extends State<SliderCaptchaClientVerify> {
  final SliderController controller = SliderController();

  SliderCaptchaMode mode = SliderCaptchaMode.puzzle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                mode = mode == SliderCaptchaMode.puzzle
                    ? SliderCaptchaMode.circle
                    : SliderCaptchaMode.puzzle;
              });
            },
            child: Text(
              mode == SliderCaptchaMode.puzzle ? 'Switch to Circle' : 'Switch to Puzzle',
              style: const TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: SliderCaptcha(
            mode: mode,
            controller: controller,
            image: Image.asset(
              'assets/image.jpeg',
              fit: BoxFit.fitWidth,
            ),
            colorBar: Colors.blue,
            colorCaptChar: Colors.blue,
            onConfirm: (value) async {
              debugPrint(value.toString());
              return await Future.delayed(const Duration(seconds: 1)).then(
                (value) {
                  controller.create.call();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

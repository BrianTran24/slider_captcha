import 'package:flutter/material.dart';
import 'package:slider_captcha/slider_captcha.dart';

class SliderCaptchaCircleVerify extends StatefulWidget {
  const SliderCaptchaCircleVerify({Key? key, required this.title})
      : super(key: key);
  final String title;

  @override
  State<SliderCaptchaCircleVerify> createState() =>
      _SliderCaptchaCircleVerifyState();
}

class _SliderCaptchaCircleVerifyState extends State<SliderCaptchaCircleVerify> {
  final SliderController controller = SliderController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SliderCaptcha(
                mode: SliderCaptchaMode.circle,
                captchaSize: 100, // Tăng kích thước vòng tròn tại đây
                controller: controller,
                image: Image.asset(
                  'assets/image.jpeg',
                  fit: BoxFit.fitWidth,
                ),
                colorBar: Colors.blue,
                colorCaptChar: Colors.blue,
                onConfirm: (value) async {
                  debugPrint('Is success: $value');
                  return await Future.delayed(const Duration(seconds: 1)).then(
                    (value) {
                      controller.create.call();
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Xoay hình tròn để khớp với ảnh gốc',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:slider_captcha/slider_captcha.dart';

class SliderCaptchaClient extends StatefulWidget {
  const SliderCaptchaClient(
      {required this.provider,
      required this.onConfirm,
      this.titleSlider,
      this.titleStyle,
      this.mode = SliderCaptchaMode.puzzle,
      Key? key})
      : super(key: key);

  final SliderCaptchaClientProvider provider;

  final SliderCaptchaMode mode;

  final String? titleSlider;

  final TextStyle? titleStyle;

  final Future<void> Function(double value) onConfirm;

  @override
  State<SliderCaptchaClient> createState() => _SliderCaptchaClientState();
}

class _SliderCaptchaClientState extends State<SliderCaptchaClient>
    with SingleTickerProviderStateMixin {
  late String titleSlider;

  late TextStyle titleStyle;

  @override
  void initState() {
    titleSlider = widget.titleSlider ?? 'Slider to verify';
    titleStyle = widget.titleStyle ?? const TextStyle();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.provider.init(context),
      key: const Key('FutureBuilder'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _SliderCaptchaComponent(
            widget.provider,
            titleSlider,
            titleStyle,
            widget.onConfirm,
            widget.mode,
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _SliderCaptchaComponent extends StatefulWidget {
  const _SliderCaptchaComponent(
      this.provider, this.title, this.titleStyle, this.onConfirm, this.mode,
      {Key? key})
      : super(key: key);

  final SliderCaptchaClientProvider provider;

  final String title;

  final TextStyle titleStyle;

  final Future<void> Function(double value) onConfirm;

  final SliderCaptchaMode mode;

  @override
  State<_SliderCaptchaComponent> createState() =>
      _SliderCaptchaComponentState();
}

class _SliderCaptchaComponentState extends State<_SliderCaptchaComponent>
    with SingleTickerProviderStateMixin {
  Size sizeImage = Size.zero;

  double offset = 0;

  late Animation<double> animation;

  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    animation = Tween<double>(begin: 1, end: 0).animate(animationController)
      ..addListener(() {
        setState(() {
          offset = offset * animation.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationController.reset();
        }
      });
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.provider.puzzleImage != null &&
            widget.provider.pieceImage != null)
          _SliderCaptchaRenderObject(
            widget.provider.puzzleImage!,
            widget.provider.pieceImage!,
            widget.provider.coordinatesY,
            offset,
            widget.mode,
          ),
        sliderBar(),
      ],
    );
  }

  /// You can customize the sliderBar here
  Widget sliderBar() => Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              offset: Offset(0, 0),
              blurRadius: 2,
              color: Colors.grey,
            )
          ],
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: Text(
                widget.title,
                style: widget.titleStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              left: offset,
              top: 0,
              height: 50,
              width: 50,
              child: GestureDetector(
                onHorizontalDragStart: (detail) =>
                    _onDragStart(context, detail),
                onHorizontalDragUpdate: (DragUpdateDetails update) {
                  _onDragUpdate(context, update);
                },
                onHorizontalDragEnd: (DragEndDetails detail) {
                  checkAnswer();
                },
                child: Container(
                  height: 50,
                  width: 50,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                    boxShadow: const <BoxShadow>[
                      BoxShadow(color: Colors.grey, blurRadius: 4)
                    ],
                  ),
                  child: const Icon(Icons.arrow_forward_rounded),
                ),
              ),
            ),
          ],
        ),
      );

  void _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    RenderBox getBox = context.findRenderObject() as RenderBox;
    var local = getBox.globalToLocal(update.globalPosition);

    if (local.dx < 0) {
      setState(() {
        offset = 0;
      });
      return;
    }

    if (local.dx > getBox.size.width) {
      setState(() {
        offset = getBox.size.width - 50;
      });
      return;
    }

    setState(() {
      offset = local.dx - 50 / 2;
    });
  }

  void _onDragStart(BuildContext context, DragStartDetails start) {
    RenderBox getBox = context.findRenderObject() as RenderBox;

    var local = getBox.globalToLocal(start.globalPosition);

    setState(() {
      offset = local.dx - 50 / 2;
    });
  }

  Future<void> checkAnswer() async {
    double value;
    if (widget.mode == SliderCaptchaMode.puzzle) {
      var imageSize = widget.provider.puzzleSize.width / widget.provider.ratio;
      value = offset / imageSize;
    } else {
      RenderBox getBox = context.findRenderObject() as RenderBox;
      // Map offset to 0..1 (representing 0..360 degrees)
      value = offset / (getBox.size.width - 50);
    }
    await widget.onConfirm.call(value);
    animationController.forward();
  }
}

class _SliderCaptchaRenderObject extends MultiChildRenderObjectWidget {
  final Image image;
  final Image piece;
  final double percent;
  final double offsetMove;
  final SliderCaptchaMode mode;

  _SliderCaptchaRenderObject(
    this.image,
    this.piece,
    this.percent,
    this.offsetMove,
    this.mode, {
    Key? key,
  }) : super(children: [image, piece], key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderTestSliderCaptChar(percent, offsetMove, mode);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    (renderObject as _RenderTestSliderCaptChar).offsetMove = offsetMove;
    renderObject.mode = mode;
  }
}

class SliderCaptchaParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderTestSliderCaptChar extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SliderCaptchaParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SliderCaptchaParentData> {
  final double percent;

  double offsetMove = 0;

  SliderCaptchaMode mode;

  _RenderTestSliderCaptChar(this.percent, this.offsetMove, this.mode);

  @override
  void paint(PaintingContext context, Offset offset) {
    var piece = childAfter(firstChild!);
    if (firstChild == null) return;

    if (piece == null) return;
    context.paintChild(firstChild!, offset);

    if (mode == SliderCaptchaMode.puzzle) {
      context.paintChild(
        piece,
        Offset(offset.dx + offsetMove,
            offset.dy + (firstChild?.size.height ?? 0) * percent),
      );
    } else {
      // Circle mode rotation
      // Map offsetMove to rotation angle (0 to 360)
      double maxScroll = size.width - 50;
      double rotationAngle = (offsetMove / maxScroll) * 360;

      context.canvas.save();
      // Center of the background image
      Offset center = Offset(size.width / 2, size.height / 2);

      context.canvas.translate(center.dx + offset.dx, center.dy + offset.dy);
      context.canvas.rotate(rotationAngle * 3.141592653589793 / 180);
      context.canvas.translate(-(center.dx + offset.dx), -(center.dy + offset.dy));

      // Paint piece at center - No changes needed here as the piece 
      // size is controlled by the image provided in the provider.
      context.paintChild(
        piece,
        Offset(offset.dx + (size.width - piece.size.width) / 2,
            offset.dy + (size.height - piece.size.height) / 2),
      );
      context.canvas.restore();
    }
  }

  @override
  void performLayout() {
    final deflatedConstraints = constraints.deflate(EdgeInsets.zero);

    for (var child = firstChild; child != null; child = childAfter(child)) {
      child.layout(deflatedConstraints, parentUsesSize: true);
    }
    size = Size(firstChild?.size.width ?? 0, firstChild?.size.height ?? 0);
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! SliderCaptchaParentData) {
      child.parentData = SliderCaptchaParentData();
    }
  }
}

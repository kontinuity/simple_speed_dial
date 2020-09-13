import 'package:flutter/material.dart';

import 'simple_speed_dial_child.dart';

class SpeedDial extends StatefulWidget {
  const SpeedDial({
    this.child,
    this.speedDialChildren,
    this.labelsStyle,
    this.controller,
    this.closedForegroundColor,
    this.openForegroundColor,
    this.closedBackgroundColor,
    this.openBackgroundColor,
    this.backgroundGradient,
  });

  final Widget child;

  final List<SpeedDialChild> speedDialChildren;

  final TextStyle labelsStyle;

  final AnimationController controller;

  final Color closedForegroundColor;

  final Color openForegroundColor;

  final Color closedBackgroundColor;

  final Color openBackgroundColor;

  final Gradient backgroundGradient;

  @override
  State<StatefulWidget> createState() {
    return _SpeedDialState();
  }
}

class _SpeedDialState extends State<SpeedDial> with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _iconRotateAnimation;
  final List<Animation<double>> _speedDialChildAnimations = <Animation<double>>[];

  @override
  void initState() {
    _animationController = widget.controller ?? AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    print(_animationController);
    _animationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _iconRotateAnimation = Tween<double>(begin: 0.0, end: 0.75).animate(_animationController);

    final double fractionOfOneSpeedDialChild = 1 / widget.speedDialChildren.length;
    for (int speedDialChildIndex = 0; speedDialChildIndex < widget.speedDialChildren.length; ++speedDialChildIndex) {
      final List<TweenSequenceItem<double>> tweenSequenceItems = <TweenSequenceItem<double>>[];

      final double firstWeight = fractionOfOneSpeedDialChild * speedDialChildIndex;
      if (firstWeight > 0.0) {
        tweenSequenceItems.add(TweenSequenceItem<double>(
          tween: ConstantTween<double>(0.0),
          weight: firstWeight,
        ));
      }

      tweenSequenceItems.add(TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: fractionOfOneSpeedDialChild,
      ));

      final double lastWeight = fractionOfOneSpeedDialChild * (widget.speedDialChildren.length - 1 - speedDialChildIndex);
      if (lastWeight > 0.0) {
        tweenSequenceItems.add(TweenSequenceItem<double>(tween: ConstantTween<double>(1.0), weight: lastWeight));
      }

      _speedDialChildAnimations.insert(0, TweenSequence<double>(tweenSequenceItems).animate(_animationController));
    }

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int speedDialChildAnimationIndex = 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (!_animationController.isDismissed)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.speedDialChildren?.map<Widget>((SpeedDialChild speedDialChild) {
                    final Widget speedDialChildWidget = Opacity(
                      opacity: _speedDialChildAnimations[speedDialChildAnimationIndex].value,
                      child: GestureDetector(
                        onTap: () {
                          if (speedDialChild.closeSpeedDialOnPressed) {
                            _animationController.reverse();
                          }
                          speedDialChild.onPressed?.call();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0 - 4.0),
                              child: Card(
                                elevation: 3.0,
                                color: Theme.of(context).cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17.5),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(17.5)),
                                    gradient: speedDialChild.backgroundGradient,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16.0,
                                      right: 16.0,
                                      top: 8.0,
                                      bottom: 8.0,
                                    ),
                                    child: Text(
                                      speedDialChild.label,
                                      style: widget.labelsStyle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ScaleTransition(
                              scale: _speedDialChildAnimations[speedDialChildAnimationIndex],
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: FloatingActionButton(
                                  heroTag: speedDialChildAnimationIndex,
                                  mini: true,
                                  child: FractionallySizedBox(
                                    widthFactor: 1.0,
                                    heightFactor: 1.0,
                                    child: Container(
                                      decoration: BoxDecoration(shape: BoxShape.circle, gradient: speedDialChild.backgroundGradient),
                                      child: speedDialChild.child,
                                    ),
                                  ),
                                  onPressed: () {
                                    if (speedDialChild.closeSpeedDialOnPressed) {
                                      _animationController.reverse();
                                    }
                                    speedDialChild.onPressed?.call();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                    speedDialChildAnimationIndex++;
                    return speedDialChildWidget;
                  })?.toList() ??
                  <Widget>[],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: FloatingActionButton(
            child: FractionallySizedBox(
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: widget.backgroundGradient),
                child: Transform.rotate(angle: _iconRotateAnimation.value, child: widget.child),
              ),
            ),
            onPressed: () {
              if (_animationController.isDismissed) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            },
          ),
        )
      ],
    );
  }
}

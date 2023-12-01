
import 'package:flutter/material.dart';
import 'package:pin_ui/size_config.dart';

typedef KeyboardTapCallback = void Function(String text);

class KeyboardUI extends StatefulWidget {
  final Widget? rightIcon;
  final Widget? leftIcon;
  final Function()? rightButtonFn;
  final Text? leftExit;
  final Function()? leftButtonExit;
  final KeyboardTapCallback? onKeyboardTap;
  final MainAxisAlignment? mainAxisAlignment;

  KeyboardUI(
      {Key? key,
        @required this.onKeyboardTap,
        this.rightButtonFn,
        this.rightIcon,
        this.leftButtonExit,
        this.leftExit,
        this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
        this.leftIcon})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _KeyboardUIState();
  }
}

class _KeyboardUIState extends State<KeyboardUI> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          SizedBox(height: SizeConfig.calculateBlockVertical(25)),
          Row(
            mainAxisAlignment: widget.mainAxisAlignment!,
            children: <Widget>[
              _calcButton('1'),
              _calcButton('2'),
              _calcButton('3'),
            ],
          ),
          SizedBox(height: SizeConfig.calculateBlockVertical(30)),
          Row(
            mainAxisAlignment: widget.mainAxisAlignment!,
            children: <Widget>[
              _calcButton('4'),
              _calcButton('5'),
              _calcButton('6'),
            ],
          ),
          SizedBox(height: SizeConfig.calculateBlockVertical(30)),
          Row(
            mainAxisAlignment: widget.mainAxisAlignment!,
            children: <Widget>[
              _calcButton('7'),
              _calcButton('8'),
              _calcButton('9'),
            ],
          ),
          SizedBox(height: SizeConfig.calculateBlockVertical(30)),
          Row(
            mainAxisAlignment: widget.mainAxisAlignment!,
            children: <Widget>[
              // InkWell(
              //     borderRadius: BorderRadius.circular(45),
              //     onTap: widget.leftButtonExit,
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         if (widget.leftExit != null) widget.leftExit! else Container(
              //           alignment: Alignment.center,
              //           width: 65,
              //           height: 65,
              //         )
              //       ],
              //     )),
              _calcButton('e', tap: widget.leftButtonExit),
              _calcButton('0'),
              _calcButton('f', tap: widget.rightButtonFn),
              // InkWell(
              //     borderRadius: BorderRadius.circular(45),
              //     onTap: widget.rightButtonFn ?? null,
              //     child: Container(
              //         alignment: Alignment.center,
              //         width: 65,
              //         height: 65,
              //         child: widget.rightIcon))
            ],
          ),
          SizedBox(height: SizeConfig.calculateBlockVertical(15)),
        ],
      ),
    );
  }

  Widget _calcButton(String value, {Function()? tap}) {
    return InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: () => value == 'e' || value == 'f'
            ? (tap?.call() ?? null)
            : widget.onKeyboardTap!(value),
        child: Container(
          alignment: Alignment.center,
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: value == 'e' || value == 'f'
                ? Colors.transparent
                : Colors.grey.withOpacity(0.13),
            borderRadius: const BorderRadius.all(Radius.circular(50.0)),
          ),
          child: value == 'f'
              ? widget.rightIcon
              : value == 'e'
              ? widget.leftIcon
              : Text(
            value == 'e'
                ? "Chiqish"
                : value == 'f'
                ? ""
                : value,
            style: TextStyle(
                fontSize: value == 'e' ? 14 : 34,
                fontWeight: FontWeight.w500),
          ),
        ));
  }
}

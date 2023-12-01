
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pin_ui/shake_widget.dart';
import 'package:pin_ui/size_config.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:vibration/vibration.dart';
import 'keyboard_ui.dart';


Color primaryAppColor(BuildContext context) {
  return ThemeProvider.themeOf(context).data.primaryColor;
}

class PinUIScreen extends StatefulWidget {
  final bool back;

  const PinUIScreen({Key? key, this.back = false}) : super(key: key);

  @override
  _PinUIScreen createState() => _PinUIScreen();
}

class _PinUIScreen extends State<PinUIScreen>
    with TickerProviderStateMixin {
  final shakeKey = GlobalKey<ShakeWidgetState>();
  Color redColor = Colors.red;
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 800),
    vsync: this,
  )..repeat(reverse: true);
  late final AnimationController _controller1 = AnimationController(
    duration: const Duration(milliseconds: 850),
    vsync: this,
  )..repeat(reverse: true);
  late final AnimationController _controller2 = AnimationController(
    duration: const Duration(milliseconds: 900),
    vsync: this,
  )..repeat(reverse: true);
  late final AnimationController _controller3 = AnimationController(
    duration: const Duration(milliseconds: 950),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );
  late final Animation<double> _animation1 = CurvedAnimation(
    parent: _controller1,
    curve: Curves.easeIn,
  );
  late final Animation<double> _animation2 = CurvedAnimation(
    parent: _controller2,
    curve: Curves.easeIn,
  );
  late final Animation<double> _animation3 = CurvedAnimation(
    parent: _controller3,
    curve: Curves.easeIn,
  );
  String text = '';
  String password = '4444';
  bool isSwitched = false;
  String _firstDigit = "";
  String _secondDigit = "";
  String _thirdDigit = "";
  String _fourthDigit = "";
  bool access = false;
  bool _isLoading = false;
  bool isFingerHas = false;

  var iconRight = SvgPicture.asset(
    'assets/fingerprint.svg',
  );
  var fingerprint = SvgPicture.asset(
    'assets/fingerprint.svg',
  );
  var selectBg;
  var _decoration = BoxDecoration(
      color: Colors.white.withOpacity(0.5),
      borderRadius: BorderRadius.circular(100));

  String pinTitle = "Pin kod kiriting";

  LocalAuthentication _auth = LocalAuthentication();
  bool _checkBio = false;
  bool _isBioFinger = false;

  Color customColor = Colors.black87;

  @override
  void initState() {
    if (Platform.isAndroid || Platform.isIOS) {
      getPinTitle();
      _checkBiometrics();
      _listBioAndFingerType();
      _startAuth();
    }

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    iconRight = SvgPicture.asset(
      'assets/icons/fingerprint.svg',
      color: primaryAppColor(context),
    );
    fingerprint = SvgPicture.asset(
      'assets/icons/fingerprint.svg',
      color: primaryAppColor(context),
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    customColor = ThemeProvider.controllerOf(context).theme.id == 'dark' ? Colors.white : Colors.black;
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            mainUI(context),
            Positioned(
                bottom: 1,
                left: 1,
                right: 1,
                child: Column(
                  children: [
                    ShakeWidget(
                      key: shakeKey,
                      shakeCount: 3,
                      shakeOffset: 10,
                      shakeDuration: Duration(milliseconds: 500),
                      child: !_isLoading
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _otpTextField(_firstDigit),
                          SizedBox(width: 16.0),
                          _otpTextField(_secondDigit),
                          SizedBox(width: 16.0),
                          _otpTextField(_thirdDigit),
                          SizedBox(width: 16.0),
                          _otpTextField(_fourthDigit),
                        ],
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          FadeTransition(
                              opacity: _animation,
                              child: _otpTextField(_firstDigit)),
                          SizedBox(width: 16.0),
                          FadeTransition(
                              opacity: _animation1,
                              child: _otpTextField(_secondDigit)),
                          SizedBox(width: 16.0),
                          FadeTransition(
                              opacity: _animation2,
                              child: _otpTextField(_thirdDigit)),
                          SizedBox(width: 16.0),
                          FadeTransition(
                              opacity: _animation3,
                              child: _otpTextField(_fourthDigit)),
                        ],
                      ),
                    ),
                    SizedBox(height: SizeConfig.calculateBlockVertical(30)),
                    Card(
                        elevation: 0.0,
                        color: ThemeProvider.controllerOf(context)
                            .theme
                            .data
                            .cardColor,
                        shadowColor: Colors.green,
                        margin: EdgeInsets.all(0),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(35),
                              topRight: Radius.circular(35)),
                        ),
                        child: getKeyboardUI())
                  ],
                )),
          ],
        ),
      ),
    );
  }

  _onKeyboardTap(String value) async {
    _firstDigit = "";
    _secondDigit = "";
    _thirdDigit = "";
    _fourthDigit = "";

    setState(() {
      int counter = 1;
      if (value != "" && text.length < 4) {
        iconRight = SvgPicture.asset(
          'assets/icons/delete.svg',
          width: 34,
          height: 34,
          color: customColor,
        );
        access = false;
        _decoration = BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(100));
        text = text + value;
        print(text);
        if (text.length == 4) {
          if (text == password) {
            // Open APP
          } else {
            setState(() {
              text = "";
              access = true;
              selectBg = openAccess();
              iconRight = fingerprint;
              _decoration = error();
            });
            if (Platform.isAndroid || Platform.isIOS) shakingFunction();
          }
        }
      } else {
        if (text.length == 0) iconRight = fingerprint;
      }
      text.characters.forEach((element) {
        switch (counter) {
          case 1:
            _firstDigit = element;
            break;
          case 2:
            _secondDigit = element;
            break;
          case 3:
            _thirdDigit = element;
            break;
          case 4:
            _fourthDigit = element;
            break;
        }
        counter = counter + 1;
      });
    });
  }

  Widget mainUI(BuildContext context) {
    return Positioned(
      left: 20,
      top: SizeConfig.calculateBlockVertical(70),
      right: 20,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: SizeConfig.calculateBlockVertical(40)),
            Text("PIN-kod",
                style: TextStyle(
                  fontSize: SizeConfig.calculateTextSize(30),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.27,
                )),
            SizedBox(height: SizeConfig.calculateBlockVertical(30)),
            Text(pinTitle,
                style: TextStyle(
                  fontSize: SizeConfig.calculateTextSize(16),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                )),
          ],
        ),
      ),
    );
  }

  Future<void> shakingFunction() async {
    shakeKey.currentState?.shake();
    var vibrate = await Vibration.hasVibrator();
    if (vibrate ?? false) {
      var vibrateAmplitude = await Vibration.hasAmplitudeControl();
      if (vibrateAmplitude ?? false) {
        Vibration.vibrate(duration: 500, amplitude: 12);
      } else {
        Vibration.vibrate(duration: 500);
      }
    } else {
      print("Not able to vibrate");
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _decoration = simple();
      });
    });
  }

  // Returns "Otp custom text field"
  Widget _otpTextField(String digit) {
    if (digit != "") {
      selectBg = select();
    } else {
      selectBg = simple();
    }
    if (password == text)
      setState(() {
        selectBg = openAccess();
      });

    return Card(
      elevation: 2.0,
      color: ThemeProvider.controllerOf(context).theme.data.cardColor,
      shadowColor: primaryAppColor(context).withOpacity(0.2),
      margin: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: new Container(
        width: 30.0,
        height: 30.0,
        alignment: Alignment.center,
        child: new Container(
          width: 30.0,
          height: 30.0,
          decoration: selectBg,
        ),
        decoration: _decoration,
      ),
    );
  }

  Widget getKeyboardUI() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: KeyboardUI(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        onKeyboardTap: _onKeyboardTap,
        rightButtonFn: text.length > 0 || _checkBio && isFingerHas
            ? () {
          setState(() {
            if (text.length > 0) {
              text = text.substring(0, text.length - 1);
              _onKeyboardTap("");
            } else {
              if (_checkBio && isFingerHas) {
                iconRight = fingerprint;
                if (Platform.isAndroid || Platform.isIOS) _startAuth();
              }
            }
          });
        }
            : null,
        rightIcon: _checkBio && isFingerHas
            ? iconRight
            : text.length >= 0
            ? SvgPicture.asset(
          'assets/delete.svg',
          width: 34,
          height: 34,
          color: customColor,
        )
            : null,
        leftButtonExit: () async {

        },
        leftIcon: Image.asset(
          "assets/exit.png",
          width: 34,
          height: 34,
          color: Colors.red,
        ),
        leftExit: Text("Chiqish",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.0,
            )),
      ),
    );
  }

  void _checkBiometrics() async {
    try {
      final bio = await _auth.canCheckBiometrics;
      setState(() {
        _checkBio = bio;
      });
      print('Biometrics = $_checkBio');
    } catch (e) {
      print('Check Biometrics Error: $e');
    }
  }

  void _listBioAndFingerType() async {
    List<BiometricType>? _listType;
    try {
      _listType = await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('List Bio Error: $e');
    }
    print('List Bio: $_listType');

    if (_listType != null) {
      if (_listType.contains(BiometricType.fingerprint)) {
        setState(() {
          _isBioFinger = true;
        });
        print('Fingerprint is $_isBioFinger');
      }
    }
  }

  void _startAuth() async {
    // isFingerHas = (await _userData.isFingerprintHas()) ?? false;
    // log("touch id is on = ${isFingerHas}");
    // bool? _isAuthenticated;
    // if (isFingerHas) {
    //   AndroidAuthMessages _androidMsg = AndroidAuthMessages(
    //       signInTitle: getTranslated(context, 'cash55'),
    //       biometricHint: "Ilovaga barmoq izi orqali ilovaga kirish",
    //       cancelButton: getTranslated(context, 'back'),
    //       goToSettingsButton: "Biometrik ma'lumotlarni o'rnatish",
    //       goToSettingsDescription:
    //       "Qurilmada biometrik ma'lumotlar o'rnatilmagan",
    //       biometricNotRecognized: getTranslated(context, 'cash57'),
    //       biometricSuccess: getTranslated(context, 'cash58'),
    //       biometricRequiredTitle: getTranslated(context, 'cash59'));
    //   IOSAuthMessages iosStrings = const IOSAuthMessages(
    //       cancelButton: 'cancel',
    //       goToSettingsButton: 'settings',
    //       goToSettingsDescription: 'Please set up your Touch ID.',
    //       lockOut: 'Please re enable your Touch ID');
    //   try {
    //     _isAuthenticated = await _auth.authenticate(
    //       options: AuthenticationOptions(
    //         biometricOnly: true,
    //         useErrorDialogs: true,
    //         stickyAuth: true,
    //       ),
    //       localizedReason: "TEST",
    //       authMessages: [iosStrings, _androidMsg],
    //     );
    //   } on PlatformException catch (e) {
    //     print('Start Auth Error: $e');
    //   }
    //
    //   if (_isAuthenticated!) {
    //     setState(() {
    //       // OPEN APP
    //       isSwitched = true;
    //     });
    //   } else {
    //     setState(() {
    //       selectBg = openAccess();
    //       isSwitched = false;
    //     });
    //   }
    // }
  }

  BoxDecoration openAccess() {
    return BoxDecoration(
        color: Colors.green.withOpacity(0.5),
        borderRadius: BorderRadius.circular(100));
  }

  BoxDecoration simple() {
    return BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(100));
  }

  BoxDecoration select() {
    return BoxDecoration(
        color: Color(0xFF7C8EE5), borderRadius: BorderRadius.circular(100));
  }

  BoxDecoration error() {
    return BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(100),
    );
  }

  void getPinTitle() {
    pinTitle ="PIN-kodni kiriting";
  }
}

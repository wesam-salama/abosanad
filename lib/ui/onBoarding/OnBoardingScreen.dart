import 'package:easy_localization/easy_localization.dart' as easyLocal;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instachatty/constants.dart';
import 'package:instachatty/services/helper.dart';
import 'package:instachatty/ui/auth/AuthScreen.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _currentPageNotifier = ValueNotifier<int>(0);

final List<String> _titlesList = [
  easyLocal.tr('onBoardingTitle1'),
  'onBoardingTitle2'.tr(),
  'onBoardingTitle3'.tr(),
  'onBoardingTitle4'.tr()
];

final List<String> _subtitlesList = [
  'onBoardingSubtitle1'.tr(),
  'onBoardingSubtitle2'.tr(),
  'onBoardingSubtitle3'.tr(),
  'onBoardingSubtitle4'.tr()
];

final List<String> _imageList = [
  'assets/images/onboarding_one.svg',
  'assets/images/onboarding_two.svg',
  'assets/images/onboarding_three.svg',
  'assets/images/onboarding_four.svg'
];
final List<Widget> _pages = [];

List<Widget> populatePages(BuildContext context) {
  _pages.clear();
  _titlesList.asMap().forEach((index, value) => _pages.add(getPage(
      _imageList.elementAt(index),
      value,
      _subtitlesList.elementAt(index),
      context,
      _isLastPage(index + 1, _titlesList.length))));
  return _pages;
}

Widget _buildCircleIndicator() {
  return CirclePageIndicator(
    selectedDotColor: Colors.white,
    dotColor: Colors.white30,
    itemCount: _pages.length,
    currentPageNotifier: _currentPageNotifier,
  );
}

Widget getPage(String image, String title, String subTitle,
    BuildContext context, bool isLastPage) {
  return Stack(
    children: <Widget>[
      Center(
        child: Container(
          color: Color(COLOR_PRIMARY),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: new SvgPicture.asset(
                        image,
                        color: Colors.white,
                        width: 150.0,
                        height: 150.0,
                        fit: BoxFit.cover,
                      )),
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      subTitle,
                      style: TextStyle(color: Colors.white, fontSize: 14.0),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      Visibility(
        visible: isLastPage,
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Directionality.of(context) == TextDirection.ltr
                  ? Alignment.bottomRight
                  : Alignment.bottomLeft,
              child: OutlineButton(
                onPressed: () {
                  setFinishedOnBoarding();
                  pushReplacement(context, AuthScreen());
                },
                child: Text(
                  'continue',
                  style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ).tr(),
                borderSide: BorderSide(color: Colors.white),
                shape: StadiumBorder(),
              ),
            )),
      ),
    ],
  );
}

Future<bool> setFinishedOnBoarding() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setBool(FINISHED_ON_BOARDING, true);
}

bool _isLastPage(int currentPosition, int pagesNumber) {
  if (currentPosition == pagesNumber) {
    return true;
  } else {
    return false;
  }
}

class OnBoardingScreen extends StatefulWidget {
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  void dispose() {
    _currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        PageView(
          children: populatePages(context),
          onPageChanged: (int index) {
            _currentPageNotifier.value = index;
          },
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: _buildCircleIndicator(),
          ),
        )
      ],
    ));
  }
}

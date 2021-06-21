import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instachatty/constants.dart';
import 'package:instachatty/services/helper.dart';
import 'package:instachatty/ui/login/LoginScreen.dart';
import 'package:instachatty/ui/signUp/SignUpScreen.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 70.0, bottom: 20.0),
                child: SvgPicture.asset(
                  'assets/images/auth_image.svg',
                  width: 150.0,
                  height: 150.0,
                  color: Color(COLOR_PRIMARY),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 32, top: 32, right: 32, bottom: 8),
              child: Text(
                'welcome',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(COLOR_PRIMARY),
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold),
              ).tr(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'welcomeSubtitle',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ).tr(),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: RaisedButton(
                  color: Color(COLOR_PRIMARY),
                  child: Text(
                    'logIn',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ).tr(),
                  textColor: isDarkMode(context) ? Colors.black : Colors.white,
                  splashColor: Color(COLOR_PRIMARY),
                  onPressed: () {
                    push(context, LoginScreen());
                  },
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Color(COLOR_PRIMARY))),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  right: 40.0, left: 40.0, top: 20, bottom: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: FlatButton(
                  child: Text(
                    'signUp',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(COLOR_PRIMARY)),
                  ).tr(),
                  onPressed: () {
                    push(context, SignUpScreen());
                  },
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.black54)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

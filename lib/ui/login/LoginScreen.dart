import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' as fire;
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'package:instachatty/constants.dart';
import 'package:instachatty/main.dart';
import 'package:instachatty/model/User.dart';
import 'package:instachatty/services/FirebaseHelper.dart';
import 'package:instachatty/services/helper.dart';
import 'package:instachatty/ui/home/HomeScreen.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

final _fireStoreUtils = FireStoreUtils();

class LoginScreen extends StatefulWidget {
  @override
  State createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen> {
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  GlobalKey<FormState> _key = new GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  String email, password;
  bool signInWithPhoneNumber = false, _isPhoneValid = false, _codeSent = false;
  String _phoneNumber, _verificationID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
            color: isDarkMode(context) ? Colors.white : Colors.black),
        elevation: 0.0,
      ),
      body: Form(
        key: _key,
        autovalidateMode: _validate,
        child: ListView(
          children: <Widget>[
            Padding(
              padding:
              const EdgeInsets.only(top: 32.0, right: 16.0, left: 16.0),
              child: Text(
                'signIn',
                style: TextStyle(
                    color: Color(COLOR_PRIMARY),
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ).tr(),
            ),
            Visibility(
              visible: !signInWithPhoneNumber,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: Padding(
                  padding:
                  const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
                  child: TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      textInputAction: TextInputAction.next,
                      validator: validateEmail,
                      onSaved: (String val) {
                        email = val;
                      },
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                      controller: _emailController,
                      style: TextStyle(fontSize: 18.0),
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: Color(COLOR_PRIMARY),
                      decoration: InputDecoration(
                        contentPadding:
                        new EdgeInsets.only(left: 16, right: 16),
                        fillColor: Colors.white,
                        hintText: 'emailAddress'.tr(),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                                color: Color(COLOR_PRIMARY), width: 2.0)),
                        errorBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Theme
                              .of(context)
                              .errorColor),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Theme
                              .of(context)
                              .errorColor),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[200]),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      )),
                ),
              ),
            ),
            Visibility(
              visible: !signInWithPhoneNumber,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: double.infinity),
                child: Padding(
                  padding:
                  const EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
                  child: TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: _passwordController,
                      obscureText: true,
                      validator: validatePassword,
                      onSaved: (String val) {
                        password = val;
                      },
                      onFieldSubmitted: (password) =>
                          _login(_emailController.text, password),
                      textInputAction: TextInputAction.done,
                      style: TextStyle(fontSize: 18.0),
                      cursorColor: Color(COLOR_PRIMARY),
                      decoration: InputDecoration(
                        contentPadding:
                        new EdgeInsets.only(left: 16, right: 16),
                        fillColor: Colors.white,
                        hintText: 'password'.tr(),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                                color: Color(COLOR_PRIMARY),
                                width: 2.0)),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme
                              .of(context)
                              .errorColor),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme
                              .of(context)
                              .errorColor),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[200]),
                          borderRadius: BorderRadius.circular(25.0),
                        ),)),
                ),
              ),
            ),
            Visibility(
              visible: signInWithPhoneNumber && !_codeSent,
              child: Padding(
                padding: EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      shape: BoxShape.rectangle,
                      border:
                      Border.all(color: Colors.grey[200])),
                  child: InternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber number) =>
                      _phoneNumber = number.phoneNumber,
                      onInputValidated: (bool value) => _isPhoneValid = value,
                      ignoreBlank: true,
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                      inputDecoration: InputDecoration(
                        hintText: 'phoneNumber'.tr(),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        isDense: true,
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                      inputBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      initialValue: PhoneNumber(isoCode: 'US'),
                      selectorConfig: SelectorConfig(
                        selectorType: PhoneInputSelectorType
                            .DIALOG,)
                  ),),
              ),),
            Visibility(
              visible: signInWithPhoneNumber && _codeSent,
              child: Padding(
                padding:
                EdgeInsets.only(top: 32.0, right: 24.0, left: 24.0),
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  keyboardType: TextInputType.phone,
                  backgroundColor: Colors.transparent,
                  pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 40,
                      fieldWidth: 40,
                      activeColor: Color(COLOR_PRIMARY),
                      activeFillColor: Colors.grey[100],
                      selectedFillColor: Colors.transparent,
                      selectedColor: Color(COLOR_PRIMARY),
                      inactiveColor: Colors.grey[600],
                      inactiveFillColor: Colors.transparent),
                  enableActiveFill: true,
                  onCompleted: (v) {
                    _submitCode(v);
                  },
                  onChanged: (value) {
                    print(value);
                  },
                ),),),
            Visibility(
              visible: !signInWithPhoneNumber || !_codeSent,
              child: Padding(
                padding:
                const EdgeInsets.only(right: 40.0, left: 40.0, top: 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: double.infinity),
                  child: RaisedButton(
                    color: Color(COLOR_PRIMARY),
                    child: Text(
                      signInWithPhoneNumber ? 'sendCode'.tr() : 'logIn'.tr(),
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    textColor:
                    isDarkMode(context) ? Colors.black : Colors.white,
                    splashColor: Color(COLOR_PRIMARY),
                    onPressed: () =>
                    signInWithPhoneNumber
                        ? _submitPhoneNumber(_phoneNumber)
                        : _login(
                        _emailController.text, _passwordController.text),
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(color: Color(COLOR_PRIMARY))),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'or',
                  style: TextStyle(
                      color: isDarkMode(context) ? Colors.white : Colors.black),
                ).tr(),
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.only(right: 40.0, left: 40.0, bottom: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: RaisedButton.icon(
                  label: Expanded(
                    child: Text(
                      'facebookLogin',
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ).tr(),
                  ),
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.asset(
                      'assets/images/facebook_logo.png',
                      color: isDarkMode(context) ? Colors.black : Colors.white,
                      height: 30,
                      width: 30,
                    ),
                  ),
                  color: Color(FACEBOOK_BUTTON_COLOR),
                  textColor: isDarkMode(context) ? Colors.black : Colors.white,
                  splashColor: Color(FACEBOOK_BUTTON_COLOR),
                  onPressed: () async {
                    final facebookLogin = FacebookLogin();
                    final result = await facebookLogin.logIn(['email']);
                    switch (result.status) {
                      case FacebookLoginStatus.loggedIn:
                        showProgress(
                            context, 'loggingInPleaseWait'.tr(), false);
                        await auth.FirebaseAuth.instance
                            .signInWithCredential(
                                auth.FacebookAuthProvider.credential(
                                    result.accessToken.token))
                            .then((auth.UserCredential authResult) async {
                          User user = await _fireStoreUtils
                              .getCurrentUser(authResult.user.uid);
                          if (user == null) {
                            _createUserFromFacebookLogin(
                                result, authResult.user.uid);
                          } else {
                            _syncUserDataWithFacebookData(result, user);
                          }
                        });
                        break;
                      case FacebookLoginStatus.cancelledByUser:
                        break;
                      case FacebookLoginStatus.error:
                        showAlertDialog(
                            context, 'error'.tr(),
                            'couldNotLoginWithFacebook'.tr());
                        break;
                    }
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(
                          color: Color(FACEBOOK_BUTTON_COLOR))),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  signInWithPhoneNumber = !signInWithPhoneNumber;
                });
              },
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    signInWithPhoneNumber
                        ? 'loginWithEmail'.tr()
                        : 'loginWithPhoneNumber'.tr(),
                    style: TextStyle(
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _login(String email, String password) async {
    if (_key.currentState.validate()) {
      _key.currentState.save();
      showProgress(context, 'loggingInPleaseWait'.tr(), false);
      User user =
      await loginWithUserNameAndPassword(email.trim(), password.trim());
      if (user != null)
        pushAndRemoveUntil(context, HomeScreen(user: user), false);
    } else {
      setState(() {
        _validate = AutovalidateMode.onUserInteraction;
      });
    }
  }

  loginWithUserNameAndPassword(String email, String password) async {
    try {
      auth.UserCredential result = await auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      fire.DocumentSnapshot documentSnapshot = await FireStoreUtils.firestore
          .collection(USERS)
          .doc(result.user.uid)
          .get();
      User user;
      if (documentSnapshot != null && documentSnapshot.exists) {
        user = User.fromJson(documentSnapshot.data());
        user.active = true;
        user.fcmToken = await FireStoreUtils.firebaseMessaging.getToken();
        await FireStoreUtils.updateCurrentUser(user);
        hideProgress();
        MyAppState.currentUser = user;
      }
      return user;
    } on auth.FirebaseAuthException catch (exception) {
      hideProgress();
      switch ((exception).code) {
        case "invalid-email":
          showAlertDialog(context, 'Couldn\'t Authenticate'.tr(),
              'Email address is malformed.'.tr());
          break;
        case "wrong-password":
          showAlertDialog(
              context, 'Couldn\'t Authenticate'.tr(), 'Wrong password.'.tr());
          break;
        case "user-not-found":
          showAlertDialog(context, 'Couldn\'t Authenticate'.tr(),
              'No user corresponding to the given email address.'.tr());
          break;
        case "user-disabled":
          showAlertDialog(
              context, 'Couldn\'t Authenticate'.tr(),
              'This user has been disabled.'.tr());
          break;
        case 'too-many-requests':
          showAlertDialog(
              context,
              'Couldn\'t Authenticate'.tr(),
              'Too many requests, Please try again later.'.tr());
          break;
      }
      print(exception.toString());
      return null;
    } catch (e) {
      hideProgress();
      showAlertDialog(context, 'Couldn\'t Authenticate'.tr(),
          'Login failed. Please try again.'.tr());
      print(e.toString());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _createUserFromFacebookLogin(FacebookLoginResult result,
      String userID) async {
    final token = result.accessToken.token;
    final graphResponse = await http.get('https://graph.facebook.com/v2'
        '.12/me?fields=name,first_name,last_name,email,picture.type(large)&access_token=$token');
    final profile = json.decode(graphResponse.body);
    User user = User(
        firstName: profile['first_name'],
        lastName: profile['last_name'],
        email: profile['email'],
        profilePictureURL: profile['picture']['data']['url'],
        fcmToken: await FireStoreUtils.firebaseMessaging.getToken(),
        active: true,
        userID: userID);
    await FireStoreUtils.firestore
        .collection(USERS)
        .doc(userID)
        .set(user.toJson())
        .then((onValue) {
      MyAppState.currentUser = user;
      hideProgress();
      pushAndRemoveUntil(context, HomeScreen(user: user), false);
    });
  }

  void _syncUserDataWithFacebookData(FacebookLoginResult result,
      User user) async {
    final token = result.accessToken.token;
    final graphResponse = await http.get('https://graph.facebook.com/v2'
        '.12/me?fields=name,first_name,last_name,email,picture.type(large)&access_token=$token');
    final profile = json.decode(graphResponse.body);
    user.profilePictureURL = profile['picture']['data']['url'];
    user.firstName = profile['first_name'];
    user.lastName = profile['last_name'];
    user.email = profile['email'];
    user.active = true;
    user.fcmToken = await FireStoreUtils.firebaseMessaging.getToken();
    await FireStoreUtils.updateCurrentUser(user);
    MyAppState.currentUser = user;
    hideProgress();
    pushAndRemoveUntil(context, HomeScreen(user: user), false);
  }

  void _createUserFromPhoneLogin(String userID) async {
    User user = User(
        firstName: 'Anonymous',
        lastName: 'User',
        email: '',
        profilePictureURL: '',
        active: true,
        fcmToken: await FireStoreUtils.firebaseMessaging.getToken(),
        lastOnlineTimestamp: fire.Timestamp.now(),
        phoneNumber: _phoneNumber,
        settings: Settings(allowPushNotifications: true),
        userID: userID);
    await FireStoreUtils.firestore
        .collection(USERS)
        .doc(userID)
        .set(user.toJson())
        .then((onValue) {
      MyAppState.currentUser = null;
      MyAppState.currentUser = user;
      hideProgress();
      pushAndRemoveUntil(context, HomeScreen(user: user), false);
    });
  }

  _submitPhoneNumber(String phoneNumber) {
    if (_isPhoneValid) {
      //send code
      setState(() {
        _codeSent = true;
      });
      auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
      _auth.verifyPhoneNumber(phoneNumber: phoneNumber,
          timeout: Duration(minutes: 2),
          verificationCompleted: (auth.AuthCredential phoneAuthCredential) {},
          verificationFailed: (auth.FirebaseAuthException error) {
            print('${error.message}');
          },
          codeSent: (String verificationId, [int forceResendingToken]) {
            _verificationID = verificationId;
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _scaffoldKey.currentState.showSnackBar(
                SnackBar(content: Text('codeTimeOut').tr()));
            setState(() {
              _codeSent = false;
            });
          });
    }
  }
  void _submitCode(String code) async {
    showProgress(context, 'Logging in...', false);
    try {
      auth.AuthCredential credential = auth.PhoneAuthProvider.credential(
          verificationId: _verificationID, smsCode: code);
      await auth.FirebaseAuth.instance.signInWithCredential(
          credential).then((auth.UserCredential authResult) async {
        User user = await _fireStoreUtils
            .getCurrentUser(authResult.user.uid);
        if (user == null) {
          _createUserFromPhoneLogin(authResult.user.uid);
        } else {
          MyAppState.currentUser = user;
          hideProgress();
          pushAndRemoveUntil(context, HomeScreen(user: user), false);
        }
      });
    } on auth.FirebaseAuthException catch (exception) {
      hideProgress();
      String message = 'An error has occurred, please try again.';
      switch (exception.code) {
        case 'invalid-verification-code':
          message = 'Invalid code or has been expired.'.tr();
          break;
        case "user-disabled":
          message = 'This user has been disabled.'.tr();
          break;
        default:
          message = 'An error has occurred, please try again.'.tr();
          break;
      }
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      hideProgress();
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(
              content: Text('An error has occurred, please try again.'.tr())));
    }
  }
}
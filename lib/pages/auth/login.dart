import 'dart:convert';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:vapual/components/form/botton_widget.dart';
import 'package:vapual/components/form/text_input_widget.dart';
import 'package:vapual/components/logo.dart';
import 'package:vapual/config/app.dart';
import 'package:vapual/pages/auth/create_account.dart';
import 'package:vapual/pages/tabs/account.dart';
import 'package:vapual/pages/webview2.dart';
import 'package:vapual/utils/Providers.dart';
import 'package:vapual/utils/network.dart';
import 'package:vapual/utils/app_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../dashboard.dart';

class Login extends HookWidget {
  final String anchor;
  const Login({Key? key, this.anchor = ""}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final email = useTextEditingController();
    final password = useTextEditingController();
    final loading = useState(false);
    final account = useProvider(accountProvider);
    final token = useProvider(userTokenProvider);
    final color = useProvider(colorProvider);

    completeLogin(data) async {
      data['logged_in'] = true;
      account.state = data;
      var box = await Hive.openBox('appBox');
      box.put('account', json.encode(data));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Account()),
      );
    }

    createAccount(formData, mode) async {
      try {
        loading.value = true;
        var response = await Network().simplePost("/users/register", formData);
        var body = json.decode(response.body);
        if (body['code'] != null && body['code'] == 200) {
          AppAction().newToastSuccess(context, "Account created successfully.");
          Map data = body['user'];
          data['login_type'] = 'social';
          data['login_mode'] = mode;
          completeLogin(data);
        } else {
          loading.value = false;
          AppAction().newToastError(context, "${body['message']}");
        }
      } catch (e) {
        print(e);
        AppAction().newToastError(
            context, "Unable to log in, check your internet connection.");
        loading.value = false;
      }
    }

    continueSignup(data, mode) async {
      try {
        loading.value = true;
        var response = await Network()
            .simplePost("/users/profile", {"email": data['email']});
        var body = json.decode(response.body);
        if (body['user'] != null && body['user']['id'] != null) {
          Map data = body['user'];
          data['login_type'] = 'social';
          data['login_mode'] = mode;
          completeLogin(data);
        } else {
          createAccount(data, mode);
        }
      } catch (e) {
        print(e);
        AppAction().newToastError(
            context, "Unable to log in, check your internet connection.");
        loading.value = false;
      }
    }

    signInWithGoogle() async {
      loading.value = true;
      GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly'],
      );
      try {
        await _googleSignIn.signIn();
        List names = _googleSignIn.currentUser!.displayName!.split(' ');
        var data = {
          'first_name': names[0],
          'last_name': names.length > 1 ? names[1] : '',
          'email': _googleSignIn.currentUser!.email,
          "billing": {
            "first_name": names[0],
            "last_name": names.length > 1 ? names[1] : '',
            "email": _googleSignIn.currentUser!.email,
          }
        };

        continueSignup(data, 'google');
      } catch (error) {
        print("errorrr: $error");
        AppAction().newToastError(context, "Unable to log in.");
        loading.value = false;
      }
    }

    signInWithFacebook() async {
      loading.value = true;
      try {
        final LoginResult result = await FacebookAuth.instance.login();
        if (result.status == LoginStatus.success) {
          // you are logged
          // final AccessToken accessToken = result.accessToken!;
          final userData = await FacebookAuth.i.getUserData(
              fields: "first_name,last_name,email,picture.width(200)");
          var data = {
            'first_name': userData['first_name'],
            'last_name': userData['last_name'],
            'email': userData['email'],
            "avatar_urls": {"96": userData['picture']}
          };

          continueSignup(data, 'facebook');
        } else {
          print("tet: ${result.message}");
          AppAction().newToastError(context, "Unable to log in.");
          loading.value = false;
        }
      } catch (e) {
        print("errorrr: $e");
        AppAction().newToastError(context, "Unable to log in.");
        loading.value = false;
      }
    }

    getUser(String thisemail, String tk) async {
      try {
        var response = await Network().simpleGetToken("users/me", tk);
        var body = json.decode(response.body);
        print(body);
        if (response.statusCode == 200) {
          AppAction().newToastSuccess(context, "Successfully logged in.");
          body['email'] = thisemail;
          body['logged_in'] = true;
          account.state = body;
          token.state = tk;
          var box = await Hive.openBox('appBox');
          box.put('account', json.encode(body));
          box.put('token', tk);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Account()),
          );
          loading.value = false;
        } else {
          loading.value = false;
          AppAction().newToastError(context, "Profile not found");
        }
      } catch (e) {
        print(e);
        AppAction().newToastError(
            context, "Unable to log in, check your internet connection.");
        loading.value = false;
      }
    }

    login() async {
      //
      try {
        if (email.text.length > 0 && password.text.length > 0) {
          var formData = {
            "username": email.text,
            "password": password.text,
          };

          loading.value = true;
          var response = await Network().postAuth(formData);
          var body = json.decode(response.body);
          if (response.statusCode == 200) {
            getUser(body["user_email"], body["token"]);
          } else {
            print(body["message"]);
            AppAction().newToastError(context,
                "${body["message"].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '')}");
            loading.value = false;
          }
        } else {
          AppAction().newToastError(context, "Both fields are required");
        }
      } catch (e) {
        print(e);
        AppAction().newToastError(
            context, "Unable to log in, check your internet connection.");
        loading.value = false;
      }
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          color: color.state == 'dark' ? primaryDark : Colors.white,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(top: 90, left: 25, right: 25),
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
       
                  Row(
                    children: [
                      InkWell(
      onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: EdgeInsets.only(left: 10),
                    child: SvgPicture.asset(
                      iconsPath + "arrow-left.svg",
                      color: Color(0xFF282828),
                      width: 20,
                    ),
                  ),
                      )
                    ],
                  ),
           
                ],
              ),
                            SizedBox(height: 50),
              Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                children: [
                        LogoWidget(20, color.state == 'dark' ? "dark" : "light"),
                ],

              ),

              SizedBox(height: 50),
              TextInputWidget(
                controller: email,
                placeholder: "Username or Email address",
                position: 0,
              ),
              SizedBox(height: 30),
              TextInputWidget(
                controller: password,
                placeholder: "Password",
                isPassword: true,
                position: 2,
              ),
              SizedBox(height: 20),
              Opacity(
                  opacity: loading.value ? 0.38 : 1,
                  child: ButtonWidget(
                      action: loading.value ? () => {} : login,
                      text: loading.value ? "Please wait..." : "Login")),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Have no account?",
                    style: TextStyle(
                        color: color.state == 'dark'
                            ? Color(0xFFA19E9C)
                            : Color(0xFF9A9FAC)),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateAccount(anchor: anchor)),
                    ),
                    child: Text(
                      "Create Account",
                      style: TextStyle(
                          color: colorPrimary, fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
              SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Forgot password?.",
                    style: TextStyle(color: Color(0xFF595959)),
                  ),
                  new InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return WebViewPage2();
                      }));
                    },
                    child: new Padding(
                      padding: new EdgeInsets.all(10.0),
                      child: new Text("Click here"),
                    ),
                  )
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: loading.value ? () => {} : signInWithFacebook,
                    child: Opacity(
                      opacity: loading.value ? 0.38 : 1,
                    ),
                  ),
                  // SizedBox(width: 10),
                  // InkWell(
                  //   onTap: loading.value ? () => {} : signInWithGoogle,
                  //   child: Opacity(
                  //     opacity: loading.value ? 0.38 : 1,
                  //     child: Container(
                  //       padding:
                  //           EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  //       decoration: BoxDecoration(
                  //           border: Border.all(
                  //             color: color.state == 'dark'
                  //                 ? darkModeText
                  //                 : Color(0xFF404040),
                  //           ),
                  //           borderRadius: BorderRadius.circular(4)),
                  //       child: Row(
                  //         children: [
                  //           Image.asset(iconsPath + 'google.png', height: 22),
                  //           SizedBox(width: 5),
                  //           Text(
                  //             "Google",
                  //             style: TextStyle(
                  //                 color: color.state == 'dark'
                  //                     ? darkModeText
                  //                     : Color(0xFF404040),
                  //                 fontSize: 14),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }
}

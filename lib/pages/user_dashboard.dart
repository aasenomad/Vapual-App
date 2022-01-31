import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vapual/config/app.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({ Key? key }) : super(key: key);

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  WebViewController? controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: EdgeInsets.only(left: 20),
                    child: SvgPicture.asset(
                      iconsPath + "arrow-left.svg",
                      color: Color(0xFF282828),
                      width: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Post & Dashboard"),
                    ],
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
            Expanded(
              child: WebView(
                gestureNavigationEnabled: true,
                initialUrl: 'https://chinblog.com/wp-admin/',
                javascriptMode: JavascriptMode.unrestricted,
                onPageFinished: (url) {
                  if (url.contains('wp-admin')) {
                    WebviewCookieManager()
                        .getCookies('https://chinblog.com')
                        .then((cookies) {
                      SharedPreferences.getInstance().then((sp) {
                        cookies = cookies
                            .toList(); //.where((e) => (e.name.contains('wordpress_logged') || e.name.contains('_sec'))).toList();
                        if (cookies.isNotEmpty) {
                          sp.setStringList(
                              'cookies', cookies.map((e) => e.name).toList());
                          for (var cookie in cookies) {
                            sp.setString(cookie.name, cookie.value);
                          }
                        }
                        print('SAVED ${cookies.length} cookies');
                      });
                    });
                  }
                },
                onWebViewCreated: (controller) {
                  this.controller = controller;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
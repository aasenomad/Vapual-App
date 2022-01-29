import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vapual/config/app.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage2 extends StatelessWidget {
  const WebViewPage2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                      Text("Reset Password"),
                    ],
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
            Expanded(
              child: Center(
                child: WebView(
                  initialUrl: "https://chinblog.com/wp-login.php?action=lostpassword", javascriptMode: JavascriptMode.unrestricted,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

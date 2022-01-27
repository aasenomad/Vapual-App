import 'package:vapual/components/provider_files.dart';
import 'package:vapual/config/app.dart';
import 'package:vapual/pages/categories/subCategories.dart';
import 'package:vapual/pages/tabs/account.dart';
import 'package:vapual/pages/tabs/bookmarks.dart';
import 'package:vapual/pages/tabs/categories.dart';
import 'package:vapual/pages/tabs/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart' as provider;

import 'tabs/home.dart';
import 'tabs/partials/animated_bottom_bar.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  late PersistentTabController controller;
  late double timeDilation;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          iconsPath + "home.svg",
          color: Colors.deepOrange,
        ),
        inactiveIcon: SvgPicture.asset(
          iconsPath + "home.svg",
          color: Colors.grey,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(iconsPath + "collection.svg",
            color: Colors.deepOrange),
        inactiveIcon: SvgPicture.asset(
          iconsPath + "collection.svg",
          color: Colors.grey,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(iconsPath + "search.svg",
            color: Colors.deepOrange),
        inactiveIcon: SvgPicture.asset(
          iconsPath + "search.svg",
          color: Colors.grey,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(iconsPath + "bookmark.svg",
            color: Colors.deepOrange),
        inactiveIcon: SvgPicture.asset(
          iconsPath + "bookmark.svg",
          color: Colors.grey,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          iconsPath + "user-circle.svg",
          color: Colors.deepOrange,
        ),
        inactiveIcon: SvgPicture.asset(
          iconsPath + "user-circle.svg",
          color: Colors.grey,
        ),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    controller = PersistentTabController(initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    provider.Provider.of<ProviderFiles>(context).themeGetter();

    return Scaffold(
      key: _scaffoldKey,
      body: PersistentTabView(
        context,
        controller: controller,
        confineInSafeArea: true,
        backgroundColor:
            provider.Provider.of<ProviderFiles>(context, listen: true)
                    .themeSwitch
                ? Colors.white
                : Colors.black,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        navBarStyle: NavBarStyle.simple,
        items: _navBarsItems(),
        screens: [
          Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              child: Home()),
          Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              child: Categories()),
          Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              child: Search()),
          Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              child: Bookmarks()),
          Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              child: Account()),
        ],
      ),
    );
  }
}

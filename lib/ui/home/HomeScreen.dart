import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instachatty/constants.dart';
import 'package:instachatty/model/User.dart';
import 'package:instachatty/services/helper.dart';
import 'package:instachatty/ui/contacts/ContactsScreen.dart';
import 'package:instachatty/ui/conversations/ConversationsScreen.dart';
import 'package:instachatty/ui/createGroup/CreateGroupScreen.dart';
import 'package:instachatty/ui/profile/ProfileScreen.dart';
import 'package:instachatty/ui/search/SearchScreen.dart';
import 'package:provider/provider.dart';

enum DrawerSelection { Conversations, Contacts, Search, Profile }

class HomeScreen extends StatefulWidget {
  final User user;

  HomeScreen({Key key, @required this.user}) : super(key: key);

  @override
  _HomeState createState() {
    return _HomeState(user);
  }
}

class _HomeState extends State<HomeScreen> {
  final User user;
  DrawerSelection _drawerSelection = DrawerSelection.Conversations;
  String _appBarTitle = tr('conversations');

  _HomeState(this.user);

  Widget _currentWidget;

  @override
  void initState() {
    super.initState();
    _currentWidget = ConversationsScreen(
      user: user,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: user,
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Consumer<User>(
                builder: (context, user, _) {
                  return DrawerHeader(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        displayCircleImage(user.profilePictureURL, 75, false),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            user.fullName(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              user.email,
                              style: TextStyle(color: Colors.white),
                            )),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Color(COLOR_PRIMARY),
                    ),
                  );
                },
              ),
              ListTile(
                selected: _drawerSelection == DrawerSelection.Conversations,
                title: Text('conversations').tr(),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _drawerSelection = DrawerSelection.Conversations;
                    _appBarTitle = 'conversations'.tr();
                    _currentWidget = ConversationsScreen(
                      user: user,
                    );
                  });
                },
                leading: Icon(Icons.chat_bubble),
              ),
              ListTile(
                  selected: _drawerSelection == DrawerSelection.Contacts,
                  leading: Icon(Icons.contacts),
                  title: Text('contacts').tr(),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _drawerSelection = DrawerSelection.Contacts;
                      _appBarTitle = 'contacts'.tr();
                      _currentWidget = ContactsScreen(
                        user: user,
                      );
                    });
                  }),
              ListTile(
                  selected: _drawerSelection == DrawerSelection.Search,
                  title: Text('search').tr(),
                  leading: Icon(Icons.search),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _drawerSelection = DrawerSelection.Search;
                      _appBarTitle = 'search'.tr();
                      _currentWidget = SearchScreen(
                        user: user,
                      );
                    });
                  }),
              ListTile(
                selected: _drawerSelection == DrawerSelection.Profile,
                leading: Icon(Icons.account_circle),
                title: Text('profile').tr(),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _drawerSelection = DrawerSelection.Profile;
                    _appBarTitle = 'profile'.tr();
                    _currentWidget = ProfileScreen(
                      user: user,
                    );
                  });
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text(
            _appBarTitle,
            style: TextStyle(
                color:
                    isDarkMode(context) ? Colors.grey.shade200 : Colors.white,
                fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            _appBarTitle == 'conversations'.tr()
                ? IconButton(
              icon: Icon(Icons.message),
              onPressed: () {
                push(context, CreateGroupScreen());
              },
              color: isDarkMode(context)
                  ? Colors.grey.shade200
                  : Colors.white,
                  )
                : Container(
                    height: 0,
                    width: 0,
                  )
          ],
          iconTheme: IconThemeData(
              color: isDarkMode(context) ? Colors.grey.shade200 : Colors.white),
          backgroundColor: Color(COLOR_PRIMARY),
          centerTitle: true,
        ),
        body: _currentWidget,
      ),
    );
  }
}

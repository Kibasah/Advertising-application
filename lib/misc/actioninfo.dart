import 'package:flutter/material.dart';

class ActionInfo {
  final String id;
  final Icon icon;
  final String text;
  final Function func;

  const ActionInfo(
      {required this.id,
      required this.text,
      required this.icon,
      required this.func});
}

List<ActionInfo> _actions() => [
      ActionInfo(
        id: '_info',
        text: 'Info',
        icon: Icon(Icons.info_outlined),
        func: () => print('Info'),
      ),
      ActionInfo(
        id: '_settings',
        text: 'Settings',
        icon: Icon(Icons.settings),
        func: () => print('Settings'),
      ),
      ActionInfo(
        id: '_me',
        text: 'Me',
        icon: Icon(Icons.person),
        func: () => print('Me'),
      ),
    ];

class XActionInfo {}

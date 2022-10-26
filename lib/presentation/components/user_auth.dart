import 'package:flutter/material.dart';

import '../../domain/authentication/firebase_authentication.dart';

class UserAuth extends StatefulWidget {
  final FirebaseAuthentication _fbAuth = FirebaseAuthentication();
  final Widget child;

  UserAuth({
    super.key,
    required this.child,
  });

  @override
  State<UserAuth> createState() => _UserAuthState();
}

class _UserAuthState extends State<UserAuth> {
  @override
  void initState() {
    widget._fbAuth.anonymousAuth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

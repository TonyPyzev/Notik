import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(NotikApp());
}

//TODO question: spalsh screen not working
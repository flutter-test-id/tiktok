import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:tiktok/constants.dart';
import 'package:tiktok/controller/auth_controller.dart';
//import 'package:tiktok/views/screens/auth/login_screen.dart';
import 'package:tiktok/views/screens/auth/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.app().delete();
  await Firebase.initializeApp(
    options: const FirebaseOptions(apiKey: "AIzaSyB5pYHzDafPAeCQbHDkYKQOPPGlRSUvSIo", 
    appId: "1:423913948926:android:890b7f437d2772be7847af", 
    messagingSenderId: 'messagingSenderId', 
    projectId: "tiktok-48c2f",
    storageBucket: 'tiktok-48c2f.appspot.com'
    )
  );
  // .then((value) =>);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      
     Get.put(AuthController());
    });
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tiktok',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor
      ),
      home: SignupScreen(),
      
    );
  }
}


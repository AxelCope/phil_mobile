 import 'package:flutter/material.dart';
 import 'package:phil_mobile/pages/consts.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  // @override
  // void initState()
  // {
  //   super.initState();
  //   Timer(const Duration(seconds: 4),
  //           ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const LoginPage() )));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(philLogo, scale: 1.5,),
            const SizedBox(height: 70,),
            Center(child: CircularProgressIndicator(color: Colors.green,),)

          ],
        ),
      ),
    );
  }
}
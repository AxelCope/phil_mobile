import 'package:flutter/material.dart';
import 'package:phil_mobile/pages/login/login.dart';
import 'package:phil_mobile/pages/splash/splashscreen.dart';
import 'package:genos_dart/genos_dart.dart';
import 'package:phil_mobile/provider/queries_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (BuildContext context) {  },
    child: const MyApp(),));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _genosInit = true;
  late final QueriesProvider _provider;
  bool gotData = true;
  bool getDataError = false;

  //late Widget _initialContent;

  @override
  void initState() {
    super.initState();
    _initGenos();
    _initProvider();
  }

  void _initProvider() async{
    _provider = await QueriesProvider.instance;
    checkDatabase();
  }

  @override
  Widget build(BuildContext context) {
    if (_genosInit) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
  Future<void> _initGenos() async {
    Genos.instance
        .initialize(
        appSignature: '91a2dbf0-292d-11ed-91f1-4f98460f463c',
        appWsSignature: '91a2dbf0-292d-11ed-91f1-4f98460f464c',
        appPrivateDirectory: '.',
        encryptionKey: '91a2dbf0-292d-11ed-91f1-4f98460d',
        host: '192.168.0.110',
        port: '8080',
        unsecurePort: '80',
        dbms: DBMS.postgres,
        onInitialization: (ge) async {
          setState(() {
            _genosInit = false;
          });
        },
    );
  }

  Future<void> checkDatabase() async {
    await _provider.checkDatabase(
      secure: false,
      onSuccess: (r) {
        setState(() {
          print("Connected");
        });
      },
      onError: (e) {
        setState(() {
          print(e);
        });
      },
    );
  }



  void shoErrorDialog(BuildContext context) async {
    showDialog<String>(
      context: context,
      builder: (context) =>
      const AlertDialog(
        title: Text("Erreur de connexion"),
        content: Text("Ressayez de vous connecter"),
      )
    );
  }

}


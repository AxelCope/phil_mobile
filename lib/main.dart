import 'package:flutter/material.dart';
import 'package:phil_mobile/pages/login/login.dart';
import 'package:genos_dart/genos_dart.dart';
import 'package:phil_mobile/provider/queries_provider.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(create: (BuildContext context) {  },
    child: const MyApp(),));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _genosInit = false;
  bool gotData = true;
  bool getDataError = false;

  //late Widget _initialContent;

  @override
  void initState() {
    super.initState();
    _initGenos();
  }


  @override
  Widget build(BuildContext context) {
    if (!_genosInit) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MyLoadingScreen(),
      );
    }
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: LoginPage(),
        );
  }
  Future<void> _initGenos() async {
    Genos.instance
        .initialize(
        appSignature: '91a2dbf0-292d-11ed-91f1-4f98460f463c',
        appWsSignature: '91a2dbf0-292d-11ed-91f1-4f98460f464c',
        appPrivateDirectory: '.',
        encryptionKey: '91a2dbf0-292d-11ed-91f1-4f98460d',
        host: '192.168.1.66',
        port: '8080',
        unsecurePort: '80',
        dbms: DBMS.postgres,
        onInitialization: (ge) async {
          setState(() {
            _genosInit = true;
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

class MyLoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 20),
            Text(
              'Chargement',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/pages/accueil/accueil.dart';
import 'package:phil_mobile/pages/login/login.dart';
import 'package:genos_dart/genos_dart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(CommsAdapter());
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (BuildContext context){},
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _genosInit = false;

  @override
  void initState() {
    super.initState();
    _initGenos();
    _checkLoggedIn();
  }
  Widget _initialContent = MyLoadingScreen();

  Future<void> _checkLoggedIn() async {
    final box = await Hive.openBox('commsBox');
    Comms? storedComms = box.get('user') as Comms?;

    setState(() {
      _initialContent = storedComms != null
          ? HomePage(comm: storedComms)
          : const LoginPage();
    });

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
      home: _initialContent,
    );
  }

  Future<void> _initGenos() async {
    Genos.instance.initialize(
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
          _genosInit = true;
        });
      },
    );
  }

  void showErrorDialog() async {
    showDialog<String>(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text("Erreur de connexion"),
        content: Text("Ressayez de vous connecter"),
      ),
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
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chargement',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phil_mobile/models/model_version.dart';
import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/pages/accueil/page_acceuil.dart';
import 'package:phil_mobile/pages/login/page_connexion.dart';
import 'package:genos_dart/genos_dart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:phil_mobile/provider/queries_provider.dart';
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
  bool _sameVers = true;
  bool connected = true;
  bool _checkingComplete = false;
  List<Versioning> version = [];
  late final QueriesProvider _provider;
  Widget _initialContent = const MyLoadingScreen();


  Future<void> _checkLoggedIn() async {
    final box = await Hive.openBox('commsBox');
    Comms? storedComms = box.get('user') as Comms?;

    setState(() {
      _initialContent = storedComms != null
          ? HomePage(comm: storedComms)
          : const LoginPage();
    });

    if(storedComms != null)
    {
      checkInternetConnection(context);
    }
  }



  @override
  void initState() {
    super.initState();
    _initGenos();
    _checkLoggedIn();
  }

  void _initProvider() async {
    _provider = await QueriesProvider.instance;
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (connected == false) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: AlertDialog(
            title: const Text('Connexion Internet non disponible'),
            content: const Text('Vérifiez votre connexion internet et réessayez.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );
    } else if (!_sameVers && _checkingComplete && connected == true) {
      return const VersionDialog();
    }


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _initialContent,
    );
  }

  Future<void> _initGenos() async {
    Genos.instance.initialize(
      appSignature: '91a2dbf0-292d-11ed-91f1-4f98460f463c',
      appWsSignature: '91a2dbf0-292d-11ed-91f1-4f98460f464c',
      appPrivateDirectory: '.',
      encryptionKey: '91a2dbf0-292d-11ed-91f1-4f98460d',
      host: '57.129.6.235',
      port: '8080',
      unsecurePort: '80',
      dbms: DBMS.postgres,
      onInitialization: (ge) async {
        setState(() {
          _genosInit = true;
        });
        _initProvider();
      },
    );
  }


  Future<void> checkInternetConnection(BuildContext context) async {
    final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();


    if(connectivityResult[0] == ConnectivityResult.none) {
      connected = false;
    } else{
      connected = true;
    }
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    await _provider.version(
      secure: false,
      onSuccess: (cms) {
        setState(() {
          for (var element in cms) {
            version.add(Versioning.MapVersion(element));
          }
          checkingVersion();
        });
      },
      onError: (error) {
        setState(() {
        });
      },
    );
  }

  Future<void> checkingVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final localVersion = packageInfo.version;
    final fetchedVersion = version.isNotEmpty ? version[0].version : '';

    if(version.isNotEmpty)
    {
      if (localVersion != fetchedVersion) {
        _sameVers = false;
      }
    }else{
      setState(() {
        AlertDialog(
          title: const Text('Connexion Internet non disponible'),
          content: const Text('Vérifiez votre connexion internet et réessayez.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                version.clear();
                _checkVersion();
              },
              child: const Text('OK'),
            ),
          ],
        );
      });
    }

    _checkingComplete = true;
    setState(() {});
  }


}

class MyLoadingScreen extends StatelessWidget {
  const MyLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
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

class VersionDialog extends StatelessWidget {
  const VersionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: AlertDialog(
          title: Text('Nouvelle version disponible'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Une nouvelle version de l\'application est disponible.'),
              SizedBox(height: 10),
              Text(
                  'Veuillez installer la nouvelle version pour continuer à utiliser l\'application.'),
            ],
          ),
        ),
      ),
    );
  }
}


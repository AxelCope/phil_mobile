import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
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
import 'package:onesignal_flutter/onesignal_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  OneSignal.initialize("20c39325-5e9b-4e03-ae75-f203a70b6ca3");
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose); // Pour le débogage, retirez en production

  // Demander la permission de notification
  await OneSignal.Notifications.requestPermission(true);

  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    print("Notification reçue : ${event.notification.body}");
    // Optionnel : empêcher l'affichage automatique de la notification
    // event.preventDefault();
    event.notification.display();
  });

  // Gestionnaire pour les clics sur les notifications
  OneSignal.Notifications.addClickListener((OSNotificationClickEvent event) {
    print("Notification cliquée : ${event.notification.body}");
    // Optionnel : naviguer vers PageTransactions
    // Nécessite un Navigator global ou un contexte
  });

  // 🔹 Init Hive
  await Hive.initFlutter();
  Hive.registerAdapter(CommsAdapter());

  // 🔹 Init Firebase (obligatoire avant tout usage de services Firebase)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );  // :contentReference[oaicite:1]{index=1}

  runApp(
    ChangeNotifierProvider(
      create: (BuildContext context) {},
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
  bool _checkingComplete = false;
  bool connected = true;

  List<Versioning> version = [];
  Widget _initialContent = const MyLoadingScreen();

  late final QueriesProvider _provider;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _initGenos();
    await checkInternetConnection();
    if (connected) {
      await _checkVersion();
    }
    await _checkLoggedIn();
  }

  Future<void> _initGenos() async {
    try {
      await Genos.instance.initialize(
        appSignature: '91a2dbf0-292d-11ed-91f1-4f98460f463c',
        appWsSignature: '91a2dbf0-292d-11ed-91f1-4f98460f464c',
        appPrivateDirectory: '.',
        encryptionKey: '91a2dbf0-292d-11ed-91f1-4f98460d',
        host: '57.129.6.235',
        port: '8080',
        unsecurePort: '80',
        dbms: DBMS.postgres,
        onInitialization: (ge) async {
          debugPrint("Genos initialized successfully");
          _provider = await QueriesProvider.instance;
          if (_provider == null) {
            debugPrint("Provider initialization failed");
            _genosInit = false;
          } else {
            debugPrint("Provider initialized successfully");
            _genosInit = true;
          }
        },
      );
    } catch (e) {
      debugPrint("Genos initialization error: $e");
      _genosInit = false;
      setState(() {
        _initialContent = _buildError(
          'Erreur d\'initialisation',
          'Échec de l\'initialisation de Genos: $e',
        );
      });
    }
  }

  Future<void> checkInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    connected = result != ConnectivityResult.none;
  }

  Future<void> _checkVersion() async {
    if (!_genosInit) {
      setState(() {
        _checkingComplete = true;
        _sameVers = true;
        _initialContent = _buildError(
          'Erreur d\'initialisation',
          'Genos ou le provider n\'est pas initialisé.',
        );
      });
      return;
    }

    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        await _provider.version(
          secure: false,
          onSuccess: (cms) {
            version = cms.map((e) => Versioning.MapVersion(e)).toList();
            _compareVersions();
          },
          onError: (error) {
            debugPrint("Attempt $attempt failed: Erreur version : $error");
            if (attempt == 3) {
              setState(() {
                _checkingComplete = true;
                _sameVers = true;
                _initialContent = _buildError(
                  'Erreur de version',
                  'Impossible de vérifier la version après plusieurs tentatives.',
                );
              });
            }
          },
        );
        return;
      } catch (e) {
        debugPrint("Attempt $attempt exception: $e");
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  void _compareVersions() async {
    final pkg = await PackageInfo.fromPlatform();
    final localVersion = pkg.version;
    final fetchedVersion = version.isNotEmpty ? version[0].version : '';
    if (fetchedVersion!.isNotEmpty && localVersion != fetchedVersion) {
      _sameVers = false;
    }
    _checkingComplete = true;
    setState(() {});
  }

  Future<void> _checkLoggedIn() async {
    final box = await Hive.openBox('commsBox');
    final storedComms = box.get('user') as Comms?;
    setState(() {
      _initialContent =
      storedComms != null ? HomePage(comm: storedComms) : const LoginPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (!connected) {
      return _buildError(
        'Connexion Internet non disponible',
        'Vérifiez votre connexion internet et réessayez.',
      );
    }

    if (!_sameVers && _checkingComplete) {
      return const VersionDialog();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _initialContent,
    );
  }

  Widget _buildError(String title, String content) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => SystemNavigator.pop(),
              child: const Text("Fermer"),
            ),
          ],
        ),
      ),
    );
  }
}

class MyLoadingScreen extends StatelessWidget {
  const MyLoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 20),
            Text(
              'Chargement',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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
              Text('Veuillez installer la nouvelle version pour continuer à utiliser l\'application.'),
            ],
          ),
        ),
      ),
    );
  }
}

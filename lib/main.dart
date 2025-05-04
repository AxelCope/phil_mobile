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
    await _initGenos(); // init Genos + Provider
    await checkInternetConnection(); // check connection
    if (connected) {
      await _checkVersion(); // fetch version
    }
    await _checkLoggedIn(); // show home or login
  }

  Future<void> _initGenos() async {
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
        _provider = await QueriesProvider.instance;
        _genosInit = true;
      },
    );
  }

  Future<void> checkInternetConnection() async {
    final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
    connected = connectivityResult.isNotEmpty && connectivityResult[0] != ConnectivityResult.none;
  }

  Future<void> _checkVersion() async {
    await _provider.version(
      secure: false,
      onSuccess: (cms) {
        version = cms.map((e) => Versioning.MapVersion(e)).toList();
        _compareVersions();
      },
      onError: (error) {
        debugPrint("Erreur lors du check de version : $error");
      },
    );
  }

  void _compareVersions() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final localVersion = packageInfo.version;
    final fetchedVersion = version.isNotEmpty ? version[0].version : '';

    if (fetchedVersion!.isNotEmpty && localVersion != fetchedVersion) {
      _sameVers = false;
    }

    _checkingComplete = true;
    setState(() {}); // trigger build
  }

  Future<void> _checkLoggedIn() async {
    final box = await Hive.openBox('commsBox');
    final storedComms = box.get('user') as Comms?;

    setState(() {
      _initialContent = storedComms != null
          ? HomePage(comm: storedComms)
          : const LoginPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (!connected) {
      return _buildError('Connexion Internet non disponible',
          'Vérifiez votre connexion internet et réessayez.');
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
  const MyLoadingScreen({super.key});

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
            SizedBox(height: 20.0),
            Text(
              'Chargement',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
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
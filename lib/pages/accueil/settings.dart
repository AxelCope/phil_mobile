import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:phil_mobile/methods/methods.dart';
import 'package:phil_mobile/models/users.dart';
import 'package:phil_mobile/pages/login/page_connexion.dart';
import 'package:phil_mobile/provider/queries_provider.dart';

class PageSettings extends StatefulWidget {
  const PageSettings({super.key, required this.comm});

  final Comms comm ;
  @override
  _PageSettingsState createState() => _PageSettingsState();
}

class _PageSettingsState extends State<PageSettings> {

  late final QueriesProvider _provider;


  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  void _initProvider() async{
    _provider = await QueriesProvider.instance;
  }

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmNewPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Modifier le mot de passe',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            // TextField(
            //   controller: currentPasswordController,
            //   obscureText: true,
            //   decoration: const InputDecoration(
            //     labelText: 'Mot de passe actuel',
            //   ),
            // ),
            const SizedBox(height: 16.0),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nouveau mot de passe',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: confirmNewPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmer le nouveau mot de passe',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
              _checkLoggedIn();},
              child: const Text('Modifier le mot de passe'),
            ),
          ],
        ),
      ),
    );
  }

  bool validatePasswords(String currentPassword, String newPassword, String confirmNewPassword) {
    return currentPassword.isNotEmpty && newPassword == confirmNewPassword;
  }


  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red, // Couleur de fond du SnackBar
      ),
    );
  }
  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,// Couleur de fond du SnackBar
      ),
    );
  }

  Future<void> _checkLoggedIn() async {
    final box = await Hive.openBox('commsBox');
    Comms? storedComms = box.get('user') as Comms?;

    if (
        newPasswordController.text.isNotEmpty &&
        confirmNewPasswordController.text.isNotEmpty) {
       if (newPasswordController.text == confirmNewPasswordController.text && (newPasswordController.text == confirmNewPasswordController.text)) {
        changerMDPUsers();
      } else {
        showErrorMessage(context, 'Les mots de passe ne correspondent pas');
      }
    } else if(
        newPasswordController.text.isEmpty ||
        confirmNewPasswordController.text.isEmpty) {
      showErrorMessage(context, "Remplissez correctement les champs");
    }
  }
  Future<void> _setPreferences( BuildContext context) async {
    final box = await Hive.openBox('commsBox');
    await box.clear();
      }

  Future<void> changerMDPUsers() async{
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from dismissing the dialog
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Déconnexion...'),
            ],
          ),
        );
      },
    );
    await _provider.changerMdpUsers(
        newPassword: confirmNewPasswordController.text,
        username: widget.comm.id,
        secure: false,
        onSuccess: (cms) {
          //previousPage(context);
          showMessage(context, 'Changement du mdp réussi');
          print('Avant la navigation');
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
          _setPreferences(context);
          print('Après la navigation');
          newPasswordController.clear();
          confirmNewPasswordController.clear();

        },
        onError: (error)
        {
          previousPage(context);
          showErrorMessage(context, 'Echec, réessayez plus tard');
        }
    );
  }

}

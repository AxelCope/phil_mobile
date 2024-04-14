import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:phil_mobile/methods/methods.dart';
import 'package:phil_mobile/pages/accueil/page_acceuil.dart';
import 'package:phil_mobile/pages/consts.dart';
import 'package:phil_mobile/provider/queries_provider.dart';
import 'package:phil_mobile/models/users.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final QueriesProvider _provider;
  TextEditingController userId = TextEditingController();
  TextEditingController password = TextEditingController();
  String? mailMsg;
  String? passMsg;
  bool obscurePassword = true;

  List<Comms> listUsers = [];


  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  void _initProvider() async{
    _provider = await QueriesProvider.instance;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
        child: ListView(
          children: [
            Center(child: Image.asset(philLogo, scale: 2,)),
            const SizedBox(height: 40,),
            TextField(
              inputFormatters: [
                FilteringTextInputFormatter(RegExp(r'^\d+\.?\d{0,2}'), allow: true),
              ],
              controller: userId,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  errorText: mailMsg,
                  hintText: "Numero commercial",
                  helperText: "Inclure l'indicatif (228)",
                  fillColor: Colors.grey.withOpacity(0.2),
                  filled: true,
                  border: const OutlineInputBorder(
                      borderSide: BorderSide.none
                  )
              ),
            ),
            const SizedBox(height: 30,),
            TextField(
              controller: password,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                hintText: "Mot de passe",
                errorText: passMsg,
                filled: true,
                fillColor: Colors.grey.withOpacity(0.2),
                border: const OutlineInputBorder(
                    borderSide: BorderSide.none
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 50,),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: philMainColor
                ),
                onPressed: (){
                     fetchUsers();
                 },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text( "SE CONNETER", style: GoogleFonts.openSans(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                )
            ),
            ],
        ),
      ),
    );

  }


  void checkCredentials() {
    bool userExists = false;
    if(userId.text.isEmpty || password.text.isEmpty)
      {
        _remplirTousLeschamps();
      }
    else{
      for (var check in listUsers) {
        if (int.parse(userId.text) == check.id && password.text == check.password) {
          Comms user = check;
          _setPreferences(user);
          Navigator.pop(context);
           nextPage(context, HomePage(comm: user));
          userExists = true;
          break;
        }
      }
      if (!userExists) {
        _showUserNotFoundErrorDialog();
      }
    }

  }

  Future<void> fetchUsers() async {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Chargement en cours'),
          content: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    await _provider.fetchUsers(
      secure: false,
      onSuccess: (r) {
        setState(() {
          for(var element in r)
            {
              listUsers.add(Comms.MapCommercial(element));
            }
          previousPage(context);
          checkCredentials();
        });
      },
      onError: (e) {
        setState(() {
          previousPage(context);
          _internetConnectionFailedDialog();
        });
      },
    );
  }

  Future<void> _showUserNotFoundErrorDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Erreur de Connexion"),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Cet utilisateur n\'existe pas.'),
                Text('Veuillez vérifier vos informations de connexion.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _internetConnectionFailedDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Erreur de Connexion"),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Impossible de se connecter à internet'),
                Text('Veuillez rééssayer avec une connexion internet stable.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _remplirTousLeschamps() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Attention"),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Veuillez remplir convenablement tous les champs'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _setPreferences(Comms comms) async {
    try {
      final box = await Hive.openBox('commsBox');
      await box.put('user', comms);
     } catch (e) {
     }
  }




}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phil_mobile/methods/methods.dart';
import 'package:phil_mobile/pages/accueil/accueil.dart';
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
            SizedBox(height: 40,),
            TextField(
              controller: userId,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  errorText: mailMsg,
                  hintText: "Numero commercial",
                  fillColor: Colors.grey.withOpacity(0.2),
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none
                  )
              ),
            ),
            SizedBox(height: 30,),
            TextField(
              controller: password,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                hintText: "Mot de passe",
                errorText: passMsg,
                filled: true,
                fillColor: Colors.grey.withOpacity(0.2),
                border: OutlineInputBorder(
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

            SizedBox(height: 50,),
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
    for (var check in listUsers) {
      if (int.tryParse(userId.text) == check.id && password.text == check.password) {
        Comms user = check;
        nextPage(context, HomePage(comm: user));
        userExists = true;
        break;
      }
    }
    if (!userExists) {
      _showUserNotFoundErrorDialog();
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
          userId.text = listUsers[0].id.toString();
          password.text = listUsers[0].password!;
          previousPage(context);
          checkCredentials();
        });
      },
      onError: (e) {
        setState(() {
          previousPage(context);
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
          title: Text("Erreur de Connexion"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Cet utilisateur n\'existe pas.'),
                Text('Veuillez vérifier vos informations de connexion.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }




}

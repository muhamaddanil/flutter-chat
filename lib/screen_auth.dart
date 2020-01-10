import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebaseAuth.dart';
class ScreenAuth extends StatefulWidget {
  @override
  _ScreenAuthState createState() => _ScreenAuthState();
}

GlobalKey loginScaffoldKey = GlobalKey();

class _ScreenAuthState extends State<ScreenAuth> {

  TextEditingController regionCodeController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  String regionCodeValue = '+62';
  String verificationId;
  String smsCode;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;

  bool isLoading = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser;

  startPhoneAuth() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            content: Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.green,
              ),
            ),
          );
        });

    FirebasePhoneAuth.instantiate(
      phoneNumber: regionCodeValue + phoneNumberController.text,
    );

    FirebasePhoneAuth.stateStream.listen((state) {
      if (state == PhoneAuthState.Verified) {
        // login(context, phoneNumberController.text);
      }
      if (state == PhoneAuthState.CodeSent) {
        // Navigator.of(context).pushReplacement(
        //   CupertinoPageRoute(
        //     builder: (BuildContext context) => ScreenVerification(),
        //   ),
        // );
      }
      if (state == PhoneAuthState.Failed)
        debugPrint("Seems there is an issue with it");
    });
  }

  Future<void> verifyPhone() async {
    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      print("!-- KODE VERIFIKASI TERKIRIM --!");
      print("!---INI COBA ---! $forceCodeResend");
      // Navigator.pushReplacement(
      //   context,
        // MaterialPageRoute(
        //     builder: (BuildContext context) => ScreenVerification(
        //           verificationId: verificationId,
        //           phoneNumber: phoneNumberController.text,
        //         )),
      // );
    };

    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential user) {
      print("!-- KODE VERIFIKASI BERHASIL --!");
      // login(context, phoneNumberController.text);
    };
    final PhoneVerificationFailed verifiedFailed = (AuthException exception) {
      print("!-- KODE VERIFIKASI GAGAL --! \n${exception.message}");
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: regionCodeValue + phoneNumberController.text,
      codeSent: smsCodeSent,
      codeAutoRetrievalTimeout: autoRetrieve,
      timeout: Duration(seconds: 120),
      verificationCompleted: verifiedSuccess,
      verificationFailed: verifiedFailed,
    );
    // GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseUser firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;

    if (firebaseUser != null) {
      // Check is already sign up
      final QuerySnapshot result =
          await Firestore.instance.collection('users').where('id', isEqualTo: firebaseUser.uid).getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        // Update data to server if new user
        Firestore.instance.collection('users').document(firebaseUser.uid).setData({
          'nickname': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl,
          'id': firebaseUser.uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'chattingWith': null
        });

        // Write data to local
        currentUser = firebaseUser;
        await prefs.setString('id', currentUser.uid);
        await prefs.setString('nickname', currentUser.displayName);
        await prefs.setString('photoUrl', currentUser.photoUrl);
      } else {
        // Write data to local
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('nickname', documents[0]['nickname']);
        // await prefs.setString('photoUrl', documents[0]['photoUrl']);
        await prefs.setString('aboutMe', documents[0]['aboutMe']);
      }
      Fluttertoast.showToast(msg: "Sign in success");
      this.setState(() {
        isLoading = false;
      });

      Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen(currentUserId: firebaseUser.uid)));
    } else {
      Fluttertoast.showToast(msg: "Sign in fail");
      this.setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: loginScaffoldKey,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(18.0),
            child: Column(
              children: <Widget>[
                //------------------------- PARTNERSHIP BANNER -------------------------//
                SafeArea(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Image.asset('assets/images/telkomsel.png', scale: 2),
                  ),
                ),
                //------------------------- PARTNERSHIP BANNER END -------------------------//

                SizedBox(
                  height: 32.0,
                ),

                //------------------------- WELCOME HEADER -------------------------//
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "SELAMAT DATANG DI",
                        style: TextStyle(
                          fontFamily: "NotoSans",
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: <Widget>[
                          Text(
                            "C-SMART",
                            style: TextStyle(
                              fontFamily: "NotoSans",
                              fontSize: 27.0,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            "Kendari",
                            style: TextStyle(
                              fontFamily: "NotoSans",
                              fontSize: 27.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Celebes School Mobile Application from Telkomsel",
                        style: TextStyle(
                          fontFamily: "NotoSans",
                          fontSize: 16.0,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "Silahkan login atau register dengan \nnomor Telpon Anda.",
                        style: TextStyle(
                          fontFamily: "NotoSans",
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
                //------------------------- WELCOME HEADER END -------------------------//

                SizedBox(
                  height: 32.0,
                ),

                //------------------------- ARTWORK -------------------------//
                Center(
                  child: Image.asset('assets/images/artwork.png', scale: 2),
                ),
                //------------------------- ARTWORK END -------------------------//

                SizedBox(
                  height: 12.0,
                ),

                //------------------------- NUMBER INPUT CARD -------------------------//
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  child: Container(
                    height: 75.0,
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.phone),
                        VerticalDivider(
                          thickness: 2.0,
                          color: Colors.green,
                        ),
                        Expanded(
                          child: TextField(
                            controller: phoneNumberController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 27.0,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  "Masukkan no. simPATI/ kartuAs / HALO/ LOOP Anda...",
                              hintStyle: TextStyle(
                                fontFamily: "NotoSans",
                                fontSize: 12.0,
                                fontStyle: FontStyle.italic,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //------------------------- NUMBER INPUT CARD END -------------------------//

                SizedBox(
                  height: 12.0,
                ),

                //------------------------- LOGIN & REGISTER BUTTON GROUP -------------------------//
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: <Widget>[
                      /* LOGIN BUTTON */
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        color: Colors.green,
                        child: RawMaterialButton(
                          child: Container(
                            height: 50.0,
                            child: Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "NotoSans",
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            startPhoneAuth();
                          },
                        ),
                      ),
                      /* LOGIN BUTTON END */

                      /* REGISTER BUTTON */
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        child: RawMaterialButton(
                          child: Container(
                            height: 50.0,
                            child: Center(
                              child: Text(
                                "Register",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontFamily: "NotoSans",
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            // login(context, '085398698896');
                          },
                        ),
                      ),
                      /* REGISTER BUTTON END */
                    ],
                  ),
                ),
                //------------------------- LOGIN & REGISTER BUTTON GROUP END -------------------------//

                SizedBox(
                  height: 32.0,
                ),

                Container(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'C-SMART',
                        style: TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Develop By ",
                            style: TextStyle(fontSize: 15.0),
                          ),
                          Image.asset('assets/images/ts.png', scale: 20),
                        ],
                      ),
                      Text(
                        "2019",
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

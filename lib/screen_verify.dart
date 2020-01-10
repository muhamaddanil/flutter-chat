import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'firebaseAuth.dart';

class ScreenVerification extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  ScreenVerification({Key key, this.verificationId, this.phoneNumber})
      : super(key: key);

  @override
  _ScreenVerificationState createState() => _ScreenVerificationState();
}

class _ScreenVerificationState extends State<ScreenVerification> {
  TextEditingController _codeOTPController = TextEditingController();
  // TextEditingController phone = TextEditingController();
  String errorMessage = "kosong";
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  FocusNode focusNode4 = FocusNode();
  FocusNode focusNode5 = FocusNode();
  FocusNode focusNode6 = FocusNode();

  Future startOTPAuth() async {
    await FirebasePhoneAuth.signInWithPhoneNumber(
      _codeOTPController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.green,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //------------------------- ARTWORK -------------------------//
              // Container(
              //   alignment: Alignment.center,
              //   child: SvgPicture.asset(
              //     'assets/svgs/otp.svg',
              //     height: 100.0,
              //     width: 100.0,
              //   ),
              // ),
              //------------------------- ARTWORK END -------------------------//

              //------------------------- ACTION PROMPT -------------------------//
              Container(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Masukkan Kode OTP Anda',
                      style: TextStyle(
                        fontFamily: "NotoSans",
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'silahkan tekan tombol kirim ulang apabila anda belum mendapatkannya.',
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.black87),
                    )
                  ],
                ),
              ),
              //------------------------- ACTION PROMPT END -------------------------//

              //------------------------- OTP CODE ENTER -------------------------//
              Container(
                height: 50.0,
                padding: EdgeInsets.all(12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _codeOTPController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 27.0,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: "Masukkan Kode OTP...",
                          hintStyle: TextStyle(
                            fontFamily: "NotoSans",
                            fontSize: 16.0,
                            fontStyle: FontStyle.italic,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //------------------------- OTP CODE ENTER END -------------------------//

              //------------------------- VERIFICATION BUTTON -------------------------//
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
                        "Verifikasi",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "NotoSans",
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    await startOTPAuth();
                    // login(context, widget.phoneNumber);
                  },
                ),
              ),
              //------------------------- VERIFICATION BUTTON END-------------------------//

              //------------------------- RESEND OTP BUTTON -------------------------//
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                color: Colors.white,
                child: RawMaterialButton(
                  child: Container(
                    height: 50.0,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.replay),
                          SizedBox(width: 8.0),
                          Text(
                            "Kirim Ulang",
                            style: TextStyle(
                              fontFamily: "NotoSans",
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onPressed: () {},
                ),
              ),
              //------------------------- RESEND OTP BUTTON END -------------------------//
            ],
          ),
        ),
      ),
    );
  }

  // Widget getField(String key, FocusNode fn) => SizedBox(
  //       height: 40.0,
  //       width: 35.0,
  //       child: TextField(
  //         key: Key(key),
  //         expands: false,
  //         autofocus: key.contains("1") ? true : false,
  //         focusNode: fn,
  //         onChanged: (String value) {
  //           if (value.length == 1) {
  //             code += value;
  //             switch (code.length) {
  //               case 1:
  //                 FocusScope.of(context).requestFocus(focusNode2);
  //                 break;
  //               case 2:
  //                 FocusScope.of(context).requestFocus(focusNode3);
  //                 break;
  //               case 3:
  //                 FocusScope.of(context).requestFocus(focusNode4);
  //                 break;
  //               case 4:
  //                 FocusScope.of(context).requestFocus(focusNode5);
  //                 break;
  //               case 5:
  //                 FocusScope.of(context).requestFocus(focusNode6);
  //                 break;
  //               default:
  //                 FocusScope.of(context).unfocus();
  //                 break;
  //             }
  //           }
  //         },
  //         maxLengthEnforced: false,
  //         textAlign: TextAlign.center,
  //         cursorColor: Colors.white,
  //         keyboardType: TextInputType.number,
  //         style: TextStyle(
  //             fontSize: 20.0, fontWeight: FontWeight.w600, color: Colors.white),
  //       ),
  //     );
}

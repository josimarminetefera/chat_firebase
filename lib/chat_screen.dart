import 'dart:io';

import 'package:chat_firebase/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  //exibir uma snac bar para notificações
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();

  FirebaseUser _usuarioLogado;

  @override
  void initState() {
    super.initState();

    //quando logar vai ter o usuário atual  quando deslogar vai ser null
    //sempre que a minha autenticação mudar ele vai chamar esta função anonima
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      _usuarioLogado = user;
    });
  }

  Future<FirebaseUser> _pegarUsuario() async {
    //se não encontrar o usuário logado vai pedir para fazer o login
    if (_usuarioLogado != null) return _usuarioLogado;

    try {
      //se a pessoa logou no google vai estar dentro destes objeto
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

      //transformar o login no google em um login do firebase.
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      //credenciais para fazer ologin no firebase.
      final AuthCredential authCredential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      //como fazer login google fecebook,gmail
      final AuthResult authResult = await FirebaseAuth.instance.signInWithCredential(authCredential);

      //pegar o usuário do firebase
      final FirebaseUser firebaseUser = authResult.user;

      return firebaseUser;
    } catch (erro) {
      return null;
    }
  }

  Future<void> _enviarMensagem({String texto, File imagem}) async {
    //usuário atual sempre que for enviar a mensagem tem que ver o usuário
    final FirebaseUser firebaseUser = await _pegarUsuario();

    if (firebaseUser == null) {
      _scafoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Não foi possível fazer o login"),
          backgroundColor: Colors.red,
        ),
      );
    }

    Map<String, dynamic> dados = {
      "uid": firebaseUser.uid,
      "senderName": firebaseUser.displayName,
      "senderFotoUrl": firebaseUser.photoUrl,
    };

    if (imagem != null) {
      //tarefa para dar nome ao arquivo
      StorageUploadTask task = FirebaseStorage.instance.ref().child(DateTime
          .now()
          .millisecondsSinceEpoch
          .toString()).putFile(imagem);
      //subir a nova imagem criada
      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      print(url);
      dados["imagem"] = url;
    }

    if (texto != null) {
      dados["texto"] = texto;
    }

    Firestore.instance.collection("mensagens").document().setData(dados);
  }

  @override
  Widget build(BuildContext context) {
    //barra no topo
    return Scaffold(
      key: _scafoldKey,
      appBar: AppBar(
        title: Text("Olá"),
        elevation: 0.0,
      ),
      //função por parametros
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              //toda vez que atualizar o banco de dados ele atualiza isso aqui
              stream: Firestore.instance.collection("mensagens").snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  default:
                    List<DocumentSnapshot> documents = snapshot.data.documents.reversed.toList();
                    return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(documents[index].data["texto"]),
                        );
                      },
                    );
                }
              },
            ),
          ),
          TextComposer(
            _enviarMensagem,
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:chat_firebase/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chat_mensagem.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  //exibir uma snac bar para notificações
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();

  FirebaseUser _usuarioLogado;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();

    //quando logar vai ter o usuário atual  quando deslogar vai ser null
    //sempre que a minha autenticação mudar ele vai chamar esta função anonima
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _usuarioLogado = user;
      });
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
      "quemEnviou": firebaseUser.displayName,
      "quemEnviouFotoUrl": firebaseUser.photoUrl,
      "time": Timestamp.now(),
    };

    if (imagem != null) {
      //tarefa para dar nome ao arquivo
      StorageUploadTask task = FirebaseStorage.instance.ref().child(DateTime.now().millisecondsSinceEpoch.toString()).putFile(imagem);

      setState(() {
        _carregando = true;
      });

      //subir a nova imagem criada
      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      print(url);
      dados["imagem"] = url;

      setState(() {
        _carregando = false;
      });
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
        title: Text((_usuarioLogado != null) ? "Olá, ${_usuarioLogado.displayName}" : "Chat App"),
        elevation: 0.0,
        actions: [
          (_usuarioLogado != null)
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    _scafoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text("Você saiu com sucesso!"),
                      ),
                    );
                  },
                )
              : Container()
        ],
      ),
      //função por parametros
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              //toda vez que atualizar o banco de dados ele atualiza isso aqui
              stream: Firestore.instance.collection("mensagens").orderBy("time").snapshots(),
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
                        return ChatMensagem(
                          documents[index].data,
                          documents[index].data["uid"] == _usuarioLogado?.uid,
                        );
                      },
                    );
                }
              },
            ),
          ),
          (_carregando) ? LinearProgressIndicator() : Container(),
          TextComposer(
            _enviarMensagem,
          ),
        ],
      ),
    );
  }
}

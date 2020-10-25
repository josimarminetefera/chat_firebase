import 'package:chat_firebase/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(MyApp());
  /*Firestore.instance.collection("mensagens").document().setData(
    {
      "texto": "Vai indo porcaria",
      "de": "Vlater",
      "lida": false,
    },
  );
  Firestore.instance.collection("mensagens").document().collection("arquivo").document().setData(
    {
      "arquivo": "foto.png",
    },
  );*/
  //LER TODAS MENSAGENS APENAS UMA VEZ
  /*QuerySnapshot snapshot = await Firestore.instance.collection("mensagens").getDocuments();
  snapshot.documents.forEach((document) {
    print(document.data);
  });*/
  //ACESSAR DADOS DE UMA MENSAGEM EM ESPECÍFICO
  /*DocumentSnapshot documentSnapshot = await Firestore.instance.collection("mensagens").document("49j5QlJnzdUkhzcmTiYA").get();
  print(documentSnapshot.data);*/
  //ATUALIZAR DOCUMENTOS EM TEMPO REAL
  /*Firestore.instance.collection("mensagens").snapshots().listen((dados) {
    dados.documents.forEach((documet) {
      print(documet.data);
    });
  });*/
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        iconTheme: IconThemeData(
          color: Colors.blue,
        ),
      ),
      home: ChatScreen(),
    );
  }
}

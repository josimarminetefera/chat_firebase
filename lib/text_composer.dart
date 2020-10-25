import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  TextComposer(this.enviarMensagem);

  //função é constrida lá fora porém é chamado aqui dentro
  final Function({String texto, File imagem}) enviarMensagem;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  //criar controlador para o campo
  final TextEditingController _textoController = TextEditingController();
  bool _temTexto = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () async {
              final File imagem = await ImagePicker.pickImage(source: ImageSource.camera);
              if (imagem == null) {
                return;
              } else {
                widget.enviarMensagem(imagem: imagem);
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: _textoController,
              decoration: InputDecoration.collapsed(hintText: "Enviar uma mensagem"),
              onChanged: (texto) {
                setState(() {
                  _temTexto = texto.isNotEmpty;
                });
              },
              onSubmitted: (texto) {
                //executa função especificada la no chat_screen
                widget.enviarMensagem(texto: texto);
                _resetarCampo();
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: (_temTexto)
                ? () {
                    //executa função especificada la no chat_screen
                    widget.enviarMensagem(texto: _textoController.text);
                    _resetarCampo();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  void _resetarCampo() {
    _textoController.clear();
    setState(() {
      _temTexto = false;
    });
  }
}

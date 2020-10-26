import 'package:flutter/material.dart';

//Não vai precsar de alterações internas
class ChatMensagem extends StatelessWidget {
  ChatMensagem(this.dados, this.minhaMensagem);

  final Map<String, dynamic> dados;
  final bool minhaMensagem; //para identificar se a mensagem enviada é minha

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          (!minhaMensagem)
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(dados["quemEnviouFotoUrl"]),
                  ),
                )
              : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment: (minhaMensagem) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                (dados["imagem"] != null)
                    ? Image.network(
                        dados["imagem"],
                        width: 250,
                      )
                    : Text(
                        dados["texto"],
                        textAlign: (minhaMensagem) ? TextAlign.end : TextAlign.start,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                Text(
                  dados["quemEnviou"],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          (minhaMensagem)
              ? Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(dados["quemEnviouFotoUrl"]),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TermoFormalWidget extends StatelessWidget {
  const TermoFormalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(
        style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
        children: const [
          TextSpan(
            text: "TERMO DE CONSCIENTIZAÇÃO E ISENÇÃO DE RESPONSABILIDADE\n\n",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          TextSpan(
            text: "Ao utilizar esta aplicação, o USUÁRIO declara que está ciente e de acordo com as condições abaixo:\n\n",
          ),
          TextSpan(
            text: "1. ORIGEM DAS INFORMAÇÕES\n",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
            "Todas as ofertas, preços, promoções, produtos e demais informações disponibilizadas nesta plataforma são de responsabilidade exclusiva dos ESTABELECIMENTOS ANUNCIANTES...\n\n",
          ),
          TextSpan(
            text: "2. POSSÍVEIS DIVERGÊNCIAS\n",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
            "As informações apresentadas podem conter erros de digitação, falhas de atualização ou divergências...\n\n",
          ),
          TextSpan(
            text: "3. LIMITAÇÃO DE RESPONSABILIDADE\n",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
            "Esta aplicação não se responsabiliza por prejuízos, danos ou perdas de qualquer natureza decorrentes da utilização das informações divulgadas...\n\n",
          ),
          TextSpan(
            text: "4. ACEITAÇÃO\n",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
            "Ao prosseguir com o uso desta aplicação, o USUÁRIO declara que leu, compreendeu e aceitou integralmente este termo.",
          ),
        ],
      ),
    );
  }
}

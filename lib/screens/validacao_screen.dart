import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:monaco_editor/monaco_editor.dart';
import 'package:panfleteiro_web/widgets/imagem_interativa.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/bar_utils.dart';
import '../models/validacao.dart';

class ValidacaoScreen extends StatefulWidget {
  const ValidacaoScreen({super.key});

  @override
  State<ValidacaoScreen> createState() => _ValidacaoScreenState();
}

class _ValidacaoScreenState extends State<ValidacaoScreen> {
  Validacao? _validacao;
  bool _carregando = false;

  final MonacoEditorController _editorController = MonacoEditorController();

  @override
  void initState() {
    super.initState();
    _editorController.initialize(
        MonacoEditorOptions(
            language: MonacoLanguage.json,
            theme: MonacoTheme.vsDark,
        )
    );
  }

  Future<void> buscarProximaValidacao() async {
    setState(() {
      _carregando = true;
    });

    final String baseUrl = dotenv.env['API_BASE_URL']!;
    final url = Uri.parse('$baseUrl/v1/validacoes');
    final token = await getToken();

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final dto = Validacao.fromJson(jsonResponse);

        setState(() {
          _validacao = dto;
          _editorController.setText(_validacao!.response);
          _carregando = false;
        });
      } else {
        setState(() {
          _validacao = null;
          _editorController.setText('');
          _carregando = false;
        });
      }
    } catch (e) {
      BarUtils.showTopFlushBar(context, content: 'Erro ao tentar buscar validações: $e');
    }
  }

  Future<void> _enviar() async {
    final String baseUrl = dotenv.env['API_BASE_URL']!;
    final url = Uri.parse('$baseUrl/v1/anuncios/lot');
    final token = await getToken();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: await _editorController.getText(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        BarUtils.showTopFlushBar(context, content: 'Enviado com sucesso!');
      } else {
        BarUtils.showTopFlushBar(
            context, content: 'Erro ao enviar: ${response.statusCode}');
      }
    } catch (e) {
      BarUtils.showTopFlushBar(context, content: 'Erro ao enviar: $e');
    }

    _excluir(false);
  }

  Future<void> _excluir(bool showMessage) async {
    final String baseUrl = dotenv.env['API_BASE_URL']!;
    final url = Uri.parse('$baseUrl/v1/validacoes/deletar/${_validacao!.id}');
    final token = await getToken();

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (showMessage) {
          BarUtils.showTopFlushBar(context, content: 'Deletado com sucesso!');
        }
      } else {
        BarUtils.showTopFlushBar(context, content: 'Erro ao deletar: ${response.statusCode} - ${response.body}');

      }
    } catch (e) {
      BarUtils.showTopFlushBar(context, content: 'Erro ao enviar: $e');
    }
    setState(() {
      _validacao = null;
    });
  }

  Future<void> _reprocessar() async {
      // TODO: Implementar reprocessamento
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: appBar(),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _validacao == null
            ? Center(
          child: ElevatedButton(
            onPressed: buscarProximaValidacao,
            child: const Text('Carregar Validação'),
          ),
        )
            : Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.white,
                      child: MonacoEditorWidget(
                        controller: _editorController,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: ImagemInterativa(
                      base64Image: _validacao!.imagemBase64,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => _excluir(true),
                  child: const Text('Excluir'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _reprocessar,
                  child: const Text('Reprocessar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _enviar,
                  child: const Text('Enviar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  appBar() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/validacao');
            },
            child: Image.asset(
              'assets/logo.png',
              height: 65,
            ),
          ),
          SizedBox(width: 8),
          Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Text(
              'Validação',
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD32F2F),
              ),
            ),
          ),
        ],
      ),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
    );
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}

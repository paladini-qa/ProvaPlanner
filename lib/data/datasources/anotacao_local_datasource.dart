import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anotacao_dto.dart';

abstract class AnotacaoLocalDataSource {
  Future<List<AnotacaoDto>> getAll();
  Future<void> save(AnotacaoDto anotacao);
  Future<void> saveAll(List<AnotacaoDto> anotacoes);
  Future<void> delete(String id);
}

class AnotacaoLocalDataSourceImpl implements AnotacaoLocalDataSource {
  static const String _key = 'anotacoes';

  @override
  Future<List<AnotacaoDto>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final anotacoesString = prefs.getString(_key);

    if (anotacoesString == null) {
      return [];
    }

    try {
      final List<dynamic> anotacoesJson =
          jsonDecode(anotacoesString) as List<dynamic>;
      return anotacoesJson
          .map((json) => AnotacaoDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> save(AnotacaoDto anotacao) async {
    final anotacoes = await getAll();
    final index = anotacoes.indexWhere((a) => a.id == anotacao.id);

    if (index >= 0) {
      anotacoes[index] = anotacao;
    } else {
      anotacoes.add(anotacao);
    }

    await saveAll(anotacoes);
  }

  @override
  Future<void> saveAll(List<AnotacaoDto> anotacoes) async {
    final prefs = await SharedPreferences.getInstance();
    final anotacoesJson = anotacoes.map((dto) => dto.toJson()).toList();
    await prefs.setString(_key, jsonEncode(anotacoesJson));
  }

  @override
  Future<void> delete(String id) async {
    final anotacoes = await getAll();
    anotacoes.removeWhere((a) => a.id == id);
    await saveAll(anotacoes);
  }
}


import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prova_dto.dart';

abstract class ProvaLocalDataSource {
  Future<List<ProvaDto>> getAll();
  Future<void> save(ProvaDto prova);
  Future<void> saveAll(List<ProvaDto> provas);
  Future<void> delete(String id);
}

class ProvaLocalDataSourceImpl implements ProvaLocalDataSource {
  static const String _key = 'provas';

  @override
  Future<List<ProvaDto>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final provasString = prefs.getString(_key);

    if (provasString == null) {
      return [];
    }

    try {
      final List<dynamic> provasJson =
          jsonDecode(provasString) as List<dynamic>;
      return provasJson
          .map((json) => ProvaDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> save(ProvaDto prova) async {
    final provas = await getAll();
    final index = provas.indexWhere((p) => p.id == prova.id);

    if (index >= 0) {
      provas[index] = prova;
    } else {
      provas.add(prova);
    }

    await saveAll(provas);
  }

  @override
  Future<void> saveAll(List<ProvaDto> provas) async {
    final prefs = await SharedPreferences.getInstance();
    final provasJson = provas.map((dto) => dto.toJson()).toList();
    await prefs.setString(_key, jsonEncode(provasJson));
  }

  @override
  Future<void> delete(String id) async {
    final provas = await getAll();
    provas.removeWhere((p) => p.id == id);
    await saveAll(provas);
  }
}


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PokemonDB {
  int id;
  String name;
  String type;

  PokemonDB({this.id, this.name, this.type});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }

  static PokemonDB fromMap(Map<String, dynamic> map) {
    return PokemonDB(
      id: map['id'],
      name: map['name'],
      type: map['type'],
    );
  }
}

class PokemonDatabase {
  static final PokemonDatabase instance = PokemonDatabase._init();
  static Database _database;

  PokemonDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDB('pokedex.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pokemons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        type TEXT
      )
    ''');
  }

  Future<int> create(PokemonDB pokemon) async {
    final db = await instance.database;
    final id = await db.insert('pokemons', pokemon.toMap());

    if (id != null) {
      print('Novo Pokémon cadastrado: ${pokemon.name}');
    } else {
      print('Erro ao cadastrar o Pokémon: ${pokemon.name}');
    }

    print(
        'ID do novo Pokémon: $id'); // Adicione este log para verificar o ID retornado

    return id;
  }

  Future<List<PokemonDB>> readAll() async {
    final db = await instance.database;
    final maps = await db.query('pokemons');
    return List.generate(maps.length, (i) {
      return PokemonDB.fromMap(maps[i]);
    });
  }

  Future<void> update(PokemonDB pokemon) async {
    final db = await instance.database;
    await db.update('pokemons', pokemon.toMap(),
        where: 'id = ?', whereArgs: [pokemon.id]);
  }

  Future<void> delete(int id) async {
    final db = await instance.database;
    await db.delete('pokemons', where: 'id = ?', whereArgs: [id]);
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PokemonDB> pokedex = [];

  @override
  void initState() {
    super.initState();
    fetchPokemonData();
  }

  @override
  Widget build(BuildContext context) {
    // Your existing build method implementation
    // ...
  }

  Future<void> fetchPokemonData() async {
    var url = Uri.https('raw.githubusercontent.com',
        '/Biuni/PokemonGO-Pokedex/master/pokedex.json');

    http.get(url).then((value) async {
      if (value.statusCode == 200) {
        var data = jsonDecode(value.body);
        List<dynamic> apiPokedex = data['pokemon'];

        List<PokemonDB> apiPokemonList = apiPokedex
            .map((pokemon) => PokemonDB(
                  id: pokemon['id'],
                  name: pokemon['name'],
                  type: pokemon['type'][
                      0], // Note: Assuming the 'type' field is a list of strings in the API
                ))
            .toList();

        // Save the data to the local database
        await savePokemonToDatabase(apiPokemonList);

        setState(() {
          pokedex = apiPokemonList;
        });
      }
    }).catchError((e) {
      print(e);
    });
  }

  Future<void> savePokemonToDatabase(List<PokemonDB> pokemonList) async {
    final db = await PokemonDatabase.instance.database;
    Batch batch = db.batch();
    for (var pokemon in pokemonList) {
      batch.insert('pokemons', pokemon.toMap());
    }
    await batch.commit();
  }
}

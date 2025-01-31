import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database> initDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), 'pokemon_database.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE pokemon('
        'id INTEGER PRIMARY KEY, '
        'name TEXT, '
        'imageUrl TEXT, '
        'types TEXT, '
        'hp INTEGER, '
        'attack INTEGER, '
        'height REAL, '
        'weight REAL)',
      );
    },
    version: 1,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o suporte ao SQLite no desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PokedexScreen(),
    );
  }
}

class PokedexScreen extends StatefulWidget {
  @override
  _PokedexScreenState createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  Pokemon? pokemon;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  Future<void> fetchPokemon(BuildContext context, String pokemonName) async {
    setState(() {
      isLoading = true;
      pokemon = null;
    });

    final url = Uri.parse(
        'https://pokeapi.co/api/v2/pokemon/${pokemonName.toLowerCase()}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        pokemon = Pokemon.fromJson(jsonDecode(response.body));
        isLoading = false;
      });
    } else {
      setState(() {
        pokemon = null;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pokémon não encontrado!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Center(
            child: Text(
              'POKÉDEX',
              style: TextStyle(
                fontFamily: "PokemonSolid",
                color: Colors.amberAccent,
              ),
            ),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Digite o nome do Pokémon ou id',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (searchController.text.isNotEmpty) {
                  fetchPokemon(context, searchController.text);
                }
              },
              child: Text('Buscar'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                print('potão precionado!');
              },
              icon: Icon(Icons.catching_pokemon_outlined,
                  size: 30, color: Colors.white),
              label: Text(""),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Cor de fundo
                foregroundColor: Colors.white, // Cor do texto
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : pokemon == null
                    ? Text('Nenhum Pokémon encontrado')
                    : GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PokemonDetailScreen(pokemon: pokemon!),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  Text(
                                    pokemon!.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 0),
                                  Image.network(
                                    pokemon!.imageUrl,
                                    width: 150,
                                    height: 150,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "ID: ${pokemon!.id}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Tipos: ${pokemon!.types.join(', ')}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

class Pokemon {
  final String name;
  final int id;
  final String imageUrl;
  final List<String> types;
  final int hp;
  final int attack;
  final double height;
  final double weight;

  Pokemon({
    required this.name,
    required this.id,
    required this.imageUrl,
    required this.types,
    required this.hp,
    required this.attack,
    required this.height,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'types': types.join(','),
      'hp': hp,
      'attack': attack,
      'height': height,
      'weight': weight,
    };
  }

  factory Pokemon.fromMap(Map<String, dynamic> map) {
    return Pokemon(
      name: map['name'],
      id: map['id'],
      imageUrl: map['imageUrl'],
      types: map['types'].split(','),
      hp: map['hp'],
      attack: map['attack'],
      height: map['height'],
      weight: map['weight'],
    );
  }

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      id: json['id'],
      imageUrl: json['sprites']['front_default'],
      types: (json['types'] as List)
          .map((t) => t['type']['name'].toString())
          .toList(),
      hp: json['stats'][0]['base_stat'],
      attack: json['stats'][1]['base_stat'],
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
    );
  }
}

class PokemonDetailScreen extends StatelessWidget {
  final Pokemon pokemon;

  PokemonDetailScreen({required this.pokemon});

  Future<void> savePokemon(BuildContext context, Pokemon pokemon) async {
    final db = await initDatabase();

    final count = await db.rawQuery('SELECT COUNT(*) FROM pokemon');
    final currentCount = count.first.values.first as int;

    if (currentCount >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Limite máximo de 6 pokémons atingido!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Salvar pokémon
    await db.insert(
      'pokemon',
      pokemon.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Mostrar sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${pokemon.name} foi salvo com sucesso!')),
    );

    // Imprimir todos os pokémons no console
    final List<Map<String, dynamic>> allPokemons = await db.query('pokemon');
    print('POKÉMONS SALVOS');
    for (var p in allPokemons) {
      print('ID: ${p['id']}');
      print('Nome: ${p['name']}');
      print('Imagem: ${p['imageUrl']}');
      print('Tipos: ${p['types']}');
      print('HP: ${p['hp']}');
      print('Ataque: ${p['attack']}');
      print('Altura: ${p['height']}');
      print('Peso: ${p['weight']}');
    }
  }

  Future<void> deleteDatabase() async {
  final dbPath = await getDatabasesPath();
  final dbFile = join(dbPath, 'pokemon_database.db');
  
  try {
    await databaseFactory.deleteDatabase(dbFile);
    print('Banco de dados apagado com sucesso!');
  } catch (e) {
    print('Erro ao apagar o banco de dados: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Center(
            child: Text(
              pokemon.name.toUpperCase(),
              style: TextStyle(
                fontFamily: "PokemonSolid",
                color: Colors.amberAccent,
                fontSize: 30,
              ),
            ),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 5.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 150,
                      child: Image.network(
                        pokemon.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error, size: 50, color: Colors.red);
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      pokemon.name.toUpperCase(),
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text("ID: ${pokemon.id}".toLowerCase()),
                    Text("Tipos: ${pokemon.types.join(', ')}".toLowerCase()),
                    Text("Vida (HP): ${pokemon.hp}"),
                    Text("Força (Ataque): ${pokemon.attack}".toLowerCase()),
                    Text("Altura: ${pokemon.height / 10} m".toLowerCase()),
                    Text("Peso: ${pokemon.weight / 10} kg".toLowerCase()),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await savePokemon(context, pokemon);
                },
                icon: Icon(Icons.catching_pokemon_outlined,
                    size: 30, color: Colors.white),
                label: Text("Capturar Pokémon"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Cor de fundo
                  foregroundColor: Colors.white, // Cor do texto
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

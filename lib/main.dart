import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

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
  // Inicialize o databaseFactoryFfiWeb para uso na web
  databaseFactory = databaseFactoryFfiWeb;
  
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
              style: TextStyle(color: Colors.white), // Cor do texto digitado
              decoration: InputDecoration(
                labelText: 'Digite o nome do Pokémon ou id',
                labelStyle:
                    TextStyle(color: Colors.white), // Cor do texto do label
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // Cor da borda
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          Colors.grey), // Cor da borda quando não está em foco
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white), // Cor da borda quando em foco
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (searchController.text.isNotEmpty) {
                  fetchPokemon(
                      context, searchController.text); // Passando context
                }
              },
              child: Text('Buscar'),
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

    await db.insert(
      'pokemon',
      pokemon.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${pokemon.name} foi salvo com sucesso!')),
    );
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

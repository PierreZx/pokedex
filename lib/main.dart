import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
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

  Future<void> fetchPokemon(String pokemonName) async {
    setState(() {
      isLoading = true;
      pokemon = null;
    });

    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/${pokemonName.toLowerCase()}');
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
        
        title:Center(
        child: Text('PEDEX'),
        )
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
              TextField(
                controller: searchController,
                style: TextStyle(color: Colors.white), // Cor do texto digitado
                decoration: InputDecoration(
                  labelText: 'Digite o nome do Pokémon',
                  labelStyle: TextStyle(color: Colors.white), // Cor do texto do label
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Cor da borda
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey), // Cor da borda quando não está em foco
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white), // Cor da borda quando em foco
                  ),
                ),
              ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (searchController.text.isNotEmpty) {
                  fetchPokemon(searchController.text);
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
                              builder: (context) => PokemonDetailScreen(pokemon: pokemon!),
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

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(title: Text(pokemon.name)),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center( // Centraliza verticalmente
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Centraliza horizontalmente
          children: [
            Image.network(pokemon.imageUrl),
            Container(
            decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
            color: Colors.black,
            width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12),
            ),
            Image.network(pokemon.imageUrl),
            Text(
              pokemon.name.toUpperCase(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("ID: ${pokemon.id}"),
            Text("Tipos: ${pokemon.types.join(', ')}"),
            Text("Vida (HP): ${pokemon.hp}"),
            Text("Força (Ataque): ${pokemon.attack}"),
            Text("Altura: ${pokemon.height / 10} m"),
            Text("Peso: ${pokemon.weight / 10} kg"),
            )
            ],
          ),
        ),
      ),
    );
}
}

import 'dart:convert'; // Para decodificar JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class Pokemon {
  final String name;
  final String imageUrl;
  final int hp;
  final int attack;
  final int defense;

  Pokemon({
    required this.name,
    required this.imageUrl,
    required this.hp,
    required this.attack,
    required this.defense,
  });

  // Método para transformar JSON em um objeto Pokemon
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      imageUrl: json['sprites']['front_default'], // URL da imagem
      hp: json['stats'][0]['base_stat'],         // HP
      attack: json['stats'][1]['base_stat'],     // Ataque
      defense: json['stats'][2]['base_stat'],    // Defesa
    );
  }
}
  Future<List<Post>> postsFuture = getPosts();
  

class MyApp extends StatelessWidget {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Consulta API'),
        ),
        body: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(hintText: "Buscar pokemon"),
            )
          ],
        ),
      ),
    );
  }
}

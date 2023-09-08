import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

void main() => runApp(PokemonBattleApp());

class PokemonBattleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PokemonBattleScreen(),
    );
  }
}

class Pokemon {
  final String name;
  int hp;
  final int attack;

  Pokemon({required this.name, required this.hp, required this.attack});
}

class PokemonBattleScreen extends StatefulWidget {
  @override
  _PokemonBattleScreenState createState() => _PokemonBattleScreenState();
}

class _PokemonBattleScreenState extends State<PokemonBattleScreen> {
  Pokemon? playerPokemon;
  Pokemon? opponentPokemon;
  bool isPlayerTurn = true;
  bool isBattleOver = false;

  @override
  void initState() {
    super.initState();
    // Initialize the opponent's Pokemon randomly
    getRandomPokemon().then((pokemon) {
      setState(() {
        opponentPokemon = pokemon;
      });
    });
  }

  Future<Pokemon> getRandomPokemon() async {
    final random = Random();
    final int randomPokemonId = random.nextInt(807) + 1; // PokeAPI tem até o Pokémon #807

    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon/$randomPokemonId/'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final name = data['name'];
      final hp = data['stats'][5]['base_stat']; // HP está no índice 5 da lista de stats
      final attack = data['stats'][4]['base_stat']; // Ataque está no índice 4 da lista de stats

      return Pokemon(name: name, hp: hp, attack: attack);
    } else {
      throw Exception('Falha ao carregar dados do Pokémon');
    }
  }

  void attack() {
    if (!isBattleOver) {
      if (isPlayerTurn) {
        // Player attacks
        final damage = playerPokemon!.attack;
        opponentPokemon!.hp -= damage;
      } else {
        // Opponent attacks
        final damage = opponentPokemon!.attack;
        playerPokemon!.hp -= damage;
      }

      // Check if the battle is over
      if (playerPokemon!.hp <= 0 || opponentPokemon!.hp <= 0) {
        isBattleOver = true;
        showResultDialog();
      } else {
        // Switch turns
        isPlayerTurn = !isPlayerTurn;
      }
    }
    setState(() {});
  }

  void showResultDialog() {
    String resultText;
    if (playerPokemon!.hp <= 0) {
      resultText = 'Você perdeu!';
    } else {
      resultText = 'Você venceu!';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Resultado da batalha'),
          content: Text(resultText),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                restartBattle();
              },
              child: Text('Reiniciar'),
            ),
          ],
        );
      },
    );
  }

  void restartBattle() {
    playerPokemon = null;
    getRandomPokemon().then((pokemon) {
      setState(() {
        opponentPokemon = pokemon;
      });
    });
    isPlayerTurn = true;
    isBattleOver = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Batalha Pokémon'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              isPlayerTurn ? 'Sua vez' : 'Vez do oponente',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            playerPokemon != null
                ? Column(
                    children: [
                      Text('Seu Pokémon: ${playerPokemon!.name}'),
                      Text('HP: ${playerPokemon!.hp}'),
                      Text('Ataque: ${playerPokemon!.attack}'),
                      SizedBox(height: 20),
                      Text('Pokémon Oponente: ${opponentPokemon!.name}'),
                      Text('HP: ${opponentPokemon!.hp}'),
                      Text('Ataque: ${opponentPokemon!.attack}'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: attack,
                        child: Text('Atacar'),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () {
                      getRandomPokemon().then((pokemon) {
                        setState(() {
                          playerPokemon = pokemon;
                        });
                      });
                    },
                    child: Text('Escolher Pokémon Inicial'),
                  ),
          ],
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';

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
  final List<Pokemon> initialPokemons = [
    Pokemon(name: 'Bulbasaur', hp: 50, attack: 10),
    Pokemon(name: 'Charmander', hp: 48, attack: 12),
    Pokemon(name: 'Squirtle', hp: 52, attack: 9),
  ];

  Pokemon? playerPokemon;
  Pokemon? opponentPokemon;
  bool isPlayerTurn = true;
  bool isBattleOver = false;

  @override
  void initState() {
    super.initState();
    // Initialize the opponent's Pokemon randomly
    opponentPokemon = getRandomPokemon();
  }

  Pokemon getRandomPokemon() {
    final random = Random();
    return initialPokemons[random.nextInt(initialPokemons.length)];
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
    opponentPokemon = getRandomPokemon();
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
                      playerPokemon = getRandomPokemon();
                      setState(() {});
                    },
                    child: Text('Escolher Pokémon Inicial'),
                  ),
          ],
        ),
      ),
    );
  }
}

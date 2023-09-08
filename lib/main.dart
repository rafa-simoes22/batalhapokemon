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
  List<Pokemon> availablePokemons = [];
  Pokemon? playerPokemon;
  Pokemon? opponentPokemon;
  bool isPlayerTurn = true;
  bool isBattleOver = false;

  @override
  void initState() {
    super.initState();
    // Obtenha os Pokémons disponíveis aleatoriamente da API
    getRandomPokemons().then((pokemons) {
      setState(() {
        availablePokemons = pokemons;
      });
    });

    getRandomPokemon().then((pokemon) {
      setState(() {
        opponentPokemon = pokemon;
      });
    });
  }

  Future<List<Pokemon>> getRandomPokemons() async {
    final random = Random();
    List<Pokemon> pokemons = [];

    for (int i = 0; i < 3; i++) {
      final int randomPokemonId = random.nextInt(807) + 1;

      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/$randomPokemonId/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final name = data['name'];
        final hp = data['stats'][5]['base_stat'];
        final attack = data['stats'][4]['base_stat'];

        pokemons.add(Pokemon(name: name, hp: hp, attack: attack));
      } else {
        throw Exception('Falha ao carregar dados do Pokémon');
      }
    }

    return pokemons;
  }

  Future<Pokemon> getRandomPokemon() async {
    final random = Random();
    final int randomPokemonId = random.nextInt(807) + 1;

    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon/$randomPokemonId/'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final name = data['name'];
      final hp = data['stats'][5]['base_stat'];
      final attack = data['stats'][4]['base_stat'];

      return Pokemon(name: name, hp: hp, attack: attack);
    } else {
      throw Exception('Falha ao carregar dados do Pokémon oponente');
    }
  }

  void choosePlayerPokemon(Pokemon selectedPokemon) {
    setState(() {
      playerPokemon = selectedPokemon;
      availablePokemons.remove(selectedPokemon);
    });
  }

  int calculateDamage(Pokemon attacker, Pokemon defender) {

  
  int damage = attacker.attack - defender.hp;
  if (damage < 1) {
    damage = 1;
  }
  
  return damage;
}

  void attack() {
    if (!isBattleOver && playerPokemon != null && opponentPokemon != null) {
      int damage = calculateDamage(playerPokemon!, opponentPokemon!);

      if (isPlayerTurn) {
        opponentPokemon!.hp -= damage;
      } else {
        playerPokemon!.hp -= damage;
      }

      if (playerPokemon!.hp <= 0 || opponentPokemon!.hp <= 0) {
        isBattleOver = true;
        showResultDialog();
      } else {
        isPlayerTurn = !isPlayerTurn;
      }
      setState(() {});
    }
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
    availablePokemons.clear();
    getRandomPokemons().then((pokemon) {
      setState(() {
        opponentPokemon = pokemon as Pokemon?;
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
                      Text('Pokémon Oponente: ${opponentPokemon?.name ?? 'Nenhum Pokémon'}'),
                      Text('HP: ${opponentPokemon?.hp ?? 0}'),
                      Text('Ataque: ${opponentPokemon?.attack ?? 0}'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: attack,
                        child: Text('Atacar'),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Text('Escolha seu Pokémon:'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: availablePokemons
                            .map(
                              (pokemon) => ElevatedButton(
                                onPressed: () => choosePlayerPokemon(pokemon),
                                child: Text(pokemon.name),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
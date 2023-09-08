import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class PokemonCard {
  final String name;
  final String type;
  int hp;
  List<String> attacks;

  PokemonCard({
    required this.name,
    required this.type,
    required this.hp,
    required this.attacks,
  });
}

class PokemonBattle {
  final List<PokemonCard> playerCards;
  final List<PokemonCard> opponentCards;
  Random _random = Random();

  PokemonBattle({
    required this.playerCards,
    required this.opponentCards,
  });

  bool _isPlayerTurn = true;

  PokemonCard _getNextOpponentCard() {
    return opponentCards[_random.nextInt(opponentCards.length)];
  }

  void _attack(PokemonCard attacker, PokemonCard defender) {
    // Implemente a lógica de ataque aqui
    // Reduza os pontos de vida do defensor, verifique condições de vitória, etc.
    int damage = _random.nextInt(10) + 5;
    defender.hp -= damage;
    print("${attacker.name} atacou ${defender.name} causando $damage de dano.");
  }

  void playTurn() {
    final currentPlayer = _isPlayerTurn ? playerCards : opponentCards;
    final currentOpponent = _isPlayerTurn ? opponentCards : playerCards;

    final attackingPokemon = currentPlayer[0];
    final defendingPokemon = _getNextOpponentCard();

    _attack(attackingPokemon, defendingPokemon);

    // Alternar o turno
    _isPlayerTurn = !_isPlayerTurn;
  }

  bool isGameOver() {
    // Implemente a lógica para verificar se o jogo acabou (por exemplo, um jogador perdeu todas as cartas)
    return playerCards.every((card) => card.hp <= 0) ||
        opponentCards.every((card) => card.hp <= 0);
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PokemonBattle? battle;

  @override
  void initState() {
    super.initState();

    // Exemplo de criação de cartas para jogador e oponente
    final playerCards = [
      PokemonCard(name: "Pikachu", type: "Electric", hp: 50, attacks: ["Thunderbolt"]),
      PokemonCard(name: "Charizard", type: "Fire", hp: 80, attacks: ["Flamethrower"]),
      PokemonCard(name: "Blastoise", type: "Water", hp: 70, attacks: ["Hydro Pump"]),
    ];

    final opponentCards = [
      PokemonCard(name: "Eevee", type: "Normal", hp: 40, attacks: ["Tackle"]),
      PokemonCard(name: "Jigglypuff", type: "Fairy", hp: 60, attacks: ["Sing"]),
      PokemonCard(name: "Meowth", type: "Normal", hp: 45, attacks: ["Scratch"]),
    ];

    battle = PokemonBattle(playerCards: playerCards, opponentCards: opponentCards);
  }

  void _playTurn() {
    setState(() {
      battle?.playTurn();
      if (battle?.isGameOver() == true) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Fim de Jogo"),
            content: Text("O jogo acabou!"),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Batalha Pokémon"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Batalha Pokémon"),
              if (battle != null)
                Column(
                  children: [
                    Text("HP do Jogador: ${battle!.playerCards[0].hp}"),
                    Text("HP do Oponente: ${battle!.opponentCards[0].hp}"),
                    ElevatedButton(
                      onPressed: () => _playTurn(),
                      child: Text("Próximo Turno"),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

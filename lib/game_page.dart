import 'package:flutter/material.dart';

import 'winning_line_painter.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const String playerX = "X";
  static const String playerY = "O";

  late String currentPlayer;
  late List<String> occupied;
  late List<int> moves;
  List<int>?
      winningLine; // value in winning line determines the winner position
  final List<GlobalKey> keys = List.generate(9, (index) => GlobalKey());
  Offset? _startOffset;
  Offset? _endOffset;
  final GlobalKey gridKey = GlobalKey();
  @override
  void initState() {
    initializeGame();
    super.initState();
  }

  void initializeGame() {
    currentPlayer = playerX;
    occupied = ["", "", "", "", "", "", "", "", ""]; //9 empty places
    moves = [];
    winningLine = null;
    _startOffset = null;
    _endOffset = null;
  }

  void makeMove(int index) {
    moves.add(index); // add the index of the move to the moves list
    if (moves.length > 5) {
      occupied[moves[0]] = ""; // remove the oldest move
      moves.removeAt(0); // remove the oldest move from the moves list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _headerText(),
            _gameContainer(),
            _restartButton(),
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
    return Column(
      children: [
        const Text(
          "Tic Tac Toe",
          style: TextStyle(
            color: Colors.green,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "$currentPlayer turn",
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _gameContainer() {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      width: MediaQuery.of(context).size.height / 2,
      margin: const EdgeInsets.all(8),
      child: Stack(
        children: [
          GridView.builder(
              key: gridKey,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              itemCount: 9,
              itemBuilder: (context, int index) {
                return _box(index);
              }),
          if (_startOffset != null && _endOffset != null)
            CustomPaint(
              painter: LinePainter(_startOffset!, _endOffset!),
              child: Container(),
            ),
        ],
      ),
    );
  }

  Widget _box(int index) {
    return InkWell(
      key: keys[index],
      onTap: () {
        //on click of box
        if (winningLine != null || occupied[index].isNotEmpty) {
          //Return if game already ended or box already clicked
          return;
        }

        setState(() {
          occupied[index] = currentPlayer;
          changeTurn();
          checkForWinner();
          if (winningLine == null) {
            makeMove(index);
          }
        });
      },
      child: Container(
        color: occupied[index].isEmpty
            ? Colors.black26
            : occupied[index] == playerX
                ? Colors.blue
                : Colors.orange,
        margin: const EdgeInsets.all(8),
        child: Center(
          child: Text(
            occupied[index],
            style: const TextStyle(fontSize: 50),
          ),
        ),
      ),
    );
  }

  _restartButton() {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            initializeGame();
          });
        },
        child: const Text("Restart Game"));
  }

  changeTurn() {
    if (currentPlayer == playerX) {
      currentPlayer = playerY;
    } else {
      currentPlayer = playerX;
    }
  }

  checkForWinner() {
    //Define winning positions
    List<List<int>> winningList = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var winningPos in winningList) {
      String playerPosition0 = occupied[winningPos[0]];
      String playerPosition1 = occupied[winningPos[1]];
      String playerPosition2 = occupied[winningPos[2]];

      if (playerPosition0.isNotEmpty) {
        if (playerPosition0 == playerPosition1 &&
            playerPosition0 == playerPosition2) {
          //all equal means player won
          showGameOverMessage("Player $playerPosition0 Won");
          winningLine = winningPos;
          _setLineEndpoints(winningLine![0]);
          _setLineEndpoints(winningLine![2]);
          return;
        }
      }
    }
  }

  void _setLineEndpoints(int index) {
    final RenderBox itemRenderBox =
        keys[index].currentContext!.findRenderObject() as RenderBox;
    final Offset itemPosition = itemRenderBox.localToGlobal(Offset.zero);

    final RenderBox gridRenderBox =
        gridKey.currentContext!.findRenderObject() as RenderBox;
    final Offset gridPosition = gridRenderBox.localToGlobal(Offset.zero);

    final Offset relativePosition = itemPosition - gridPosition;

    final Size size = itemRenderBox.size;
    final Offset center =
        relativePosition + Offset(size.width / 2, size.height / 2);

    setState(() {
      if (_startOffset == null) {
        _startOffset = center;
      } else {
        _endOffset = center;
      }
    });
  }

  showGameOverMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Game Over \n $message",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
            ),
          )),
    );
  }
}

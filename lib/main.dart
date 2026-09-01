import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:math';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = '0';
  String firstNumber = '';
  String operator = '';
  String secondNumber = '';
  bool newNumber = false;
  bool showResult = false;
  bool newCalculation = false;

  String gridDigit = '';
  List<List<int>> activeCells = [];

  String activeButton = '';
  String lastAnswer = '';

  String currentTime = '';
  Timer? _clockTimer;

  

  final Map<String, List<List<int>>> digitPatterns = {
    '0': [
      [0,1], [0,2],
      [1,0],       [1,3],
      [2,0],       [2,3],
      [3,0],       [3,3],
      [4,0], [4,1], [4,2], [4,3],
    ],

    '1': [
      [0,1],
      [1,0], [1,1],
      [2,1],
      [3,1], [3,3],
      [4,0], [4,1], [4,2], [4,3],
    ],

    '2': [
      [0,1], [0,2],
      [1,3],
      [2,1], [2,2],
      [3,0],
      [4,0], [4,1], [4,2], [4,3],
    ],

    '3': [
      [0,0], [0,1],
            [1,2],
      [2,1], [2,2], 
            [3,3],
      [4,0], [4,1], [4,2], [4,3],
    ],

    '4': [
              [0,2],
      [1,1],       
      [2,0], [2,2], 
                    [3,0], [3,1], [3,2], [3,3],
                    [4,2],
    ],

    '5': [
      [0,1], [0,2],
      [1,0],
      [2,1], [2,2], 
            [3,3],
      [4,0], [4,1], [4,2],  [4,3],
    ],

    '6': [
      [0,1], [0,2],
      [1,0],
      [2,1], [2,2],
      [3,0],       [3,3],
      [4,0], [4,1], [4,2],  [4,3],
    ],

    '7': [
      [0,0], [0,1], [0,2], [0,3],
            [1,3],
            [2,1], [2,2],
            [3,2],
            [4,2],
    ],

    '8': [
      [0,1], [0,2], 
      [1,0],       [1,3],
      [2,1], [2,2],
      [3,0],       [3,3],
      [4,0], [4,1], [4,2], [4,3], 
    ],

    '9': [
      [0,1], [0,2],
      [1,0],       [1,3],
      [2,0], [2,1], [2,2],
            [3,3],
      [4,0], [4,1], [4,2], [4,3], 
    ],
  };



  final Map<String, Color> buttonColors = {
  // Chiffres
  '0': const Color(0xFFff651b),
  '1': const Color(0xFFff651b),
  '2': const Color(0xFFff651b),
  '3': const Color(0xFFff651b),
  '4': const Color(0xFFff651b),
  '5': const Color(0xFFff651b),
  '6': const Color(0xFFff651b),
  '7': const Color(0xFFff651b),
  '8': const Color(0xFFff651b),
  '9': const Color(0xFFff651b),

  // Opérateurs
  '+': const Color(0xFF1f39ff),
  '−': const Color(0xFF1f39ff),
  '×': const Color(0xFF1f39ff),
  '÷': const Color(0xFF1f39ff),

  // Actions
  '=': const Color(0xFF2196F3),
  'DEL': const Color(0xFFfe0000),
  'AC': const Color(0xFFffffff),
  '±': const Color(0xFFffcc00),
  
  // Virgule / point
  '.': const Color(0xFFffcc00),

  // Parenthèses
  '( )': const Color(0xFFffcc00),

};



  final List<Timer> _cellTimers = [];


  @override
  void initState() {
    super.initState();

    _updateClock();

    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateClock(),
    );
  }

  void _updateClock() {
    final now = DateTime.now();

    if (!mounted) return;

    setState(() {
      currentTime =
          '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}:'
          '${now.second.toString().padLeft(2, '0')}';
    });
  }



  
  @override
  void dispose() {
    _clockTimer?.cancel();

    for (final timer in _cellTimers) {
      timer.cancel();
    }
    _cellTimers.clear();

    super.dispose();
  }
  



  void animateCellsRandomly(String digit) {
    // Annuler toutes les anciennes animations
    for (final timer in _cellTimers) {
      timer.cancel();
    }
    _cellTimers.clear();

    final cells = List<List<int>>.from(
      digitPatterns[digit]!.map((cell) => List<int>.from(cell)),
    );

    final random = Random();

    // Mélange aléatoire pour l'apparition
    cells.shuffle(random);

    activeCells = [];

    // APPARITION ALÉATOIRE
    for (int i = 0; i < cells.length; i++) {
      final cell = cells[i];

      final timer = Timer(
        Duration(milliseconds: 100 * i),
        () {
          if (!mounted) return;

          setState(() {
            activeCells.add(cell);
          });
        },
      );

      _cellTimers.add(timer);
    }

    // Temps nécessaire pour que toutes les cellules apparaissent
    final appearanceDuration = 100 * cells.length;

    // DISPARITION ALÉATOIRE
    final disappearCells = List<List<int>>.from(
      cells.map((cell) => List<int>.from(cell)),
    );

    disappearCells.shuffle(random);

    for (int i = 0; i < disappearCells.length; i++) {
      final cell = disappearCells[i];

      final timer = Timer(
        Duration(
          milliseconds: appearanceDuration + 1500 + (100 * i),
        ),
        () {
          if (!mounted) return;

          setState(() {
            activeCells.removeWhere(
              (activeCell) =>
                  activeCell[0] == cell[0] &&
                  activeCell[1] == cell[1],
            );
          });
        },
      );

      _cellTimers.add(timer);
    }
  }



  



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [

            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentTime,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'offbit-regular',
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    'DR-5',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'offbit-regular',
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            // ÉCRAN
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(25, 10, 25, 0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white24,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [

                    // GRID
                    CustomPaint(
                      size: Size.infinite,
                      painter: GridPainter(),
                    ),



                    Positioned(
                      top: 320,
                      left: 0,
                      right: 0,
                      child: SizedBox(
                        width: 400,
                        height: 450,
                        child: Column(
                          children: List.generate(
                            5,
                            (row) => Expanded(
                              child: Row(
                                children: List.generate(
                                  4,
                                  (col) => Expanded(
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeOut,
                                      margin: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: activeCells.any(
                                          (cell) =>
                                              cell[0] == row &&
                                              cell[1] == col,
                                        )
                                            ? const Color(0xFFFFFFFF).withValues(alpha: 0.3)
                                            : Colors.transparent,

                                        border: Border.all(
                                          color: Colors.transparent,
                                        ),

                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    

                    // TEXTE SYSTEME
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LAST ANS:',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'OffBit-Regular',
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),

                          const SizedBox(height: 2),

                          GestureDetector(
                            onTap: () {
                              // S'il n'y a encore aucun résultat, on ne fait rien
                              if (lastAnswer.isEmpty) return;

                              setState(() {
                                display = lastAnswer;
                                firstNumber = '';

                                secondNumber = '';
                                operator = '';
                                newNumber = false;
                                newCalculation = false;
                                showResult = false;
                              });
                            },

                            child: Text(
                              lastAnswer.isEmpty
                                  ? '0000000000000'
                                  : lastAnswer,
                              style: const TextStyle(
                                color: Color(0xFFF24B29),
                                fontFamily: 'OffBit-Regular',
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // RESULTAT
                    // CALCUL LINÉAIRE
                    Positioned(
                      bottom: -10,
                      left: 15,
                      right: 25,
                      child: SizedBox(
                        width: double.infinity,
                        height: 150,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.bottomRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [

                                // PREMIER NOMBRE
                                Text(
                                  showResult
                                      ? display
                                      : (firstNumber.isEmpty ? display : firstNumber),
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(
                                    color: showResult
                                        ? const Color(0xFF2196F3)
                                        : Colors.white,
                                    fontSize: 120,
                                    fontFamily: 'OffBit-Dot',
                                  ),
                                ),

                                // OPÉRATEUR
                                if (operator.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    child: Text(
                                      operator,
                                      style: const TextStyle(
                                        color: const Color(0xFF1f39ff),
                                        fontSize: 80,
                                        fontFamily: 'OffBit-Dot',
                                      ),
                                    ),
                                  ),

                                // DEUXIÈME NOMBRE
                                if (secondNumber.isNotEmpty)
                                  Text(
                                    secondNumber,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: const TextStyle(
                                      color: const Color(0xFFff651b),
                                      fontSize: 100,
                                      fontFamily: 'OffBit-Dot',
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // CLAVIER
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  row(['AC', '( )', '±', 'DEL']),
                  row(['7', '8', '9', '÷']),
                  row(['4', '5', '6', '×']),
                  row(['1', '2', '3', '−']),
                  row(['0', '.', '=', '+']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget row(List<String> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.map((e) => button(e)).toList(),
    );
  }

  Widget button(String text) {
    return SizedBox(
      width: 90,
      child: GestureDetector(
        onTap: () {
          setState(() {
            activeButton = text;
          });

          Timer(const Duration(milliseconds: 500), () {
            if (!mounted) return;

            setState(() {
              if (activeButton == text) {
                activeButton = '';
              }
            });
          });

          setState(() {

            // AC — RESET COMPLET
            if (text == 'AC') {
              display = '0';
              firstNumber = '';
              operator = '';
              secondNumber = '';
              newNumber = false;
              newCalculation = false;
              showResult = false;
              return;
            }

            // DEL — SUPPRIMER LE DERNIER ÉLÉMENT DU CALCUL
            if (text == 'DEL') {

              // DEUXIÈME NOMBRE
              if (operator.isNotEmpty && secondNumber.isNotEmpty) {

                if (secondNumber.length > 1) {
                  secondNumber =
                      secondNumber.substring(0, secondNumber.length - 1);
                } else {
                  secondNumber = '';
                  newNumber = true;
                }

                return;
              }

              // OPÉRATEUR
              if (operator.isNotEmpty && secondNumber.isEmpty) {

                operator = '';
                newNumber = false;

                // Le premier nombre redevient le nombre affiché
                display = firstNumber;

                // On vide firstNumber pour revenir à la saisie normale
                firstNumber = '';

                return;
              }

              // PREMIER NOMBRE
              if (operator.isEmpty) {

                if (display.length > 1) {
                  display =
                      display.substring(0, display.length - 1);
                } else {
                  display = '0';
                }

                return;
              }

              return;
            }

            // POSITIF / NÉGATIF
            if (text == '±') {
              if (display != '0') {
                if (display.startsWith('-')) {
                  display = display.substring(1);
                } else {
                  display = '-$display';
                }
              }
              return;
            }


            // CHIFFRE OU POINT
            if (text == '.' || int.tryParse(text) != null) {



              if (digitPatterns.containsKey(text)) {
                animateCellsRandomly(text);
              }

              // Nouveau calcul après "="
              if (newCalculation) {
                display = text;
                newCalculation = false;
                showResult = false;
              }

              // Nouveau deuxième nombre après un opérateur
              else if (newNumber) {
                secondNumber = text;
                newNumber = false;
              }

              // On continue le deuxième nombre
              else if (operator.isNotEmpty) {
                secondNumber += text;
              }

              // Premier nombre
              else if (display == '0') {
                if (text == '.') {
                  display = '0.';
                } else {
                  display = text;
                }
              }

              else {
                display += text;
              }
            }


            // OPÉRATEUR
            if (text == '+' ||
                text == '−' ||
                text == '×' ||
                text == '÷') {

              firstNumber = display;
              operator = text;
              newNumber = true;
              newCalculation = false;
            }


            // ÉGAL
            if (text == '=') {
              double first = double.parse(firstNumber);
              double second = double.parse(secondNumber);

              double result = 0;

              if (operator == '+') {
                result = first + second;
              } else if (operator == '−') {
                result = first - second;
              } else if (operator == '×') {
                result = first * second;
              } else if (operator == '÷') {
                result = first / second;
              }

              // Garde uniquement le résultat
              display = result.toString();

              // MÉMORISE LE DERNIER RÉSULTAT
              lastAnswer = display;

              // Reset du calcul
              firstNumber = '';
              operator = '';
              secondNumber = '';
              newNumber = false;
              newCalculation = true;
              showResult = true;
            }

          });
        },

        child: Padding(
          padding: const EdgeInsets.all(5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            height: 80,
            decoration: BoxDecoration(
              color: activeButton == text
                  ? buttonColors[text] ?? Colors.white
                  : Colors.transparent,
              border: Border.all(
                color: Colors.white24,
              ),

              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'OffBit-Regular',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 0.5;

    const step = 20.0;

    // Coins arrondis du quadrillage
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(25),
      ),
    );

    // Lignes verticales
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Lignes horizontales
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

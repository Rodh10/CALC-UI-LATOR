import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

                              HapticFeedback.selectionClick();

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
                    // RESULTAT
                    // CALCUL LINÉAIRE
                    Positioned(
                      bottom: 0,
                      left: 15,
                      right: 15,
                      child: SizedBox(
                        width: double.infinity,
                        height: 150,
                        child: RollingCalculationDisplay(
                          firstNumber: showResult
                              ? display
                              : (firstNumber.isEmpty ? display : firstNumber),
                          operator: operator,
                          secondNumber: secondNumber,
                          showResult: showResult,
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
                  row(['7', '8', '9', '+']),
                  row(['4', '5', '6', '−']),
                  row(['1', '2', '3', '×']),
                  row(['0', '.', '=', '÷']),
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

  Future<void> _vibrateButton(String text) async {
    // CHIFFRES
    if (int.tryParse(text) != null) {
      await HapticFeedback.lightImpact();
      return;
    }

    // OPÉRATEURS : ··
    if (text == '+' ||
        text == '−' ||
        text == '×' ||
        text == '÷') {
      await HapticFeedback.lightImpact();

      await Future.delayed(
        const Duration(milliseconds: 55),
      );

      await HapticFeedback.lightImpact();
      return;
    }

    // DEL : —
    if (text == 'DEL') {
      await HapticFeedback.mediumImpact();
      return;
    }

    // AC : — ·
    if (text == 'AC') {
      await HapticFeedback.heavyImpact();

      await Future.delayed(
        const Duration(milliseconds: 90),
      );

      await HapticFeedback.lightImpact();
      return;
    }

    // ÉGAL : ——
    if (text == '=') {
      await HapticFeedback.mediumImpact();

      await Future.delayed(
        const Duration(milliseconds: 100),
      );

      await HapticFeedback.heavyImpact();
      return;
    }

    // ± : · ·
    if (text == '±') {
      await HapticFeedback.lightImpact();

      await Future.delayed(
        const Duration(milliseconds: 70),
      );

      await HapticFeedback.lightImpact();
      return;
    }

    // POINT : · très léger
    if (text == '.') {
      await HapticFeedback.selectionClick();
      return;
    }

    // PARENTHESES : ·—
    if (text == '( )') {
      await HapticFeedback.selectionClick();

      await Future.delayed(
        const Duration(milliseconds: 80),
      );

      await HapticFeedback.mediumImpact();
      return;
    }
  }


  Widget button(String text) {
    return SizedBox(
      width: 90,
      child: GestureDetector(
        onTap: () {
          _vibrateButton(text);

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



class RollingCalculationDisplay extends StatefulWidget {
  final String firstNumber;
  final String operator;
  final String secondNumber;
  final bool showResult;

  const RollingCalculationDisplay({
    super.key,
    required this.firstNumber,
    required this.operator,
    required this.secondNumber,
    required this.showResult,
  });

  @override
  State<RollingCalculationDisplay> createState() =>
      _RollingCalculationDisplayState();
}


class _RollingCalculationDisplayState
    extends State<RollingCalculationDisplay>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  String _oldValue = '';
  String _previousValue = '';

  @override
  void initState() {
    super.initState();

    _oldValue = _buildValue();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }


  String _buildValue() {
    return widget.firstNumber +
        widget.operator +
        widget.secondNumber;
  }


  @override
  void didUpdateWidget(
    covariant RollingCalculationDisplay oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    final newValue = _buildValue();

    if (newValue == _oldValue) {
      return;
    }

    final previousValue = _oldValue;

    _oldValue = newValue;

    // ----------------------------------------------------------
    // NOUVEAU CARACTÈRE
    // ----------------------------------------------------------

    if (newValue.length > previousValue.length &&
        newValue.startsWith(previousValue)) {

      _controller.forward(from: 0);
    }

    // ----------------------------------------------------------
    // DEL / AC / RÉSULTAT
    // ----------------------------------------------------------

    else {
      _controller.stop();
      _controller.value = 1;
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {

            return CustomPaint(
              size: Size(
                constraints.maxWidth,
                150,
              ),

              painter: _RollingCalculationPainter(
                firstNumber: widget.firstNumber,
                operator: widget.operator,
                secondNumber: widget.secondNumber,
                oldValue: _oldValue,
                progress: _controller.value,
                showResult: widget.showResult,
              ),
            );
          },
        );
      },
    );
  }
}


class _RollingCalculationPainter extends CustomPainter {

  final String firstNumber;
  final String operator;
  final String secondNumber;

  final String oldValue;

  final double progress;

  final bool showResult;


  _RollingCalculationPainter({
    required this.firstNumber,
    required this.operator,
    required this.secondNumber,
    required this.oldValue,
    required this.progress,
    required this.showResult,
  });


  static const TextStyle numberStyle = TextStyle(
    fontSize: 100,
    fontFamily: 'OffBit-Dot',
    height: 1,
  );


  static const TextStyle operatorStyle = TextStyle(
    fontSize: 80,
    fontFamily: 'OffBit-Dot',
    height: 1,
  );


  // ------------------------------------------------------------
  // CONSTRUIT LA SÉQUENCE COMPLÈTE
  // ------------------------------------------------------------

  List<_CalculationCharacter> _characters() {

    final characters = <_CalculationCharacter>[];


    // PREMIER NOMBRE
    for (final char in firstNumber.split('')) {
      characters.add(
        _CalculationCharacter(
          char: char,
          color: showResult
              ? const Color(0xFF2196F3)
              : Colors.white,
          isOperator: false,
        ),
      );
    }


    // OPÉRATEUR
    if (operator.isNotEmpty) {
      characters.add(
        _CalculationCharacter(
          char: operator,
          color: const Color(0xFF1f39ff),
          isOperator: true,
        ),
      );
    }


    // DEUXIÈME NOMBRE
    for (final char in secondNumber.split('')) {
      characters.add(
        _CalculationCharacter(
          char: char,
          color: const Color(0xFFff651b),
          isOperator: false,
        ),
      );
    }


    return characters;
  }


  @override
  void paint(Canvas canvas, Size size) {

    final characters = _characters();

    if (characters.isEmpty) {
      return;
    }


    // ----------------------------------------------------------
    // LARGEUR DE CHAQUE TYPE DE CARACTÈRE
    // ----------------------------------------------------------

    double characterWidth(
      _CalculationCharacter character,
    ) {

      final painter = TextPainter(
        text: TextSpan(
          text: character.char,
          style: character.isOperator
              ? operatorStyle.copyWith(
                  color: character.color,
                )
              : numberStyle.copyWith(
                  color: character.color,
                ),
        ),
        textDirection: TextDirection.ltr,
      );

      painter.layout();

      return painter.width;
    }


    // ----------------------------------------------------------
    // CALCUL DE LA POSITION
    //
    // TOUS LES ÉLÉMENTS utilisent exactement le même chemin.
    // ----------------------------------------------------------

    Offset positionOf(
      int index,
      List<_CalculationCharacter> list,
    ) {

      double usedWidth = 0;

      int line = 0;

      double currentX = size.width;


      // On parcourt depuis la DROITE.
      for (int i = list.length - 1; i >= index; i--) {

        final width = characterWidth(list[i]);


        // Si le caractère ne rentre plus sur la ligne,
        // on monte d'une ligne.
        if (currentX - width < 0) {

          line++;

          currentX = size.width;
        }


        if (i == index) {

          return Offset(
            currentX - width,
            size.height -
                100 -
                (line * 100),
          );
        }


        currentX -= width;
      }


      return Offset(
        0,
        size.height - 100,
      );
    }


    final animation =
        Curves.easeOutCubic.transform(progress);


    final isAdding =
        characters.length > oldValue.length &&
        _buildCurrentString().startsWith(oldValue);


    // ----------------------------------------------------------
    // ANIMATION D'UN NOUVEAU CARACTÈRE
    // ----------------------------------------------------------

    if (isAdding) {

      // --------------------------------------------
      // ANCIENS CARACTÈRES
      // --------------------------------------------

      for (int i = 0;
          i < characters.length - 1;
          i++) {

        final character = characters[i];

        final oldCharacters =
            characters.sublist(
          0,
          characters.length - 1,
        );


        final oldPosition =
            positionOf(i, oldCharacters);

        final newPosition =
            positionOf(i, characters);


        final x =
            oldPosition.dx +
            (newPosition.dx - oldPosition.dx) *
                animation;


        final y =
            oldPosition.dy +
            (newPosition.dy - oldPosition.dy) *
                animation;


        _drawCharacter(
          canvas,
          character,
          Offset(x, y),
        );
      }


      // --------------------------------------------
      // NOUVEAU CARACTÈRE
      //
      // ARRIVE DEPUIS LA DROITE
      // --------------------------------------------

      final newIndex =
          characters.length - 1;


      final target =
          positionOf(
            newIndex,
            characters,
          );


      final startX = size.width;


      final x =
          startX +
          (target.dx - startX) *
              animation;


      _drawCharacter(
        canvas,
        characters[newIndex],
        Offset(
          x,
          target.dy,
        ),
      );


      return;
    }


    // ----------------------------------------------------------
    // AFFICHAGE NORMAL
    // ----------------------------------------------------------

    for (int i = 0;
        i < characters.length;
        i++) {

      final position =
          positionOf(
            i,
            characters,
          );


      _drawCharacter(
        canvas,
        characters[i],
        position,
      );
    }
  }


  String _buildCurrentString() {
    return firstNumber +
        operator +
        secondNumber;
  }


  void _drawCharacter(
    Canvas canvas,
    _CalculationCharacter character,
    Offset position,
  ) {

    final style = character.isOperator
        ? operatorStyle
        : numberStyle;


    final painter = TextPainter(
      text: TextSpan(
        text: character.char,
        style: style.copyWith(
          color: character.color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );


    painter.layout();


    painter.paint(
      canvas,
      position,
    );
  }


  @override
  bool shouldRepaint(
    covariant _RollingCalculationPainter oldDelegate,
  ) {

    return oldDelegate.firstNumber != firstNumber ||
        oldDelegate.operator != operator ||
        oldDelegate.secondNumber != secondNumber ||
        oldDelegate.progress != progress ||
        oldDelegate.showResult != showResult;
  }
}


class _CalculationCharacter {

  final String char;

  final Color color;

  final bool isOperator;


  _CalculationCharacter({
    required this.char,
    required this.color,
    required this.isOperator,
  });
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

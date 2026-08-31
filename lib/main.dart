import 'package:flutter/material.dart';

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
                vertical: 15,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    '00:25:05',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Courier',
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'DR-5',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Courier',
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            // ÉCRAN
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white24,
                  ),
                ),
                child: Stack(
                  children: [

                    // GRID
                    CustomPaint(
                      size: Size.infinite,
                      painter: GridPainter(),
                    ),



                    Center(
                      child: SizedBox(
                        width: 240,
                        height: 300,
                        child: Column(
                          children: List.generate(
                            5,
                            (row) => Expanded(
                              child: Row(
                                children: List.generate(
                                  4,
                                  (col) => Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: activeCells.any(
                                          (cell) => cell[0] == row && cell[1] == col,
                                        )

                                            ? Colors.white
                                            : Colors.transparent,

                                        border: Border.all(
                                          color: Colors.white24,
                                        ),

                                        borderRadius: BorderRadius.circular(100),
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'DERNIER REP (AC):',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Courier',
                              fontSize: 20,
                              letterSpacing: 2,
                            ),
                          ),

                          SizedBox(height: 20),

                          Text(
                            '0011011011011001101',
                            style: TextStyle(
                              color: Colors.white54,
                              fontFamily: 'OffBit-Regular',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // RESULTAT
                    Positioned(
                      bottom: 40,
                      right: 25,
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        children: [

                          Text(
                            showResult ? display : (firstNumber.isEmpty ? display : firstNumber),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 120,
                              fontFamily: 'OffBit-Dot',
                              height: 0.8,
                            ),
                          ),

                          Text(
                            operator,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 40,
                              fontFamily: 'OffBit-Dot',
                            ),
                          ),

                          Text(
                            secondNumber,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 70,
                              fontFamily: 'OffBit-Dot',
                            ),
                          ),
                        ],
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
      children:
          items.map((e) => button(e)).toList(),
    );
  }

  Widget button(String text) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
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

            // DEL — SUPPRIMER LE DERNIER CARACTÈRE
            if (text == 'DEL') {
              if (display.length > 1) {
                display = display.substring(0, display.length - 1);
              } else {
                display = '0';
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


              final Map<String, List<List<int>>> digitPatterns = {
                '0': [
                  [0,0], [0,1], [0,2],
                  [1,0],       [1,2],
                  [2,0],       [2,2],
                  [3,0],       [3,2],
                  [4,0], [4,1], [4,2],
                ],

                '1': [
                  [0,1],
                  [1,0], [1,1],
                  [2,1],
                  [3,1],
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
                  [0,0], [0,1], [0,2],
                        [1,2],
                  [2,0], [2,1], [2,2],
                        [3,2],
                  [4,0], [4,1], [4,2],
                ],

                '4': [
                  [0,0],       [0,2],
                  [1,0],       [1,2],
                  [2,0], [2,1], [2,2],
                                [3,2],
                                [4,2],
                ],

                '5': [
                  [0,0], [0,1], [0,2],
                  [1,0],
                  [2,0], [2,1], [2,2],
                        [3,2],
                  [4,0], [4,1], [4,2],
                ],

                '6': [
                  [0,0], [0,1], [0,2],
                  [1,0],
                  [2,0], [2,1], [2,2],
                  [3,0],       [3,2],
                  [4,0], [4,1], [4,2],
                ],

                '7': [
                  [0,0], [0,1], [0,2],
                        [1,2],
                        [2,2],
                        [3,2],
                        [4,2],
                ],

                '8': [
                  [0,0], [0,1], [0,2],
                  [1,0],       [1,2],
                  [2,0], [2,1], [2,2],
                  [3,0],       [3,2],
                  [4,0], [4,1], [4,2],
                ],

                '9': [
                  [0,0], [0,1], [0,2],
                  [1,0],       [1,2],
                  [2,0], [2,1], [2,2],
                        [3,2],
                  [4,0], [4,1], [4,2],
                ],
              };

              if (digitPatterns.containsKey(text)) {
                activeCells = digitPatterns[text]!;
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
                display = text;
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
          padding: const EdgeInsets.all(4),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white24,
              ),
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

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

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
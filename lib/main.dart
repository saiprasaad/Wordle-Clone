import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

// Todo:
// Keyboard press
// Fade in keyboard

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<List<String>> textValues = List.generate(6, (i) => List.filled(5, ""));
  late Future<Map<String, List<int>>> indexMap;
  late String word;

  List<List<String>> textValuesPresence =
      List.generate(6, (i) => List.filled(5, ""));
  var randomWord = List.filled(5, "");

  @override
  void initState() {
    super.initState();
    indexMap = getRandomWord();
  }

  final alphabetsMap = {
    0: "Q",
    1: "W",
    2: "E",
    3: "R",
    4: "T",
    5: "Y",
    6: "U",
    7: "I",
    8: "O",
    9: "P",
    10: "A",
    11: "S",
    12: "D",
    13: "F",
    14: "G",
    15: "H",
    16: "J",
    17: "K",
    18: "L",
    20: "Z",
    21: "X",
    22: "C",
    23: "V",
    24: "B",
    25: "N",
    26: "M"
  };
  int row = 0, column = 0;
  bool validWord = false;

  int getAlphabetPosition(int i, int j) {
    if (i < 1) {
      return j;
    } else if (i < 2) {
      return 10 + j;
    } else {
      return 19 + j;
    }
  }

  Future<Map<String, List<int>>> getRandomWord() async {
    Map<String, List<int>> compareMap = {};
    String apiUrl =
        'https://api.wordnik.com/v4/words.json/randomWord?hasDictionaryDef=true&minLength=5&maxLength=5&api_key=50wn9urpdtws87eu1p22kxln8onnw2wd1qe8uaqvb2knw3e7k';
    var response = await http.get(Uri.parse(apiUrl));
    String value = "";
    RegExp regex = RegExp(r'^[a-zA-Z]+$');
    if (response.statusCode == 200) {
      while (!validWord) {
        if (value.isNotEmpty) {
          response = await http.get(Uri.parse(apiUrl));
        }
        final dynamic responseData = json.decode(response.body);
        value = responseData["word"];
        word = value.toLowerCase();
        var check = await wordExists(word);
        if (check || regex.hasMatch(word)) {
          validWord = true;
        }
      }
      print(value);
      for (int i = 0; i < value.length; i++) {
        randomWord[i] = value[i];
      }
      for (int i = 0; i < randomWord.length; i++) {
        if (compareMap.containsKey(randomWord[i])) {
          compareMap[randomWord[i]]!.add(i + 1);
        } else {
          compareMap[randomWord[i]] = [i + 1];
        }
      }
      return compareMap;
    } else {
      throw Exception('Failed to fetch random word');
    }
  }

  Future<bool> wordExists(String word) async {
    String endpoint = 'https://api.dictionaryapi.dev/api/v2/entries/en/$word';

    try {
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    int count = -1;
    String wordToCheck = "";
    var screenHeight = MediaQuery.of(context).size.height;
    var blockHeight = MediaQuery.of(context).size.height / 1.5;
    var keyboardHeight = screenHeight - blockHeight;
    var screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 500) {
      screenWidth = 500;
    }
    print(screenHeight);
    print(blockHeight);
    print(keyboardHeight);

    return MaterialApp(
      title: 'Flutter Demo',
      home: FutureBuilder<Map<String, List<int>>>(
        future: indexMap,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            final compareMap = snapshot.data as Map<String, List<int>>;
            count = -1;
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  "Wordle",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
              ),
              body: Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        height: blockHeight,
                        child: Column(
                          children: List.generate(6, (i) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (j) {
                                return SizedBox(
                                  width: 65,
                                  height: blockHeight / 7.5,
                                  child: Card(
                                    color: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Colors.black26, width: 1),
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    child: AnimatedContainer(
                                      color: i >= row
                                          ? Colors.white
                                          : (textValuesPresence[i][j] ==
                                                  "Correct"
                                              ? const Color(0xff6ca965)
                                              : (textValuesPresence[i][j] ==
                                                      "Partial"
                                                  ? const Color(0xffc8b653)
                                                  : const Color(0xff787c7f))),
                                      duration:
                                          const Duration(milliseconds: 1000),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            textValues[i][j],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: screenWidth * 0.060,
                                              color: textValuesPresence[i][j]
                                                      .isNotEmpty
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            );
                          }),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                          height: keyboardHeight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: List.generate(3, (i) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                    i == 0 ? 10 : (i == 1 ? 9 : 9), (j) {
                                  count++;
                                  return count == 19
                                      ? SizedBox(
                                          height: keyboardHeight / 3,
                                          width: screenWidth / 6,
                                          child: GestureDetector(
                                            onTap: () async {
                                              for (var c = 0;
                                                  c < textValues[row].length;
                                                  c++) {
                                                wordToCheck +=
                                                    textValues[row][c];
                                              }
                                              var isValidWord =
                                                  await wordExists(wordToCheck);
                                              setState(() {
                                                if (isValidWord) {
                                                  if (word.toLowerCase() ==
                                                      wordToCheck
                                                          .toLowerCase()) {
                                                    setState(() {
                                                      for (int col = 0;
                                                          col <
                                                              textValues[row]
                                                                  .length;
                                                          col++) {
                                                        textValuesPresence[row]
                                                            [col] = "Correct";
                                                      }
                                                      row = row + 1;
                                                      column = 0;

                                                      showDialog<String>(
                                                        barrierDismissible:
                                                            false,
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            AlertDialog(
                                                          title: const Text(
                                                              'You Won!'),
                                                          content: const Text(
                                                              'Congratulations! You have guessed the word correctly!'),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed: () => {
                                                                setState(() {
                                                                  count = -1;
                                                                  validWord =
                                                                      false;
                                                                  row = 0;
                                                                  column = 0;
                                                                  textValues = List.generate(
                                                                      6,
                                                                      (i) => List
                                                                          .filled(
                                                                              5,
                                                                              ""));
                                                                  textValuesPresence =
                                                                      List.generate(
                                                                          6,
                                                                          (i) => List.filled(
                                                                              5,
                                                                              ""));
                                                                  randomWord =
                                                                      List.filled(
                                                                          5,
                                                                          "");
                                                                  indexMap =
                                                                      getRandomWord();
                                                                  Navigator.pop(
                                                                      context,
                                                                      'Start Again');
                                                                })
                                                              },
                                                              child: const Text(
                                                                  'Start Again'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    });
                                                  } else {
                                                    for (int col = 0;
                                                        col <
                                                            textValues[row]
                                                                .length;
                                                        col++) {
                                                      if (compareMap.containsKey(
                                                          textValues[row][col]
                                                              .toLowerCase())) {
                                                        if (compareMap[textValues[
                                                                            row]
                                                                        [col]
                                                                    .toLowerCase()]!
                                                                .isNotEmpty &&
                                                            compareMap[textValues[
                                                                            row]
                                                                        [col]
                                                                    .toLowerCase()]!
                                                                .contains(
                                                                    col + 1)) {
                                                          textValuesPresence[
                                                                  row][col] =
                                                              "Correct";
                                                        } else {
                                                          textValuesPresence[
                                                                  row][col] =
                                                              "Partial";
                                                        }
                                                      } else {
                                                        textValuesPresence[row]
                                                            [col] = "Inorrect";
                                                      }
                                                    }
                                                    row = row + 1;
                                                    column = 0;
                                                    if (row == 6) {
                                                      showDialog<String>(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            AlertDialog(
                                                          title: const Text(
                                                              'You Lost!'),
                                                          content: Text(
                                                              "The word was $word, That's Okay! Try Again!"),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed: () => {
                                                                setState(() {
                                                                  count = -1;
                                                                  row = 0;
                                                                  validWord =
                                                                      false;
                                                                  column = 0;
                                                                  textValues = List.generate(
                                                                      6,
                                                                      (i) => List
                                                                          .filled(
                                                                              5,
                                                                              ""));
                                                                  textValuesPresence =
                                                                      List.generate(
                                                                          6,
                                                                          (i) => List.filled(
                                                                              5,
                                                                              ""));
                                                                  randomWord =
                                                                      List.filled(
                                                                          5,
                                                                          "");
                                                                  indexMap =
                                                                      getRandomWord();
                                                                  Navigator.pop(
                                                                      context,
                                                                      'OK');
                                                                })
                                                              },
                                                              child: const Text(
                                                                  'OK'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                          const SnackBar(
                                                    content: Text(
                                                        'Not a valid word!'),
                                                  ));
                                                }
                                              });
                                            },
                                            child: Card(
                                              color: Colors.grey[300],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              elevation: 2,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "ENTER",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: screenWidth *
                                                            0.045),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : (count != 27
                                          ? SizedBox(
                                              width: screenWidth / 11,
                                              height: keyboardHeight / 3,
                                              child: GestureDetector(
                                                onTap: () => {
                                                  setState(() {
                                                    if (row < 6 && column < 5) {
                                                      textValues[row][
                                                          column] = alphabetsMap[
                                                              getAlphabetPosition(
                                                                  i, j)] ??
                                                          "";
                                                      column = column + 1;
                                                    }
                                                  })
                                                },
                                                child: Card(
                                                  color: Colors.grey[300],
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  elevation: 2,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        alphabetsMap[count]
                                                                ?.toString() ??
                                                            "",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                screenWidth *
                                                                    0.060),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          : SizedBox(
                                              width: screenWidth / 8,
                                              height: keyboardHeight / 3,
                                              child: GestureDetector(
                                                onTap: () => {
                                                  setState(
                                                    () {
                                                      if (column - 1 >= 0) {
                                                        textValues[row]
                                                            [column - 1] = "";
                                                        column = column - 1;
                                                      }
                                                    },
                                                  )
                                                },
                                                child: Card(
                                                  color: Colors.grey[300],
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  elevation: 2,
                                                  child: const Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.backspace),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ));
                                }),
                              );
                            }),
                          ),
                        )),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

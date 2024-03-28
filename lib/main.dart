import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

// Todo:
// Dialog win/lose
// Keyboard press
// Fade in keyboard

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<List<String>> textValues = List.generate(6, (i) => List.filled(5, ""));
  late final Future<Map<String, List<int>>> indexMap;

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
    String apiUrl = 'https://random-word-api.herokuapp.com/word?length=5';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);
      String value = responseData[0];
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
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    centerTitle: true,
                  ),
                  body: Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(children: [
                        Column(
                            children: List.generate(6, (i) {
                          return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (j) {
                                return SizedBox(
                                    width: 65,
                                    height: 65,
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
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold,
                                                  color: textValuesPresence[i]
                                                              [j]
                                                          .isNotEmpty
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              )
                                            ]),
                                      ),
                                    ));
                              }));
                        })),
                        const Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                        Column(
                            children: List.generate(3, (i) {
                          return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                  i == 0 ? 10 : (i == 1 ? 9 : 9), (j) {
                                count++;
                                return count == 19
                                    ? SizedBox(
                                        width:  MediaQuery.of(context).size.width < 500 ? 55 : 70,
                                        height: 60,
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
                                                  for (int col = 0;
                                                      col <
                                                          textValues[row]
                                                              .length;
                                                      col++) {
                                                    if (compareMap.containsKey(
                                                        textValues[row][col]
                                                            .toLowerCase())) {
                                                      if (compareMap[textValues[
                                                                      row][col]
                                                                  .toLowerCase()]!
                                                              .isNotEmpty &&
                                                          compareMap[textValues[
                                                                      row][col]
                                                                  .toLowerCase()]!
                                                              .contains(
                                                                  col + 1)) {
                                                        textValuesPresence[row]
                                                            [col] = "Correct";
                                                      } else {
                                                        textValuesPresence[row]
                                                            [col] = "Partial";
                                                      }
                                                    } else {
                                                      textValuesPresence[row]
                                                          [col] = "Inorrect";
                                                    }
                                                  }
                                                  row = row + 1;
                                                  column = 0;
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                          const SnackBar(
                                                    content: Text(
                                                        'Not a valid word!'),
                                                  ));
                                                }
                                              });

                                              // }
                                              // }
                                              // else {
                                              //   Fluttertoast.showToast(
                                              //     msg: "Not a valid word!",
                                              //     toastLength: Toast.LENGTH_SHORT,
                                              //     gravity: ToastGravity.BOTTOM,
                                              //     backgroundColor: Colors.grey,
                                              //     textColor: Colors.white,
                                              //     fontSize: 16.0,
                                              //   );
                                              // }
                                              // }
                                            },
                                            child: Card(
                                              color: Colors.grey[300],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              elevation: 2,
                                              child: const Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "ENTER",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  ]),
                                            )),
                                      )
                                    : (count != 27
                                        ? SizedBox(
                                            width: MediaQuery.of(context).size.width < 500 ? 35 : 50,
                                            height: 60,
                                            child: GestureDetector(
                                                onTap: () => {
                                                      setState(() {
                                                        if (row < 6 &&
                                                            column < 5) {
                                                          textValues[row]
                                                                  [column] =
                                                              alphabetsMap[
                                                                      getAlphabetPosition(
                                                                          i,
                                                                          j)] ??
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
                                                          style: const TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      ]),
                                                )),
                                          )
                                        : SizedBox(
                                           width: MediaQuery.of(context).size.width < 500 ? 50 : 70,
                                            height: 60,
                                            child: GestureDetector(
                                                onTap: () => {
                                                      setState(
                                                        () {
                                                          if (column - 1 >= 0) {
                                                            textValues[row][
                                                                column -
                                                                    1] = "";
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
                                                        Icon(Icons.backspace,
                                                            size: 20),
                                                      ]),
                                                )),
                                          ));
                              }));
                        }))
                      ])));
            }
          }),
    );
  }
}

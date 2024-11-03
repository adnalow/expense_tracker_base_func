import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  int tbalance = 0; // Total balance
  List<Map<String, dynamic>> history = []; // List to store title, amount, and timestamp history

  final titleController = TextEditingController();
  final amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData(); // Load data when the app starts
  }

  // Function to load data from local storage
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      tbalance = prefs.getInt('tbalance') ?? 0;
      String? historyString = prefs.getString('history');
      if (historyString != null) {
        history = List<Map<String, dynamic>>.from(
          historyString.split(';').where((entry) => entry.isNotEmpty).map((entry) {
            List<String> parts = entry.split('|');
            return {
              "title": parts[0],
              "amount": int.parse(parts[1]),
              "timestamp": parts[2],
            };
          }),
        );
      }
    });
  }


  // Function to save data to local storage
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('tbalance', tbalance);
    String historyString = history.map((entry) {
      return '${entry["title"]}|${entry["amount"]}|${entry["timestamp"]}';
    }).join(';');
    prefs.setString('history', historyString);
  }

  void _showAdjustDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Adjust Balance", textAlign: TextAlign.center,),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Adjust dialog size
          children: [
            TextField(
              controller: amountController, // Reuse your existing controller
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Balance",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () async {
              int? amount = int.tryParse(amountController.text);
              if (amount != null) {
                setState(() {
                  tbalance = amount; // Set the new balance based on user input
                });

                // Save the new balance to local storage
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('tbalance', tbalance);

                // Optionally, update the history and save it if needed
                history.insert(0,{
                  "title": "Balance Adjusted",
                  "amount": amount,
                  "timestamp": DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()),
                });
                await prefs.setString('history', history.map((entry) {
                  return "${entry['title']}|${entry['amount']}|${entry['timestamp']}";
                }).join(';'));

                // Clear the input field after saving
                amountController.clear();
              }
              Navigator.of(context).pop(); // Close the dialog after adjusting
            },
            child: const Text("Adjust"),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        backgroundColor: const Color(0xff57CC99),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              width: 340,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xff57CC99),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      const Text(
                        "Total Balance",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        tbalance.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showAdjustDialog(context);
                    },
                    child: const Text("Adjust"),
                  ),
                ],
              ),
            ),
            Container(
              width: 340,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: "Amount",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (amountController.text.isNotEmpty && titleController.text.isNotEmpty) {
                            setState(() {
                              int? amount = int.tryParse(amountController.text);
                              if (amount != null) {
                                tbalance += amount;
                                history.insert(0, {
                                  "title": titleController.text,
                                  "amount": amount,
                                  "timestamp": DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()),
                                });
                                _saveData(); // Save data after adding
                              }
                              titleController.clear();
                              amountController.clear();
                            });
                          }
                        },
                        child: const Text("Add"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (amountController.text.isNotEmpty && titleController.text.isNotEmpty) {
                            setState(() {
                              int? amount = int.tryParse(amountController.text);
                              if (amount != null) {
                                tbalance -= amount;
                                history.insert(0, {
                                  "title": titleController.text,
                                  "amount": -amount,
                                  "timestamp": DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()),
                                });
                                _saveData(); // Save data after deduction
                              }
                              titleController.clear();
                              amountController.clear();
                            });
                          }
                        },
                        child: const Text("Deduct"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 340,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("History"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          int amount = history[index]["amount"];
                          String formattedAmount = amount >= 0 ? "+$amount" : amount.toString();
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(history[index]["title"] ?? "No Title"),
                                  Text(
                                    history[index]["timestamp"] ?? "",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                formattedAmount,
                                style: TextStyle(
                                  color: amount >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

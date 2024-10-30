import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

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

  final titleController = TextEditingController(); // Controller for title input
  final amountController = TextEditingController(); // Controller for amount input

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
                      // Logic for adjusting balance (can be implemented later)
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
                  // TextField for Title
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // TextField for Amount
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
                                tbalance += amount; // Add amount to balance
                                history.insert(0, { // Insert at the beginning of the list
                                  "title": titleController.text,
                                  "amount": amount,
                                  "timestamp": DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()), // Add timestamp
                                });
                              }
                              // Clear text fields after adding
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
                                tbalance -= amount; // Deduct amount from balance
                                history.insert(0, { // Insert at the beginning of the list
                                  "title": titleController.text,
                                  "amount": -amount,
                                  "timestamp": DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()), // Add timestamp
                                });
                              }
                              // Clear text fields after deducting
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
                    const SizedBox(height: 10), // Space between header and list
                    Expanded(
                      child: ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          // Get the amount and check if it's positive or negative
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
                                    history[index]["timestamp"] ?? "", // Display timestamp
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey, // Grey color for timestamp
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                formattedAmount,
                                style: TextStyle(
                                  color: amount >= 0 ? Colors.green : Colors.red, // Set color based on amount
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

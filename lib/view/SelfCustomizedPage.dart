import 'package:flutter/material.dart';
import 'package:control_app/styles/button_styles.dart';
import 'package:http/http.dart' as http;

class SelfCustomizedPage extends StatefulWidget {
  @override
  _SelfCustomizedPageState createState() => _SelfCustomizedPageState();
}

class _SelfCustomizedPageState extends State<SelfCustomizedPage> {
  List<Map<String, TextEditingController>> _cycles = [
    {
      'freq': TextEditingController(),
      'run': TextEditingController(),
      'break': TextEditingController(),
    }
  ];

  void sendSequenceToMotor(String sequence) async {
    final ip = 'http://10.0.2.2:8080';
    final url = Uri.parse('$ip/start?seq=$sequence');

    try {
      final response = await http.get(url);
      print('Response: ${response.body}');
    } catch (e) {
      print('Failed to send sequence: $e');
    }
  }

  void sendCommandToMotor(String command) async {
    final ip = 'http://10.0.2.2:8080';
    final url = Uri.parse('$ip/$command');

    try {
      final response = await http.get(url);
      print('Response: ${response.body}');
    } catch (e) {
      print('Failed to send command: $e');
    }
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Cycle"),
          content: Text("Are you sure you want to delete this cycle?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  _cycles.removeAt(index);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _buildMotorSequence() {
    String sequence = "";
    for (var cycle in _cycles) {
      String freq = cycle['freq']!.text.padLeft(2, '0');
      String run = cycle['run']!.text.padLeft(2, '0');
      String brk = cycle['break']!.text.padLeft(2, '0');

      int runInt = int.tryParse(run) ?? 0;
      int brkInt = int.tryParse(brk) ?? -1;

      if (runInt < 1 || runInt > 20) return "INVALID_RUN";
      if (brkInt < 0 || brkInt > 5) return "INVALID_BREAK";

      sequence += freq + run + brk;
    }
    return sequence;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Self Customized"),
        backgroundColor: Color(0xF6698FFa),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              ...List.generate(_cycles.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _cycles[index]['freq'],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Hz',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: TextField(
                          controller: _cycles[index]['run'],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Run (1–20)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: TextField(
                          controller: _cycles[index]['break'],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Break (0-5)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: _cycles.length > 1
                            ? () => _confirmDelete(index)
                            : null,
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _cycles.length < 5
                    ? () {
                        setState(() {
                          _cycles.add({
                            'freq': TextEditingController(),
                            'run': TextEditingController(),
                            'break': TextEditingController(),
                          });
                        });
                      }
                    : null,
                icon: Icon(Icons.add),
                label: Text("Add Cycle"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        String seq = _buildMotorSequence();
                        if (seq == "INVALID_RUN") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Run time must be between 01–20 minutes")),
                          );
                        } else if (seq == "INVALID_BREAK") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Break time must be between 00–05 minutes")),
                          );
                        } else {
                          sendSequenceToMotor(seq);
                        }
                      },
                      style: ButtonStyles.greenButton,
                      child: Text("Start"),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        sendCommandToMotor("stop");
                      },
                      style: ButtonStyles.greenButton,
                      child: Text("Stop"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

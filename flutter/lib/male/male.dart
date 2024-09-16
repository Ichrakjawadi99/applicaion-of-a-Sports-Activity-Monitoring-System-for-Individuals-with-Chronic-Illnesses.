// Import necessary packages
import 'package:flutter/material.dart';
import 'diabetes.dart'; // Importer les autres fichiers depuis le sous-répertoire
import 'obesity.dart';
import 'heart_diseases.dart';
import 'cramp.dart';
import 'normal.dart';

class MalePage extends StatefulWidget {
  const MalePage({Key? key}) : super(key: key);

  @override
  _MalePageState createState() => _MalePageState();
}

class _MalePageState extends State<MalePage> {
  late String selectedCondition;

  @override
  void initState() {
    selectedCondition = 'diabetes'; // Valeur par défaut
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select your health condition:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20),
              _buildConditionCard('Diabetes', 'diabetes'),
              const SizedBox(height: 10),
              _buildConditionCard('Obesity', 'obesity'),
              const SizedBox(height: 10),
              _buildConditionCard('Heart diseases', 'heart diseases'),
              const SizedBox(height: 10),
              _buildConditionCard('Cramp', 'cramp'),
              const SizedBox(height: 10),
              _buildConditionCard('I\'m not sick, I just want to exercise', 'normal'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _navigateToSelectedPage(context);
                },
                child: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionCard(String title, String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCondition = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        decoration: BoxDecoration(
          color: selectedCondition == value ? Color.fromARGB(255, 22, 10, 92) : Color.fromARGB(255, 114, 205, 247),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSelectedPage(BuildContext context) {
    switch (selectedCondition) {
      case 'diabetes':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DiabetesPage()),
        );
        break;
      case 'obesity':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ObesityPage()),
        );
        break;
      case 'heart diseases':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HeartDiseasesPage()),
        );
        break;
      case 'cramp':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CrampPage()),
        );
        break;
      case 'normal':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NormalPage()),
        );
        break;
    }
  }
}

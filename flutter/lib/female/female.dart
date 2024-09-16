// ignore_for_file: library_private_types_in_public_api, use_super_parameters, sort_child_properties_last

import 'package:flutter/material.dart';
import 'diabetes.dart'; // Importer les autres fichiers depuis le sous-répertoire
import 'obesity.dart';
import 'heart_diseases.dart';
import 'normal.dart';
import 'cramp.dart';

class FemalePage extends StatefulWidget {
  const FemalePage({Key? key}) : super(key: key);

  @override
  _FemalePageState createState() => _FemalePageState();
}

class _FemalePageState extends State<FemalePage> {
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
          color: selectedCondition == value ? Color.fromARGB(255, 233, 8, 177) : Color.fromARGB(255, 240, 169, 210),
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
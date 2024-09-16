import 'package:flutter/material.dart';
import 'alarm_page.dart';
import 'calendar_page.dart';
import 'training_page.dart';
import 'oxygen_page.dart';
import 'article_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedOption;
  String? _highlightedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          _buildIconButton(
            onPressed: () {
              // Code de déconnexion
            },
            icon: Icon(Icons.logout),
          ),
          _buildIconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AlarmPage()),
              );
            },
            icon: Icon(Icons.alarm),
          ),
          _buildIconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarPage()),
              );
            },
            icon: Icon(Icons.calendar_today),
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRectangle('training', 'training', Icons.fitness_center,
                'assets/trainig.jpg'),
            SizedBox(height: 20),
            _buildRectangle('Heart & Oxygen Stats', 'Heart & Oxygen Stats', Icons.analytics,
                'assets/electrocardiogram-21012708.jpg'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedOption != null
                  ? () {
                      if (_selectedOption == 'training') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrainingPage(),
                          ),
                        );
                      } else if (_selectedOption == 'Heart & Oxygen Stats') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OxygenPage(),
                          ),
                        );
                      }
                    }
                  : null,
              child: Text('Bouton'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ArticlePage()),
          );
        },
        child: Icon(Icons.article),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildRectangle(
      String text, String option, IconData iconData, String assetPath) {
    bool isSelected = _highlightedOption == option;

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _highlightedOption = option;
        });
      },
      onTapUp: (_) {
        setState(() {
          _selectedOption = option;
          _highlightedOption = null;
        });
      },
      onTapCancel: () {
        setState(() {
          _highlightedOption = null;
        });
      },
      child: Container(
        height: 150,
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.green : Colors.white),
          color: isSelected ? Colors.green : Colors.transparent,
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(iconData,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
      {required VoidCallback onPressed, required Icon icon}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: IconButton(
        onPressed: onPressed,
        icon: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: icon,
        ),
      ),
    );
  }
}

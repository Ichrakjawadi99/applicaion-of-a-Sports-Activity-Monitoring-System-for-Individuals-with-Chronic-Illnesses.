import 'package:flutter/material.dart';
import 'male/male.dart';
import 'female/female.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({Key? key}) : super(key: key);

  @override
  _TrainingPageState createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  late String selectedGender;

  @override
  void initState() {
    selectedGender = 'male'; // Default value
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
                "What's your gender?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedGender = 'male';
                      });
                    },
                    child: Container(
                      width: 150,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 244, 245, 247), // Blue background for male
                        image: DecorationImage(
                          image: const AssetImage('assets/fittness.jpg'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            const Color.fromARGB(255, 145, 188, 223).withOpacity(0.6),
                            BlendMode.dstATop,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: selectedGender == 'male' ? Colors.green : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Male 🧑',
                          style: TextStyle(
                            color: selectedGender == 'male' ? Colors.white : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedGender = 'female';
                      });
                    },
                    child: Container(
                      width: 150,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 247, 245, 243), // Pink background for female
                        image: DecorationImage(
                          image: const AssetImage('assets/cp.png'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Color.fromARGB(255, 247, 243, 244).withOpacity(0.6),
                            BlendMode.dstATop,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: selectedGender == 'female' ? Colors.green : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Female 👩‍🦰',
                          style: TextStyle(
                            color: selectedGender == 'female' ? Colors.white : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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

  void _navigateToSelectedPage(BuildContext context) {
    switch (selectedGender) {
      case 'male':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MalePage()),
        );
        break;
      case 'female':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FemalePage()),
        );
        break;
    }
  }
}

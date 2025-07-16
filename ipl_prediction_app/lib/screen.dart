import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PredictionScreen extends StatefulWidget {
  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _runsLeftController = TextEditingController();
  final _oversLeftController = TextEditingController();
  final _wicketsLeftController = TextEditingController();
  final _currentRunsController = TextEditingController();
  final _totalRunsController = TextEditingController();
  final _requiredRRController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  // IPL Teams List
  final List<String> teams = [
    'Royal Challengers Bangalore',
    'Kings XI Punjab',
    'Delhi Daredevils',
    'Mumbai Indians',
    'Kolkata Knight Riders',
    'Rajasthan Royals',
    'Deccan Chargers',
    'Chennai Super Kings',
    'Kochi Tuskers Kerala',
    'Pune Warriors',
    'Sunrisers Hyderabad',
    'Gujarat Lions',
    'Rising Pune Supergiants',
    'Rising Pune Supergiant',
    'Delhi Capitals',
    'Punjab Kings',
    'Lucknow Super Giants',
    'Gujarat Titans',
    'Royal Challengers Bengaluru',
  ];

  // Cities List
  final List<String> cities = [
    'Bangalore',
    'Chandigarh',
    'Delhi',
    'Mumbai',
    'Kolkata',
    'Jaipur',
    'Hyderabad',
    'Chennai',
    'Cape Town',
    'Port Elizabeth',
    'Durban',
    'Centurion',
    'East London',
    'Johannesburg',
    'Kimberley',
    'Bloemfontein',
    'Ahmedabad',
    'Cuttack',
    'Nagpur',
    'Dharamsala',
    'Kochi',
    'Indore',
    'Visakhapatnam',
    'Pune',
    'Raipur',
    'Ranchi',
    'Abu Dhabi',
    'Rajkot',
    'Kanpur',
    'Bengaluru',
    'Dubai',
    'Sharjah',
    'Navi Mumbai',
    'Lucknow',
    'Guwahati',
    'Mohali',
  ];

  String? selectedBattingTeam;
  String? selectedBowlingTeam;
  String? selectedCity;
  String? winPercentage;
  String? lossPercentage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _rotateController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  Future<void> getPrediction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final url = Uri.parse(
      'http://192.168.1.2:8000/predict',
    ); // Replace with your actual IP

    setState(() {
      isLoading = true;
    });

    _rotateController.repeat();

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "batting_team": selectedBattingTeam!,
          "bowling_team": selectedBowlingTeam!,
          "city": selectedCity!,
          "runs_left": int.parse(_runsLeftController.text),
          "overs_left": double.parse(_oversLeftController.text),
          "wickets_left": int.parse(_wicketsLeftController.text),
          "current_runs": int.parse(_currentRunsController.text),
          "total_runs_x": int.parse(_totalRunsController.text),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          winPercentage = data['batting_win_probability'].toString();
          lossPercentage = data['bowling_win_probability'].toString();
        });
      } else {
        print("Error: ${response.body}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      }
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Exception: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
      _rotateController.stop();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    _runsLeftController.dispose();
    _oversLeftController.dispose();
    _wicketsLeftController.dispose();
    _currentRunsController.dispose();
    _totalRunsController.dispose();
    _requiredRRController.dispose();
    super.dispose();
  }

  Widget _buildGlassContainer({required Widget child, double opacity = 0.1}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(opacity),
            Colors.white.withOpacity(opacity * 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }

  Widget _buildAnimatedDropdown({
    required String? value,
    required String labelText,
    required List<String> items,
    required Function(String?) onChanged,
    required String? Function(String?) validator,
    int delay = 0,
  }) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildGlassContainer(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  value: value,
                  decoration: InputDecoration(
                    labelText: labelText,
                    labelStyle: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.amber, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                  ),
                  dropdownColor: Colors.black.withOpacity(0.8),
                  style: TextStyle(color: Colors.white),
                  items: items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item, style: TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: onChanged,
                  validator: validator,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String labelText,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    int delay = 0,
  }) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildGlassContainer(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: labelText,
                    labelStyle: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.amber, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                  ),
                  style: TextStyle(color: Colors.white),
                  keyboardType: keyboardType,
                  validator: validator,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Network Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://dehatpost.com/wp-content/uploads/2023/09/rajiv-gandhi-international-stadium-uppal-hyderabad-859x639-1.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildGlassContainer(
                          opacity: 0.15,
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.sports_cricket,
                                  color: Colors.amber,
                                  size: 30,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'IPL Win Predictor',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Team Selection Section
                          _buildAnimatedDropdown(
                            value: selectedBattingTeam,
                            labelText: 'Batting Team',
                            items: teams,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedBattingTeam = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a batting team';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          _buildAnimatedDropdown(
                            value: selectedBowlingTeam,
                            labelText: 'Bowling Team',
                            items: teams,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedBowlingTeam = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a bowling team';
                              }
                              if (value == selectedBattingTeam) {
                                return 'Bowling team must be different from batting team';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          _buildAnimatedDropdown(
                            value: selectedCity,
                            labelText: 'City',
                            items: cities,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCity = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a city';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          // Match Stats Section
                          _buildAnimatedTextField(
                            controller: _runsLeftController,
                            labelText: 'Runs Left',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter runs left';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          _buildAnimatedTextField(
                            controller: _oversLeftController,
                            labelText: 'Overs Left',
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter overs left';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          _buildAnimatedTextField(
                            controller: _wicketsLeftController,
                            labelText: 'Wickets Left',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter wickets left';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          _buildAnimatedTextField(
                            controller: _currentRunsController,
                            labelText: 'Current Runs',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter current runs';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          _buildAnimatedTextField(
                            controller: _totalRunsController,
                            labelText: 'Total Runs',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter total runs';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 32),

                          // Predict Button
                          AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) {
                              return ScaleTransition(
                                scale: _scaleAnimation,
                                child: Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.amber.withOpacity(0.8),
                                        Colors.orange.withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : getPrediction,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: isLoading
                                        ? AnimatedBuilder(
                                            animation: _rotateAnimation,
                                            builder: (context, child) {
                                              return Transform.rotate(
                                                angle:
                                                    _rotateAnimation.value *
                                                    2 *
                                                    3.14159,
                                                child: Icon(
                                                  Icons.sports_cricket,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                              );
                                            },
                                          )
                                        : Text(
                                            'Get Prediction',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 32),

                          // Results Section
                          if (winPercentage != null)
                            AnimatedBuilder(
                              animation: _fadeAnimation,
                              builder: (context, child) {
                                return FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: _buildGlassContainer(
                                    opacity: 0.2,
                                    child: Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Prediction Results',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          SizedBox(height: 24),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Expanded(
                                                child: _buildGlassContainer(
                                                  opacity: 0.1,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(20),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          selectedBattingTeam ??
                                                              '',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        SizedBox(height: 12),
                                                        Text(
                                                          '${winPercentage}%',
                                                          style: TextStyle(
                                                            fontSize: 28,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8),
                                                        Text(
                                                          'Win Probability',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.white70,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 16),
                                              Expanded(
                                                child: _buildGlassContainer(
                                                  opacity: 0.1,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(20),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          selectedBowlingTeam ??
                                                              '',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        SizedBox(height: 12),
                                                        Text(
                                                          '${lossPercentage}%',
                                                          style: TextStyle(
                                                            fontSize: 28,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8),
                                                        Text(
                                                          'Win Probability',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                Colors.white70,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

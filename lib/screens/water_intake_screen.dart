import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../widgets/button.dart';
import '../models/water_intake.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class WaterIntakeScreen extends StatefulWidget {
  const WaterIntakeScreen({Key? key}) : super(key: key);

  @override
  State<WaterIntakeScreen> createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends State<WaterIntakeScreen> {
  final _databaseService = DatabaseService();
  List<WaterIntake> _intakes = [];
  double _totalIntake = 0;
  final _target = 2000.0; // Daily target in ml
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadWaterIntake();
  }

  Future<void> _loadWaterIntake() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final intakes = await _databaseService.getWaterIntakeForDate(
        user.uid,
        _selectedDate,
      );
      setState(() {
        _intakes = intakes;
        _calculateTotalIntake();
      });
    }
  }

  void _calculateTotalIntake() {
    _totalIntake = _intakes.fold(
      0,
          (sum, intake) => sum + intake.amount,
    );
  }

  Future<void> _addWaterIntake(double amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final intake = WaterIntake(
        id: const Uuid().v4(),
        userId: user.uid,
        date: _selectedDate,
        amount: amount,
      );

      await _databaseService.logWaterIntake(intake);
      await _loadWaterIntake();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomCard(
              child: Column(
                children: [
                  Text(
                    'Daily Progress',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: CircularProgressIndicator(
                          value: _totalIntake / _target,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '${(_totalIntake / 1000).toStringAsFixed(1)}L',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          Text(
                            'of ${(_target / 1000).toStringAsFixed(1)}L',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CustomCard(
              child: Column(
                children: [
                  Text(
                    'Quick Add',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickAddButton(250),
                      _buildQuickAddButton(500),
                      _buildQuickAddButton(1000),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CustomCard(
              child: Column(
                children: [
                  Text(
                    'Today\'s Log',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  if (_intakes.isEmpty)
                    const Text('No water intake logged today')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _intakes.length,
                      itemBuilder: (context, index) {
                        final intake = _intakes[index];
                        return ListTile(
                          leading: const Icon(Icons.water_drop),
                          title: Text('${intake.amount}ml'),
                          subtitle: Text(
                            '${intake.date.hour}:${intake.date.minute.toString().padLeft(2, '0')}',
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddButton(double amount) {
    return ElevatedButton(
      onPressed: () => _addWaterIntake(amount),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text('${amount.toInt()}ml'),
    );
  }
}
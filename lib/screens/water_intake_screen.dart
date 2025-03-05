import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:lottie/lottie.dart';
import '../widgets/custom_card.dart';
import '../widgets/button.dart';
import '../models/water_intake.dart';
import '../services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';

class WaterIntakeScreen extends StatefulWidget {
  const WaterIntakeScreen({Key? key}) : super(key: key);

  @override
  State<WaterIntakeScreen> createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends State<WaterIntakeScreen> with SingleTickerProviderStateMixin {
  final _databaseService = DatabaseService();
  List<WaterIntake> _intakes = [];
  double _totalIntake = 0;
  final _target = 2000.0; // Daily target in ml
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _loadWaterIntake();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadWaterIntake() async {
    setState(() => _isLoading = true);
    try {
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
        _animationController.forward(from: 0);
      }
    } finally {
      setState(() => _isLoading = false);
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

      setState(() {
        _intakes.insert(0, intake);
        _calculateTotalIntake();
      });

      try {
        await _databaseService.logWaterIntake(intake);
        _animationController.forward(from: 0);
      } catch (e) {
        setState(() {
          _intakes.removeAt(0);
          _calculateTotalIntake();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add water intake: $e')),
        );
      }
    }
  }

  Future<void> _deleteWaterIntake(WaterIntake intake) async {
    final index = _intakes.indexOf(intake);
    setState(() {
      _intakes.remove(intake);
      _calculateTotalIntake();
    });

    try {
      await _databaseService.deleteWaterIntake(
        intake.userId,
        intake.date,
        intake.id,
      );
      _animationController.forward(from: 0);
    } catch (e) {
      setState(() {
        _intakes.insert(index, intake);
        _calculateTotalIntake();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete water intake: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Water Intake'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return CustomCard(
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
                              value: _progressAnimation.value * (_totalIntake / _target),
                              strokeWidth: 12,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
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
                );
              },
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
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No water intake logged today'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _intakes.length,
                      itemBuilder: (context, index) {
                        final intake = _intakes[index];
                        return PageTransitionSwitcher(
                          transitionBuilder: (
                              Widget child,
                              Animation<double> animation,
                              Animation<double> secondaryAnimation,
                              ) {
                            return FadeScaleTransition(
                              animation: animation,
                              child: child,
                            );
                          },
                          child: Dismissible(
                            key: Key(intake.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: AppTheme.errorColor,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) => _deleteWaterIntake(intake),
                            child: ListTile(
                              leading: const Icon(
                                Icons.water_drop,
                                color: AppTheme.primaryColor,
                              ),
                              title: Text(
                                '${intake.amount.toInt()}ml',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              subtitle: Text(
                                '${intake.date.hour}:${intake.date.minute.toString().padLeft(2, '0')}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: AppTheme.errorColor,
                                onPressed: () => _deleteWaterIntake(intake),
                              ),
                            ),
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
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text('${amount.toInt()}ml'),
    );
  }
}
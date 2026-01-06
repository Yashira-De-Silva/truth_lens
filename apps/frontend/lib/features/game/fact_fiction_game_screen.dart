import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

class FactFictionGameScreen extends ConsumerStatefulWidget {
  const FactFictionGameScreen({super.key});

  @override
  ConsumerState<FactFictionGameScreen> createState() =>
      _FactFictionGameScreenState();
}

class _FactFictionGameScreenState extends ConsumerState<FactFictionGameScreen>
    with SingleTickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _streak = 0;
  int _highScore = 0;
  bool _hasAnswered = false;
  bool? _isCorrect;
  int _timeLeft = 15;
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> _questions = [
    {
      'headline': 'Scientists discover water on Mars',
      'isFact': true,
      'explanation': 'NASA confirmed evidence of liquid water on Mars in 2015.',
    },
    {
      'headline': 'Eating carrots gives you night vision',
      'isFact': false,
      'explanation':
          'This was WWII propaganda. Carrots are healthy but don\'t grant night vision.',
    },
    {
      'headline': 'The Great Wall of China is visible from space',
      'isFact': false,
      'explanation':
          'This is a myth. The wall is not visible from space with the naked eye.',
    },
    {
      'headline': 'Honey never spoils',
      'isFact': true,
      'explanation':
          'Archaeologists have found 3000-year-old honey that\'s still edible.',
    },
    {
      'headline': 'Humans only use 10% of their brain',
      'isFact': false,
      'explanation':
          'Brain scans show we use virtually all parts of our brain throughout the day.',
    },
    {
      'headline': 'Lightning can strike the same place twice',
      'isFact': true,
      'explanation':
          'Lightning often strikes the same place multiple times, especially tall buildings.',
    },
    {
      'headline': 'Goldfish have a 3-second memory',
      'isFact': false,
      'explanation': 'Studies show goldfish can remember things for months.',
    },
    {
      'headline': 'Mount Everest is the tallest mountain on Earth',
      'isFact': true,
      'explanation':
          'At 8,849m, Everest is Earth\'s highest peak above sea level.',
    },
    {
      'headline': 'Cracking knuckles causes arthritis',
      'isFact': false,
      'explanation':
          'Multiple studies found no link between knuckle cracking and arthritis.',
    },
    {
      'headline': 'The Earth orbits around the Sun',
      'isFact': true,
      'explanation':
          'Earth completes one orbit around the Sun every 365.25 days.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _questions.shuffle(Random());
    _startTimer();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('fact_fiction_high_score') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    if (_score > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('fact_fiction_high_score', _score);
      setState(() {
        _highScore = _score;
      });
    }
  }

  void _startTimer() {
    _timeLeft = 15;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _handleAnswer(null); // Time's up
        }
      });
    });
  }

  void _handleAnswer(bool? userAnswer) {
    if (_hasAnswered) return;

    _timer?.cancel();
    setState(() {
      _hasAnswered = true;
      if (userAnswer == null) {
        _isCorrect = false;
        _streak = 0;
      } else {
        _isCorrect = userAnswer == _questions[_currentQuestionIndex]['isFact'];
        if (_isCorrect!) {
          _score += (10 + _streak * 2 + _timeLeft);
          _streak++;
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
        } else {
          _streak = 0;
        }
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _hasAnswered = false;
          _isCorrect = null;
        });
        _startTimer();
      } else {
        _endGame();
      }
    });
  }

  void _endGame() {
    _timer?.cancel();
    _saveHighScore();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1F3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.3)),
          ),
          title: Column(
            children: [
              Icon(
                _score > _highScore ? Icons.emoji_events : Icons.check_circle,
                color: _score > _highScore
                    ? const Color(0xFFFFD700)
                    : AppColors.secondary,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _score > _highScore ? 'New High Score!' : 'Game Over!',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildScoreRow('Final Score', _score.toString()),
              const SizedBox(height: 8),
              _buildScoreRow('High Score', _highScore.toString()),
              const SizedBox(height: 8),
              _buildScoreRow(
                'Accuracy',
                '${(_score > 0 ? (_currentQuestionIndex + 1) : 0)}/${_questions.length}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Exit',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _restartGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              child: const Text(
                'Play Again',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  void _restartGame() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _streak = 0;
      _hasAnswered = false;
      _isCorrect = null;
      _questions.shuffle(Random());
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF020617), Color(0xFF0A2540)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1220).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Fact vs Fiction',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Stats Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1220).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        Icons.score,
                        'Score',
                        _score.toString(),
                        AppColors.secondary,
                      ),
                      _buildStatItem(
                        Icons.local_fire_department,
                        'Streak',
                        _streak.toString(),
                        Colors.orange,
                      ),
                      _buildStatItem(
                        Icons.timer,
                        'Time',
                        _timeLeft.toString(),
                        _timeLeft > 5 ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'High Score: $_highScore',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _questions.length,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.secondary,
                    ),
                    minHeight: 8,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Question Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isCorrect == true ? _scaleAnimation.value : 1.0,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1220).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _hasAnswered
                              ? (_isCorrect! ? Colors.green : Colors.red)
                              : Colors.white.withValues(alpha: 0.1),
                          width: _hasAnswered ? 3 : 1,
                        ),
                        boxShadow: _hasAnswered
                            ? [
                                BoxShadow(
                                  color:
                                      (_isCorrect! ? Colors.green : Colors.red)
                                          .withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.article,
                                size: 64,
                                color: AppColors.secondary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                currentQuestion['headline'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (_hasAnswered) ...[
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        (_isCorrect!
                                                ? Colors.green
                                                : Colors.red)
                                            .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _isCorrect!
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: _isCorrect!
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _isCorrect! ? 'Correct!' : 'Wrong!',
                                            style: TextStyle(
                                              color: _isCorrect!
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        currentQuestion['explanation'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Answer Buttons
              if (!_hasAnswered)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildAnswerButton(
                          'FACT',
                          Icons.check_circle,
                          Colors.green,
                          () => _handleAnswer(true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildAnswerButton(
                          'FICTION',
                          Icons.cancel,
                          Colors.red,
                          () => _handleAnswer(false),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_hasAnswered)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Next question loading...',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAnswerButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color, width: 2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

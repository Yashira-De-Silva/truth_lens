import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewsQuizGameScreen extends ConsumerStatefulWidget {
  const NewsQuizGameScreen({super.key});

  @override
  ConsumerState<NewsQuizGameScreen> createState() => _NewsQuizGameScreenState();
}

class _NewsQuizGameScreenState extends ConsumerState<NewsQuizGameScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _answered = false;
  String? _selectedAnswer;
  bool _gameCompleted = false;

  final List<QuizQuestion> _questions = [
    QuizQuestion(
      question: 'What does "misinformation" mean?',
      options: [
        'Deliberately false information',
        'Unintentionally false or inaccurate information',
        'Information from social media',
        'Any news article',
      ],
      correctAnswer: 1,
      explanation:
          'Misinformation is false or inaccurate information shared without intent to deceive, while disinformation is deliberately false.',
    ),
    QuizQuestion(
      question: 'Which is the BEST way to verify a news story?',
      options: [
        'Check only the headline',
        'Share immediately if it seems interesting',
        'Cross-reference multiple credible sources',
        'Trust if it has many likes',
      ],
      correctAnswer: 2,
      explanation:
          'Always verify information by checking multiple reliable sources before believing or sharing news.',
    ),
    QuizQuestion(
      question: 'What is a "deepfake"?',
      options: [
        'A very detailed news article',
        'AI-generated fake videos or images',
        'A type of social media platform',
        'A news category',
      ],
      correctAnswer: 1,
      explanation:
          'Deepfakes are synthetic media created using AI to make realistic but fake videos or images of people.',
    ),
    QuizQuestion(
      question: 'What should you check first when evaluating a news source?',
      options: [
        'The number of ads on the page',
        'How sensational the headline is',
        'The credibility and reputation of the source',
        'The length of the article',
      ],
      correctAnswer: 2,
      explanation:
          'Always evaluate the credibility and track record of the news source before trusting the information.',
    ),
    QuizQuestion(
      question: 'What is "confirmation bias"?',
      options: [
        'Confirming facts before sharing',
        'Tendency to believe information that confirms existing beliefs',
        'A fact-checking method',
        'A type of news website',
      ],
      correctAnswer: 1,
      explanation:
          'Confirmation bias is our tendency to search for and believe information that confirms what we already think.',
    ),
    QuizQuestion(
      question: 'Which date format is most commonly used in journalism?',
      options: ['MM/DD/YYYY', 'DD/MM/YYYY', 'Month DD, YYYY', 'YYYY-MM-DD'],
      correctAnswer: 2,
      explanation:
          'Most journalism uses "Month DD, YYYY" format (e.g., January 4, 2026) for clarity and readability.',
    ),
    QuizQuestion(
      question: 'What does "fact-checking" primarily involve?',
      options: [
        'Reading the article quickly',
        'Verifying claims against reliable sources',
        'Counting the number of facts',
        'Sharing with friends',
      ],
      correctAnswer: 1,
      explanation:
          'Fact-checking involves systematically verifying claims and statements against credible, reliable sources.',
    ),
    QuizQuestion(
      question: 'What is "clickbait"?',
      options: [
        'Fishing for information',
        'Sensationalized headlines to attract clicks',
        'A type of computer virus',
        'A news category',
      ],
      correctAnswer: 1,
      explanation:
          'Clickbait uses sensational or misleading headlines to attract clicks, often without delivering substantive content.',
    ),
  ];

  void _selectAnswer(int index) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = _questions[_currentQuestionIndex].options[index];
      _answered = true;

      if (index == _questions[_currentQuestionIndex].correctAnswer) {
        _score += 10;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedAnswer = null;
      });
    } else {
      setState(() {
        _gameCompleted = true;
      });
    }
  }

  void _restartGame() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _answered = false;
      _selectedAnswer = null;
      _gameCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF0A0E27)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _gameCompleted ? _buildGameOver() : _buildQuizContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'News Quiz Challenge',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Test your news literacy skills',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$_score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_gameCompleted) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF6366F1),
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    final question = _questions[_currentQuestionIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Question Card
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.quiz, color: Color(0xFF6366F1), size: 48),
                    const SizedBox(height: 16),
                    Text(
                      question.question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Answer Options
          ...List.generate(
            question.options.length,
            (index) => _buildAnswerOption(
              question.options[index],
              index,
              question.correctAnswer,
            ),
          ),

          // Explanation (shown after answering)
          if (_answered) ...[
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: Color(0xFFFBBF24),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Did you know?',
                            style: TextStyle(
                              color: Color(0xFFFBBF24),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.explanation,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentQuestionIndex < _questions.length - 1
                      ? 'Next Question'
                      : 'See Results',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerOption(String option, int index, int correctIndex) {
    final isSelected = _selectedAnswer == option;
    final isCorrect = index == correctIndex;
    final showResult = _answered;

    Color getColor() {
      if (!showResult) {
        return isSelected
            ? const Color(0xFF6366F1)
            : Colors.white.withOpacity(0.1);
      }
      if (isCorrect) return const Color(0xFF10B981);
      if (isSelected && !isCorrect) return const Color(0xFFEF4444);
      return Colors.white.withOpacity(0.1);
    }

    IconData? getIcon() {
      if (!showResult) return null;
      if (isCorrect) return Icons.check_circle;
      if (isSelected && !isCorrect) return Icons.cancel;
      return null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _selectAnswer(index),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: getColor().withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: getColor(), width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: getColor(),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: getIcon() != null
                          ? Icon(getIcon(), color: Colors.white, size: 20)
                          : Text(
                              String.fromCharCode(65 + index), // A, B, C, D
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    final percentage = (_score / (_questions.length * 10) * 100).round();
    String getMessage() {
      if (percentage >= 90) return 'Outstanding! 🌟';
      if (percentage >= 70) return 'Great Job! 🎉';
      if (percentage >= 50) return 'Good Effort! 👍';
      return 'Keep Learning! 📚';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Color(0xFFFBBF24),
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      getMessage(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your Score',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_score / ${_questions.length * 10}',
                      style: const TextStyle(
                        color: Color(0xFF6366F1),
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$percentage% Correct',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(
                          Icons.check_circle,
                          'Correct',
                          '${(_score / 10).round()}',
                          const Color(0xFF10B981),
                        ),
                        _buildStat(
                          Icons.cancel,
                          'Wrong',
                          '${_questions.length - (_score / 10).round()}',
                          const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _restartGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.replay),
                  SizedBox(width: 8),
                  Text(
                    'Play Again',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back to Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
        ),
      ],
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}

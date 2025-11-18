import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/feedback/feedback_bloc.dart';
import '../../bloc/feedback/feedback_event.dart';
import '../../bloc/feedback/feedback_state.dart';

/// Simple static method to show feedback from anywhere in your app
class FeedbackDialog {
  /// Call this from your settings screen or anywhere you want feedback
  ///
  /// Example usage:
  /// ```dart
  /// FeedbackDialog.show(context);
  /// ```
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) => FeedbackBloc(),
          child: const _FeedbackDialogContent(),
        );
      },
    );
  }
}

Future<void> openPlayStore() async {
  final url = Uri.parse(
    "https://play.google.com/store/apps/details?id=com.zooq.ai.photo.art.image.generator",
  );

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not open the Play Store.');
  }
}

class _FeedbackDialogContent extends StatefulWidget {
  const _FeedbackDialogContent();

  @override
  State<_FeedbackDialogContent> createState() => _FeedbackDialogContentState();
}

class _FeedbackDialogContentState extends State<_FeedbackDialogContent> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedbackBloc, FeedbackState>(
      listener: (context, state) {
        if (state.isSubmitted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you for your feedback!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        // Show rating dialog (first popup)
        return _buildRatingDialog(context, state);
      },
    );
  }

  /// First Popup - Rating with emojis
  Widget _buildRatingDialog(BuildContext context, FeedbackState state) {
    return Scaffold(
      backgroundColor:  Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF25272F),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.grey, size: 20),
                  ),
                ),
                const SizedBox(height: 10),
        
                // Emoji based on rating
                SvgPicture.asset(
                  _getEmojiAsset(state.rating),
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 20),
        
                // Title
                const Text(
                  'How satisfied are you?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(height: 8),
        
                // Subtitle
                const Text(
                  'Your feedback is valuable',
                  style: TextStyle(fontSize: 14, color: Color(0xFFFFFFFF)),
                ),
                const SizedBox(height: 20),
        
                // 5 Star Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    final isSelected = starIndex <= state.rating;
        
                    return GestureDetector(
                      onTap: () {
                        context.read<FeedbackBloc>().add(
                          UpdateRatingEvent(starIndex),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          isSelected ? Icons.star : Icons.star_border,
                          color: isSelected ? Color(0xFFFFC107) : Colors.grey,
                          size: 36,
                          fill: isSelected ? 1.0 : 0.0,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
        
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final parentContext =
                          context; // 👈 Save parent context (very important)
        
                      if (state.rating >= 1 && state.rating <= 3) {
                        showDialog(
                          context: parentContext,
                          barrierDismissible: false,
                          builder: (context) {
                            return BlocProvider.value(
                              value: parentContext.read<FeedbackBloc>(),
                              child: _buildFeedbackFormDialog(context, state),
                            );
                          },
                        );
                        
                      } else if (state.rating >= 4) {
                        openPlayStore();
                        context.pop();
                    
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please select a rating before submitting.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
        
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFEE5776),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child:
                        state.isSubmitting
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Second Popup - Detailed feedback form (shows when rating <= 3)
  Widget _buildFeedbackFormDialog(BuildContext context, FeedbackState state) {
    return BlocBuilder<FeedbackBloc, FeedbackState>(
      builder: (context, currentState) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: Center(
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25272F),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close button
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.close, color: Colors.grey, size: 20),
                        ),
                      ),
                      const SizedBox(height: 10),
                        
                      // Title
                      const Text(
                        'Your Opinion Matters!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      const SizedBox(height: 20),
                        
                      // Checkbox options
                      _buildCheckboxOption(
                        context,
                        currentState,
                        'option1',
                        'Do you like the interface?',
                        currentState.option1,
                      ),
                      const SizedBox(height: 12),
                      _buildCheckboxOption(
                        context,
                        currentState,
                        'option2',
                        'Are the generated images meeting your expectations?',
                        currentState.option2,
                      ),
                      const SizedBox(height: 12),
                      _buildCheckboxOption(
                        context,
                        currentState,
                        'option3',
                        'It generates images very quickly.',
                        currentState.option3,
                      ),
                      const SizedBox(height: 12),
                      _buildCheckboxOption(
                        context,
                        currentState,
                        'option4',
                        'How can we make this app even better for you?',
                        currentState.option4,
                      ),
                      const SizedBox(height: 20),
                        
                      // Comment section title
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Write your suggestions here...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                        
                      // Comment input box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextField(
                          controller: _commentController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Enter here...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          style: const TextStyle(fontSize: 14),
                          onChanged: (value) {
                            context.read<FeedbackBloc>().add(UpdateCommentEvent(value));
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                        
                      // Send Feedback button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: currentState.isSubmitting
                              ? null
                              : () {
                                  context.read<FeedbackBloc>().add(
                                    const SubmitFeedbackEvent(),

                                  );
                                  context.pop();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C3E50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: currentState.isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Send Feedback',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckboxOption(
    BuildContext context,
    FeedbackState state,
    String optionKey,
    String text,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<FeedbackBloc>().add(
          UpdateFeedbackOptionEvent(optionKey, !isSelected),
        );
      },
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? const Color(0xFF2C3E50) : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
              color: isSelected ? const Color(0xFF2C3E50) : Colors.transparent,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  String _getEmojiAsset(int rating) {
    switch (rating) {
      case 1:
        return 'assets/svg/emoj1.svg';
      case 2:
        return 'assets/svg/emoj2.svg';
      case 3:
        return 'assets/svg/emoj3.svg';
      case 4:
        return 'assets/svg/emoj4.svg';
      case 5:
        return 'assets/svg/emoj5.svg';
      default:
        return 'assets/svg/emoj3.svg'; // Default neutral emoji
    }
  }
}

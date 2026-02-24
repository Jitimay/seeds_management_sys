import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color? color;
  final bool allowHalfRating;
  final Function(int)? onRatingChanged;

  const RatingStars({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 24.0,
    this.color,
    this.allowHalfRating = true,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? Colors.amber;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starValue = index + 1;
        IconData iconData;
        
        if (rating >= starValue) {
          iconData = Icons.star;
        } else if (allowHalfRating && rating >= starValue - 0.5) {
          iconData = Icons.star_half;
        } else {
          iconData = Icons.star_border;
        }
        
        return GestureDetector(
          onTap: onRatingChanged != null ? () => onRatingChanged!(starValue) : null,
          child: Icon(
            iconData,
            size: size,
            color: starColor,
          ),
        );
      }),
    );
  }
}

class RatingInput extends StatefulWidget {
  final Function(int rating, String? comment) onSubmit;
  final int initialRating;
  final String? initialComment;

  const RatingInput({
    super.key,
    required this.onSubmit,
    this.initialRating = 0,
    this.initialComment,
  });

  @override
  State<RatingInput> createState() => _RatingInputState();
}

class _RatingInputState extends State<RatingInput> {
  late int _rating;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _commentController = TextEditingController(text: widget.initialComment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Votre évaluation',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        RatingStars(
          rating: _rating.toDouble(),
          size: 32,
          onRatingChanged: (rating) {
            setState(() {
              _rating = rating;
            });
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _commentController,
          decoration: const InputDecoration(
            labelText: 'Commentaire (optionnel)',
            border: OutlineInputBorder(),
            hintText: 'Partagez votre expérience...',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _rating > 0
                ? () => widget.onSubmit(_rating, _commentController.text.isEmpty ? null : _commentController.text)
                : null,
            child: const Text('Soumettre l\'évaluation'),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final int rating;
  final bool editable;
  final void Function(int)? onRatingChanged;
  final String? comment;
  final void Function(String)? onCommentChanged;
  final bool showCommentField;
  final bool showLabel;

  const RatingStars({
    Key? key,
    required this.rating,
    this.editable = false,
    this.onRatingChanged,
    this.comment,
    this.onCommentChanged,
    this.showCommentField = false,
    this.showLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            'Your Rating',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final filled = index < rating;
            return IconButton(
              icon: Icon(
                filled ? Icons.star : Icons.star_border,
                color: filled ? Colors.amber : Colors.grey,
                size: 32,
              ),
              onPressed:
                  editable && onRatingChanged != null
                      ? () => onRatingChanged!(index + 1)
                      : null,
              splashRadius: 20,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            );
          }),
        ),
        if (showCommentField)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextField(
              enabled: editable && onCommentChanged != null,
              controller: TextEditingController(text: comment ?? '')
                ..selection = TextSelection.collapsed(
                  offset: (comment ?? '').length,
                ),
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Comment (optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: onCommentChanged,
            ),
          ),
      ],
    );
  }
}

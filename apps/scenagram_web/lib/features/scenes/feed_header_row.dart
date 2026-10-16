import 'package:flutter/material.dart';

class FeedHeaderRow extends StatelessWidget {
  const FeedHeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 27,
          backgroundImage: NetworkImage(
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nadia K.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.verified_rounded,
                    size: 17,
                    color: Color(0xFF7238D8),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(
                '12 min ago  ?  Witnessed',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF73798A),
                ),
              ),
            ],
          ),
        ),

        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF8B24C7),
            side: const BorderSide(
              color: Color(0xFFE2D7EA),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Follow',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(width: 12),

        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.more_vert_rounded,
            color: Color(0xFF555C6B),
            size: 21,
          ),
        ),
      ],
    );
  }
}


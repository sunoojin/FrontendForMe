import 'package:diary_for_me/db_models/daily_data/daily_data_model.dart';

import '../../../db_models/event/event_model.dart';
import 'section_card.dart';
import 'package:flutter/material.dart';
import 'package:diary_for_me/common/ui_kit.dart';

class LocationCard extends StatefulWidget {
  final Event event;
  const LocationCard({super.key, required this.event});

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  List<Location> get location => widget.event.dailydata.location;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
        title: '위치',
        children: [
          contents(
            children: [
              Text('위도: ${location.first.lat}, 경도: ${location.first.lng}' ?? '주소 없음', style: cardTitle()),
              SizedBox(height: 16),
              borderHorizontal(),
            ],
          ),
          bottomButton(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '위치 변경',
                  style: cardDetail(color: textTertiary),
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 19,
                  color: textTertiary,
                ),
              ],
            ),
            onTap: () {},
          ),
        ],
      );
  }
}

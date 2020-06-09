import 'package:flutter/material.dart';

import '../config/palette.dart';
import '../utils/enums.dart';
import '../widgets/event.dart';

class Timeline extends StatelessWidget {
  final List data;
  final Function callback;

  Timeline(this.data, this.callback);

  List sortByDate(List data, String orderBy, Order order) {
    if (order == Order.asc) {
      data.sort((a, b) {
        return a[orderBy].compareTo(b[orderBy]);
      });
    } else {
      data.sort((a, b) {
        return b[orderBy].compareTo(a[orderBy]);
      });
    }

    return data;
  }

  List pickValues(Map data) {
    List l = [];

    l.addAll(data["comments"]);
    l.addAll(data["communications"]);
    l.addAll(data["versions"]);

    return l;
  }

  @override
  Widget build(BuildContext context) {
    // var events = pickValues(data);
    var sortedEvents = sortByDate(data, "creation", Order.desc);
    List<Widget> children = [];
    List<Widget> indicators = [];

    sortedEvents.forEach((event) {
      EventType eventType;
      Icon indicator;

      if (event["communication_medium"] == "Email") {
        eventType = EventType.email;
        indicator = Icon(
          Icons.email,
          color: Palette.dimTxtColor,
        );
      } else if (event["comment_type"] == "Comment") {
        eventType = EventType.comment;
        indicator = Icon(
          Icons.comment,
          color: Palette.dimTxtColor,
        );
      } else if (event["data"] != null ||
          event["comment_type"] == "Attachment") {
        eventType = EventType.docVersion;
        indicator = Icon(
          Icons.edit,
          color: Palette.dimTxtColor,
        );
      } else if (event["comment_type"] == "Like") {
        eventType = EventType.docVersion;
        indicator = Icon(
          Icons.favorite,
          color: Colors.red,
        );
      } else {
        eventType = EventType.docVersion;
        indicator = Icon(
          Icons.edit,
          color: Palette.dimTxtColor,
        );
      }
      children.add(Event(eventType, event, callback));
      indicators.add(indicator);
    });

    return Column(
      children: <Widget>[
        TimelineView(
          lineColor: Palette.dimTxtColor,
          children: children,
          indicators: indicators,
        )
      ],
    );
  }
}

class TimelineView extends StatelessWidget {
  const TimelineView({
    @required this.children,
    this.indicators,
    this.isLeftAligned = true,
    this.itemGap = 12.0,
    this.gutterSpacing = 4.0,
    this.padding = const EdgeInsets.all(8),
    this.controller,
    this.lineColor = Colors.grey,
    this.physics,
    this.shrinkWrap = true,
    this.primary = false,
    this.reverse = false,
    this.indicatorSize = 30.0,
    this.lineGap = 4.0,
    this.indicatorColor = Colors.blue,
    this.indicatorStyle = PaintingStyle.fill,
    this.strokeCap = StrokeCap.butt,
    this.strokeWidth = 1.0,
    this.style = PaintingStyle.stroke,
  })  : itemCount = children.length,
        assert(itemGap >= 0),
        assert(lineGap >= 0),
        assert(indicators == null || children.length == indicators.length);

  final List<Widget> children;
  final double itemGap;
  final double gutterSpacing;
  final List<Widget> indicators;
  final bool isLeftAligned;
  final EdgeInsets padding;
  final ScrollController controller;
  final int itemCount;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final bool primary;
  final bool reverse;

  final Color lineColor;
  final double lineGap;
  final double indicatorSize;
  final Color indicatorColor;
  final PaintingStyle indicatorStyle;
  final StrokeCap strokeCap;
  final double strokeWidth;
  final PaintingStyle style;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      separatorBuilder: (_, __) => SizedBox(height: itemGap),
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      controller: controller,
      reverse: reverse,
      primary: primary,
      itemBuilder: (context, index) {
        final child = children[index];

        Widget indicator;
        if (indicators != null) {
          indicator = indicators[index];
        }

        final isFirst = index == 0;
        final isLast = index == itemCount - 1;

        final timelineTile = <Widget>[
          CustomPaint(
            foregroundPainter: _TimelinePainter(
              hideDefaultIndicator: indicator != null,
              lineColor: lineColor,
              indicatorColor: indicatorColor,
              indicatorSize: indicatorSize,
              indicatorStyle: indicatorStyle,
              isFirst: isFirst,
              isLast: isLast,
              lineGap: lineGap,
              strokeCap: strokeCap,
              strokeWidth: strokeWidth,
              style: style,
              itemGap: itemGap,
            ),
            child: SizedBox(
              height: double.infinity,
              width: indicatorSize,
              child: indicator,
            ),
          ),
          SizedBox(width: gutterSpacing),
          Expanded(child: child)
        ];

        return IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:
                isLeftAligned ? timelineTile : timelineTile.reversed.toList(),
          ),
        );
      },
    );
  }
}

class _TimelinePainter extends CustomPainter {
  _TimelinePainter({
    @required this.hideDefaultIndicator,
    @required this.indicatorColor,
    @required this.indicatorStyle,
    @required this.indicatorSize,
    @required this.lineGap,
    @required this.strokeCap,
    @required this.strokeWidth,
    @required this.style,
    @required this.lineColor,
    @required this.isFirst,
    @required this.isLast,
    @required this.itemGap,
  })  : linePaint = Paint()
          ..color = lineColor
          ..strokeCap = strokeCap
          ..strokeWidth = strokeWidth
          ..style = style,
        circlePaint = Paint()
          ..color = indicatorColor
          ..style = indicatorStyle;

  final bool hideDefaultIndicator;
  final Color indicatorColor;
  final PaintingStyle indicatorStyle;
  final double indicatorSize;
  final double lineGap;
  final StrokeCap strokeCap;
  final double strokeWidth;
  final PaintingStyle style;
  final Color lineColor;
  final Paint linePaint;
  final Paint circlePaint;
  final bool isFirst;
  final bool isLast;
  final double itemGap;

  @override
  void paint(Canvas canvas, Size size) {
    final indicatorRadius = indicatorSize / 2;
    final halfItemGap = itemGap / 2;
    final indicatorMargin = indicatorRadius + lineGap;

    final top = size.topLeft(Offset(indicatorRadius, 0.0 - halfItemGap));
    final centerTop = size.centerLeft(
      Offset(indicatorRadius, -indicatorMargin),
    );

    final bottom = size.bottomLeft(Offset(indicatorRadius, 0.0 + halfItemGap));
    final centerBottom = size.centerLeft(
      Offset(indicatorRadius, indicatorMargin),
    );

    if (!isFirst) canvas.drawLine(top, centerTop, linePaint);
    if (!isLast) canvas.drawLine(centerBottom, bottom, linePaint);

    if (!hideDefaultIndicator) {
      final Offset offsetCenter = size.centerLeft(Offset(indicatorRadius, 0));

      canvas.drawCircle(offsetCenter, indicatorRadius, circlePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

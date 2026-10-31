import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heroine/heroine.dart';

class _RecordingShuttleBuilder extends SimpleShuttleBuilder {
  _RecordingShuttleBuilder();

  final shown = <Widget>[];

  @override
  Widget buildHero({
    required BuildContext flightContext,
    required Widget fromHero,
    required Widget toHero,
    required double valueFromTo,
    required HeroFlightDirection flightDirection,
  }) {
    shown.add(fromHero);

    return const SizedBox.shrink();
  }

  @override
  List<Object?> get props => [];
}

void main() {
  testWidgets('a flight goes on when its hero leaves the tree', (tester) async {
    final animation = AnimationController(vsync: tester, value: 0.5);
    addTearDown(animation.dispose);

    final builder = _RecordingShuttleBuilder();
    BuildContext? fromContext;
    Widget? shuttle;
    final hero = Builder(
      builder: (context) {
        fromContext = context;

        return const SizedBox(height: 10);
      },
    );
    var showHero = true;
    late StateSetter setShowHero;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            setShowHero = setState;

            return Column(
              children: [
                if (showHero) hero else const SizedBox(height: 10),
                Builder(
                  builder: (flightContext) {
                    // Called once, as a flight's overlay is
                    return shuttle ??= builder.call(
                      flightContext,
                      animation,
                      HeroFlightDirection.pop,
                      fromContext!,
                      flightContext,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );

    setShowHero(() => showHero = false);
    await tester.pump();

    animation.value = 0.25;
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(builder.shown.last, same(hero));
  });
}

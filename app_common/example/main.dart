// A theme generated from one hex brand color, its swatch and a readable
// text color on each shade.
import 'package:material_ui/material_ui.dart';
import 'package:tekartik_app_flutter_common_utils/color.dart';
import 'package:tekartik_app_flutter_common_utils/hex_color.dart';

final brandColor = HexColor.fromHex('#0d6efd');
final brandSwatch = generateMaterialColor(brandColor);

const _shades = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900];

void main() {
  runApp(const ExampleApp());
}

/// Example app.
class ExampleApp extends StatelessWidget {
  /// Example app.
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: brandSwatch),
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Brand ${brandColor.toHex(noAlpha: true)}')),
        body: ListView(
          children: [
            for (var shade in _shades)
              Container(
                color: brandSwatch[shade],
                padding: const EdgeInsets.all(16),
                child: Text(
                  '$shade ${brandSwatch[shade]!.toHex()}',
                  style: TextStyle(
                    color: brandSwatch[shade]!.isDark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

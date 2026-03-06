import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid_to_hsl/uuid_to_hsl.dart';

const generator = UuidToHsl();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UUID to HSL Grid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const UuidColorGridPage(),
    );
  }
}

class UuidColorGridPage extends StatefulWidget {
  const UuidColorGridPage({super.key});

  @override
  State<UuidColorGridPage> createState() => _UuidColorGridPageState();
}

class _UuidColorGridPageState extends State<UuidColorGridPage> {
  static const int sampleCount = 300;
  static const int crossAxisCount = 20;

  final _uuid = const Uuid();
  late List<String> _uuids;

  String? _lastExportPath;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    _uuids = List.generate(sampleCount, (_) => _uuid.v4());
  }

  void _regenerate() {
    setState(() {
      _generate();
      _lastExportPath = null;
    });
  }

  Future<void> _exportCurrentGrid() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final result = await generateGridFiles(
        _uuids,
        cols: 30,
        cell: 64,
        padding: 16,
        header: 70,
      );

      if (!mounted) return;

      setState(() {
        _lastExportPath = result.pngPath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported PNG + CSV to:\n${result.directoryPath}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandColor = Color.fromARGB(255, 66, 190, 165);

    return Scaffold(
      appBar: AppBar(
        title: const Text('UUID to HSL Colours'),
        actions: [
          IconButton(
            onPressed: _regenerate,
            tooltip: 'Regenerate',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _isExporting ? null : _exportCurrentGrid,
            tooltip: 'Export PNG + CSV',
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${_uuids.length} samples',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Text('•'),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: brandColor,
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('RGB(66,190,165)'),
                      ],
                    ),
                  ],
                ),
                if (_lastExportPath != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Last PNG: $_lastExportPath',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _uuids.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final id = _uuids[index];
                final color = generator.hslColorFromUuid(id).toColor();

                return Tooltip(
                  message: [
                    id,
                    'H: ${generator.getHueFromUuid(id).toStringAsFixed(1)}',
                    'S: ${generator.getSatFromUuid(id).toStringAsFixed(3)}',
                    'L: ${generator.getLightFromUuid(id).toStringAsFixed(3)}',
                  ].join('\n'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: _idealTextColor(color),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _idealTextColor(Color background) {
    final brightness = ThemeData.estimateBrightnessForColor(background);
    return brightness == Brightness.dark ? Colors.white : Colors.black87;
  }
}

class ExportResult {
  final String directoryPath;
  final String pngPath;
  final String csvPath;

  const ExportResult({
    required this.directoryPath,
    required this.pngPath,
    required this.csvPath,
  });
}

/// Generates the PNG and CSV from the exact UUID list currently displayed.
Future<ExportResult> generateGridFiles(
  List<String> uuids, {
  int cols = 30,
  int cell = 64,
  int padding = 16,
  int header = 70,
}) async {
  final n = uuids.length;
  final rows = (n / cols).ceil();
  final width = padding * 2 + cols * cell;
  final height = header + padding + rows * cell + padding;

  final canvas = img.Image(width: width, height: height);
  img.fill(canvas, color: img.ColorRgb8(245, 245, 245));

  img.drawString(
    canvas,
    'UUID to HSL Colours ($n samples)',
    font: img.arial24,
    x: padding,
    y: 18,
    color: img.ColorRgb8(20, 20, 20),
  );

  img.fillRect(
    canvas,
    x1: width - padding - 40,
    y1: 22,
    x2: width - padding,
    y2: 62,
    color: img.ColorRgb8(66, 190, 165),
  );

  for (var i = 0; i < n; i++) {
    final r = i ~/ cols;
    final c = i % cols;
    final x = padding + c * cell;
    final y = header + r * cell;

    final id = uuids[i];
    final h = generator.getHueFromUuid(id);
    final s = generator.getSatFromUuid(id);
    final l = generator.getLightFromUuid(id);

    final rgb = hslToRgb(h, s, l);

    img.fillRect(
      canvas,
      x1: x,
      y1: y,
      x2: x + cell - 1,
      y2: y + cell - 1,
      color: rgb,
    );

    img.drawRect(
      canvas,
      x1: x,
      y1: y,
      x2: x + cell - 1,
      y2: y + cell - 1,
      color: img.ColorRgb8(230, 230, 230),
    );
  }

  final bins = List<int>.filled(36, 0);
  for (final id in uuids) {
    final h = generator.getHueFromUuid(id);
    bins[(h ~/ 10).clamp(0, 35)]++;
  }

  final dir = await getTemporaryDirectory();
  final outDir = Directory('${dir.path}/uuid_grid_out');
  await outDir.create(recursive: true);

  final pngPath = '${outDir.path}/uuid_colors_$n.png';
  final csvPath = '${outDir.path}/uuid_hue_bins_$n.csv';

  await File(pngPath).writeAsBytes(img.encodePng(canvas));

  final csv = StringBuffer('bin_start_deg,count\n');
  for (var i = 0; i < bins.length; i++) {
    csv.writeln('${i * 10},${bins[i]}');
  }
  await File(csvPath).writeAsString(csv.toString());

  return ExportResult(
    directoryPath: outDir.path,
    pngPath: pngPath,
    csvPath: csvPath,
  );
}

/// Minimal HSL -> RGB
img.Color hslToRgb(double h, double s, double l) {
  h = (h % 360 + 360) % 360;
  final c = (1 - (2 * l - 1).abs()) * s;
  final x = c * (1 - ((h / 60) % 2 - 1).abs());
  final m = l - c / 2;

  double r1 = 0;
  double g1 = 0;
  double b1 = 0;

  if (h < 60) {
    r1 = c;
    g1 = x;
    b1 = 0;
  } else if (h < 120) {
    r1 = x;
    g1 = c;
    b1 = 0;
  } else if (h < 180) {
    r1 = 0;
    g1 = c;
    b1 = x;
  } else if (h < 240) {
    r1 = 0;
    g1 = x;
    b1 = c;
  } else if (h < 300) {
    r1 = x;
    g1 = 0;
    b1 = c;
  } else {
    r1 = c;
    g1 = 0;
    b1 = x;
  }

  int to255(double v) => ((v + m) * 255).round().clamp(0, 255);

  return img.ColorRgb8(to255(r1), to255(g1), to255(b1));
}

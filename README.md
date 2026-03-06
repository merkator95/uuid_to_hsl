## Features

Deterministic HSL colours from UUIDs (or any string).

- same input → same colour.
- returns Flutter `Color` / `HSLColor`.
- control saturation, lightness and brand‑hue avoidance.

### Basic use

```dart
import 'package:uuid_to_hsl/uuid_to_hsl.dart';

const generator = UuidToHsl();

final color = generator.colorFromUuid(someUuid);      // Flutter Color
final hsl   = generator.hslColorFromUuid(someUuid);  // HSLColor

final hue = generator.getHueFromUuid(someUuid);      // double 0–360
final sat = generator.getSatFromUuid(someUuid);      // double 0–1
final light = generator.getLightFromUuid(someUuid);  // double 0–1
```

### Configuration

```dart
const generator = UuidToHsl(
  brandHue: 170,
  avoidDeg: 30,
  sMin: 0.5,
  sMax: 0.7,
  lMin: 0.45,
  lMax: 0.65,
);
```

`brandHue`/`avoidDeg` avoid a specific hue band; `sMin`/`sMax`/`lMin`/`lMax` set saturation/lightness ranges.



### Example app & colour distribution

Flutter example in `example/`:

- Grid of UUID‑based colours with tooltips.
- Export current grid as PNG + CSV.



It should produce a fairly uniform distribution over the hue circle. An example of 300 generated colours:

![color_distribution](https://github.com/merkator95/uuid_to_hsl/blob/master/uuid_colors_300.png)

### Legacy (0.0.1) API

```dart
final color = UuidToHsl.getColorFromUUID(uuid);

final hsl = UuidToHsl.getHSLColorFromUUID(
  uuid,
  0.7,
  0.8,
  0.9,
);
```

These static methods are **deprecated** and keep the original 0.0.1 behaviour.
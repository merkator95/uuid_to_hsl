## Features

This package can generate a color for given UUID v4. The color will always be the same, given the same UUID.

It uses two bytes from UUID to generate a color by generating a random hue value in HSL color space.

Method `getColorFromUuid` returns a `Color` object.

If you want to modify other HSL values of the returned Color you can use `getHSLColorFromUUID` method.

Example use:

```dart
color: UuidToHsl.getHSLColorFromUUID(_uuid, 0.7, 0.8, 0.9).toColor()
```
^ will return Color object with alpha of 0.7, saturation of 0.8, and lightness of 0.9 and random hue value generated for the given uuid.

```dart
color: UuidToHsl.getColorFromUUID(_uuid)
```
^ will return Color object with hue generated from uuid and use default values of alpha of 0.9, saturation of 0.9, and lightness of 0.35.

It should return a fairly uniform distribution. Example of 300 generated colors:
![color_distribution](https://github.com/merkator95/uuid_to_hsl/blob/master/hue-distribution.png)
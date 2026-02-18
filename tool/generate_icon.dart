import 'dart:io';
import 'package:image/image.dart';

void main() {
  const size = 1024;
  final image = Image(width: size, height: size);

  // Colors
  final midnightBlue = ColorRgb8(21, 34, 56); // #152238
  final gold = ColorRgb8(255, 215, 0); // #FFD700

  // 1. Fill Background
  fill(image, color: midnightBlue);

  // 2. Draw Outer Crescent Circle (Gold)
  // Center (512, 512), Radius 350
  fillCircle(image, x: 512, y: 512, radius: 350, color: gold, antialias: true);

  // 3. Draw Inner Cutout Circle (Background Color)
  // Shifted right and up to create crescent shape opening to top-right
  // Center (580, 460), Radius 300
  fillCircle(
    image,
    x: 580,
    y: 460,
    radius: 300,
    color: midnightBlue,
    antialias: true,
  );

  // 4. Draw Star (Simple Circle for minimalism)
  // Positioned in the crescent opening
  fillCircle(image, x: 720, y: 360, radius: 35, color: gold, antialias: true);

  // Save to file
  final png = encodePng(image);
  final file = File('assets/icon/app_icon.png');
  file.createSync(recursive: true);
  file.writeAsBytesSync(png);

  print('Successfully generated minimalist Islamic app icon at ${file.path}');
}

import 'dart:io';
import 'package:image/image.dart';

void main() {
  final file = File('assets/icon/original_generated.png');
  if (!file.existsSync()) {
    print('Source file not found');
    exit(1);
  }

  // Decode the image
  final image = decodePng(file.readAsBytesSync())!;

  // The AI generation sometimes adds rounded corners with white/transparent background.
  // We want to CROP the center square to remove these corners.
  // Or simpler: We can just fill the transparent/white pixels with our background color.

  // Strategy: Crop 5% from edges to be safe from corner artifacts
  final cropAmount = (image.width * 0.05).round();
  final cropped = copyCrop(
    image,
    x: cropAmount,
    y: cropAmount,
    width: image.width - (cropAmount * 2),
    height: image.height - (cropAmount * 2),
  );

  // Resize back to 1024x1024
  final resized = copyResize(cropped, width: 1024, height: 1024);

  // Ensure solid background (just in case)
  // We'll create a new solid blue image and draw our cropped icon on top
  final finalImage = Image(width: 1024, height: 1024);
  // Deep Midnight Blue #152238 = RGB(21, 34, 56)
  fill(finalImage, color: ColorRgb8(21, 34, 56));

  // Composite the resized icon on top
  compositeImage(finalImage, resized);

  // Save
  File('assets/icon/app_icon.png').writeAsBytesSync(encodePng(finalImage));
  print('Icon corrected and saved to assets/icon/app_icon.png');
}

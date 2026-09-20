import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ExifService {
  /// Remove metadados EXIF (incluindo GPS e localização) de uma fotografia antes de compartilhar.
  static Future<File> stripExifData(File originalImage) async {
    final bytes = await originalImage.readAsBytes();
    final decodedImage = img.decodeImage(bytes);

    if (decodedImage == null) {
      // Retorna original se falhar decodificação
      return originalImage;
    }

    // Criar nova imagem limpa copiando apenas os pixels sem EXIF
    final cleanImage = img.Image.from(decodedImage);
    final cleanBytes = img.encodeJpg(cleanImage, quality: 90);

    final tempDir = await getTemporaryDirectory();
    final fileName = 'clean_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final cleanFile = File(p.join(tempDir.path, fileName));

    await cleanFile.writeAsBytes(cleanBytes);
    return cleanFile;
  }
}

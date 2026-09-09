import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void registerAdditionalLicenses() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString(
      'assets/licenses/multilingual_e5_small_LICENSE.txt',
    );

    yield LicenseEntryWithLineBreaks(
      ['multilingual-e5-small'],
      license,
    );
  });

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString(
      'assets/licenses/tokenizers_LICENSE.txt',
    );

    yield LicenseEntryWithLineBreaks(
      ['Hugging Face tokenizers'],
      license,
    );
  });
}
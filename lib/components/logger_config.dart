import 'package:logger/logger.dart';

// Create a configured instance of the logger
final logger = Logger(
  // Use PrettyPrinter for formatted output in debug builds
  printer: PrettyPrinter(
    methodCount: 1, // Number of method calls to be displayed
    errorMethodCount: 5, // Number of method calls if stacktrace is provided
    lineLength: 120, // Width of the output
    colors: true, // Colorful log messages
    printEmojis: true, // Print an emoji for each log level
    dateTimeFormat: DateTimeFormat.none, // Replaces printTime: false
  ),
  // Filter for controlling log output in release mode
  filter: ProductionFilter(),
);

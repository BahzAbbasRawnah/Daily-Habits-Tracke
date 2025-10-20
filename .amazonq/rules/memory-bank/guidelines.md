# Daily Habits - Development Guidelines

## Code Quality Standards

### Naming Conventions
- **Classes**: PascalCase (e.g., `Win32Window`, `MyApplication`)
- **Functions/Methods**: camelCase (e.g., `registerWith`, `GetCommandLineArguments`)
- **Variables**: snake_case for C++ (e.g., `window_handle_`, `class_registered_`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `DWMWA_USE_IMMERSIVE_DARK_MODE`)
- **File Names**: snake_case (e.g., `win32_window.cpp`, `utils.cpp`)

### Documentation Standards
- **Header Comments**: Include file generation notices for auto-generated files
- **Function Documentation**: Use platform-specific documentation styles:
  - C++: Brief inline comments for complex operations
  - Java: Standard Javadoc format with @NonNull annotations
  - Swift: Standard Swift documentation format
- **Code Comments**: Explain complex logic, especially platform-specific implementations

### Error Handling Patterns
- **Try-Catch Blocks**: Comprehensive error handling in plugin registration (Java)
- **Null Checks**: Consistent null pointer validation before operations
- **Resource Management**: Proper cleanup of system resources (Windows handles, memory)
- **Logging**: Structured error logging with descriptive messages

## Platform-Specific Implementation Patterns

### Windows (C++)
- **RAII Pattern**: Automatic resource management in constructors/destructors
- **Singleton Pattern**: WindowClassRegistrar uses singleton for window class management
- **Message Handling**: Centralized WndProc with switch-case message routing
- **DPI Awareness**: Dynamic DPI scaling support with scale factor calculations
- **Theme Integration**: Registry-based system theme detection and application

### Android (Java)
- **Plugin Registration**: Centralized plugin management with error isolation
- **Annotation Usage**: @Keep and @NonNull for code optimization and null safety
- **Exception Isolation**: Individual try-catch blocks for each plugin registration
- **Logging**: Consistent error logging with plugin-specific tags

### macOS/iOS (Swift)
- **Plugin Registry Pattern**: Centralized plugin registration function
- **Import Organization**: Grouped imports by framework type
- **Function Naming**: Descriptive function names following Swift conventions

## Architectural Patterns

### Cross-Platform Consistency
- **Generated Code**: Consistent auto-generation patterns across platforms
- **Plugin Integration**: Standardized plugin registration across all platforms
- **Error Handling**: Platform-appropriate error handling while maintaining consistency
- **Resource Management**: Platform-specific but consistent resource cleanup patterns

### Code Organization
- **Separation of Concerns**: Platform-specific code isolated in respective directories
- **Single Responsibility**: Each class/function has a clear, single purpose
- **Dependency Management**: Minimal coupling between platform layers
- **Interface Consistency**: Similar patterns across different platform implementations

## Development Best Practices

### Memory Management
- **C++**: RAII pattern with proper constructor/destructor pairs
- **Reference Counting**: Proper increment/decrement of active window counts
- **Resource Cleanup**: Explicit cleanup in destructors and error paths

### Performance Considerations
- **Lazy Loading**: WindowClassRegistrar registers classes only when needed
- **Efficient Scaling**: Mathematical scaling operations for DPI awareness
- **Minimal Allocations**: Reuse of system resources where possible

### Security Practices
- **Input Validation**: Proper validation of system inputs and parameters
- **Safe Casting**: Use of reinterpret_cast with proper type checking
- **Registry Access**: Safe registry key access with error checking

### Testing Considerations
- **Error Path Testing**: Comprehensive error handling in plugin registration
- **Platform Isolation**: Platform-specific code can be tested independently
- **Resource Cleanup**: Proper cleanup ensures testable, repeatable operations
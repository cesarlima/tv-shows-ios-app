![](https://github.com/cesarlima/tv-shows-ios-app/workflows/CI/badge.svg)
# Work in progress

# **iOS Architecture Showcase Project**

## **Project Overview**

A comprehensive iOS application demonstrating enterprise-level development practices and architectural patterns designed for large-scale team collaboration. This project serves as a practical implementation of industry best practices, showcasing advanced iOS development methodologies essential for building robust, maintainable, and scalable mobile applications.

## **Build and Run**

### Prerequisites
- Xcode 16.0 or later
- iOS 15.0+ deployment target
- [Tuist](https://docs.tuist.dev/en/) installed

### Setup Instructions
1. **Clone the repository**
   ```bash
   git clone https://github.com/cesarlima/tv-shows-ios-app.git
   cd tv-shows-ios-app
   ```

2. **Install Tuist (if not already installed)**
   [Tuist Documentation](https://docs.tuist.dev/en/guides/quick-start/install-tuist)

3. **Generate the Xcode project**
   ```bash
   tuist generate
   ```

4. **Open the workspace**
   ```bash
   open TVShowsApp.xcworkspace
   ```

5. **Build and run**
   - Select your target device or simulator
   - Press `Cmd + R` or click the Run button in Xcode

### Running Tests
```bash
tuist test
```

Or run tests directly in Xcode:
- Press `Cmd + U` to run all tests
- Use the Test navigator to run specific test suites

## **Technical Objectives**
This project was architected to demonstrate proficiency in critical areas of modern iOS development:
### **Enterprise Development Practices**
- **Modular Architecture**: Implemented a highly modular codebase using feature-based modules to enable independent development and testing by multiple teams
- **Clean Architecture**: Applied Uncle Bob's Clean Architecture principles with clear separation of concerns across presentation, domain, and data layers
- **Clean Code**: Enforced SOLID principles, meaningful naming conventions, and comprehensive code documentation throughout the project

### **Advanced iOS Technologies**
- **SwiftUI**: Built modern, declarative user interfaces leveraging SwiftUI's reactive programming paradigm
- **Swift Concurrency**: Implemented async/await patterns, actors, and structured concurrency for efficient asynchronous operations
- **Dependency Injection**: Utilized protocol-oriented programming and dependency injection containers for loose coupling and enhanced testability

### **Development Infrastructure**
- **Tuist Configuration**: Established sophisticated project generation and management using Tuist for consistent build configurations across team environments
- **CI/CD Pipeline**: Designed and implemented automated continuous integration and deployment workflows ensuring code quality and streamlined release processes
- **Comprehensive Testing**: Developed extensive unit test suites with high code coverage, including mock implementations and test doubles

## **Technologies & Tools**

**Core Technologies**: Swift, SwiftUI, Combine, Swift Concurrency  
**Architecture**: Clean Architecture, MVVM, Coordinator Pattern  
**Tools**: [Tuist](https://docs.tuist.dev/en/), Xcode, Git, Fastlane  
**Testing**: XCTest
**CI/CD**: GitHub Actions
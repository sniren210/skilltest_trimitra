# Architecture Guide

## 🏗️ System Architecture Overview

Attendance App menggunakan clean architecture dengan separation of concerns yang jelas.

## 📊 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
├─────────────────────────────────────────────────────────────┤
│  Screens    │  Widgets    │  Providers (State Management)   │
│  - Login    │  - Animated │  - AuthProvider                 │
│  - Splash   │  - Cards    │  - AttendanceProvider           │
│  - Dashboard│  - Buttons  │  - LocationProvider             │
│  - History  │  - Maps     │  - ThemeProvider                │
│  - Settings │             │                                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Business Logic Layer                     │
├─────────────────────────────────────────────────────────────┤
│  Services           │  Models                               │
│  - LocationService  │  - Attendance                         │
│  - CameraService    │  - User                               │
│  - AttendanceService│  - Location                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
├─────────────────────────────────────────────────────────────┤
│  Local Storage      │  External APIs                        │
│  - Hive Database    │  - GPS/Location Services              │
│  - SharedPreferences│  - Camera API                         │
│  - File System      │  - Geocoding API                      │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow

### 1. User Interaction Flow

```
User Input → Screen → Provider → Service → Database/API → UI Update
```

### 2. Location Validation Flow

```
GPS Request → LocationService → Distance Calculation → UI Feedback
```

### 3. Attendance Creation Flow

```
Location Check → Camera Capture → Data Validation → Database Save → UI Update
```

## 🎯 Design Patterns

### 1. Provider Pattern

- **Purpose**: Reactive state management
- **Implementation**: ChangeNotifier dengan Consumer widgets
- **Benefits**: Automatic UI updates, testable logic

### 2. Service Locator Pattern

- **Purpose**: Dependency injection
- **Implementation**: GetIt package
- **Benefits**: Loose coupling, easy testing, single responsibility

### 3. Repository Pattern

- **Purpose**: Data access abstraction
- **Implementation**: Service classes
- **Benefits**: Data source independence, easier mocking

## 🎨 UI Architecture

### Theme Management

- Material 3 design system
- Dynamic theming dengan ThemeProvider
- Dark/Light mode support
- Consistent color schemes

### Animation Strategy

- Flutter Animate untuk micro-interactions
- Staggered animations untuk lists
- Smooth page transitions
- Loading state animations

## 📊 Performance Considerations

### Memory Management

- Proper provider disposal
- Image caching strategies
- Lazy loading implementations

### Battery Optimization

- Efficient location updates
- Minimal background processing
- Smart animation scheduling

### Data Optimization

- Local-first architecture
- Efficient database queries
- Image compression

## 🔒 Security Architecture

### Data Protection

- Local encryption untuk sensitive data
- Secure storage practices
- Input validation

### Permission Management

- Runtime permission requests
- Graceful permission denials
- User-friendly permission explanations

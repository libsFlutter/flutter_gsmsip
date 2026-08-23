# Understanding: UI Theming

## Phase: EXITING

## Validated Understanding

**ThemeService** provides theme management with Material 3 support.

### Core Capabilities:

1. **Theme Mode Management**
   - Light theme
   - Dark theme (default for technical monitoring)
   - System theme (auto-switching)
   - Persistent theme storage via SharedPreferences

2. **Theme Cycling**
   - `toggleTheme()` - Cycle: Light → Dark → System → Light
   - Individual setters: `setLightTheme()`, `setDarkTheme()`, `setSystemTheme()`

3. **Theme Information**
   - `getThemeName()` - "Light", "Dark", or "System"
   - `getThemeDescription()` - User-friendly descriptions
   - `getThemeIcon()` - Appropriate icons for each theme
   - `getAvailableThemes()` - List of all theme options

4. **Status Colors** (Technical Monitoring)

| Status Type | States | Colors |
|-------------|--------|--------|
| Connection | connected/online | Green (#10B981) |
| Connection | connecting | Yellow (#F59E0B) |
| Connection | disconnected/offline | Red (#EF4444) |
| Signal | 80-100% | Green |
| Signal | 60-80% | Light green |
| Signal | 40-60% | Yellow |
| Signal | 20-40% | Orange |
| Signal | 0-20% | Red |
| Call | active/incoming/outgoing | Green |
| Call | ended/missed | Red |
| Call | idle/waiting | Yellow |

### ThemeOption Class:

```dart
class ThemeOption {
  final ThemeMode mode;
  final String name;
  final String description;
  final IconData icon;
}
```

### Implementation Details:

- Extends `ChangeNotifier` for reactive updates
- Default: Dark theme (technical monitoring preference)
- Storage key: `gost_simbox_theme`
- System theme detection via `platformDispatcher.platformBrightness`

## Sources

- `lib/services/theme_service.dart` - Theme management service
- `lib/main.dart` - Material 3 theme configuration

## Flow Recommendation

**Type**: VDD (Visual-Driven Development)
**Confidence**: medium
**Rationale**: User-facing visual experience, theme switching

## Bubble Up

- Three theme modes (Light, Dark, System)
- Persistent storage
- Technical monitoring color palette
- ChangeNotifier integration

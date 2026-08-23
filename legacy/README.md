# GOSTsimbox Android Gateway

A modern Flutter application that provides a bidirectional bridge between GSM telephony + SMS using SIP and SMPP. 

## Features

### 🔄 **Bidirectional Gateway**
- Routes calls between GSM and SIP networks
- Handles incoming SIP calls and routes them to GSM
- Manages outgoing GSM calls initiated by SIP
- Real-time call state synchronization

### 📱 **Modern UI/UX**
- Dark theme with modern Material Design
- Intuitive dashboard with status indicators
- Real-time logging with search and filter capabilities
- Responsive design for various screen sizes

### ⚙️ **Configuration Management**
- SIP credentials management with auto-login
- Device-specific configuration
- Advanced gateway options
- Persistent settings storage

### 📊 **Monitoring & Logging**
- Real-time status monitoring
- Comprehensive logging system
- Search and filter logs
- Call history tracking

## Screenshots

### Authentication Screen
- Clean login interface for SIP credentials
- Remember credentials option
- Auto-login functionality

### Dashboard Screen
- Status cards showing gateway, SIP, and GSM connection states
- Call controls with start/stop functionality
- Recent logs display
- Test controls for development

### Settings Screen
- SIP configuration management
- Gateway options and permissions
- Advanced settings

### Logs Screen
- Full log viewer with search functionality
- Log level indicators (error, warning, success)
- Clear logs option

## Architecture

### Core Components

1. **Models**
   - `GatewayConfig`: Configuration settings
   - `GatewayStatus`: Current gateway state
   - `CallInfo`: Call information and state

2. **Services**
   - `GatewayService`: Core gateway logic
   - `StorageService`: Local storage management

3. **Providers**
   - `GatewayProvider`: State management

4. **Screens**
   - `AuthScreen`: Authentication and setup
   - `DashboardScreen`: Main gateway interface
   - `SettingsScreen`: Configuration management
   - `LogsScreen`: Log viewing and management

### State Management
- Uses Provider pattern for state management
- Real-time status updates
- Persistent configuration storage
- Log management

## Installation

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Android Studio / VS Code
- Android device or emulator (API level 21+)

### Setup
1. Clone the repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

## Configuration

### SIP Settings
- **Username**: Your SIP account username
- **Password**: Your SIP account password
- **Server**: SIP server address (default: 192.168.88.254)
- **Port**: SIP server port (default: 5060)

### Gateway Options
- **Auto Start**: Automatically start gateway on app launch
- **Replace Dialer**: Replace system dialer with gateway dialer
- **Enable Permissions**: Request elevated telephony permissions
- **Remember Credentials**: Save credentials for auto-login

## Usage

### Initial Setup
1. Launch the application
2. Enter your SIP credentials on the authentication screen
3. Configure additional settings if needed
4. Save settings and proceed to dashboard

### Gateway Operation
1. **Start Gateway**: Tap the "Start Gateway" button
2. **Monitor Status**: Watch the status cards for connection states
3. **View Logs**: Check recent logs or view full log screen
4. **End Calls**: Use the "End Call" button when calls are active

### Testing
- Use test buttons to simulate SIP and GSM calls
- Monitor logs for call flow information
- Check status indicators for connection states

## Development

### Project Structure
```
lib/
├── models/           # Data models
├── services/         # Business logic
├── providers/        # State management
├── screens/          # UI screens
├── widgets/          # Reusable components
└── utils/            # Utility functions
```

### Key Dependencies
- `provider`: State management
- `shared_preferences`: Local storage
- `google_fonts`: Typography
- `device_info_plus`: Device information
- `permission_handler`: Permissions
- `logger`: Logging system

### Building for Production
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

## Troubleshooting

### Common Issues
1. **SIP Registration Failed**
   - Check network connectivity
   - Verify SIP credentials
   - Ensure server is reachable

2. **Permissions Issues**
   - Grant required permissions in app settings
   - Enable "Enable Permissions" in settings

3. **Gateway Won't Start**
   - Check configuration settings
   - Verify device compatibility
   - Review logs for error messages

### Debug Information
- View real-time logs in the logs screen
- Check status indicators on dashboard
- Use test controls for debugging

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the ISC License.

## Acknowledgments

- Based on the React Native Legacy Simbox Gateway by Anton Dodonov
- Uses modern Flutter development practices
- Implements Material Design principles


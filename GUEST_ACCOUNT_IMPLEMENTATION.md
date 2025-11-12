# Guest Account Implementation

This implementation provides a complete guest account system using BLoC state management pattern.

## Architecture

### 1. Repository Layer (`lib/repositories/guest_repository.dart`)
- **GuestRepository**: Handles all API interactions and SharedPreferences operations
- Methods:
  - `getStoredGuestToken()`: Retrieves stored guest token
  - `createGuestAccount()`: Makes API call to create guest account
  - `saveGuestToken()`: Saves token to SharedPreferences
  - `removeGuestToken()`: Removes token (for logout)
  - `_getDeviceId()`: Gets unique device identifier

### 2. BLoC Layer (`lib/bloc/guest/`)
- **GuestEvent**: Defines events
  - `CheckGuestEvent`: Check for existing token
  - `CreateGuestEvent`: Create new guest account
  - `LogoutGuestEvent`: Remove guest token
- **GuestState**: Defines states
  - `GuestInitial`: Initial state
  - `GuestLoading`: Loading state with progress indicator
  - `GuestCreated(token)`: Success state with token
  - `GuestError(message)`: Error state with error message
- **GuestBloc**: Main business logic controller

### 3. Service Layer (`lib/services/guest_service.dart`)
- **GuestService**: Utility methods for guest token access
- Methods:
  - `getCurrentGuestToken()`: Get current token
  - `isGuestLoggedIn()`: Check if guest is logged in

## API Integration

### Endpoint
```
POST https://yourserver.com/auth/guest
```

### Request Body
```json
{
  "firstName": "Guest",
  "lastName": "User", 
  "tokenId": "<UUID>",
  "deviceId": "<DEVICE_ID>"
}
```

### Expected Response
```json
{
  "token": "jwt_token_here"
}
```

## UI Integration

### MainScreen Integration
- Automatically triggers `CheckGuestEvent` on app startup via `initState()`
- Uses `BlocListener` to handle errors (shows SnackBar)
- Uses `BlocBuilder` to show loading indicator during API calls
- Loading state shows CircularProgressIndicator overlay without blocking navigation

## Flow

1. **App Startup**: MainScreen's `initState()` triggers `CheckGuestEvent`
2. **Check Existing Token**: GuestBloc checks SharedPreferences for existing token
3. **Token Found**: If token exists, emits `GuestCreated(token)` state
4. **No Token Found**: If no token, automatically triggers `CreateGuestEvent`
5. **Create Guest Account**: Makes API call with generated UUID and device ID
6. **Save Token**: On success, saves token to SharedPreferences and emits `GuestCreated(token)`
7. **Error Handling**: Any errors emit `GuestError(message)` state

## Dependencies Added

```yaml
dependencies:
  http: ^1.1.0                    # HTTP requests
  flutter_bloc: ^8.1.3           # BLoC state management
  shared_preferences: ^2.2.2     # Local storage
  device_info_plus: ^10.1.0      # Device information
  uuid: ^4.2.1                   # UUID generation
  equatable: ^2.0.5             # Value equality for events/states
```

## Usage

### Access Guest Token Anywhere in App
```dart
import 'package:walldecor/services/guest_service.dart';

// Get current guest token
final token = await GuestService.getCurrentGuestToken();

// Check if user is logged in as guest
final isLoggedIn = await GuestService.isGuestLoggedIn();
```

### Logout Guest
```dart
context.read<GuestBloc>().add(const LogoutGuestEvent());
```

### Listen to Guest State Changes
```dart
BlocBuilder<GuestBloc, GuestState>(
  builder: (context, state) {
    if (state is GuestCreated) {
      return Text('Guest Token: ${state.token}');
    } else if (state is GuestLoading) {
      return const CircularProgressIndicator();
    } else if (state is GuestError) {
      return Text('Error: ${state.message}');
    }
    return const SizedBox();
  },
)
```

## Error Handling

- Network errors are caught and displayed via SnackBar
- SharedPreferences errors are handled gracefully
- Device ID retrieval failures use fallback values
- API response validation ensures token exists
- All operations run only once on app startup

## Security Notes

- Guest tokens are stored in SharedPreferences
- Device ID is used for unique identification
- UUID generates unique tokenId for each request
- API endpoint should be updated to your actual server URL

## Customization

To customize the implementation:

1. **Change API Endpoint**: Update `_baseUrl` in `GuestRepository`
2. **Modify Guest User Data**: Update request body in `createGuestAccount()`
3. **Add Additional States**: Extend `GuestState` for more complex flows
4. **Custom Loading UI**: Modify loading overlay in `MainScreen`
5. **Additional Events**: Add more events to `GuestEvent` for features like retry

## Testing

The implementation is testable with:
- Repository can be mocked for unit tests
- BLoC can be tested independently
- Dependency injection allows for test doubles
- Clear separation of concerns for isolated testing
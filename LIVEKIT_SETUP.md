# LiveKit Configuration Guide

Complete setup instructions for LiveKit video calling integration.

## Current Configuration Status

### ✅ Flutter App Configuration
The LiveKit WebSocket URL is already configured in [`environment.dart`](file:///c:/Users/ASUS/S/S01.v1.10/lib/environment.dart):

```dart
static const String liveKitUrl = 'wss://my-new-project-21vhn4cm.livekit.cloud';
```

### ✅ Appwrite Cloud Function
The token generation function is ready at [`livekit_function/index.js`](file:///c:/Users/ASUS/S/S01.v1.10/livekit_function/index.js).

## Required Setup: Appwrite Function Environment Variables

You need to configure the following environment variables in your Appwrite Cloud Function dashboard:

### Environment Variables for `generate-livekit-token` Function

```env
LIVEKIT_URL=wss://my-new-project-21vhn4cm.livekit.cloud
LIVEKIT_API_KEY=API2d8KTSdmswXB
LIVEKIT_API_SECRET=aKIIgM8a0igoiRzPGrw8gVaWowkNIlfmB8wDimI7BiS
```

### Steps to Configure in Appwrite Console

1. **Navigate to Appwrite Console**
   - Go to [https://cloud.appwrite.io/console](https://cloud.appwrite.io/console)
   - Select your project: `gvone`

2. **Create or Update the Function**
   - Go to **Functions** in the sidebar
   - Find or create function: `generate-livekit-token`

3. **Add Environment Variables**
   - Click on the function
   - Go to **Settings** → **Environment Variables**
   - Add the three variables listed above

4. **Deploy the Function**
   - Upload the code from `livekit_function/index.js`
   - Or deploy via Appwrite CLI:
     ```bash
     appwrite functions createDeployment \
       --functionId=generate-livekit-token \
       --entrypoint=index.js \
       --code=./livekit_function
     ```

## Verification

Test the function by calling it from your Flutter app:
```dart
final token = await appwriteService.getLiveKitToken(roomName: 'test-room');
print('LiveKit Token: $token');
```

## Security Notes

> [!WARNING]
> - **Never commit API secrets to version control**
> - Store credentials only in Appwrite function environment variables
> - Rotate API keys periodically for security

## Next Steps

Once configured, the video calling feature will:
- ✅ Generate secure access tokens for each call
- ✅ Allow users to join LiveKit rooms
- ✅ Enable real-time video/audio communication

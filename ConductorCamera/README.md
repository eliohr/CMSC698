# Conductor camera for playback tempo sync
Outlined with help from Google Gemini

## Parameters to optimize
- Elaborate
- On
- This

## Pose Estimation on iOS
- Use Apple Vision framework built on CoreML
- Technical considerations for accuracy/efficiency:
    - Use AVCaptureVideoDataOutputSampleBufferDelegate to receive video frames in real-time
    - Process frames efficiently: alwaysDiscardsLateVideoFrames should be true on your AVCaptureVideoDataOutput to ensure you're always working with the freshest frame
    - Run pose estimation asynchronously on a background queue to avoid blocking the UI

## Hand attributes and MIDI events
- Elaborate
- On
- This

## iOS sends expression information to PC
- Use MIDI Kit framework to set up MIDI Bluetooth
- Create a MIDI Client and advertise it as a Bluetooth MIDI Peripheral
- User configures Bluetooth from Audio MIDI Setup > Window > Show MIDI studio > MIDI studio > Open Bluetooth Configuration > Advertise
- Send a MIDI Event for each hand attribute

## UX
- Elaborate
- On
- This

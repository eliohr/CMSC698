# Conductor camera for playback tempo sync
Outlined with help from Google Gemini

## Parameters to optimize
- Elaborate
- On
- This

## Pose Estimation on iOS
- Use Apple Vision framework built on CoreML
- Technical considerations for accuracy/efficiency:
    - Experiment to determine optimal video resolution and keypoint (right hand or elbow?)
    - Use AVCaptureVideoDataOutputSampleBufferDelegate to receive video frames in real-time
    - Process frames efficiently: alwaysDiscardsLateVideoFrames should be true on your AVCaptureVideoDataOutput to ensure you're always working with the freshest frame
    - Run pose estimation asynchronously on a background queue to avoid blocking the UI
    - Target Frame Rate: Aim for at least 30 FPS for smooth tempo detection. 60 FPS would be even better if achievable. This model proved 100% accurate up to 150 bpm and (about?) 90% accurate up to 200 bpm at 30 FPS

## Hand attributes and MIDI events
- Elaborate
- On
- This

## iOS sends expression information to PC
- Create a MIDI Client and advertise it as a Bluetooth MIDI Peripheral
    - Import CoreMIDI
    - Use MIDIDeviceCreate with the MIDIPropertyCanAdvertise property
    - MIDIBluetoothDriverActivateAllConnections()
- User configures Bluetooth from Audio MIDI Setup > Window > Show MIDI studio > MIDI studio > Open Bluetooth Configuration > Advertise
- Send a MIDI Event for each hand attribute

## UX
- Elaborate
- On
- This

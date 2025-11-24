# Conductor camera for playback tempo sync
Outlined with help from Google Gemini

## Parameters to optimize
- Hand keypoint
- Vision observation confidence
- Buffer capacity
- EMA filter weight
- Beat acceleration threshold
- Tempo range
- Tempo hysterisis

## Pose Estimation on iOS
- Use Apple Vision framework built on CoreML
- Technical considerations for accuracy/efficiency:
    - Experiment to determine optimal video resolution and keypoint (right hand or elbow?)
    - Use AVCaptureVideoDataOutputSampleBufferDelegate to receive video frames in real-time
    - Process frames efficiently: alwaysDiscardsLateVideoFrames should be true on your AVCaptureVideoDataOutput to ensure you're always working with the freshest frame
    - Run pose estimation asynchronously on a background queue to avoid blocking the UI
    - Target Frame Rate: Aim for at least 30 FPS for smooth tempo detection. 60 FPS would be even better if achievable. This model proved 100% accurate up to 150 bpm and (about?) 90% accurate up to 200 bpm at 30 FPS

## Tempo Determination Logic
- Low-pass filtering to smooth out minor jitters
- Beat Detection Algorithm to determine local acceleration peaks
    - Velocity/Acceleration: The "flick" of the hand often corresponds to a peak in acceleration, which can be a more robust indicator than just position. You might derive velocity from coordinate changes and then acceleration.
    - Thresholding: A minimum displacement to qualify as a beat.
    - Time-based Windowing: Peaks must occur within a reasonable time window to be considered part of a rhythmic pattern.
- Tempo Calculation
    * Measure the time between detected peaks (Inter-Beat Interval - IBI).
    * Convert IBI to BPM: BPM = 60 / IBI (in seconds).
    * Averaging: Don't send every single IBI. Average over a few beats to provide a more stable tempo value. A moving average filter would be appropriate.
    * Tempo Range: Define reasonable min/max BPMs.
    * Hysteresis: Implement some hysteresis to prevent rapid, jumpy tempo changes being sent to the DAW due to minor fluctuations in gesture.

## iOS sends tempo information to PC
- Create a MIDI Client and advertise it as a Bluetooth MIDI Peripheral
    - Import CoreMIDI
    - Use MIDIDeviceCreate with the MIDIPropertyCanAdvertise property
    - MIDIBluetoothDriverActivateAllConnections()
- User configures Bluetooth from Audio MIDI Setup > Window > Show MIDI studio > MIDI studio > Open Bluetooth Configuration > Advertise
- Send a MIDI clock signal from the iOS app to the PC using that established connection

## UX
- Display smoothed MIDI clock signal with a pulsing dot
- Receive MIDI Send Song Position Pointer info from the DAW and display “Measure X, Beat X”
- Latency slider to delay the signal from 0-1000 ms (in case the conductor wants to conduct faster)
- Play/pause button
    - Provide a count-in on play at the project’s default tempo (whatever the piece starts at)
    - Sends MIDI Start/Stop messages for playback
    - Only turn on video processing when playing to save power

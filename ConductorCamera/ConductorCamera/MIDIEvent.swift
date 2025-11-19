//
//  MIDIEvent.swift
//  ConductorCamera
//
//  Created by Eli Hooker Reese on 11/19/25.
//  Copyright © 2025 Apple. All rights reserved.
//

// Gemini made this basically
enum MIDIEvent {
    case PitchBend(value: UInt16) // 14-bit data often represented by a 16-bit integer
    case AfterTouch(value: UInt8) // 7-bit data
    case ControlChange(MIDICC)
}
extension MIDIEvent {
    var displayName: String {
        switch self {
        case .PitchBend:
            return "Pitch Bend (14-bit)"
        case .AfterTouch:
            return "Aftertouch (Channel Pressure - 7-bit)"
        case let .ControlChange(cc):
            return cc.displayName
        }
    }
}
enum MIDICC: UInt8, CaseIterable {
    
    // CC numbers 0 through 31 are MSB (Most Significant Byte)
    case BankSelect = 0
    case ModulationWheel = 1
    case BreathController = 2
    case Undefined_3 = 3
    case FootController = 4
    case PortamentoTime = 5
    case DataEntryMSB = 6
    case ChannelVolume = 7
    case Balance = 8
    case Undefined_9 = 9
    case Pan = 10
    case ExpressionController = 11
    case EffectControl1 = 12
    case EffectControl2 = 13
    case Undefined_14 = 14
    case Undefined_15 = 15
    case GeneralPurposeController1 = 16
    case GeneralPurposeController2 = 17
    case GeneralPurposeController3 = 18
    case GeneralPurposeController4 = 19

    case Undefined_20 = 20
    case Undefined_21 = 21
    case Undefined_22 = 22
    case Undefined_23 = 23
    case Undefined_24 = 24
    case Undefined_25 = 25
    case Undefined_26 = 26
    case Undefined_27 = 27
    case Undefined_28 = 28
    case Undefined_29 = 29
    case Undefined_30 = 30
    case Undefined_31 = 31

    // CC numbers 32 through 63 are LSB (Least Significant Byte) for 0-31
    case BankSelectLSB = 32
    case ModulationWheelLSB = 33
    case BreathControllerLSB = 34
    case UndefinedLSB_35 = 35
    case FootControllerLSB = 36
    case PortamentoTimeLSB = 37
    case DataEntryLSB = 38
    case ChannelVolumeLSB = 39
    case BalanceLSB = 40
    case UndefinedLSB_41 = 41
    case PanLSB = 42
    case ExpressionControllerLSB = 43
    case EffectControl1LSB = 44
    case EffectControl2LSB = 45
    case UndefinedLSB_46 = 46
    case UndefinedLSB_47 = 47
    case GeneralPurposeController1LSB = 48
    case GeneralPurposeController2LSB = 49
    case GeneralPurposeController3LSB = 50
    case GeneralPurposeController4LSB = 51

    case UndefinedLSB_52 = 52
    case UndefinedLSB_53 = 53
    case UndefinedLSB_54 = 54
    case UndefinedLSB_55 = 55
    case UndefinedLSB_56 = 56
    case UndefinedLSB_57 = 57
    case UndefinedLSB_58 = 58
    case UndefinedLSB_59 = 59
    case UndefinedLSB_60 = 60
    case UndefinedLSB_61 = 61
    case UndefinedLSB_62 = 62
    case UndefinedLSB_63 = 63

    // Switches (64-69)
    case SustainPedal = 64
    case Portamento = 65
    case Sostenuto = 66
    case SoftPedal = 67
    case LegatoFootswitch = 68
    case Hold2 = 69

    // Sound Controllers (70-79)
    case SoundController1_SoundVariation = 70
    case SoundController2_Timbre = 71
    case SoundController3_ReleaseTime = 72
    case SoundController4_AttackTime = 73
    case SoundController5_Brightness = 74
    case SoundController6_DecayTime = 75
    case SoundController7_VibratoRate = 76
    case SoundController8_VibratoDepth = 77
    case SoundController9_VibratoDelay = 78
    case SoundController10_Undefined = 79

    // General Purpose Controllers (80-84)
    case GeneralPurposeController5 = 80
    case GeneralPurposeController6 = 81
    case GeneralPurposeController7 = 82
    case GeneralPurposeController8 = 83
    case PortamentoControl = 84

    case Undefined_85 = 85
    case Undefined_86 = 86
    case Undefined_87 = 87
    case Undefined_88 = 88
    case Undefined_89 = 89
    case Undefined_90 = 90

    // Effects Depth (91-95)
    case Effects1Depth_ReverbSendLevel = 91
    case Effects2Depth_TremoloDepth = 92
    case Effects3Depth_ChorusSendLevel = 93
    case Effects4Depth_DetuneDepth = 94
    case Effects5Depth_PhaserDepth = 95

    // Parameter Controls (96-101)
    case DataIncrement = 96
    case DataDecrement = 97
    case NonRegisteredParameterNumberLSB = 98
    case NonRegisteredParameterNumberMSB = 99
    case RegisteredParameterNumberLSB = 100
    case RegisteredParameterNumberMSB = 101

    case Undefined_102 = 102
    case Undefined_103 = 103
    case Undefined_104 = 104
    case Undefined_105 = 105
    case Undefined_106 = 106
    case Undefined_107 = 107
    case Undefined_108 = 108
    case Undefined_109 = 109
    case Undefined_110 = 110
    case Undefined_111 = 111
    case Undefined_112 = 112
    case Undefined_113 = 113
    case Undefined_114 = 114
    case Undefined_115 = 115
    case Undefined_116 = 116
    case Undefined_117 = 117
    case Undefined_118 = 118
    case Undefined_119 = 119

    // Channel Mode Messages (120-127)
    case AllSoundOff = 120
    case ResetAllControllers = 121
    case LocalControl = 122
    case AllNotesOff = 123
    case OmniModeOff = 124
    case OmniModeOn = 125
    case MonoModeOn = 126
    case PolyModeOn = 127
}

extension MIDICC {

    var displayName: String {
        let ccNumber = self.rawValue
        let ccName: String
        
        // The switch must cover all cases in the MIDICC enum
        switch self {
        case .BankSelect: ccName = "Bank Select (MSB)"
        case .ModulationWheel: ccName = "Modulation Wheel (MSB)"
        case .BreathController: ccName = "Breath Controller (MSB)"
        case .Undefined_3: ccName = "Undefined"
        case .FootController: ccName = "Foot Controller (MSB)"
        case .PortamentoTime: ccName = "Portamento Time (MSB)"
        case .DataEntryMSB: ccName = "Data Entry MSB"
        case .ChannelVolume: ccName = "Channel Volume (MSB)"
        case .Balance: ccName = "Balance (MSB)"
        case .Undefined_9: ccName = "Undefined"
        case .Pan: ccName = "Pan (MSB)"
        case .ExpressionController: ccName = "Expression Controller (MSB)"
        case .EffectControl1: ccName = "Effect Control 1 (MSB)"
        case .EffectControl2: ccName = "Effect Control 2 (MSB)"
        case .Undefined_14, .Undefined_15, .Undefined_20, .Undefined_21, .Undefined_22, .Undefined_23, .Undefined_24, .Undefined_25, .Undefined_26, .Undefined_27, .Undefined_28, .Undefined_29, .Undefined_30, .Undefined_31: ccName = "Undefined"
            
        // General Purpose Controllers (MSB 16-19)
        case .GeneralPurposeController1: ccName = "GPC 1 (MSB)"
        case .GeneralPurposeController2: ccName = "GPC 2 (MSB)"
        case .GeneralPurposeController3: ccName = "GPC 3 (MSB)"
        case .GeneralPurposeController4: ccName = "GPC 4 (MSB)"
            
        // LSBs
        case .BankSelectLSB: ccName = "Bank Select (LSB)"
        case .ModulationWheelLSB: ccName = "Modulation Wheel (LSB)"
        case .BreathControllerLSB: ccName = "Breath Controller (LSB)"
        case .UndefinedLSB_35: ccName = "Undefined LSB"
        case .FootControllerLSB: ccName = "Foot Controller (LSB)"
        case .PortamentoTimeLSB: ccName = "Portamento Time (LSB)"
        case .DataEntryLSB: ccName = "Data Entry LSB"
        case .ChannelVolumeLSB: ccName = "Channel Volume (LSB)"
        case .BalanceLSB: ccName = "Balance (LSB)"
        case .UndefinedLSB_41: ccName = "Undefined LSB"
        case .PanLSB: ccName = "Pan (LSB)"
        case .ExpressionControllerLSB: ccName = "Expression Controller (LSB)"
        case .EffectControl1LSB: ccName = "Effect Control 1 (LSB)"
        case .EffectControl2LSB: ccName = "Effect Control 2 (LSB)"
        case .UndefinedLSB_46, .UndefinedLSB_47, .UndefinedLSB_52, .UndefinedLSB_53, .UndefinedLSB_54, .UndefinedLSB_55, .UndefinedLSB_56, .UndefinedLSB_57, .UndefinedLSB_58, .UndefinedLSB_59, .UndefinedLSB_60, .UndefinedLSB_61, .UndefinedLSB_62, .UndefinedLSB_63: ccName = "Undefined LSB"
            
        // General Purpose Controllers (LSB 48-51)
        case .GeneralPurposeController1LSB: ccName = "GPC 1 (LSB)"
        case .GeneralPurposeController2LSB: ccName = "GPC 2 (LSB)"
        case .GeneralPurposeController3LSB: ccName = "GPC 3 (LSB)"
        case .GeneralPurposeController4LSB: ccName = "GPC 4 (LSB)"

        // Switches
        case .SustainPedal: ccName = "Sustain Pedal (Hold 1)"
        case .Portamento: ccName = "Portamento Switch"
        case .Sostenuto: ccName = "Sostenuto"
        case .SoftPedal: ccName = "Soft Pedal"
        case .LegatoFootswitch: ccName = "Legato Footswitch"
        case .Hold2: ccName = "Hold 2"

        // Sound Controllers
        case .SoundController1_SoundVariation: ccName = "Sound Variation / Sound Controller 1"
        case .SoundController2_Timbre: ccName = "Timbre / Harmonic Content"
        case .SoundController3_ReleaseTime: ccName = "Release Time"
        case .SoundController4_AttackTime: ccName = "Attack Time"
        case .SoundController5_Brightness: ccName = "Brightness"
        case .SoundController6_DecayTime: ccName = "Decay Time"
        case .SoundController7_VibratoRate: ccName = "Vibrato Rate"
        case .SoundController8_VibratoDepth: ccName = "Vibrato Depth"
        case .SoundController9_VibratoDelay: ccName = "Vibrato Delay"
        case .SoundController10_Undefined: ccName = "Undefined (Sound Controller 10)"

        // General Purpose Controllers (80-84)
        case .GeneralPurposeController5: ccName = "General Purpose Controller 5"
        case .GeneralPurposeController6: ccName = "General Purpose Controller 6"
        case .GeneralPurposeController7: ccName = "General Purpose Controller 7"
        case .GeneralPurposeController8: ccName = "General Purpose Controller 8"
        case .PortamentoControl: ccName = "Portamento Control"
        case .Undefined_85, .Undefined_86, .Undefined_87, .Undefined_88, .Undefined_89, .Undefined_90: ccName = "Undefined"

        // Effects Depth
        case .Effects1Depth_ReverbSendLevel: ccName = "Effects 1 Depth (Reverb Send Level)"
        case .Effects2Depth_TremoloDepth: ccName = "Effects 2 Depth (Tremolo Depth)"
        case .Effects3Depth_ChorusSendLevel: ccName = "Effects 3 Depth (Chorus Send Level)"
        case .Effects4Depth_DetuneDepth: ccName = "Effects 4 Depth (Detune Depth)"
        case .Effects5Depth_PhaserDepth: ccName = "Effects 5 Depth (Phaser Depth)"

        // Parameter Controls
        case .DataIncrement: ccName = "Data Increment (+1)"
        case .DataDecrement: ccName = "Data Decrement (-1)"
        case .NonRegisteredParameterNumberLSB: ccName = "NRPN LSB"
        case .NonRegisteredParameterNumberMSB: ccName = "NRPN MSB"
        case .RegisteredParameterNumberLSB: ccName = "RPN LSB"
        case .RegisteredParameterNumberMSB: ccName = "RPN MSB"

        case .Undefined_102, .Undefined_103, .Undefined_104, .Undefined_105, .Undefined_106, .Undefined_107, .Undefined_108, .Undefined_109, .Undefined_110, .Undefined_111, .Undefined_112, .Undefined_113, .Undefined_114, .Undefined_115, .Undefined_116, .Undefined_117, .Undefined_118, .Undefined_119: ccName = "Undefined"

        // Channel Mode Messages
        case .AllSoundOff: ccName = "All Sound Off"
        case .ResetAllControllers: ccName = "Reset All Controllers"
        case .LocalControl: ccName = "Local Control"
        case .AllNotesOff: ccName = "All Notes Off"
        case .OmniModeOff: ccName = "Omni Mode Off"
        case .OmniModeOn: ccName = "Omni Mode On"
        case .MonoModeOn: ccName = "Mono Mode On"
        case .PolyModeOn: ccName = "Poly Mode On"
        }
        
        // Combine the number and the name
        return "CC \(ccNumber) - \(ccName)"
    }
}

extension MIDIEvent {
    
    /// A static property that generates a complete, ordered list of all
    /// MIDIEvent instances to be used as a data source (e.g., for a PickerView).
    static let allPickableEvents: [MIDIEvent] = {
        // 1. Start with non-CC events
        var events: [MIDIEvent] = [
            .PitchBend(value: 0),
            .AfterTouch(value: 0)
        ]
        
        // 2. Append all 128 Control Change messages using MIDICC.allCases
        let ccEvents = MIDICC.allCases.map { ccCase -> MIDIEvent in // <-- FIX IS HERE!
            // Swift now knows to look inside the MIDIEvent enum for .ControlChange
            return .ControlChange(ccCase)
        }
        
        // 3. Combine the lists
        events.append(contentsOf: ccEvents)
        
        return events
    }()
}

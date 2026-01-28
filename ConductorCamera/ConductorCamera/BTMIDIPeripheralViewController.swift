//
//  BTMIDIPeripheralViewController.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2025 Steffan Andrews • Licensed under MIT License
//

#if os(iOS) || os(visionOS)

import CoreAudioKit
import UIKit

class BTMIDIPeripheralViewController: CABTMIDILocalPeripheralViewController {
    var uiViewController: UIViewController?
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneAction)
        )
        
        // cursor helped me with this ui stuff
        let bodyLabelTag = 99238
        if self.view.viewWithTag(bodyLabelTag) == nil {
            let bodyLabel = UILabel()
            bodyLabel.tag = bodyLabelTag
            bodyLabel.text = "Turn on 'Advertise MIDI Service' above.\n\nIf you're using a Mac computer open Audio MIDI Setup. In the Audio MIDI Setup menu navigate to Window > Show MIDI Studio. In the MIDI Studio menu navigate to MIDI Studio > Open Bluetooth Configuration... and connect to this iPhone.\n\nIf you're using a Windows computer... sorry idk but I'm sure you can find a tutorial on how to connect to Bluetooth MIDI peripherals somewhere online...\n\nProceed by closing this pane and using the settings screen to associate hand attributes with MIDI parameter in the menus below: select a hand attribute from the first menu, select a MIDI parameter from the second menu, and tap 'set MIDI-hand mapping' to apply the changes. I'll give you a little more instruction once you've done that."
            bodyLabel.numberOfLines = 0
            bodyLabel.font = UIFont.systemFont(ofSize: 15)
            bodyLabel.textColor = .secondaryLabel
            bodyLabel.textAlignment = .left
            bodyLabel.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(bodyLabel)

            NSLayoutConstraint.activate([
                bodyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                bodyLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                bodyLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                bodyLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -32)
            ])
        }
    }
    
    @objc
    public func doneAction() {
        uiViewController?.dismiss(animated: true, completion: nil)
    }
}

#endif

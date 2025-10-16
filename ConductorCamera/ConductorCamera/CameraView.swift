/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract: The camera view shows the feed from the camera, and renders the points returned from VNDetectHumanHandpose observations.
*/

import UIKit
import AVFoundation

class CameraView: UIView {

    private var overlayLayer = CAShapeLayer()
    private var coordsDisplayer = CATextLayer()

    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOverlay()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupOverlay()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        if layer == previewLayer {
            overlayLayer.frame = layer.bounds
        }
    }

    private func setupOverlay() {
        previewLayer.addSublayer(overlayLayer)
        previewLayer.addSublayer(coordsDisplayer)
        
        // assistance from Gemini
        coordsDisplayer.frame = CGRect(x: 10, y: 100, width: 300, height: 40)
        coordsDisplayer.foregroundColor = UIColor.white.cgColor
        coordsDisplayer.backgroundColor = UIColor.clear.cgColor
        
        coordsDisplayer.backgroundColor = UIColor.red.withAlphaComponent(0.5).cgColor
    }
    
    func showPoints(color: UIColor, point: CGPoint) {
        overlayLayer.fillColor = color.cgColor
        coordsDisplayer.fontSize = 24
        coordsDisplayer.string = "Wrist: (\(Int(point.x)), \(Int(point.y)))" // assistance from Gemini
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.commit()
    }
}

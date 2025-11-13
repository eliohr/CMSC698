/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract: The camera view shows the feed from the camera, and renders the points returned from VNDetectHumanHandpose observations.
*/

import UIKit
import AVFoundation

class CameraView: UIView {

    private var overlayLayer = CAShapeLayer()
    private var coordsDisplayer = CATextLayer()
    private var accDisplayer = CATextLayer()
    private var tempoDisplayer = CATextLayer()

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
        previewLayer.addSublayer(tempoDisplayer)
        
        // assistance from Gemini
        coordsDisplayer.frame = CGRect(x: 10, y: 100, width: 300, height: 40)
        coordsDisplayer.foregroundColor = UIColor.white.cgColor
        coordsDisplayer.backgroundColor = UIColor.red.withAlphaComponent(0.5).cgColor
        
        accDisplayer.frame = CGRect(x: 10, y: 200, width: 300, height: 40)
        accDisplayer.foregroundColor = UIColor.white.cgColor
        accDisplayer.backgroundColor = UIColor.red.withAlphaComponent(0.5).cgColor
        
        tempoDisplayer.frame = CGRect(x: 10, y: 300, width: 300, height: 40)
        tempoDisplayer.foregroundColor = UIColor.white.cgColor
        tempoDisplayer.backgroundColor = UIColor.red.withAlphaComponent(0.5).cgColor
    }
    
    func showPoints(color: UIColor, point: BufferPoint) {
        
        overlayLayer.fillColor = color.cgColor
        coordsDisplayer.fontSize = 16
        
        let ax = (round((point.filteredAcceleration.dx)*1000))/1000
        let ay = (round((point.filteredAcceleration.dy)*1000))/1000
        let x = (round((point.filteredPoint.x)*1000))/1000
        let y = (round((point.filteredPoint.y)*1000))/1000
        
        let coordsDisplay = "x: \(x), y: \(y)"
        let accDisplay = "xAcc: \(ax), yAcc: \(ay)"
        // let tempoDisplay = "bpm: \(tempo.bpm), meter: \(tempo.meter), beat: \(tempo.beat)"
        coordsDisplayer.string = coordsDisplay
        accDisplayer.string = accDisplay
        // tempoDisplayer.string = tempoDisplay
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.commit()
    }
}

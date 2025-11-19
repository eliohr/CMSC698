/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The camera view shows the feed from the camera, and renders the points returned from VNDetectHumanHandpose observations.
*/

import UIKit
import AVFoundation

class CameraView: UIView {

    private var overlayLayer = CAShapeLayer()
    private var pointsPath = UIBezierPath()
    
    private let filter = EMAFilter()
    private var previousPoints = [CGPoint]()
    
    private let parameters = Parameters()

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
    }
    
    func showPoints(_ points: [CGPoint], color: UIColor) {
        pointsPath.removeAllPoints()
        if previousPoints.isEmpty { previousPoints = points } // TODO: FIGURE OUT WHY THIS RESULTS IN A FATAL INDEX OUT OF RANGE ERROR ONLY SOMETIMES
        for (i, point) in points.enumerated() {
            let x = CGFloat(filter.applyFilter(value: Double(point.x), previousValue: Double(previousPoints[i].x), weight: parameters.displayFilterWeight))
            let y = CGFloat(filter.applyFilter(value: Double(point.y), previousValue: Double(previousPoints[i].y), weight: parameters.displayFilterWeight))
            let p = CGPoint(x: x, y: y)
            pointsPath.move(to: p)
            pointsPath.addArc(withCenter: point, radius: 5, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        }
        overlayLayer.fillColor = color.cgColor
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        overlayLayer.path = pointsPath.cgPath
        CATransaction.commit()
    }
}

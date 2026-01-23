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
    
    func clearPoints() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        overlayLayer.opacity = 0.0
        CATransaction.commit()
    }
    
    func unclearPoints() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        overlayLayer.opacity = 1.0
        CATransaction.commit()
    }

    
    func showPoints(_ points: [CGPoint], color: UIColor) {
        pointsPath.removeAllPoints()
        
        unclearPoints()
        
        if previousPoints.count != points.count {
                previousPoints = points
        }
        
        var filteredPoints: [CGPoint] = []
        
        for (i, point) in points.enumerated() {
            let x = CGFloat(filter.applyFilter(value: Double(point.x), previousValue: Double(previousPoints[i].x), weight: parameters.displayFilterWeight))
            let y = CGFloat(filter.applyFilter(value: Double(point.y), previousValue: Double(previousPoints[i].y), weight: parameters.displayFilterWeight))
            
            let filteredPoint = CGPoint(x: x, y: y)
                    filteredPoints.append(filteredPoint)
            
            pointsPath.move(to: filteredPoint)
            pointsPath.addArc(withCenter: filteredPoint, radius: 10, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        }
        
        previousPoints = filteredPoints
        
        overlayLayer.fillColor = color.cgColor
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        overlayLayer.path = pointsPath.cgPath
        CATransaction.commit()
        
    }
}

//
//  ColorPickerViewController.swift
//  loaderHUD
//
//  Created by Manjunath Chandrashekar on 25/03/18.
//  Copyright © 2018 Manjunath Chandrashekar. All rights reserved.
//

import UIKit

protocol EnumSequence
{
    associatedtype T: RawRepresentable where T.RawValue == Int
    static func all() -> AnySequence<T>
}
extension EnumSequence
{
    static func all() -> AnySequence<T> {
        return AnySequence { return EnumGenerator() }
    }
}

private struct EnumGenerator<T: RawRepresentable>: IteratorProtocol where T.RawValue == Int {
    var index = 0
    mutating func next() -> T? {
        guard let item = T(rawValue: index) else {
            return nil
        }
        index += 1
        return item
    }
}

enum ColorPickerType : Int, EnumSequence {
    typealias T = ColorPickerType
    
    case statusColor
    case spinnerColor
    case hudColor
    case backgroundColor
}

protocol ColorPickerDelegate {
    func selectedColor(_ color: UIColor, for type: ColorPickerType)
}

class ColorPickerViewController: UIViewController {

    @IBOutlet weak var colorWheelView: ColorPickerView!
    var colorPickerType: ColorPickerType!
    var delegate: ColorPickerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dismissVC(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            guard let selectedColor = self.colorWheelView.selectedColor else {
                self.delegate = nil
                return
            }
            self.delegate.selectedColor(selectedColor, for: self.colorPickerType)
            self.delegate = nil
        })
    }
    
}

class ColorPickerView: UIView {

    private var colorWheelImage: UIImage?
    private var imageView: UIImageView?
    private var lensView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = view.frame.width/2
        view.layer.masksToBounds = true
        return view
    }()
    var selectedColor: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        colorWheelImage = buildHueCircle(in: frame, radius: min(frame.width, frame.height))!
        imageView = UIImageView(image: colorWheelImage)
        imageView?.layer.cornerRadius = (imageView?.frame.width)!/2
        imageView?.layer.masksToBounds = true
        addSubview(imageView!)
        addSubview(lensView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        colorWheelImage = buildHueCircle(in: frame, radius: min(frame.width, frame.height))!
        imageView = UIImageView(image: colorWheelImage)
        imageView?.layer.cornerRadius = (imageView?.frame.width)!/2
        imageView?.layer.masksToBounds = true
        addSubview(imageView!)
        addSubview(lensView)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        addSubview(lensView)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchPoint = touches.first?.location(in: self) {
            let color = UIColor(cgColor: colorOfPoint(point: touchPoint))
            selectedColor = color
            lensView.frame = CGRect(x: touchPoint.x-100, y: touchPoint.y-100, width: 100.0, height: 100.0)
            lensView.backgroundColor = color
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lensView.removeFromSuperview()
    }
    
    func colorOfPoint(point:CGPoint) -> CGColor {
        
        var pixel: [CUnsignedChar] = [0, 0, 0, 0]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        
        layer.render(in: context!)
        
        let red: CGFloat   = CGFloat(pixel[0]) / 255.0
        let green: CGFloat = CGFloat(pixel[1]) / 255.0
        let blue: CGFloat  = CGFloat(pixel[2]) / 255.0
        let alpha: CGFloat = CGFloat(pixel[3]) / 255.0
        
        let color = UIColor(red:red, green: green, blue:blue, alpha:alpha)
        
        return color.cgColor
    }

}

func buildHueCircle(in rect: CGRect, radius: CGFloat, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
    let width = Int(rect.size.width * scale)
    let height = Int(rect.size.height * scale)
    let center = CGPoint(x: width / 2, y: height / 2)
    
    let space = CGColorSpaceCreateDeviceRGB()
    let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: space, bitmapInfo: Pixel.bitmapInfo)!
    
    let buffer = context.data!
    
    let pixels = buffer.bindMemory(to: Pixel.self, capacity: width * height)
    var pixel: Pixel
    let maxDistance = hypot(CGFloat(width) - center.x, CGFloat(height) - center.y)/radius
    for y in 0 ..< height {
        for x in 0 ..< width {
            let angle = fmod(atan2(CGFloat(x) - center.x, CGFloat(y) - center.y) + 2 * .pi, 2 * .pi)
            let distance = hypot(CGFloat(x) - center.x, CGFloat(y) - center.y)
            
            let value = UIColor(hue: angle/2 / .pi, saturation: abs(distance/radius) / maxDistance, brightness: 1, alpha: 1)
            
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            value.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            if distance <= (radius * scale) {
                pixel = Pixel(red:   UInt8(red * 255),
                              green: UInt8(green * 255),
                              blue:  UInt8(blue * 255),
                              alpha: UInt8(alpha * 255))
            } else {
                pixel = Pixel(red: 255, green: 255, blue: 255, alpha: 0)
            }
            pixels[y * width + x] = pixel
        }
    }
    
    let cgImage = context.makeImage()!
    return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
}

struct Pixel: Equatable {
    private var rgba: UInt32
    
    var red: UInt8 {
        return UInt8((rgba >> 24) & 255)
    }
    
    var green: UInt8 {
        return UInt8((rgba >> 16) & 255)
    }
    
    var blue: UInt8 {
        return UInt8((rgba >> 8) & 255)
    }
    
    var alpha: UInt8 {
        return UInt8((rgba >> 0) & 255)
    }
    
    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        let red = (UInt32(red) << 24)
        let green = (UInt32(green) << 16)
        let blue = (UInt32(blue) << 8)
        let alpha = (UInt32(alpha) << 0)
        rgba = red | green | blue | alpha
    }
    
    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    
    static func ==(lhs: Pixel, rhs: Pixel) -> Bool {
        return lhs.rgba == rhs.rgba
    }
}


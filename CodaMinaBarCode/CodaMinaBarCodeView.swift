//
//  CodaMinaBarCodeGen.swift
//  CodaMinaBarCode
//
//  Created by Terry Lou on 2023/9/2.
//  BSD license

import Foundation
import SwiftUI
import UIKit

public struct CodaMinaBarcodeView: UIViewRepresentable {
    
    public typealias UIViewType = BarcodeView
    public typealias OnBarcodeGenerated = (UIImage?)->Void
    
    public enum BarcodeType: String {
        case qrCode = "CIQRCodeGenerator"
        case barcode128 = "CICode128BarcodeGenerator"
        case aztecCode = "CIAztecCodeGenerator"
        case PDF417 = "CIPDF417BarcodeGenerator"
    }

    public enum Orientation {
        case up
        case down
        case right
        case left
    }

    @Binding public var data: String
    @Binding public var barcodeType: BarcodeType
    @Binding public var orientation: Orientation
    
    private var onGenerated: OnBarcodeGenerated?

    public init(data: Binding<String>,
        barcodeType: Binding<BarcodeType>,
        orientation: Binding<Orientation>,
        onGenerated: OnBarcodeGenerated?
        ) {

        self._data = data
        self._barcodeType = barcodeType
        self._orientation = orientation
        self.onGenerated = onGenerated
    }
    
    public func makeUIView(context: UIViewRepresentableContext<CodaMinaBarcodeView>) -> CodaMinaBarcodeView.UIViewType {
        let view = BarcodeView()
        view.onGenerated = self.onGenerated
        return view
    }

    public func updateUIView(_ uiView: BarcodeView, context: UIViewRepresentableContext<CodaMinaBarcodeView>) {
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        uiView.gen(data: data, barcodeType: barcodeType)
        uiView.rotate(orientation: orientation)
    }

}

public class BarcodeView: UIImageView {
    
    private var data:String?
    private var barcodeType: CodaMinaBarcodeView.BarcodeType?
    var onGenerated: CodaMinaBarcodeView.OnBarcodeGenerated?
    var ciContext=CIContext()
    func gen(data: String?, barcodeType: CodaMinaBarcodeView.BarcodeType) {
        guard let string = data, !string.isEmpty else {
            self.image = nil
            return
        }
        self.data = data
        self.barcodeType = barcodeType
        let data = string.data(using: String.Encoding.utf8)
        var uiImage: UIImage?
        guard let filter = CIFilter(name: barcodeType.rawValue) else{
            print("gen filter failed..")
            return
        }
        
        if self.barcodeType == CodaMinaBarcodeView.BarcodeType.qrCode{
            filter.setDefaults()
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
        }else{
            filter.setValue(data, forKey: "inputMessage")
        }
        guard let outputImage = filter.outputImage, let cgImage = CIContext().createCGImage(outputImage,
                                                                                       from: outputImage.extent) else {
            return
        }
        let size = CGSize(width: outputImage.extent.width * 3.0,height: outputImage.extent.height * 3.0)
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else {
            print("gen scaledImage failed..")
            DispatchQueue.main.async {
                self.onGenerated?(nil)
            }
            return
        }
        context.interpolationQuality = .none
        context.draw(cgImage,in: CGRect(origin: .zero,size: size))
        uiImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.image = uiImage
        DispatchQueue.main.async {
            self.onGenerated?(uiImage)
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard let barcodeType = barcodeType else{return}
        gen(data: data, barcodeType: barcodeType)
    }

    private func radians (_ degrees: Float) -> Float {
        return degrees * .pi / 180
    }

    func rotate(orientation: CodaMinaBarcodeView.Orientation) {
        if (orientation == .right) {
            self.image = self.image?.rotate(radians: radians(90))
        } else if (orientation == .left) {
            self.image = self.image?.rotate(radians: radians(-90))
        } else if (orientation == .up) {
            self.image = self.image?.rotate(radians: radians(0))
        } else if (orientation == .down) {
            self.image = self.image?.rotate(radians: radians(180))
        }
    }
}

private extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
            context.rotate(by: CGFloat(radians))
            self.draw(in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }
}

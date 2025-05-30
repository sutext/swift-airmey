//
//  AMTextView.swift
//  
//
//  Created by mac-cyy on 2021/11/5.
//

import UIKit

public class AMTextView: UITextView {
    public var placeholder: String = "" {
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    public var placeHolderColor: UIColor = UIColor.gray{
        didSet{
            self.setNeedsDisplay()
        }
    }
    public var placeholderInset: UIEdgeInsets = .init(top: 7, left: 5, bottom: 0, right: 0)
    public override var font: UIFont?{
        didSet{
            self.setNeedsDisplay()
        }
    }
    public override var text: String!{
        didSet{
            self.setNeedsDisplay()
        }
    }
    public override var attributedText: NSAttributedString!{
        didSet{
            self.setNeedsDisplay()
        }
    }
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChanged(noti:)), name: UITextView.textDidChangeNotification, object: self)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func textDidChanged(noti: NSNotification)  {
        self.setNeedsDisplay()
    }
    public override func draw(_ rect: CGRect) {
        if self.hasText {
            return
        }
        let size = placeholder.getStringSize(rectSize: rect.size, font: font ?? UIFont.systemFont(ofSize: 14))
        
        let newOrigin = CGPoint(x: placeholderInset.left, y: placeholderInset.top)
        let newSize = CGSize(width: size.width, height: size.height)
        let newRect = CGRect(origin: newOrigin, size: newSize)
        (self.placeholder as NSString).draw(in: newRect, withAttributes: [NSAttributedString.Key.font: self.font ?? UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor: self.placeHolderColor])
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: self)
    }
}


extension String {
    func getStringSize(rectSize: CGSize,font: UIFont) -> CGSize {
        let str: NSString = self as NSString
        let rect = str.boundingRect(with: rectSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return CGSize(width: ceil(rect.width), height: ceil(rect.height))
    }
}

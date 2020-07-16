import UIKit

//Hello
public enum ShadowCorner {
  case leftTop
  case leftBottom
  case rightTop
  case rightBottom
}

extension UIView {
  //addSubview multiple UIView at a time
  public func addSubviews(views: [UIView]) {
    views.forEach({ addSubview($0) })
  }
  
  //Make the corners of the UIView round.
  public func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
       let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
       let mask = CAShapeLayer()
       mask.path = path.cgPath
       self.layer.mask = mask
  }
  
  public func makeShadow(color: CGColor = UIColor.black.cgColor, opacity: Float = 0.7, whichCorner: ShadowCorner = .rightBottom, offsetWidth: CGFloat = 3, offsetHeight: CGFloat = 3, radius: CGFloat = 5) {
    
    self.layer.masksToBounds = false
    self.layer.shadowColor = color
    self.layer.shadowOpacity = opacity
    
    switch whichCorner {
    case .leftBottom:
      self.layer.shadowOffset = CGSize(width: -offsetWidth, height: offsetHeight)
    case .leftTop:
      self.layer.shadowOffset = CGSize(width: -offsetWidth, height: -offsetHeight)
    case .rightTop:
      self.layer.shadowOffset = CGSize(width: offsetWidth, height: -offsetHeight)
    case .rightBottom:
      self.layer.shadowOffset = CGSize(width: offsetWidth, height: offsetHeight)
    }
    
    self.layer.shadowRadius = radius
    self.layer.shouldRasterize = true
    self.layer.rasterizationScale = UIScreen.main.scale
  }
}

extension UITextField {
  //Add left and right insets of UITextField
  public func addLeftPadding(_ inset: Int = 10) {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(inset), height: self.frame.height))
    self.leftView = paddingView
    self.leftViewMode = ViewMode.always
  }
  
  public func addRightPadding(_ inset: Int = 10) {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(inset), height: self.frame.height))
    self.rightView = paddingView
    self.rightViewMode = ViewMode.always
  }
}

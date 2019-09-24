//
//  HBImageViewer.swift
//  HBChat
//
//  Created by 尤鸿斌 on 2019/9/17.
//

import UIKit

class HBImageViewer: UIView {
    
    var oldRect:CGRect?
    
    var imageArray:[String]?
    
    var imageView:UIImageView!
    
    var isScale = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        
        let image = UIImage.init(named: "catelina")
        let size = self.resizeImage(size: image!.size, maxWidth: kScreenWidth)
        let imgv = UIImageView.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        imgv.isUserInteractionEnabled = true
        imgv.image = image
        imgv.center = self.center
        addSubview(imgv)
        
        let pan =  UIPanGestureRecognizer.init(target: self, action: #selector(panAction(pan:)))
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction(tap:)))
        
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(doubleTapAction(doubleTap:)))
        doubleTap.numberOfTapsRequired = 2
        
        imgv.addGestureRecognizer(pan)
        imgv.addGestureRecognizer(tap)
        imgv.addGestureRecognizer(doubleTap)
        tap.require(toFail: doubleTap)
        
        self.imageView = imgv
    }
    
    func showWithView(imageV:UIImageView) {
        let window = UIApplication.shared.keyWindow
        let rect = imageV.convert(imageV.bounds, to: window)
        oldRect = rect
        
        self.alpha = 1
        self.isHidden = false
        imageView.frame = rect
        let image = imageV.image
        imageView.image = image
        let size = self.resizeImage(size: image!.size, maxWidth: kScreenWidth)
        UIView.animate(withDuration: 0.3) {
            self.imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            self.imageView.center = self.center
        }
        
    }
    
    @objc func panAction(pan:UIPanGestureRecognizer){
        let transP = pan.translation(in: self.imageView)
        
        switch pan.state {
        case .began: break
        case .changed:
            self.imageView.transform = CGAffineTransform.init(translationX: transP.x, y: transP.y)
        case .ended:
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.imageView.transform = CGAffineTransform.init(translationX: 0, y: 0)
            }, completion: nil)
            break
        
        default:
            break
        }
    }
    
    @objc func tapAction(tap:UITapGestureRecognizer){
        if self.isHidden == false {
            UIView.animate(withDuration: 0.3, animations: {
                self.imageView.frame = self.oldRect!
                self.alpha = 0
            }) { (completed) in
                self.isHidden = true
            }
        }
    }
    @objc func doubleTapAction(doubleTap:UITapGestureRecognizer){
//        let locatePoint = doubleTap.location(in: self.imageView)
        
        if isScale == true {
            isScale = false
            UIView.animate(withDuration: 0.3) {
                self.imageView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
        }else{
            isScale = true
            UIView.animate(withDuration: 0.3) {
                self.imageView.transform = CGAffineTransform.init(scaleX: 2, y: 2)
            }
//            UIView.animate(withDuration: 0.3, animations: {
//                self.imageView.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
//                self.alpha = 0
//            }) { (completed) in
//                self.isHidden = true
//            }
        }
        
        
        
    }
    
    
    func resizeImage(size:CGSize,maxWidth:CGFloat)->CGSize{
        
        var scale:CGFloat = 1
        var newWidth:CGFloat = maxWidth
        var newHeight:CGFloat = maxWidth
        
        if size.width != size.height{
            if size.width > size.height{
                scale = size.width/maxWidth
                newHeight = size.height/scale
            }
            if size.width < size.height{
                scale = size.height/maxWidth
                newWidth = size.width/scale
            }
        }
        return CGSize(width: newWidth, height: newHeight)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("imgviewer error")
    }
    
}

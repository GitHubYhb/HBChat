//
//  HBImageViewer.swift
//  HBChat
//
//  Created by 尤鸿斌 on 2019/9/17.
//

import UIKit

class HBImageViewer: UIView {
    
    func showWithRect(rect:CGRect) {
        self.isHidden = false
    }
    var imageArray:[String]?
    
    var imageView:UIImageView!
    
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
        imgv.addGestureRecognizer(pan)
        self.imageView = imgv
    }
    @objc func panAction(pan:UIPanGestureRecognizer){
        let transP = pan.translation(in: self.imageView)
        
        print(transP)
        switch pan.state {
        case .began: break
        case .changed:
//            self.imageView.center = transP
            self.imageView.transform = CGAffineTransform.init(translationX: transP.x, y: transP.y)
        case .ended:
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.imageView.transform = CGAffineTransform.init(translationX: 0, y: 0)
            }, completion: nil)
            break
        case .cancelled:
            print("cancle")
        default:
            break
        }
//        pan.setTranslation(CGPoint.zero, in: self.imageView)
//        // 移动图片控件
//        self.imageView.transform = CGAffineTransformTranslate(self.imageView.transform, transP.x, transP.y);
//
//        // 复位,表示相对上一次
//        [pan setTranslation:CGPointZero inView:self.imageView];

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

# HBChat介绍

这是我的第一个git项目，我在学习Swift的过程中，不断迭代的一个项目。

现在这个项目也很简单，就是模仿微信朋友圈绘制的一个界面。                 
但是就像它的名字一样，后续我会完善这个项目，在里面加入新的东西。                 
相信大家也知道，微信朋友圈看似简单，实际操作起来还是比较复杂的。      
这里我也会记录一些我在编码过程当中遇到的比较麻烦的问题以及注意的点。

## 常用框架引用
>   pod 'Alamofire'     
  pod 'RxSwift'     
  pod 'RxCocoa'     
  pod 'Kingfisher'      
  pod 'SnapKit'     
  pod 'Moya'        
  pod 'HandyJSON'       
  pod 'Result'      
  pod 'RxDataSources'       
  pod 'SVProgressHUD'       
  pod 'YYText'      
  pod 'RxKeyboard'      

## 网络
目前这里面的API接口，是我用RAP2写的模拟数据API。        
其中，我采用`Alamofire+Moya`来做数据请求，采用`HandyJSON`来做数据解析       
网络图片加载则是用了`Kingfisher`
## 布局
布局方面就是用了`SnapKit`。由于以前我主要是写`Objective-C`，并且用的是`SDAutoLayout`,所以对`masonry`并不是很熟悉，也相当是一个新手从零开始学习，但这毕竟是用的人最多的，跟随大众的脚步，总不会错的。    
`SnapKit`主要做的就是基础控件的布局，以及每条cell的高度自适应。

## 响应式
我相信，学习`Swift`，那么必不能错过的就是`RxSwift`，并且在最近我有发现最新的`SwiftUI`中一部分内容跟`RxSwift`很是相似，相比这也是前端开发发展的一个趋势。   
在这个项目中了，有用到不少`RxSwift`以及`RxCocoa`的内容，并且确实提供了相当的便利性。

## 遇到的问题
### 1、全文和收起功能
微信朋友圈当文本内容过长时，会只显示一部分，需要用户点击`全文`才会全部显示，这其中我遇到的问题呢，是当用户点了全文之后，我通过`数据模型`去控制开关，如果在OC中，修改了这个`数据模型`中的数据，那么对应的数组里面的那个模型也会跟着改变，就是深拷贝的那个问题，但是在`swift`中似乎就不一样。      

**解决方法**：在修改了`数据模型`中的数据之后，主动去替换原数组中的那个模型。

### 2、刷新单行动画导致的数据残留问题
具体问题描述跟解决办法我已经在篇文章里面有具体说明了，有想法的请移步
https://juejin.im/post/5d70aeeaf265da03b8108081

### 3、SnapKit报错
Unable to simultaneously satisfy constraints. Probably at least one of the constraints in the following list is one you don't want. Try this:

找到报错的根源，然后给他加上优先级就可以解决了      
**解决方法**：
```
imageContainer.snp.makeConstraints{
            $0.top.equalTo(moreBtn.snp.bottom).offset(10)
            $0.left.equalTo(nameLabel.snp.left)
            $0.width.equalTo(250)
            $0.height.equalTo(250).priority(999)
}
```

### 4、单张图片以及多张图片布局问题
多张图片的情况相对单张图片比较简单，多张图片只需要无脑设置`等长宽`的`UIImageView`就可以了，但是单张就需要根据图片的比例设置长宽。  
起初我在处理的时候，没有考虑清楚，拿了第一张图就直接进行了不同长宽的设置，导致了cell复用时，显示的错误。        
后来我把单张图片的情况，单独列了出来，不再跟多张图片混合使用。

### 5、评论点赞模块富文本
评论点赞模块其实还是有点复杂的。        
我在做的时候，使用了`YYLabel`，之所以不用`UILabel`的原因是原生`UILabel`设置了超链接之后，字体颜色是死的。

### 6、单张图片修改大小循环引用导致内存泄漏
我在设置单张图片的时候，由于接口没有返回图片尺寸，所以我需要在图片加载完成之后再根据图片尺寸做UIImageView大小调整。         
然后我在`kingfisher`加载完图片后的闭包回调中，将尺寸以及需要刷新单行的信息通过`PublishSubject`发送给外界，起初我以为是重复加载图片导致的卡顿问题，后来才发现是因为循环引用导致了内存泄漏！问题很严重啊！      
于是，我尝试了各种方法，都没有解决。
这种案例确确实实经常存在，所以我选择不直接用`kingfisher`那种简便的方法。
在加载图片前，我先判断是否有缓存。如果有缓存就主动获取图片，没有的话，就`下载`图片，注意：这里是`下载`，并不显示图片。
在下载完成之后，刷新单行时，那必定会有缓存了。下面是代码
```
//临时图片
let urlStr = BaiduImages[0]
let url = URL(string: urlStr)

let kfManager = KingfisherManager.shared
// 通过manager 获取cache
let cache = kfManager.cache

//下载完图片后，必有缓存
if cache.isCached(forKey: urlStr) {
    var img = cache.retrieveImageInMemoryCache(forKey: urlStr, options: nil)
    if img == nil {
        // 虽弃用但可用，如果放到block 里面会因为线程回调导致UI错误
        img = cache.retrieveImageInDiskCache(forKey: urlStr)
    }
    let newSize = self.resizeImage(size: img?.size ?? CGSize(width: 0, height: 0 ))
    self.singleImageView.image = img

    self.singleImageView.snp.updateConstraints{
        $0.width.equalTo(newSize.width)
        $0.height.equalTo(newSize.height)
    }
    self.sepView.snp.updateConstraints{
        $0.top.equalTo(newSize.height).priority(999)
    }
}else{
    kfManager.downloader.downloadImage(with: url!, options: nil) { result in
        self.needReloadRow.onNext(true)
    }
}
```


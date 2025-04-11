//
//  AMImageCache.swift
//  Airmey
//
//  Created by supertext on 2020/9/7.
//  Copyright © 2020年 airmey. All rights reserved.
//

import UIKit
import Photos

/// Convert a synchronous image task to an asynchronous task
/// Add cancelable implemention
public class AMImageTask:NSObject{
    var item:DispatchWorkItem!
    var finish: ONResult<UIImage>?
    var exe:()->Result<UIImage,Error>
    public init(_ exe:@escaping (()->Result<UIImage,Error>),finish: ONResult<UIImage>?){
        self.finish = finish
        self.exe = exe
        super.init()
        self.item = .init(block: {[weak self] in
            guard let self else { return }
            let result = self.exe()
            DispatchQueue.main.async {
                self.finish?(result)
            }
        })
    }
    public func resume(in queue:DispatchQueue){
        queue.async(execute: item)
    }
    public func cancel(){
        self.item?.cancel()
        self.finish = nil
    }
}
/// image cache control
public class AMImageCache {
    public static let shared = AMImageCache()
    private let rootQueue = DispatchQueue(label: "com.airmey.imageQueue")
    private let imageCache = NSCache<NSString,UIImage>()//big image cache
    private let thumbCache = NSCache<NSString,UIImage>()//thumb image cache
    private let diskCache = URLCache(memoryCapacity: 120*1024*1024, diskCapacity: 1000*1024*1024, diskPath: "com.airmey.imageCache")
    private lazy var downloader:URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = self.diskCache
        config.httpShouldSetCookies = true
        config.httpShouldUsePipelining = true
        config.requestCachePolicy = .useProtocolCachePolicy
        config.allowsCellularAccess = true
        config.timeoutIntervalForRequest = 60
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        queue.underlyingQueue = rootQueue
        queue.name = "com.airmey.imageQueue.session"
        queue.qualityOfService = .default
        return URLSession(configuration: config,delegate: nil,delegateQueue: queue)
    }()

    private init(){
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        self.thumbCache.countLimit = 50
        
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let costLimit = totalMemory / 5
        self.imageCache.totalCostLimit = (costLimit > Int.max) ? Int.max : Int(costLimit)
        self.imageCache.countLimit = 0
    }
    
    @objc private func didEnterBackground() {
        clearMemery()
    }
}
extension AMImageCache{
    /// remove image for url
    public func remove(image url:String){
        if let u = URL(string: url){
            imageCache.removeObject(forKey: url as NSString)
            diskCache.removeCachedResponse(for: URLRequest(url: u))
        }
    }
    /// clear all memery and disk cahce
    public func clear(){
        self.diskCache.removeAllCachedResponses()
        self.imageCache.removeAllObjects()
        self.thumbCache.removeAllObjects()
    }
    /// total cached size of image cache
    public var diskUseage:Int{
        return self.diskCache.currentDiskUsage
    }
    /// remove all the disk image cache
    public func clearDisk(){
        self.diskCache.removeAllCachedResponses()
    }
    /// remove all the memery image cache
    public func clearMemery(){
        self.imageCache.removeAllObjects()
        self.thumbCache.removeAllObjects()
    }
    
    /// request a remote image sync
    @discardableResult
    public func image(with url:String,scale:CGFloat = 3,finish: ONResult<UIImage>?) -> URLSessionDataTask?{
        guard let requrl = URL(string: url) else {
            finish?(.failure(AMImageError.invalidURL(url)))
            return nil
        }
        var request = URLRequest(url: requrl)
        request.httpMethod = "GET"
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        let task = self.downloader.dataTask(with: request) { data, resp, error in
            guard let data = data else{
                let error = error ?? AMImageError.invalidData(data)
                DispatchQueue.main.async { finish?(.failure(error)) }
                return
            }
            guard let image:UIImage = .data(data, scale: scale) else{
                let error = AMImageError.invalidData(data)
                DispatchQueue.main.async { finish?(.failure(error)) }
                return
            }
            self.imageCache.setObject(image, forKey: url as NSString)
            DispatchQueue.main.async { finish?(.success(image)) }
        }
        task.resume()
        return task
    }
}
extension AMImageCache{
    /// ge memeryt cached image if exsit
    public func image(for url:String)->UIImage?{
        self.imageCache.object(forKey: url as NSString)
    }
    /// get disk cached image if exsit
    public func diskImage(for url:String)->UIImage?{
        if let url = URL(string: url),
           let data = diskCache.cachedResponse(for: URLRequest(url: url))?.data {
            return .data(data)
        }
        return nil
    }
    /// get memeryt cached image from PHAsset if exsit
    public func image(for asset:PHAsset)->UIImage?{
        self.imageCache.object(forKey: asset.localIdentifier as NSString)
    }
    /// get memeryt cached thumb image from PHAsset if exsit
    public func thumb(for asset:PHAsset,size:CGSize)->UIImage?{
        let key = "\(asset.localIdentifier)_w\(size.width)_h\(size.height)" as NSString
        if let image = self.thumbCache.object(forKey: key) {
            return image
        }
        return nil
    }
    public func diskImage(for url:String,finish:ONResult<UIImage>?)->AMImageTask{
        let task = AMImageTask({
            if let image  = self.diskImage(for: url){
                return .success(image)
            }
            return .failure(NSError(domain: "NotExsit", code: 0))
        }) { result in
            if let image = result.value {
                self.imageCache.setObject(image, forKey: url as NSString)
            }
            finish?(result)
        }
        task.resume(in: self.rootQueue)
        return task
    }
}
extension AMImageCache{
    /// get image form PHAsset sync
    public func image(with asset:PHAsset) -> Result<UIImage,Error>{
        let maxlen = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        return self.image(with: asset, size: CGSize(width:maxlen,height:maxlen))
    }
    /// get image form PHAsset sync
    public func image(with asset:PHAsset,size:CGSize) ->Result<UIImage,Error>{
        let options = PHImageRequestOptions()
        options.isSynchronous = true;
        var image:UIImage?
        var userInfo:[String:Any]?
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .default, options: options) { (img, info) in
            image = img
            userInfo = info as? [String:Any]
        }
        guard let img = image else {
            return .failure(AMImageError.invalidAsset(userInfo))
        }
        return .success(img);
    }
    /// get an image from PHAsset async
    @discardableResult
    public func image(with asset:PHAsset,finish: ONResult<UIImage>?)->AMImageTask{
        let task = AMImageTask {
            self.image(with: asset)
        } finish: { result in
            if let image  =  result.value{
                self.imageCache.setObject(image, forKey: asset.localIdentifier as NSString)
            }
            DispatchQueue.main.async { finish?(result) }
        }

        task.resume(in: rootQueue)
        return task
    }
    /// get an thumb image from PHAsset async.
    @discardableResult
    public func thumb(with asset:PHAsset,size:CGSize,finish: ONResult<UIImage>?)->AMImageTask{
        let key = "\(asset.localIdentifier)_w\(size.width)_h\(size.height)" as NSString
        let task = AMImageTask {
            self.image(with: asset,size: size)
        } finish: { result in
            if let image  =  result.value{
                self.imageCache.setObject(image, forKey: key)
            }
            DispatchQueue.main.async { finish?(result) }
        }
        task.resume(in: rootQueue)
        return task
    }
}
fileprivate var imageTaskKey:Void?
fileprivate var remoteTaskKey:Void?
extension UIView{
    var imageTask:AMImageTask?{
        get{
            return objc_getAssociatedObject(self, &imageTaskKey) as? AMImageTask
        }
        set{
            objc_setAssociatedObject(self, &imageTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    var remoteTask:URLSessionDataTask?{
        get{
            return objc_getAssociatedObject(self, &remoteTaskKey) as? URLSessionDataTask
        }
        set{
            objc_setAssociatedObject(self, &remoteTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
extension UIImageView{
    public func setImage(
        with url:String,
        scale:CGFloat = 3,
        placeholder:UIImage? = nil,
        animate: Bool = true,
        finish:((UIImageView,Result<UIImage,Error>)->Void)? = nil)
    {
        self.imageTask?.cancel()
        self.remoteTask?.cancel()
        if let image = AMImageCache.shared.image(for: url){
            self.image = image
            finish?(self,.success(image))
            return
        }
        self.image = placeholder
        self.imageTask = AMImageCache.shared.diskImage(for: url) {[weak self] result in
            guard let self = self else { return }
            self.imageTask = nil
            if let image = result.value{
                self.image = image
                finish?(self,.success(image))
                return
            }
            self.remoteTask?.cancel()
            self.remoteTask = AMImageCache.shared.image(with: url,scale:scale) {[weak self] result in
                guard let self = self else { return }
                self.imageTask = nil
                guard case .success(let image) = result else{
                    finish?(self,result)
                    return
                }
                if animate {
                    UIView.transition(
                        with: self,
                        duration: 0.5,
                        options: .transitionCrossDissolve,
                        animations: { self.image = image }) { _ in
                        finish?(self,result)
                    }
                }else {
                    self.image = image
                    finish?(self,result)
                }
            }
        }
    }
    public func setImage(with asset:PHAsset,placeholder:UIImage? = nil,finish:((UIImageView,Result<UIImage,Error>)->Void)? = nil){
        if let image = AMImageCache.shared.image(for: asset) {
            self.image = image
            finish?(self,.success(image))
            return
        }
        self.image = placeholder
        self.imageTask?.cancel()
        self.imageTask  = AMImageCache.shared.image(with: asset) {[weak self] result in
            guard let self = self else { return }
            self.imageTask = nil
            guard case .success(let image) = result else{
                finish?(self,result)
                return
            }
            UIView.transition(
                with: self,
                duration: 0.5,
                options: .transitionCrossDissolve,
                animations: { self.image = image }) { _ in
                finish?(self,result)
            }
        }
    }
    public func setThumb(with asset:PHAsset,size:CGSize,placeholder:UIImage?  = nil,finish:((UIImageView,Result<UIImage,Error>)->Void)? = nil){
        if let image = AMImageCache.shared.thumb(for: asset,size: size) {
            self.image = image
            finish?(self,.success(image))
            return
        }
        self.image = placeholder
        self.imageTask?.cancel()
        self.imageTask = AMImageCache.shared.thumb(with: asset,size:size) {[weak self] result in
            guard let self = self else { return }
            self.imageTask = nil
            guard case .success(let image) = result else{
                finish?(self,result)
                return
            }
            UIView.transition(
                with: self,
                duration: 0.5,
                options: .transitionCrossDissolve,
                animations: { self.image = image }) { _ in
                finish?(self,result)
            }
        }
    }
}
extension UIButton{
    public func setImage(with url:String,scale:CGFloat = 3,placeholder:UIImage? = nil,for state:UIControl.State = .normal,finish:((UIButton,Result<UIImage,Error>)->Void)? = nil)  {
        if let image = AMImageCache.shared.image(for: url){
            self.setImage(image, for: state)
            finish?(self,.success(image))
            return
        }
        self.setImage(placeholder, for: state)
        self.imageTask?.cancel()
        self.imageTask = AMImageCache.shared.diskImage(for: url) {[weak self] result in
            guard let self = self else { return }
            self.imageTask  = nil
            if let image = result.value{
                self.setImage(image, for: state)
                finish?(self,.success(image))
                return
            }
            self.remoteTask?.cancel()
            self.remoteTask = AMImageCache.shared.image(with: url,scale:scale) {[weak self] result in
                guard let self = self else { return }
                self.imageTask = nil
                guard case .success(let image) = result else{
                    finish?(self,result)
                    return
                }
                UIView.transition(
                    with: self,
                    duration: 0.5,
                    options: .transitionCrossDissolve,
                    animations: { self.setImage(image, for: .normal) }) { _ in
                    finish?(self,result)
                }
            }
        }
    }
}
public enum AMImageError:Error{
    case invalidAsset([String:Any]?=nil)
    case invalidURL(String)
    case invalidData(Data?=nil)
}

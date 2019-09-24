//
//  Create.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {
    // MARK: create

    /**
     Creates an observable sequence from a specified subscribe method implementation.

     - seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)

     - parameter subscribe: Implementation of the resulting observable sequence's `subscribe` method.
     - returns: The observable sequence with the specified implementation for the `subscribe` method.
     */
    public static func create(_ subscribe: @escaping (AnyObserver<Element>) -> Disposable) -> Observable<Element> {
        //1. 调用AnonymousObservable 初始化方法，保存了我们写的block 代码
        
        return AnonymousObservable(subscribe)
    }
}

final private class AnonymousObservableSink<Observer: ObserverType>: Sink<Observer>, ObserverType {
    // 重命名
    typealias Element = Observer.Element 
    typealias Parent = AnonymousObservable<Element>

    // state
    private let _isStopped = AtomicInt(0)

    #if DEBUG
        fileprivate let _synchronizationTracker = SynchronizationTracker()
    #endif

    //初始化 保存了我们传递过来的观察者 
    override init(observer: Observer, cancel: Cancelable) {
        super.init(observer: observer, cancel: cancel)
        
    }

    func on(_ event: Event<Element>) {
        
        #if DEBUG
            self._synchronizationTracker.register(synchronizationErrorMessage: .default)
            defer { self._synchronizationTracker.unregister() }
        #endif
        switch event {
        case .next:
            if load(self._isStopped) == 1 {
                return
            }
            self.forwardOn(event)
        case .error, .completed:
            if fetchOr(self._isStopped, 1) == 0 {
                self.forwardOn(event)
                self.dispose()
            }
        }
    }
    
    // 8. AnonymousObservableSink run方法调用
    func run(_ parent: Parent) -> Disposable {
        //9. 执行保存的block的内容 参数就是我们后续需要执行onNext的观察者
        // AnyObserver(self)
        return parent._subscribeHandler(AnyObserver(self))
    }
}

final private class AnonymousObservable<Element>: Producer<Element> {
    typealias SubscribeHandler = (AnyObserver<Element>) -> Disposable

    let _subscribeHandler: SubscribeHandler

    init(_ subscribeHandler: @escaping SubscribeHandler) {
        self._subscribeHandler = subscribeHandler
    }

    //6. run方法被调用
    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        //7. 创建 AnonymousObservableSink 调用 run
        let sink = AnonymousObservableSink(observer: observer, cancel: cancel)
        let subscription = sink.run(self)
        return (sink: sink, subscription: subscription)
    }
}

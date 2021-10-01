//
//  Observable.swift
//  Messenger
//
//  Created by Усман Туркаев on 20.08.2021.
//

import Foundation

class Observable<T>: NSObject {
    
    var value: T? {
        didSet {
            listener?(value)
        }
    }
    
    private var listener: ((T?) -> Void)?
    
    func bind(_ listener: @escaping ((T?) -> Void)) {
        listener(value)
        self.listener = listener
    }
    
    func waitUpdates(_ listener: @escaping ((T?) -> Void)) {
        self.listener = listener
    }
    
    func removeListener() {
        self.listener = nil
    }
}

class MultiObservable<T>: NSObject {
    
    var value: T? {
        didSet {
            listener1?(value)
            listener2?(value)
        }
    }
    
    private var listener1: ((T?) -> Void)?
    
    private var listener2: ((T?) -> Void)?
    
    func bindFirst(_ listener: @escaping ((T?) -> Void)) {
        listener(value)
        self.listener1 = listener
    }
    
    func bindSecond(_ listener: @escaping ((T?) -> Void)) {
        listener(value)
        self.listener2 = listener
    }
    
    func waitUpdates(_ listener: @escaping ((T?) -> Void)) {
        self.listener2 = listener
    }
    
    func removeFirstListener() {
        self.listener1 = nil
    }
    
    func removeSecondListener() {
        self.listener2 = nil
    }
}


class PredefinedObservable<T>: NSObject {
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    private var listener: ((T) -> Void)?
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ listener: @escaping ((T) -> Void)) {
        self.listener = listener
    }
    
    func removeListener() {
        self.listener = nil
    }
}

class DefinedObservable<T>: NSObject {
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    private var listener: ((T) -> Void)?
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ listener: @escaping ((T) -> Void)) {
        self.listener = listener
        listener(value)
    }
    
    func removeListener() {
        self.listener = nil
    }
}

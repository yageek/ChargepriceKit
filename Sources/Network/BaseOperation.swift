//
//  File.swift
//  
//
//  Created by Yannick Heinrich on 11.03.21.
//

import Foundation

class BaseOperation: Operation {
    var _isFinished: Bool = false
    override var isFinished: Bool {
        set {
            willChangeValue(forKey: "isFinished")
            _isFinished = newValue
            didChangeValue(forKey: "isFinished")
        }

        get {
            return _isFinished
        }
    }

    var _isExecuting: Bool = false

    override var isExecuting: Bool {
        set {
            willChangeValue(forKey: "isExecuting")
            _isExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }

        get {
            return _isExecuting
        }
    }

    func finish() {
        isExecuting = false
        isFinished = true
    }
}

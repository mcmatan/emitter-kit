import Foundation


public func += (storage: inout [Listener], listener: Listener) {
  storage.append(listener)
}

open class Listener {
    open let cleanListenerNotificationName = NSNotification.Name("cleanListenerNotificationName")

  public var isListening: Bool {
    get {
      return _listening
    }
    set {
      if _listening == newValue {
        return
      }
      _listening = newValue
      if _listening {
        _startListening()
      } else {
        _stopListening()
      }
    }
  }

  public weak var target: AnyObject!

  public let once: Bool

  let _targetID: String

  let _handler: (Any!) -> Void

  var _listening = false

  func _startListening () {}

  func _stopListening () {}

  open func _trigger (_ data: Any!) {
    _handler(data)
    if self.once {
      self.isListening = false
    }
  }
    
    open func onInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(clean), name: self.cleanListenerNotificationName, object: nil)
    }

    public init (_ target: AnyObject!, _ once: Bool, _ handler: @escaping (Any!) -> Void) {

    _handler = handler

    if let targetID = target as? String {
      _targetID = targetID
    } else {
      _targetID = getHash(target)

      self.target = target
    }

    self.once = once
    self.isListening = true
        
    self.onInit()
  }

    @objc func clean() {
        self.isListening = false
        NotificationCenter.default.removeObserver(self)
    }

  deinit {
    self.clean()
  }
}

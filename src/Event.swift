
open class Event <T> {

  open var listenerCount: Int { return _listeners.count }

  public init () {}

  open func on (_ handler: @escaping (T) -> Void) -> EventListener<T> {
    return EventListener(self, nil, false, handler)
  }

  open func on (_ target: AnyObject, _ handler: @escaping (T) -> Void) -> EventListener<T> {
    return EventListener(self, target, false, handler)
  }

  @discardableResult
  open func once (handler: @escaping (T) -> Void) -> EventListener<T> {
    return EventListener(self, nil, true, handler)
  }

  @discardableResult
  open func once (target: AnyObject, _ handler: @escaping (T) -> Void) -> EventListener<T> {
    return EventListener(self, target, true, handler)
  }

  open func emit (_ data: T) {
    _emit(data, on: "0")
  }

  open func emit (_ data: T, on target: AnyObject) {
    _emit(data, on: (target as? String) ?? getHash(target))
  }

  open func emit (_ data: T, on targets: [AnyObject]) {
    for target in targets {
      _emit(data, on: (target as? String) ?? getHash(target))
    }
  }

  // 1 - getHash(Listener.target)
  // 2 - getHash(Listener)
  // 3 - DynamicPointer<Listener>
  open var _listeners = [String:[String:DynamicPointer<Listener>]]()

  open func _emit (_ data: Any!, on targetID: String) {
    if let listeners = _listeners[targetID] {
      for (_, listener) in listeners {
        listener.object._trigger(data)
      }
    }
  }

  deinit {
    self.clean()
  }
    
  open func clean() {
        for (_, listeners) in _listeners {
            for (_, listener) in listeners {
                if let isObject = listener.object {
                    isObject._listening = false
                }
            }
        }
    }
}

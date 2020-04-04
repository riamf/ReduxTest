import Foundation

typealias DispatchFunction = (Action) -> Void
typealias Middleware<State> = (@escaping DispatchFunction, @escaping () -> State?)
                                -> (@escaping DispatchFunction) -> DispatchFunction
typealias Reducer<ReducerStateType> = (_ action: Action, _ state: ReducerStateType?) -> ReducerStateType

class ReduxStore {
    var state: State? {
        didSet {
            guard let state = state else { return }
            subscribers.allObjects.forEach {
                ($0 as? StateChangeObserver)?.notify(state, oldState: oldValue)
            }
        }
    }
    var subscribers = NSPointerArray(options: .weakMemory)
    var middleware: [Middleware<State>]
    var reducer: Reducer<State>
    var dispatchFunction: DispatchFunction!

    init(state: State?,
         reducer: @escaping Reducer<State>,
         middleware: [Middleware<State>] = []) {
        self.reducer = reducer
        self.middleware = middleware
        self.dispatchFunction = middleware.reversed().reduce({ [unowned self] action in self._defaultDispatch(action: action) }, { dispatchFunction, middleware in
            let dispatch: (Action) -> Void = { [weak self] in self?.dispatch($0) }
            let getState = { [weak self] in self?.state }
            return middleware(dispatch, getState)(dispatchFunction)
        })

        if let state = state {
            self.state = state
        }
    }

    func dispatch(_ action: Action) {
        dispatchFunction(action)
    }

    func _defaultDispatch(action: Action) {
        let newState = reducer(action, state)
        state = newState
    }

    func add(subscriber: StateChangeObserver) {
        subscribers
            .addPointer(Unmanaged.passUnretained(subscriber as AnyObject).toOpaque())
    }
}

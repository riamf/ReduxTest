import Foundation

public protocol Action { }

public typealias DispatchFunction = (Action) -> Void
public typealias Middleware<State> = (@escaping DispatchFunction, @escaping () -> State?)
    -> (@escaping DispatchFunction) -> DispatchFunction
public typealias Reducer<ReducerStateType> = (_ action: Action, _ state: ReducerStateType, _ hasChanged: inout Bool) -> ReducerStateType

public final class ReduxStore<S: State> {
    var state: ObserverAdapter<S>
    var middleware: [Middleware<S>]
    var reducer: Reducer<S>
    var dispatchFunction: DispatchFunction!
    public var value: S {
        return state.value
    }
    
    public init(state: S,
                reducer: @escaping Reducer<S> = S.reduce(_:_:_:),
         middleware: [Middleware<S>] = []) {
        self.reducer = reducer
        self.middleware = middleware
        self.state = ObserverAdapter(state)
        self.dispatchFunction = middleware.reversed().reduce(
            { [unowned self] action in self._defaultDispatch(action: action) },
            { dispatchFunction, middleware in
                let dispatch: (Action) -> Void = { [weak self] in self?.dispatch($0) }
                let getState = { [weak self] in self?.state.value }
                return middleware(dispatch, getState)(dispatchFunction)
        })
    }
    
    public func onChange(_ observation: @escaping (S, S?) -> Void) {
        state.onChange(observation)
    }
    
    public func dispatch(_ action: Action) {
        dispatchFunction(action)
    }
    
    func _defaultDispatch(action: Action) {
        var hasChanged = false
        let newState = reducer(action, state.value, &hasChanged)
        if hasChanged {
            state.value = newState
        }
    }
}


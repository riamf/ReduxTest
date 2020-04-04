import Foundation

public protocol Action { }
public struct LoadState<S>: Action {
    let state: S
    public init(_ state: S) {
        self.state = state
    }
}

public typealias DispatchFunction = (Action) -> Void
public typealias Middleware<State> = (@escaping DispatchFunction, @escaping () -> State?)
    -> (@escaping DispatchFunction) -> DispatchFunction
public typealias Reducer<ReducerStateType> = (_ action: Action, _ state: ReducerStateType, _ hasChanged: inout Bool) -> ReducerStateType

public final class ReduxStore<S: State & Reducable> {
    var state: ObserverAdapter<S>
    var middleware: [Middleware<S>]
    var reducer: Reducer<S>
    var dispatchFunction: DispatchFunction!
    public var stateKeeper = StateKeeper<S>()
    public var value: S {
        return state.value
    }

    public init(state: S,
                reducer: @escaping Reducer<S> = S.reduce(_:_:_:),
         middleware: [Middleware<S>] = []) {
        self.reducer = reducer
        self.middleware = middleware
        self.state = ObserverAdapter(state)
        stateKeeper.add(state)
        self.dispatchFunction = middleware.reversed().reduce({ [unowned self] action in self._defaultDispatch(action: action) }, { dispatchFunction, middleware in
                let dispatch: (Action) -> Void = { [weak self] in self?.dispatch($0) }
                let getState = { [weak self] in self?.state.value }
                return middleware(dispatch, getState)(dispatchFunction)
        })
    }

    public func onChange(_ observation: @escaping (S, S?) -> Void) {
        state.onChange(observation)
    }

    public func dispatch(_ action: Action) {
        stateKeeper.add(action)
        if let loadAction = action as? LoadState<S> {
            state.value = loadAction.state
        } else {
            dispatchFunction(action)
        }
    }

    func _defaultDispatch(action: Action) {
        var hasChanged = false
        let newState = reducer(action, state.value, &hasChanged)
        if hasChanged {
            stateKeeper.add(newState)
            state.value = newState
        }
    }
}

public struct HistoryItem<T> {
    public let value: T
    public let timestamp: TimeInterval
    
    init(_ value: T) {
        self.value = value
        self.timestamp = Date().timeIntervalSince1970
    }
}

public final class StateKeeper<S> {
    public var history: [HistoryItem<S>] = []
    public var actions: [HistoryItem<Action>] = []
    
    init() {}
    
    func add(_ action: Action) {
        actions.append(HistoryItem(action))
    }
    
    func add(_ state: S) {
        history.append(HistoryItem(state))
    }
}

import Foundation

struct M {
    static let AppState: Middleware<State> = { dispatch, getState in
        return { next in
            return  { action in
                next(action)
            }
        }
    }
}

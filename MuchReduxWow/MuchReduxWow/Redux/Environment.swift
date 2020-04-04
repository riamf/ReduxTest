import Foundation

class AppEnvironment {
    let store = ReduxStore(state: nil,
                           reducer: AppState.appStateReducer,
                           middleware: [M.AppState, M.SearchResults, M.Filters])
    let useCaseFactory = UseCaseFactory()
    var coordinator: Coordinator!
}

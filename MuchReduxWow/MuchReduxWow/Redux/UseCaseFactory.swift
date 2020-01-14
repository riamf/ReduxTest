import Foundation

struct UseCaseFactory {
    func takeOff() {
        environment.store.dispatch(TakeOffAction())
    }
    
    func search(filter: FiltersState = FiltersState.default) {
        environment.store.dispatch(SearchAction(filter: filter))
    }
    
    func pop(userInfo: [String: Any] = [:]) {
        environment.store.dispatch(PopAction(userInfo: userInfo))
    }
    
    func present(userInfo: [String: Any] = [:]) {
        environment.store.dispatch(PresentAction(userInfo: userInfo))
    }
    
    func hideFilters(userInfo: [String: Any] = [:]) {
        environment.store.dispatch(DismissAction(userInfo: userInfo))
    }
    
    func changeState(filterState: FiltersState) {
        environment.store.dispatch(ChangeFilter(filterState: filterState))
    }
}

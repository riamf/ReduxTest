import Foundation

struct UseCaseFactory {
    func takeOff() {
        environment.store.dispatch(TakeOffAction())
    }
    
    func search(filter: FiltersState = FiltersState.default) {
        environment.store.dispatch(SearchAction(filter: filter))
    }
}

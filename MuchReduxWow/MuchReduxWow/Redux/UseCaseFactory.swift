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
    
    func changeState(order: Order?, phrase: String? = nil) {
        environment.store.dispatch(ChangeFilter(order: order, phrase: phrase))
    }
    
    func fetchLanguages() {
        environment.store.dispatch(FetchLanguages())
    }
    
    func selectLanguage(_ language: Language) {
        environment.store.dispatch(SelectLanguage(language: language))
    }
}

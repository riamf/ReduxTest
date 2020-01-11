import Foundation

struct UseCaseFactory {
    func takeOff() {
        environment.store.dispatch(TakeOffAction())
    }
}

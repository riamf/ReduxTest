import Foundation

struct HomeNavigationState: SceneState {
    
    enum Route {
        case popSearch
    }
    
    var children: [SceneState] = []
    
    var presentingScene: SceneState?
    
    var coordinatorType: Coordinator.Type {
        return HomeNavigationCoordinator.self
    }
    
    init(state: SceneState?, action: Action) {
        if let _ = action as? TakeOffAction {
            children = [
                 HomeState(state: state, action: action)
            ]
        }
    }
    
    mutating func mutate(with action: Action) {
        if let action = action as? NewDataAction {
            children.append(SearchResultsState(state: nil, action: action))
        } else if let action = action as? PopAction,
                  let route = action.userInfo["route"] as? Route {
            go(to: route)
        }
    }
    
    mutating private func go(to route: Route) {
        switch route {
        case .popSearch:
            if children.last is SearchResultsState {
                children.removeLast()
            }
        }
    }
}

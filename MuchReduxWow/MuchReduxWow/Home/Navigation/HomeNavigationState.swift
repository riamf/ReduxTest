import Foundation

struct HomeNavigationState: SceneState {
    
    enum Route {
        case popSearch
        case presentFilters
        case dismissFilters
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
        presentingScene?.mutate(with: action)
        if let action = action as? NewDataAction {
            children.append(SearchResultsState(state: nil, action: action))
        } else if let action = action as? PopAction,
                  let route = action.userInfo["route"] as? Route {
            go(to: route, action: action)
        } else if let action = action as? PresentAction,
            let route = action.userInfo["route"] as? Route {
            go(to: route, action: action)
        } else if let action = action as? DismissAction,
                   let route = action.userInfo["route"] as? Route {
                   go(to: route, action: action)
        }
    }
    
    mutating private func go(to route: Route, action: Action) {
        switch route {
        case .popSearch:
            if children.last is SearchResultsState {
                children.removeLast()
            }
        case .presentFilters:
            let preselected = (children.last as? SearchResultsState)?.filter ?? FiltersState.default
            presentingScene = FiltersSceneState(state: nil,
                                                action: action,
                                                preselected: preselected)
        case .dismissFilters:
            presentingScene = nil
        }
    }
}

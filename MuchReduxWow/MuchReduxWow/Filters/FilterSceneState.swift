import Foundation

struct FiltersSceneState: SceneState {

    var children: [SceneState] = []
    var presentingScene: SceneState?
    var coordinatorType: Coordinator.Type {
        return FiltersCoordinator.self
    }
    var preselected: FiltersState = FiltersState.default
    var languages: [Language] = []

    init(state: SceneState?, action: Action) { }
    init(state: SceneState?, action: Action, preselected: FiltersState) {
        self.preselected = preselected
    }

    mutating func mutate(with action: Action) {
        if let action = action as? ChangeFilter {
            preselected = FiltersState(order: action.order ?? preselected.order,
                                       phrase: action.phrase ?? preselected.phrase,
                                       languages: preselected.languages)
        } else if let action = action as? NewLanguages {
            languages = action.languages
        } else if let action = action as? SelectLanguage {
            var selectedLanguages = preselected.languages
            if let idx = selectedLanguages.firstIndex(of: action.language) {
                selectedLanguages.remove(at: idx)
            } else {
                selectedLanguages.append(action.language)
            }
            preselected = FiltersState(order: preselected.order,
                                       phrase: preselected.phrase,
                                       languages: selectedLanguages)
        }
    }
}

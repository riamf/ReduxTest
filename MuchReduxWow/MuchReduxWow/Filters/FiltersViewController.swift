import UIKit

class FiltersViewController: UIViewController, Coordinated {
    var coordinator: Coordinator?
    var viewModel: FiltersViewModel!

    init(selected: FiltersState) {
        super.init(nibName: nil, bundle: nil)
        viewModel = FiltersViewModel(selected: selected, languages: [])
        environment.store.add(subscriber: self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func loadView() {
        
        view = FiltersView(frame: .zero) { filtersView in
            filtersView.button.addTarget(self,
                                         action: #selector(applyFilters),
                                         for: .touchUpInside)
            filtersView.orderSwitch.addTarget(self,
                                              action: #selector(switchButton(button:)),
                                              for: .touchUpInside)
            viewModel.reloadHandler = { [weak filtersView] in
                filtersView?.table.reloadData()
            }
            filtersView.orderSwitch.isOn = viewModel.order == .asc
            filtersView.table.delegate = self
            filtersView.table.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        environment.useCaseFactory.fetchLanguages()
    }
    
    @objc private func switchButton(button: UISwitch) {
        let order: Order = button.isOn ? .asc : .desc
        environment.useCaseFactory.changeState(order: order, phrase: nil)
    }
    
    @objc private func applyFilters() {
        environment.useCaseFactory.hideFilters(userInfo: ["route": HomeNavigationState.Route.dismissFilters])
        environment.useCaseFactory.search(filter: viewModel.generateFilterState())
    }
}

extension FiltersViewController: StateChangeObserver {
    func notify(_ state: State, oldState: State?) {
        guard let state = state.sceneState.of(of: FiltersSceneState.self) else { return }
        viewModel.phrase = state.preselected.phrase
        viewModel.order = state.preselected.order
        viewModel.languages = state.languages
        viewModel.selectedLanguages = state.preselected.languages
    }
}

class FiltersViewModel {
    struct LanguageViewModel {
        let language: Language
        let isSelected: Bool
        var name: String {
            return language.name
        }
    }
    var phrase: String
    var order: Order
    var selectedLanguages: [Language] = []
    var languages: [Language] {
        didSet {
            reloadHandler?()
        }
    }
    var reloadHandler: (() -> ())?
    
    init(selected: FiltersState, languages: [Language]) {
        self.phrase = selected.phrase
        self.order = selected.order
        self.languages = languages
    }
    
    func languageViewModel(for indexPath: IndexPath) -> LanguageViewModel {
        let language = languages[indexPath.row]
        return LanguageViewModel(language: language,
                                 isSelected: selectedLanguages.contains(language))
    }
    
    func generateFilterState() -> FiltersState {
        return FiltersState(order: order, phrase: phrase, languages: selectedLanguages)
    }
}

extension FiltersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        cell.textLabel?.text = viewModel.languageViewModel(for: indexPath).name
        cell.accessoryType = viewModel.languageViewModel(for: indexPath).isSelected
                                ? .checkmark
                                : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        environment.useCaseFactory.selectLanguage(viewModel.languageViewModel(for: indexPath).language)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

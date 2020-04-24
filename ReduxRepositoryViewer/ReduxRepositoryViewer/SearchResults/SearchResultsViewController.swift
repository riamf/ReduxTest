import UIKit
import GHClient
import SimpleRedux

class SearchResultsViewController: UIViewController, NavigationItemController {

    private(set) var environment: AppEnvironment!
    private var repositories: [Repository] {
        return myState?.repositories ?? []
    }
    private(set) var uniqueId: Int!
    private var myState: SearchResultsState? {
        return environment.store.value.repositories.item(for: uniqueId)
    }
    private var viewTable: ViewTable? {
        return viewIfLoaded as? ViewTable
    }
    private lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = true
        search.searchBar.placeholder = "Search"
        search.searchBar.delegate = self
        return search
    }()

    required init(_ environment: AppEnvironment, _ uniqueId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.environment = environment
        self.uniqueId = uniqueId
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = ViewTable()
        viewTable?.tableView.dataSource = self
        viewTable?.tableView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(back))
        navigationItem.searchController = searchController
        definesPresentationContext = true
        environment.store.onChange { [weak self] _, _ in
            self?.resolve()
        }

        if let phrase = myState?.phrase {
            environment.useCases.searchRepositories(page: 0,
                                                    isNextPage: false,
                                                    uniqueId: uniqueId,
                                                    phrase: phrase)
        }
    }

    private func resolve() {
        guard let state = myState else { return }
        title = state.title
        searchController.searchBar.text = state.phrase
        viewTable?.tableView.reloadData()
    }

    @objc private func back() {
        environment.useCases.popResults()
    }
}

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        cell.textLabel?.text = repositories[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        environment.useCases.showDetails(for: repositories[indexPath.row])
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let state = myState, indexPath.row == repositories.count - 15 else { return }
        environment.useCases.searchRepositories(page: state.page + 1,
                                                isNextPage: true,
                                                uniqueId: state.uniqueId,
                                                phrase: state.phrase)
    }
}

extension SearchResultsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let phrase = searchBar.text, !phrase.isEmpty else { return }
        environment.useCases.showNewSearch(for: phrase)
        searchController.isActive = false
    }
}

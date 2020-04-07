import UIKit
import GHClient

class RepositoriesViewController: UIViewController, NavigationItemController {

    private(set) var environment: AppEnvironment!
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

    private var repositories: [Repository] {
        return myState?.repositories ?? []
    }

    private var myState: RepositoriesListState? {
        return environment.store.value.repositories.item(for: uniqueId)
    }

    private(set) var uniqueId: Int!

    required init(_ environment: AppEnvironment, _ uniqueId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.environment = environment
        self.uniqueId = uniqueId
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = ViewTable()
        viewTable?.tableView.dataSource = self
        viewTable?.tableView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        definesPresentationContext = true

        environment.store.onChange { [weak self] new, _ in
            guard let uniqueId = self?.uniqueId,
                let new: RepositoriesListState = new.repositories.item(for: uniqueId) else { return }
            self?.resolve(new)
        }
        environment.store.dispatch(DownloadRepositories(since: 0,
                                                        isNextPage: false,
                                                        uniqueId: uniqueId))
    }

    private func resolve(_ state: RepositoriesListState) {
        title = state.title
        searchController.searchBar.text = state.phrase
        viewTable?.tableView.reloadData()
    }
}

extension RepositoriesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CELL") else {
            fatalError("don't worry about it")
        }
        cell.textLabel?.text = repositories[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let state = myState, indexPath.row == repositories.count - 10 else { return }
        environment.store.dispatch(DownloadRepositories(since: state.since,
                                                        isNextPage: true,
                                                        uniqueId: uniqueId))
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        environment.store.dispatch(ShowDetails(repository: repositories[indexPath.row]))
    }
}

extension RepositoriesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let phrase = searchBar.text, !phrase.isEmpty else { return }
        environment.store.dispatch(NewSearch(phrase: phrase))
        searchController.isActive = false
    }
}

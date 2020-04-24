import UIKit
import GHClient

class RepositoriesViewController: UIViewController, NavigationItemController {

    var environment: AppEnvironment!
    var tableView: UITableView!
    lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = true
        search.searchBar.placeholder = "Search"
        search.searchBar.delegate = self
        return search
    }()

    var repositories: [Repository] {
        return myState?.repositories ?? []
    }

    var myState: RepositoriesListState? {
        return environment.store.value.repositories.list(for: uniqueId)
    }

    private var uniqueId: Int!

    required init(_ environment: AppEnvironment, _ uniqueId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.environment = environment
        self.uniqueId = uniqueId
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView(frame: .zero)
        tableView = UITableView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CELL")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        definesPresentationContext = true

        if environment.store.value.repositories.navigationStack.count > 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back",
                                                               style: .plain,
                                                               target: self,
                                                               action: #selector(back))
        }
        self.environment.store.onChange { [weak self] new, _ in
            guard let uniqueId = self?.uniqueId,
                let new = new.repositories.list(for: uniqueId) else { return }
            self?.resolve(new)
        }
        if let uniqueId = myState?.uniqueId, myState?.phrase == nil {
            environment.store.dispatch(DownloadRepositories(since: 0, isNextPage: false,
                                                            uniqueId: uniqueId))
        }
    }

    @objc private func back() {
        environment.store.dispatch(PopResults())
    }

    private func resolve(_ state: RepositoriesListState) {
        title = state.title
        searchController.searchBar.text = state.phrase
        tableView.reloadData()
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
        if indexPath.row == repositories.count - 10 {
             if let phras = myState?.phrase,
                let page = myState?.since,
                let uniqueId = myState?.uniqueId {
                 environment.store.dispatch(NewSearch(phrase: phras,
                                                      page: page + 1,
                                                      isNextPage: true,
                                                      uniqueId: uniqueId))
             } else if let since = myState?.since,
                let uniqueId = myState?.uniqueId {
                environment.store.dispatch(DownloadRepositories(since: since,
                                                                isNextPage: true,
                                                                uniqueId: uniqueId))
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        environment.store.dispatch(ShowDetails(repository: repositories[indexPath.row]))
    }
}

extension RepositoriesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let phrase = searchBar.text, !phrase.isEmpty, let myState = myState else { return }
        environment.store.dispatch(NewSearch(phrase: phrase,
                                             page: 0,
                                             isNextPage: false,
                                             uniqueId: myState.uniqueId))
        searchController.isActive = false
    }
}

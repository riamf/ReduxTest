import UIKit
import GHClient

class RepositoriesNavigtion: UINavigationController {

    var environment: AppEnvironment!

    init(_ environment: AppEnvironment) {
        super.init(nibName: nil, bundle: nil)
        self.environment = environment
        self.viewControllers = [
            RepositoriesViewController(environment)
        ]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        environment.store.dispatch(DownloadRepositories(since: 0, isNextPage: false))
    }
}

class RepositoriesViewController: UIViewController {

    var environment: AppEnvironment!
    var tableView: UITableView!

    var repositories: [Repository] {
        environment.store.value.repositories.repositoriesList.repositories
    }

    init(_ environment: AppEnvironment) {
        super.init(nibName: nil, bundle: nil)
        self.environment = environment
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

        self.environment.store.onChange { [weak self] new, _ in
            self?.resolve(new.repositories.repositoriesList)
        }
    }

    private func resolve(_ state: RepositoriesListState) {
        title = state.title
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
            let since = environment.store.value.repositories.repositoriesList.since
            environment.store.dispatch(DownloadRepositories(since: since, isNextPage: true))
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        environment.store.dispatch(ShowDetails(repository: repositories[indexPath.row]))
    }
}

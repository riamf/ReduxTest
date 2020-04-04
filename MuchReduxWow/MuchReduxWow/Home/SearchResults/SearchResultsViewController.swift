import UIKit

class SearchResultsViewController: UIViewController, Coordinated {
    let cellId = "cell"
    weak var coordinator: Coordinator?
    private var items: Items?
    private var filter: FiltersState?
    private var data: [Repository] {
        return items?.items ?? []
    }
    private lazy var table: UITableView = {
        let table = UITableView(frame: .zero)
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        table.tableFooterView = UIView(frame: .zero)
        table.allowsSelection = false
        return table
    }()

    lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = true
        search.searchBar.placeholder = "Search"
        search.searchBar.delegate = self
        return search
    }()

    lazy var filtersButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Filters", for: .normal)
        button.addTarget(self, action: #selector(showFilters), for: .touchUpInside)
        return button
    }()

    init(items: Items?, filter: FiltersState?) {
        super.init(nibName: nil, bundle: nil)
        self.items = items
        self.filter = filter
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func loadView() {
        view = UIView(frame: .zero)
        filtersButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filtersButton)
        NSLayoutConstraint.activate([
            filtersButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filtersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filtersButton.topAnchor.constraint(equalTo: view.topAnchor),
            filtersButton.heightAnchor.constraint(equalToConstant: 40.0)
        ])

        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)
        NSLayoutConstraint.activate([
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.topAnchor.constraint(equalTo: filtersButton.bottomAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(back))

        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.text = filter?.phrase
    }

    @objc private func back() {
        environment.useCaseFactory.pop(userInfo: ["route": HomeNavigationState.Route.popSearch])
    }

    @objc private func showFilters() {
        environment.useCaseFactory.present(userInfo: ["route": HomeNavigationState.Route.presentFilters])
    }
}

extension SearchResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = data[indexPath.row].name + " : " + (data[indexPath.row].language ?? "")
        return cell
    }
}

extension SearchResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension SearchResultsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let phrase = filter?.phrase ?? ""
        environment.useCaseFactory.search(filter: FiltersState(order: filter?.order ?? .asc,
                                                               phrase: searchBar.text ?? phrase,
                                                               languages: filter?.languages ?? []))
        searchController.isActive = false
        searchBar.text = filter?.phrase
    }
}

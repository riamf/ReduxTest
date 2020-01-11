import UIKit

class HomeViewController: UIViewController, Coordinated {
    weak var coordinator: Coordinator?
    
    lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = true
        search.searchBar.placeholder = "Search"
        search.searchBar.delegate = self
        return search
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "1"
        view.backgroundColor = .red
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        environment.useCaseFactory.search(filter: FiltersState(order: .asc, phrase: searchBar.text ?? ""))
    }
}

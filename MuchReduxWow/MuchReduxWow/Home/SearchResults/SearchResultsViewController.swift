import UIKit

class SearchResultsViewController: UIViewController, Coordinated {
    weak var coordinator: Coordinator?
    var items: Items?
    
    init(items: Items?) {
        super.init(nibName: nil, bundle: nil)
        self.items = items
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
    }
}

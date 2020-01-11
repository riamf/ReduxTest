import UIKit

class HomeNavigationViewController: UINavigationController, Coordinated {
    weak var coordinator: Coordinator?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}

import UIKit

class HomeViewController: UIViewController, Coordinated {
    weak var coordinator: Coordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "1"
        view.backgroundColor = .red
    }
}

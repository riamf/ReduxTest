import UIKit

class ProfileViewController: UIViewController, Coordinated {
    weak var coordinator: Coordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "2"
        view.backgroundColor = .blue
    }
}

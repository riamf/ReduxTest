import UIKit

class ProfileViewController: UIViewController {
    var environment: AppEnvironment!

    init(_ environment: AppEnvironment) {
        super.init(nibName: nil, bundle: nil)
        self.environment = environment
        loadViewIfNeeded()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        environment.store.onChange { [weak self] new, _ in
            self?.title = new.profile.title
            self?.view.backgroundColor = .yellow
        }
    }
}

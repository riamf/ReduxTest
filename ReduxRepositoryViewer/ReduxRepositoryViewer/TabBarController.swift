import UIKit

class TabBarController: UITabBarController {

    var environment: AppEnvironment!
    var repositoriesNavigation: RepositoriesNavigtion!

    init(_ environment: AppEnvironment) {
        super.init(nibName: nil, bundle: nil)
        self.environment = environment
        repositoriesNavigation = RepositoriesNavigtion(environment)
        viewControllers = [
            repositoriesNavigation,
            ProfileViewController(environment)
        ]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

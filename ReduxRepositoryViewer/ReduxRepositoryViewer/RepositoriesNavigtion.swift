import UIKit

class RepositoriesNavigtion: UINavigationController {

    var environment: AppEnvironment!

    init(_ environment: AppEnvironment) {
        super.init(nibName: nil, bundle: nil)
        self.environment = environment
        self.viewControllers = environment.store.value.repositories.navigationStack.compactMap {
            $0.navigationItemControllerType.init(environment, $0.uniqueId) as? UIViewController
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

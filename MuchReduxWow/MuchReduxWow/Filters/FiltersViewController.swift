import UIKit

class FiltersViewController: UIViewController, Coordinated {
    var coordinator: Coordinator?
    
    var preselected: FiltersState?
    
    lazy var button: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.backgroundColor = .white
        btn.setTitleColor(.black, for: .normal)
        btn.setTitle("Apply", for: .normal)
        btn.addTarget(self, action: #selector(applyFilters), for: .touchUpInside)
        return btn
    }()
    
    override func loadView() {
        view = UIView(frame: .zero)
        view.backgroundColor = .cyan
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            button.heightAnchor.constraint(equalToConstant: 80.0)
        ])
    }
    
    @objc private func applyFilters() {
        environment.useCaseFactory.hideFilters(userInfo: ["route": HomeNavigationState.Route.dismissFilters])
        environment.useCaseFactory.search(filter: FiltersState(order: .desc, phrase: preselected?.phrase ?? ""))
    }
}

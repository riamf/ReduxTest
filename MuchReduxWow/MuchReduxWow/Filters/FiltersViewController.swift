import UIKit

class FiltersViewController: UIViewController, Coordinated {
    var coordinator: Coordinator?
    var selected: FiltersState!
    
    lazy var button: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.backgroundColor = .white
        btn.setTitleColor(.black, for: .normal)
        btn.setTitle("Apply", for: .normal)
        btn.addTarget(self, action: #selector(applyFilters), for: .touchUpInside)
        return btn
    }()
    
    lazy var text: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "desc     asc"
        label.textColor = .black
        return label
    }()
    
    lazy var orderSwitch: UISwitch = {
        let orderSwitch = UISwitch(frame: .zero)
        orderSwitch.isOn = self.selected.order == .asc
        orderSwitch.addTarget(self, action: #selector(switchButton(button:)), for: .touchUpInside)
        return orderSwitch
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        environment.store.add(subscriber: self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func loadView() {
        view = UIView(frame: .zero)
        view.backgroundColor = .cyan
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        orderSwitch.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(orderSwitch)
        text.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(text)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            button.heightAnchor.constraint(equalToConstant: 80.0),
            text.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            text.topAnchor.constraint(equalTo: view.topAnchor, constant: 40.0),
            orderSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            orderSwitch.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 10.0)
        ])
    }
    
    @objc private func switchButton(button: UISwitch) {
        let order: Order = button.isOn ? .asc : .desc
        environment.useCaseFactory.changeState(filterState: FiltersState(order: order, phrase: selected.phrase))
    }
    
    @objc private func applyFilters() {
        environment.useCaseFactory.hideFilters(userInfo: ["route": HomeNavigationState.Route.dismissFilters])
        environment.useCaseFactory.search(filter: selected)
    }
}

extension FiltersViewController: StateChangeObserver {
    func notify(_ state: State, oldState: State?) {
        guard let state = state.sceneState.of(of: FiltersSceneState.self) else { return }
        selected = state.preselected
    }
}

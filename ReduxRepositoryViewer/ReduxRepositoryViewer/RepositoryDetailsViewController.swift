import UIKit
import GHClient

class RepositoryDetailsViewController: UIViewController {
    var environment: AppEnvironment!
    
    private var detailsView: DetailsView? {
        return viewIfLoaded as? DetailsView
    }
    
    private var repository: Repository? {
        return environment.store.value.repositories.repositoryDetails?.repository
    }
    
    init(_ environment: AppEnvironment) {
        super.init(nibName: nil, bundle: nil)
        self.environment = environment
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = DetailsView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Back", style: .plain,
                                                                target: self,
                                                                action: #selector(back))
        environment.store.onChange { [weak detailsView, repository] new, _ in
            guard let repository = repository else { return }
            detailsView?.backgroundColor = .white
            detailsView?.id.text = "\(repository.id)"
            detailsView?.owner.text = repository.owner.login
            detailsView?.desc.text = repository.description
        }
    }
    
    @objc private func back() {
        environment.store.dispatch(PopDetails())
    }
}

class DetailsView: UIView {
    var id: UILabel
    var owner: UILabel
    var desc: UILabel
    
    
    init() {
        id = UILabel(frame: .zero)
        id.font = UIFont.systemFont(ofSize: 11)
        owner = UILabel(frame: .zero)
        owner.font = UIFont.systemFont(ofSize: 16)
        desc = UILabel(frame: .zero)
        desc.font = UIFont.italicSystemFont(ofSize: 16)
        desc.lineBreakMode = .byWordWrapping
        desc.numberOfLines = 0
        super.init(frame: .zero)
        
        addSubview(id)
        addSubview(owner)
        addSubview(desc)
        id.translatesAutoresizingMaskIntoConstraints = false
        owner.translatesAutoresizingMaskIntoConstraints = false
        desc.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            id.topAnchor.constraint(equalTo: topAnchor, constant: 106),
            id.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            id.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            id.bottomAnchor.constraint(equalTo: owner.topAnchor, constant: -16),
            owner.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            owner.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            owner.bottomAnchor.constraint(equalTo: desc.topAnchor, constant: -16),
            desc.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            desc.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            desc.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

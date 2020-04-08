import UIKit
import GHClient

class RepositoryDetailsViewController: UIViewController, NavigationItemController {
    var environment: AppEnvironment!

    private var detailsView: DetailsView? {
        return viewIfLoaded as? DetailsView
    }

    private var repository: Repository? {
        let myState: RepositoryDetailsState? = environment.store.value.repositories.item(for: uniqueId)
        return myState?.repository
    }
    private(set) var uniqueId: Int!

    required init(_ environment: AppEnvironment, _ uniqueId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.environment = environment
        self.uniqueId = uniqueId
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
        environment.store.onChange { [weak detailsView, repository] _, _ in
            guard let repository = repository else { return }
            detailsView?.backgroundColor = .white
            detailsView?.identifier.text = "\(repository.id)"
            detailsView?.owner.text = repository.owner.login
            detailsView?.desc.text = repository.description
        }
    }

    @objc private func back() {
        environment.useCases.popDetails()
    }
}

class DetailsView: UIView {
    var identifier: UILabel
    var owner: UILabel
    var desc: UILabel

    init() {
        identifier = UILabel(frame: .zero)
        identifier.font = UIFont.systemFont(ofSize: 11)
        owner = UILabel(frame: .zero)
        owner.font = UIFont.systemFont(ofSize: 16)
        desc = UILabel(frame: .zero)
        desc.font = UIFont.italicSystemFont(ofSize: 16)
        desc.lineBreakMode = .byWordWrapping
        desc.numberOfLines = 0
        super.init(frame: .zero)

        addSubview(identifier)
        addSubview(owner)
        addSubview(desc)
        identifier.translatesAutoresizingMaskIntoConstraints = false
        owner.translatesAutoresizingMaskIntoConstraints = false
        desc.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            identifier.topAnchor.constraint(equalTo: topAnchor, constant: 106),
            identifier.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            identifier.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            identifier.bottomAnchor.constraint(equalTo: owner.topAnchor, constant: -16),
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

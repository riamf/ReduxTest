import UIKit
import SimpleRedux

class HistoryState: State {
    let title = "History"
}

class HistoryViewController: UIViewController {
    var environment: AppEnvironment!

    private lazy var dateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.locale = Locale.current
        result.timeZone = TimeZone.current
        result.dateFormat = "HH:mm:ss"
        return result
    }()

    var tableView: UITableView!
    var history: [HistoryItem<MainState>] {
        environment.store.stateKeeper.history
    }

    init(_ environment: AppEnvironment) {
        super.init(nibName: nil, bundle: nil)
        self.environment = environment
        loadViewIfNeeded()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView(frame: .zero)
        tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CELL")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        environment.store.onChange { [weak self] new, _ in
            self?.title = new.history.title
            self?.view.backgroundColor = .yellow
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CELL") else {
            fatalError("don't worry everything is fixable")
        }
        let date = Date(timeIntervalSince1970: history[indexPath.row].timestamp)
        cell.textLabel?.text = dateFormatter.string(from: date) + " " + "\(history[indexPath.row].value)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let alert = UIAlertController(title: "Alert",
                                      message: "Should I load this state?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Load", style: .default, handler: { [weak self] _ in
            guard let environment = self?.environment, let history = self?.history else { return }
            environment.load(history[indexPath.row].value)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

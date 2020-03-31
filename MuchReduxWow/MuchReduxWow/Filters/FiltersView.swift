import UIKit

class FiltersView: UIView {
    
    private(set) lazy var button: UIButton = {
        let btn = UIButton(frame: .zero)
        btn.backgroundColor = .white
        btn.setTitleColor(.black, for: .normal)
        btn.setTitle("Apply", for: .normal)
        return btn
    }()
    
    private(set) lazy var text: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "desc     asc"
        label.textColor = .black
        return label
    }()
    
    private(set) lazy var orderSwitch: UISwitch = {
        let orderSwitch = UISwitch(frame: .zero)
        return orderSwitch
    }()
    
    private(set) lazy var table: UITableView = {
        let table = UITableView(frame: .zero)
        table.tableFooterView = UIView(frame: .zero)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "CELL")
        table.isMultipleTouchEnabled = true
        return table
    }()
    
    init(frame: CGRect, _ actionConfiguration: (FiltersView) -> Void) {
        super.init(frame: frame)
        setup()
        actionConfiguration(self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .cyan
        
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        orderSwitch.translatesAutoresizingMaskIntoConstraints = false
        addSubview(orderSwitch)
        text.translatesAutoresizingMaskIntoConstraints = false
        addSubview(text)
        table.translatesAutoresizingMaskIntoConstraints = false
        addSubview(table)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.heightAnchor.constraint(equalToConstant: 80.0),
            text.centerXAnchor.constraint(equalTo: centerXAnchor),
            text.topAnchor.constraint(equalTo: topAnchor, constant: 40.0),
            orderSwitch.centerXAnchor.constraint(equalTo: centerXAnchor),
            orderSwitch.topAnchor.constraint(equalTo: text.bottomAnchor, constant: 10.0),
            table.leadingAnchor.constraint(equalTo: leadingAnchor),
            table.trailingAnchor.constraint(equalTo: trailingAnchor),
            table.topAnchor.constraint(equalTo: orderSwitch.bottomAnchor, constant: 10.0),
            table.bottomAnchor.constraint(equalTo: button.topAnchor)
        ])
    }
}

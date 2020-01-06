//
//  ErrorViewController.swift
//  ReduxTest
//
//  Created by Pawel Kowalczuk on 06/01/2020.
//  Copyright © 2020 alpha. All rights reserved.
//

import UIKit

class ErrorViewController: UIViewController {
    override func loadView() {
        view = UIView(frame: .zero)
        let closeButton = UIButton(frame: .zero)
        closeButton.setTitle("CLOSE", for: .normal)
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor),
            closeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        closeButton.addTarget(self, action: #selector(closeError), for: .touchUpInside)
    }
    
    @objc private func closeError() {
        environment.store.dispatch(HideError())
    }
}

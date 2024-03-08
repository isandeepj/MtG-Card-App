//
//  SegmentCell.swift
//  CodingInterviewSampleProject2022
//
//  Created by Sandeep on 07/03/24.
//

import Foundation
import UIKit

class SegmentCell: UICollectionViewCell {
    // MARK: - Properties
    lazy var indictorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 0.5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
     lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layout()
    }

    // MARK: - Layout

    func layout() {
        addSubview(lineView)
        addSubview(indictorView)
        addSubview(nameLabel)
        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            lineView.widthAnchor.constraint(equalToConstant: 1),
            lineView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),

            indictorView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            indictorView.leftAnchor.constraint(equalTo: leftAnchor, constant: 2),
            indictorView.rightAnchor.constraint(equalTo: rightAnchor, constant: -2),
            indictorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),

            nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    // MARK: - Public Methods

    // Set the cell's content and update its appearance based on selection state
    func set(item: String, selected: Bool, row: Int) {
        nameLabel.text = item
        lineView.isHidden = selected || row == 0
        indictorView.isHidden = !selected
    }

}

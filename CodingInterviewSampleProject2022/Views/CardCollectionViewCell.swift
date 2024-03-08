//
//  CardCollectionViewCell.swift
//  CodingInterviewSampleProject2022
//
//  Created by Sandeep on 07/03/24.
//

import Foundation
import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    lazy var cardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
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
        contentView.addSubview(cardImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 24),

            cardImageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            cardImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)

        ])
    }

    // MARK: - Public Method

    // Set the cell's content based on the provided Card object
    func set(card: Card) {
        nameLabel.text = card.nameJapanese
        activityIndicator.startAnimating()
        cardImageView.setImage(withURL: card.imageURL) {[weak self]  _,_ in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
        }
    }
}

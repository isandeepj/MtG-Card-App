//
//  CardCollectionViewController.swift
//  CodingInterviewSampleProject2022
//
//  Created by Sandeep on 07/03/24.
//

import Foundation
import UIKit

class CardCollectionViewController: UIViewController {
    // MARK: - Properties

    lazy var segmentedControl: SegmentedControl = {
        let segmentedControl = SegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        return segmentedControl
    }()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing * 2
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        return collectionView
    }()
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // Constants for spacing and cell size
    let spacing: CGFloat = 8
    lazy var cellSize: CGSize = {
        let numberOfColumns: CGFloat = 2
        let totalSpacing = spacing * (numberOfColumns - 1) + spacing * 2
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = (screenWidth - totalSpacing) / numberOfColumns
        let cellHeight = cellWidth * (680.0 / 480.0) + 25 // Maintain the aspect ratio
        return CGSize(width: cellWidth.rounded(.down), height: cellHeight.rounded(.down))
    }()

    var cards: [Card] = []
    var filteredCards: [Card] = []
    var uniqueCardTypes: [CardType] = [.all]

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchCards()
    }

}
// MARK: - UI Setup
extension CardCollectionViewController {
    func setupUI() {
        view.addSubview(segmentedControl)
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Data Fetching
    func fetchCards() {
        // Start the activity indicator animation
        activityIndicator.startAnimating()

        // Call the async function within an async block
        Task {
            do {
                self.cards = try await CardAdapter.getCards()
                // Get unique CardType values
                let allCardTypes = Set(self.cards.flatMap { $0.types })
                self.uniqueCardTypes = [.all] + Array(allCardTypes.sorted())

                // Update segmented control items
                self.activityIndicator.stopAnimating()
                self.segmentedControl.set(items: self.uniqueCardTypes.compactMap({$0.name}))
                self.segmentedControl.selectedIndex = 0
                segmentedControlValueChanged()

            } catch let error as CardAdapterError {
                self.activityIndicator.stopAnimating()
                // Handle API and data parsing errors

                switch error {
                case .apiError(let apiError):
                    Logger.shared.error("API Error: \(apiError)")
                case .dataParsingError:
                    Logger.shared.error("Data Parsing Error")
                }
            } catch {
                self.activityIndicator.stopAnimating()
                Logger.shared.error("Unexpected Error")
            }
        }
    }

    // MARK: - User Interaction
    @objc func segmentedControlValueChanged() {
        // Filter cards based on the selected segment and reload the collection view
        filterCardsByType(index: segmentedControl.selectedIndex)
        collectionView.reloadData()
    }

    func filterCardsByType(index: Int) {
        let selectedType = uniqueCardTypes[index]
        if selectedType == .all {
            filteredCards = cards
        } else {
            filteredCards = cards.filter { $0.types.contains(selectedType) }
        }
    }
}
// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
extension CardCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        guard let cell = cell as? CardCollectionViewCell else { return cell }
        cell.set(card: filteredCards[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}
// MARK: - UICollectionViewDataSourcePrefetching
extension CardCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for path in indexPaths {
            let card = filteredCards[path.row]
            guard let url = card.imageURL else { continue }
            DownloadManager.shared.download(withURL: url)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for path in indexPaths {
            let card = filteredCards[path.row]
            guard let url = card.imageURL else { continue }
            DownloadManager.shared.cancel(withURL: url)
        }
    }
}

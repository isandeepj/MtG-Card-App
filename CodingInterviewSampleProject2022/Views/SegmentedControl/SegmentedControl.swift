//
//  SegmentedControl.swift
//  CodingInterviewSampleProject2022
//
//  Created by Sandeep on 07/03/24.
//

import Foundation
import UIKit

class SegmentedControl: UIControl {
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.isScrollEnabled = true
        collectionView.bounces = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(SegmentCell.self, forCellWithReuseIdentifier: "cell")

        return collectionView
    }()

    private (set) var items: [String] = []

    // Currently selected segment item
    var selectedItem: String? {
        guard self.selectedIndex < self.items.count else { return nil}
        return self.items[self.selectedIndex]
    }

    // Index of the currently selected segment
    var selectedIndex: Int = 0 {
        didSet {
            if oldValue != selectedIndex {
                // Reload collection view data, notify value change, and trigger haptic feedback
                collectionView.reloadData()
                sendActions(for: .valueChanged)
                hapticsHandler()
            }
        }
    }

    // Flag to enable/disable haptic feedback
    var isHapticsEnabled: Bool = true

    // Font for segment labels
    let font: UIFont = UIFont.boldSystemFont(ofSize: 14)

    // Width constraint for the container view
    private var containerWidthConstraint: NSLayoutConstraint!

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
    private func layout() {
        // Configure the segmented control appearance
        self.backgroundColor = UIColor.clear
        self.addSubview(self.containerView)
        self.alpha = 0
        self.containerView.addSubview(self.collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self

        // Set up constraints
        containerWidthConstraint = containerView.widthAnchor.constraint(equalToConstant: 50)
        NSLayoutConstraint.activate([
            containerWidthConstraint,
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 32),

            collectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

        ])
    }

    // MARK: - Public Methods

    // Set items for the segmented control
    func set(items: [String]) {
        alpha = 1
        self.items = items
        collectionView.reloadData()
        selectedIndex = 0
        adjustContainerWidthToFitContent()
    }

    // MARK: - Private Methods

    // Handle haptic feedback
    private func hapticsHandler() {
        if isHapticsEnabled {
            UIImpactFeedbackGenerator(style: .light)
                .impactOccurred(intensity: 1.0)
        }
    }

    // Adjust container width to fit content
    private func adjustContainerWidthToFitContent() {
        var totalWidth: CGFloat = 0

        for item in items {
            let width = item.width(withConstrainedHeight: 32, font: font) + 24
            totalWidth += width
        }

        // Calculate the width of the superview minus any padding
        let availableWidth = self.frame.width - 32  // Adjust padding as needed

        // Adjust the totalWidth to ensure it fits within the availableWidth
        let adjustedWidth = min(totalWidth, availableWidth)

        // Update the containerView's width constraint
        containerWidthConstraint.constant = adjustedWidth
    }
}


// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension SegmentedControl: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        guard let cell = cell as? SegmentCell else { return cell }
        cell.nameLabel.font = self.font
        cell.set(item: items[indexPath.row], selected: indexPath.row == selectedIndex, row: indexPath.row)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row

        // Check if the selected item is not fully visible
        if !collectionView.indexPathsForVisibleItems.contains(indexPath) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = self.items[indexPath.item]
        let width = item.width(withConstrainedHeight: 32, font: font) + 24
        return CGSize(width: width, height: 32)
    }

}





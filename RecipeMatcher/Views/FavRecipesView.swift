//  FavRecipesView.swift
//  RecipeMatcher
//  Created by Eric Widjaja on 12/25/19.

import UIKit

class FavRecipesView: UIView {
    lazy var favoriteList: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 5, left: 1, bottom: 2, right: 1)
        let cellTable = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cellTable.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        return cellTable
    }()
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        favRecipesConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        favRecipesConstraints()
    }
    
    private func favRecipesConstraints() {
        addSubview(favoriteList)
        favoriteList.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            favoriteList.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            favoriteList.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            favoriteList.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            favoriteList.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)])
    }
}

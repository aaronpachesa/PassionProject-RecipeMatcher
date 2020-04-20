//  FavRecipesVC.swift
//  RecipeMatcher
//  Created by Eric Widjaja on 12/23/19.

import UIKit
import Kingfisher

class FavRecipesVC: UIViewController {
    
    //MARK: - Properties
    var faveRecipeView = FavRecipesView()
    var favedCell = FavdRecipesCell()
    var favoriteRecipe = [Favorite]() {
        didSet {
            DispatchQueue.main.async {
                self.faveRecipeView.favoriteList.reloadData()
                //checking if the recipes that user favorited are existed
                dump(self.favoriteRecipe)
            }
        }
    }
    //MARK: - Functions
    @objc private func signOut() {
        let alert = UIAlertController(title: "Sign Out from this App?", message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction.init(title: "Yes", style: .destructive, handler: .some({ (action) in
            DispatchQueue.main.async {
                FirebaseAuthService.manager.logoutUser()
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let sceneDelegate = windowScene.delegate as? SceneDelegate, let window = sceneDelegate.window
                    else {
                        return
                }
                UIView.transition(with: window, duration: 0.5, options: .curveEaseInOut
                    , animations: {
                        window.rootViewController = LogInScreenVC()
                }, completion: nil)
            }
        }))
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated:true)
    }
    
    private func getUserFavorites() {
        DispatchQueue.global(qos: .default).async {
            guard FirebaseAuthService.manager.currentUser != nil else
            { return }
            FirestoreService.manager.getAllFavorites(sortingCriteria: .fromNewestToOldest)
            {(result) in
                switch result {
                case .success(let favorites):
                    self.favoriteRecipe = favorites
                case .failure(let error):
                    print("error getting fave recipes \(error)")
                }
            }
        }
    }
    
    private func updateCellsWithFaveRecipes(_ indexPath: IndexPath,_ cell: FavdRecipesCell) {
        let favdRecipeToSet = favoriteRecipe[indexPath.row]
        cell.favdRecipeLabel.text = favdRecipeToSet.label
        cell.favdRecipeImage.kf.indicatorType = .activity
        cell.favdRecipeImage.kf.setImage(
            with: URL(string: favdRecipeToSet.imageUrl!),
            placeholder: UIImage(named: "RecipeImgHolder"),
            options: [ .scaleFactor(UIScreen.main.scale),
                       .transition(.flipFromRight(3))])
    }

    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(faveRecipeView)
        faveRecipeView.favoriteList.register(FavdRecipesCell.self, forCellWithReuseIdentifier: "FavdCell")
        
        faveRecipeView.favoriteList.delegate = self
        faveRecipeView.favoriteList.dataSource = self
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(signOut))
        view.backgroundColor = .systemTeal
        getUserFavorites()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserFavorites()
        
    }
}
//MARK: - Extensions -#########################################################

//extension FavRecipesVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return favoriteRecipe.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let favCell = faveRecipeView.favoriteList.dequeueReusableCell(withReuseIdentifier: "FavdCell", for: indexPath) as? FavdRecipesCell else {
//            return UICollectionViewCell()
//        }
//
//        let favdRecipeToSet = favoriteRecipe[indexPath.row]
//        favCell.favdRecipeLabel.text = favdRecipeToSet.label
//        favCell.favdRecipeImage.kf.indicatorType = .activity
//        favCell.favdRecipeImage.kf.setImage(
//            with: URL(string: favdRecipeToSet.imageUrl!),
//            placeholder: UIImage(named: "RecipeImgHolder"),
//            options: [ .scaleFactor(UIScreen.main.scale),
//                       .transition(.flipFromRight(3))])
//        return favCell;
//    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        //Passing selected FavRecipe into DetailVC
//        let showFavRecipeToDetailVC = FavRecipeDetailVC()
//        showFavRecipeToDetailVC.selectedRecipe = favoriteRecipe[indexPath.row]
//        //        print(favoriteRecipe[indexPath.row].url)
//        present(showFavRecipeToDetailVC, animated: true)
//    }
//}
extension FavRecipesVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteRecipe.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let favCell = faveRecipeView.favoriteList.dequeueReusableCell(withReuseIdentifier: "FavdCell", for: indexPath) as? FavdRecipesCell else {
            return UICollectionViewCell()
        }
        updateCellsWithFaveRecipes(indexPath, favCell)
        
        //        let favdRecipeToSet = favoriteRecipe[indexPath.row]
        //        favCell.favdRecipeLabel.text = favdRecipeToSet.label
        //        favCell.favdRecipeImage.kf.indicatorType = .activity
        //        favCell.favdRecipeImage.kf.setImage(
        //            with: URL(string: favdRecipeToSet.imageUrl!),
        //            placeholder: UIImage(named: "RecipeImgHolder"),
        //            options: [ .scaleFactor(UIScreen.main.scale),
        //                       .transition(.flipFromRight(3))])
        return favCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Passing selected FavRecipe into DetailVC
        let showFavRecipeToDetailVC = FavRecipeDetailVC()
        showFavRecipeToDetailVC.selectedRecipe = favoriteRecipe[indexPath.row]
        //        print(favoriteRecipe[indexPath.row].url)
        present(showFavRecipeToDetailVC, animated: true)
    }
}
extension FavRecipesVC : HeartButtonDelegate {
    func saveToPersistance(tag: Int) {
        
    }
    
    func deleteFromPersistance(tag: Int) {
        
    }
}


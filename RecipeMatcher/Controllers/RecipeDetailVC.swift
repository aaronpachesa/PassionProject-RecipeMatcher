//  RecipeDetailVC.swift
//  RecipeMatcher
//  Created by Eric Widjaja on 12/16/19.

import UIKit
import Kingfisher
import SafariServices
import FirebaseAuth
import FirebaseFirestore

enum HeartStatus {
    case filled
    case notFilled
}

class RecipeDetailVC: UIViewController {
    
    //MARK: - Properties
    var recipe: RecipeWrapper?
    var detailRecipeView = RecipeDetailView()
    var heartStatus: HeartStatus = .notFilled
    
    //MARK: - Functions
    private func updateRecipeHearts(url: String, recipeDetail: RecipeDetailView ) {
        FirestoreService.manager.getUserFavorites(userID: FirebaseAuthService.manager.currentUser?.uid ?? "") { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let favedRecipes):
                if favedRecipes.contains(where: {(recipe) -> Bool in recipe.url == url
                }) {
                    print("from detVC \(recipeDetail.recipe.url)")
                    self.makeHeartFill()
                } else {
                    self.makeHeartEmpty()
                }
            }
        }
    }
    
    func setDetailRecipeView() {
        view.addSubview(detailRecipeView)
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        //https://cocoapods.org/pods/Kingfisher
        let favoritedRecipe = detailRecipeView.recipe
        updateRecipeHearts(url: favoritedRecipe?.url ?? "", recipeDetail: detailRecipeView)
        detailRecipeView.recipeImage.kf.indicatorType = .activity
        detailRecipeView.recipeImage.kf.setImage(
            with: URL(string: recipe?.image ?? ""),
            placeholder: UIImage(named: "RecipeImgHolder"),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(2))])
        
        detailRecipeView.recipeLabel.text = recipe?.label
        let lines = recipe?.ingredientLines.map {$0.replacingOccurrences(of: ",", with: "")}
            .map { $0 + "\n" }
        let arrangedIngredients = lines?.joined()
        detailRecipeView.ingredientsTxtView.text = arrangedIngredients
        
        //code start here to open in safari with url link
        let cookInstUrl = recipe?.url
    }
    
    func showSafariVC(for cookInstUrl: String) {
        guard let url = URL(string: cookInstUrl)
            else {return}
        
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    //MARK: - OBJC Functions
    @objc func shareTapped(_ sender: UIButton) {
          //TODO: Create a share link thru sms, email, instagram or fb
        let activityController = UIActivityViewController(activityItems: [recipe?.url], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
      }
    
    @objc func bookmarkTapped(sender: UIButton) {
        let showBookmarkTappedVC = AddOrCreateVC()
        showBookmarkTappedVC.addOrCreateCollection = recipe
        present(showBookmarkTappedVC, animated: true)
    }
    
    @objc func heartButtonPressed(_ sender: UIButton) {
        switch heartStatus {
        case .filled:
            makeHeartEmpty()
            deleteFromPersistance(tag: 0)
        case .notFilled:
            makeHeartFill()
            saveToPersistance(tag: 0)
        }
    }
    
    @objc func cookingInstructionButtonPressed(_ sender: UIButton) {
        showSafariVC(for: "\(self.recipe?.url)")
        print("\(self.recipe?.url)")
    }
    
    
    private func setHeartImage() {
        switch heartStatus {
        case .filled:
            makeHeartFill()
        case .notFilled:
            makeHeartEmpty()
        }
    }
    
    private func makeHeartFill() {
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: UIImage.SymbolWeight.medium)
        let heart = UIImage(systemName: "heart.fill", withConfiguration: config)
        detailRecipeView.heartButton.setImage(heart, for: .normal)
        heartStatus = .filled
    }
    private func makeHeartEmpty() {
        let config = UIImage.SymbolConfiguration(pointSize: 40, weight: UIImage.SymbolWeight.medium)
        let heart = UIImage(systemName: "heart", withConfiguration: config)
        detailRecipeView.heartButton.setImage(heart, for: .normal)
        heartStatus = .notFilled
    }
    
    //MARK: Firestore
    private func saveRecipeToFireStore(_ tag: Int) {
        let favedRecipe = recipe
        let newFirestoreRecipe = Favorite(creatorID: FirebaseAuthService.manager.currentUser?.uid ?? "", recipeTitle: favedRecipe!.label, imageUrl: favedRecipe?.image, dateCreated: FirebaseAuthService.manager.currentUser?.metadata.creationDate, urlCookInst: favedRecipe?.url ?? "", ingredientLinesArr: favedRecipe!.ingredientLines, faveId: favedRecipe!.uri)
        FirestoreService.manager.createFavorites(favd: newFirestoreRecipe, recipeTitle: newFirestoreRecipe.label) { (result) in
            switch result {
            case .success:
                print("Saved in firestore")
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func deleteRecipeFromFireStore(_ tag: Int) {
        let unFavoriteRecipe = recipe
        FirestoreService.manager.findIdToUnfavor(fave: unFavoriteRecipe!.uri, userID: FirebaseAuthService.manager.currentUser?.uid ?? "") { (result) in
            FirestoreService.manager.unfavoritedRecipe(result: result) { (result) in
                switch result {
                case .failure(let error):
                    print("Problem deleting recipe from FireStore: \(error)")
                case .success:
                    print("'\(unFavoriteRecipe!.label)' successfully unfavorited")
                }
            }
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setDetailRecipeView()
        setHeartImage()
        detailRecipeView.urlButton.addTarget(self, action: #selector(cookingInstructionButtonPressed(_:)), for: .touchUpInside)
        detailRecipeView.heartButton.addTarget(self, action: #selector(heartButtonPressed(_:)), for: .touchUpInside)
        detailRecipeView.shareButton.addTarget(self, action: #selector(shareTapped(_:)), for: .touchUpInside)
        detailRecipeView.bookmarkButton.addTarget(self, action: #selector(bookmarkTapped(sender:)), for: .touchUpInside)
    }
}

//MARK: - Extensions
extension RecipeDetailVC: HeartButtonDelegate {
    func saveToPersistance(tag: Int) {
        saveRecipeToFireStore(tag)
        print(tag)
    }
    
    func deleteFromPersistance(tag: Int) {
        deleteRecipeFromFireStore(tag)
    }
}

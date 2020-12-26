//
//  ViewController.swift
//  ProgrammingFact
//
//  Created by Wikan Setiaji on 03/03/20.
//  Copyright © 2020 Wikan Setiaji. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var intro: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    
    var answered = 0
    var score = 0
    
    var trivias:[FactModel] = []
    
    var category:CategoryModel?
    
    var viewModel: FactViewModel = FactViewModel()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trivias.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FactCell", for: indexPath) as! FactCell
        let fact = trivias[indexPath.row]
        
        cell.fact = fact
        cell.viewController = self
        
        fact.index = indexPath.row
        
        cell.layer.cornerRadius = 16
        cell.buttonTrue.layer.cornerRadius = 30
        cell.buttonFalse.layer.cornerRadius = 30
        
        fact.first = false
        fact.last = false
        
        if (indexPath.row == 0){
            fact.first = true
        }
        else if (indexPath.row == trivias.count-1){
            fact.last = true
        }

        if (indexPath.row%3==0){
            cell.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        }
        else if (indexPath.row%3==1){
            cell.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        }
        else if (indexPath.row%3==2){
            cell.backgroundColor = #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1)
        }
        return cell
    }
    
    enum ScrollType {
        case dragging
        case deceleratingRight
        case deceleratingLeft
    }
    
    func snapScroll(_ collectionView: UICollectionView, _ scrollType:ScrollType) {
        for i in 0..<collectionView.numberOfItems(inSection: 0) {
            if let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout{

                let itemWithSpaceWidth = collectionViewFlowLayout.itemSize.width + collectionViewFlowLayout.minimumLineSpacing
                let dragOffsetToSnap = scrollType == .dragging ? collectionViewFlowLayout.itemSize.width / 2 : 0
                let leftScrollOffset = scrollType == .deceleratingLeft && i != 0 ? 1 : 0

                if collectionView.contentOffset.x <= CGFloat(i) * itemWithSpaceWidth + dragOffsetToSnap {
                    let indexPath = IndexPath(item: i - leftScrollOffset, section: 0)
                    UIView.animate(withDuration: 0.2, animations: { [weak self] in
                        self?.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                    })
                    break
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate){
            snapScroll(collectionView, ScrollType.dragging)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let point = scrollView.panGestureRecognizer.translation(in: scrollView)
        if point.x < 0 {
            snapScroll(collectionView,ScrollType.deceleratingRight)
        }
        else if point.x > 0{
          snapScroll(collectionView,ScrollType.deceleratingLeft)
        }
    }
    
    @IBAction func refreshButtonClick(_ sender: Any) {
        loadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        viewModel.factsChanged = { (facts) in
            self.toggleDataChange(facts: facts)
        }
        
        viewModel.loadingStateChanged = { (isLoading) in
            self.toggleLoading(isLoading: isLoading)
        }
        
        viewModel.errorChanged = { (error) in
            self.toggleError(error: error)
        }
        
        loadData()
        
        if let temp = category{
            navItem.title = temp.title
            intro.text = "Here is some random \(temp.title.lowercased()) trivia. Let's see if you know it."
            refreshButton.setTitle("I want other \(temp.title.lowercased()) trivias!", for: .normal)
        }
    }
    
    func toggleLoading(isLoading: Bool){
        DispatchQueue.main.async {
            if isLoading{
                self.collectionView.isHidden = true
                self.loading.startAnimating()
            }
            else{
                self.loading.stopAnimating()
            }
        }
    }
    
    func toggleDataChange(facts: [FactModel]){
        DispatchQueue.main.async {
            self.trivias = facts
            self.collectionView.reloadData()
            self.collectionView.isHidden = false
            self.collectionView.scrollToItem(at: IndexPath(row: 0,section: 0), at: .left, animated: true)
        }
    }
    
    func toggleError(error: APIRequest.Error?){
        guard let error = error else{return}
        
        var title = ""
        var message = ""
        
        if error == .noInternet{
            title = "Oops!"
            message = "There is something wrong with the internet connection"
        }
        else{
            title = "Uh ohh"
            message = "No data was fetched from the API"
        }
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message:
                                                        message, preferredStyle: .alert)
            
            if error == .noInternet{
                alertController.addAction(UIAlertAction(title: "Try again", style: .default, handler: {
                    action in
                    self.loadData()
                    self.navigationController?.popViewController(animated: true)
                }))
            }
            else{
                alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: {
                    action in
                    self.navigationController?.popViewController(animated: true)
                }))
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func loadData(){
        guard let category = category else{return}
        answered = 0
        score = 0
        viewModel.fetchCategories(id: category.id)
    }
    
    func next(current:Int){
        if (current<trivias.count){
            self.collectionView.scrollToItem(at: IndexPath(row: current+1,section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    func prev(current:Int){
        if (current != 0){
            self.collectionView.scrollToItem(at: IndexPath(row: current-1,section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    func answer(answer:Bool){
        score = answer ? score+1:score
        answered+=1
        if (answered == 5){
            var greet = ""
            switch score {
            case 5:
                greet = "Perfect!"
            case 4:
                greet = "Very cool!"
            case 3:
                greet = "Great!"
            case 2:
                greet = "Nice!"
            case 1:
                greet = "Hmm,"
            case 0:
                greet = "Im sorry,"
            default:
                greet = "Cool!"
            }
            let alertController = UIAlertController(title: "You have finished 😊", message:
                "\(greet) You answered \(score) questions right out of 5 questions!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default))
            self.present(alertController, animated: true, completion: nil)
            self.collectionView.scrollToItem(at: IndexPath(row: 0,section: 0), at: .left, animated: true)
        }
    }
    
}


//
//  ViewController.swift
//  ProgrammingFact
//
//  Created by Wikan Setiaji on 03/03/20.
//  Copyright © 2020 Wikan Setiaji. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var intro: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    
    var answered = 0
    var score = 0
    
    var trivias:[TriviaModel] = []
    
    var category:CategoryModel?
    
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
    
    enum Error {
        case zeroItem
        case noInternet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        loadData()
        
        if let temp = category{
            navItem.title = temp.title
            intro.text = "Here is some random \(temp.title.lowercased()) trivia. Let's see if you know it."
            refreshButton.setTitle("I want other \(temp.title.lowercased()) trivias!", for: .normal)
        }
    }
    
    func fetchFacts(successFetch: @escaping ([TriviaModel]) -> Void, errorFetch: @escaping (Error) -> Void) {
        var id = 9
        if let temp = category{
            id = temp.id
        }
        let url = URL(string: "https://opentdb.com/api.php?amount=5&category=\(id)&type=boolean&encode=base64")!

        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                errorFetch(Error.noInternet)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                    print("Error")
                    errorFetch(Error.noInternet)
                    return
            }

            if let data = data{
                let result = try! JSONDecoder().decode(FactResponse.self, from: data)
                if (result.results.count == 0){
                    errorFetch(Error.zeroItem)
                    return
                }
                successFetch(result.results)
            }
        })
        task.resume()
    }
    
    func loadData(){
        answered = 0
        score = 0
        collectionView.isHidden = true
        loading.startAnimating()
        fetchFacts(
            successFetch: { (data) in
            self.trivias = data
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.loading.stopAnimating()
                self.collectionView.isHidden = false
                self.collectionView.scrollToItem(at: IndexPath(row: 0,section: 0), at: .left, animated: true)
                
            }
        },
            errorFetch: {
                (type) in
                DispatchQueue.main.async {
                    self.loading.stopAnimating()
                    self.collectionView.isHidden = false
                    if (type == Error.noInternet){
                        let alertController = UIAlertController(title: "Oops!", message:
                            "There is something wrong with the internet connection", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Try again later", style: .default, handler: {
                            action in self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    else if (type == Error.zeroItem){
                        let alertController = UIAlertController(title: "Oops!", message:
                            "There is no trivia yet in this category", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Back", style: .default, handler: {
                            action in self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
        }
        )
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


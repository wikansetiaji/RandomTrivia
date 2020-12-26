//
//  MainPageController.swift
//  ProgrammingFact
//
//  Created by Wikan Setiaji on 11/03/20.
//  Copyright © 2020 Wikan Setiaji. All rights reserved.
//

import UIKit

class MainPageController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var chooseButton: UIButton!
    
    var categories:[CategoryModel] = [CategoryModel(2, "Sports"),CategoryModel(3, "Movies"),CategoryModel(4, "Music"), CategoryModel(5, "Detective"),CategoryModel(6, "Undercover"), CategoryModel(2, "Sports"),CategoryModel(3, "Movies"),CategoryModel(4, "Music"), CategoryModel(5, "Detective"),CategoryModel(6, "Undercover")]
    
    var viewModel = CategoryViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        picker.dataSource = self
        picker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.categoriesChanged = { (categories) in
            self.toggleDataChange(categories: categories)
        }
        
        viewModel.loadingStateChanged = { (isLoading) in
            self.toggleLoading(isLoading: isLoading)
        }
        
        viewModel.errorChanged = { (error) in
            self.toggleError(error: error)
        }
        
        loadData()
    }
    
    
    func toggleLoading(isLoading: Bool){
        DispatchQueue.main.async {
            if isLoading{
                self.picker.isHidden = true
                self.loading.startAnimating()
            }
            else{
                self.loading.stopAnimating()
            }
        }
    }
    
    func toggleDataChange(categories: [CategoryModel]){
        DispatchQueue.main.async {
            self.categories = categories
            self.picker.reloadAllComponents()
            self.picker.isHidden = false
            self.chooseButton.isEnabled = true
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
        viewModel.fetchCategories()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
  
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].title
    }
    
    @IBAction func chooseCategoryButtonClick(_ sender: Any) {
        performSegue(withIdentifier: "categorySegue", sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier=="categorySegue"){
            let destination = segue.destination as! CategoryViewController
            destination.category = categories[picker.selectedRow(inComponent: 0)]
        }
    }
    
}

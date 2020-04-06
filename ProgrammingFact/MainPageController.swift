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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.dataSource = self
        picker.delegate = self
        
        loadData()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        self.navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
    
    func loadData(){
        loading.startAnimating()
        fetchCategories{ (data) in
            self.categories = data.sorted(){
                (this, other) in
                return this.title < other.title
            }
            DispatchQueue.main.async {
                self.picker.reloadAllComponents()
                self.picker.isHidden = false
                self.picker.selectRow(10, inComponent: 0, animated: true)
                self.loading.stopAnimating()
                self.chooseButton.isEnabled = true
            }
        }
    }
    
    func fetchCategories(successFetch: @escaping ([CategoryModel]) -> Void) {
      let url = URL(string: "https://opentdb.com/api_category.php")!

      let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
        if let error = error {
            print("Error: \(error)")
            //TODO: handle request error
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
                print("Error")
                //TODO: handle response error
                return
        }

        if let data = data{
            let result = try! JSONDecoder().decode(CategoryResponse.self, from: data)
            successFetch(result.trivia_categories)
        }
      })
        task.resume()
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
            let destination = segue.destination as! ViewController
            destination.category = categories[picker.selectedRow(inComponent: 0)]
        }
    }
    
}

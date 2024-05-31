//
//  ViewController.swift
//  MealTime
//
//  Created by Ivan Akulov on 10/02/2020.
//  Copyright © 2020 Ivan Akulov. All rights reserved.
//


import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var context: NSManagedObjectContext!
    
    var user: User!
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        let meal = Meal(context: context) //создали объект мил
        meal.date = Date() //присвоили ему текущую дату
        //создаем копию приемов пищи у юзера
        let meals = user.meals?.mutableCopy() as? NSMutableOrderedSet //массив
        meals?.add(meal) //добавляем новый примем пищи meals
        user.meals = meals  //присвоили юзеру новый массив
        
        do {
            try context.save()
            tableView.reloadData()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let userName = "Max"
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest() //хотим получать данные по юзеру
        fetchRequest.predicate = NSPredicate(format: "name == %@", userName) //пишем предикат для имени
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                user = User(context: context)
                user.name = userName
                try context.save()
            } else {
                user = results.first
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My happy meal time"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.meals?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        //нужно получить конкретный прием пищи и поместить его в конкретную строку
        guard let meal = user.meals?[indexPath.row] as? Meal,
              let mealDate = meal.date
        else { return cell } //если не получилось просто вернули пустую ячейку
        
        cell.textLabel!.text = dateFormatter.string(from: mealDate)
        return cell
    }
    //Пропишем удаление приема пищи в таблице
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //получить прием пищи в конкретной строке таблицы, получили Meal проверяем стайл
        guard let meal = user.meals?[indexPath.row] as? Meal, editingStyle == .delete else { return }
        //meal лежит в контексте, поэтому удаляем meal из него
        context.delete(meal)
        
        do {
            try context.save()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}


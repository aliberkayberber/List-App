//
//  ViewController.swift
//  ListApp
//
//  Created by Ali Berkay BERBER on 14.08.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var alertController = UIAlertController()
    
    @IBOutlet weak var tableView: UITableView!
    
    var data = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetch()
    }

    
    @IBAction func didRemoveBarButtonItemTapped(_ sender: UIBarButtonItem){
        presentAlert(title: "UYARI",
                     massage: "Listedeki bütün öğeleri silmek istediğinizden emin misiniz?",
                    defaultButtonTitle: "Evet",
                     cancelButtonTitle: "Vazgeç"
                     ) { _ in
            //self.data.removeAll()
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListItem")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try! managedObjectContext?.execute(deleteRequest)
            
            self.fetch()
     
            
            //self.tableView.reloadData()
        }
    }
    
    
    @IBAction func didAddBarButtonItemTapped( _ sender:UIBarButtonItem){
        
        presentAddAlert()
    }
    
    func presentAddAlert(){

        presentAlert(title: "Yeni Eleman Ekle",
                     massage: nil,
                     defaultButtonTitle: "EKLE",
                     cancelButtonTitle: "VAZGEÇ",
                     isTextFieldAvailable: true,
                     defaultButtonHadler: { _ in
            let text = self.alertController.textFields?.first?.text
            if text != ""  {
                
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                
                let entity = NSEntityDescription.entity(forEntityName: "ListItem", in: managedObjectContext!)
                
                let listItem = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
                
                listItem.setValue(text, forKey: "title")
                
                try? managedObjectContext?.save()
                
                
                self.fetch()
            }else{
                self.presentWarningAlert()
            }
        })
        
        
        
    }
    func presentWarningAlert(){
        
        let alertController = UIAlertController(title: "UYARI!",
                                                message: "Listeye boş eleman ekleyemezsiniz",
                                                preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "TAMAM",
                                         style: .cancel)
        alertController.addAction(cancelButton)
        present(alertController, animated: true, completion: nil)
        
        presentAlert(title: "UYARI!", massage: "Listeye boş eleman ekleyemezsiniz", cancelButtonTitle: "TAMAM")
    }
    
    func presentAlert(title: String?,
                      massage: String?,
                      preferredStyle: UIAlertController.Style = .alert,
                      defaultButtonTitle: String? = nil,
                      cancelButtonTitle: String?,
                      isTextFieldAvailable: Bool = false,
                      defaultButtonHadler: ((UIAlertAction) -> Void)? = nil
    ){
        
        alertController = UIAlertController(title: title,
                                            message: massage,
                                            preferredStyle: .alert)
        
        if defaultButtonTitle != nil {
            
            let defaultButton = UIAlertAction(title: defaultButtonTitle,
                                              style: .default ,
                                              handler: defaultButtonHadler)
            alertController.addAction(defaultButton)
            
        }

        
        let cancelButton = UIAlertAction(title: cancelButtonTitle,
                                         style: .cancel)
        
        if isTextFieldAvailable == true {
            alertController.addTextField()
        }
        
        
        alertController.addAction(cancelButton)
        present(alertController, animated: true, completion: nil)
        
    }
    
    func fetch(){
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        
        data = try! managedObjectContext!.fetch(fetchRequest)
        tableView.reloadData()
    }
}



extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        let listİtem = data[indexPath.row]
        cell.textLabel?.text = listİtem.value(forKey: "title") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath:
                   IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal,
                                              title: "Sil") { _, _, _ in
           
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            managedObjectContext?.delete(self.data[indexPath.row])
            
            try? managedObjectContext?.save()
            
            self.fetch()
        }
        
        let editAction = UIContextualAction(style: .normal,
                                              title: "Düzenle") { _, _, _ in
            self.presentAlert(title: "Elemanı Düzenle",
                              massage: nil,
                              defaultButtonTitle: "Düzenle",
                              cancelButtonTitle: "Vazgeç",
                              isTextFieldAvailable: true) { _ in
                let text = self.alertController.textFields?.first?.text
                if text != ""  {
                    //self.data[indexPath.row] = text!
                    
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                    
                    self.data[indexPath.row].setValue(text , forKey: "title")
                    
                    if managedObjectContext!.hasChanges{
                        try? managedObjectContext?.save()
                    }
                    
                    self.tableView.reloadData()
                }else{
                    self.presentWarningAlert()
                }
            }
        }
        
        deleteAction.backgroundColor = .systemRed
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
        return config
    }
    
    
}


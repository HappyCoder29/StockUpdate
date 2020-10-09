//
//  TableViewController.swift
//  StockUpdate
//
//  Created by Ashish Ashish on 10/8/20.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class TableViewController: UITableViewController {

    
    var arr = [StockProfile]()
    
    @IBOutlet var tblView: UITableView!
    
    let refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arr.append(StockProfile("MSFT"))
        arr.append(StockProfile("AMZN"))
        arr.append(StockProfile("GOOG"))
        arr.append(StockProfile("TSLA"))
        arr.append(StockProfile("FB"))
        
        if #available(iOS 10.0, *){
            tblView.refreshControl = refresh
        }else {
            tblView.addSubview(refresh)
        }
        
        refresh.addTarget(self, action: #selector(refreshStockData(_:)), for: .valueChanged)
        refresh.attributedTitle = NSAttributedString(string: "Getting Stock Values")
        

        
    }
    
    @ objc private func refreshStockData(_ sender: Any){
        refreshData()
    }
    
    
    @IBAction func refreshStockValues(_ sender: Any) {
        
        refreshData()
    }
    
    
    func refreshData(){
        
        let url = getURL()
        
        AF.request(url).responseJSON { (response) in
            self.refresh.endRefreshing()
            if response.error == nil{
                
                // Get JSON STring and convert it into JSON Array
                guard let jsonString = response.data else { return }
                guard let stocks: [JSON] = JSON(jsonString).array else { return }
                
                // If there are no stocks return
                if stocks.count < 1 { return }
                
                // Re initialize the stock values
                self.arr.removeAll()
                
                for stock in stocks{
                    
                    let stockProfile = self.getStockProfileFromJSON(stock: stock)
                    
                    if stockProfile.symbol == "NONE" { return }

                    self.arr.append(stockProfile)
                 
                }
                // reload table
                self.tblView.reloadData()
                
            }
            
        }
        
        
        
    }
    
    func getStockProfileFromJSON(stock : JSON)-> StockProfile{
        let defaultStock = StockProfile("NONE")
        guard let symbol = stock["symbol"].rawString() else {return defaultStock}
        guard let price = stock["price"].double  else {return defaultStock}
        guard let companyName = stock["companyName"].rawString() else {return defaultStock}
        guard let industry = stock["industry"].rawString() else {return defaultStock}
        guard let website = stock["website"].rawString() else {return defaultStock}
        guard let description = stock["description"].rawString() else {return defaultStock}
        guard let ceo = stock["ceo"].rawString() else {return defaultStock}
       
        let stockProfile = StockProfile(symbol)
        stockProfile.price = price
        stockProfile.companyName = companyName
        stockProfile.industry = industry
        stockProfile.website = website
        stockProfile.description = description
        stockProfile.ceo = ceo
       
        return stockProfile
    }
    
    func getURL() -> String{
        var url = apiURL
        
        for stock in arr {
            url.append(stock.symbol)
            url.append(",")
        }
        url = String(url.dropLast())
        
        url.append("?apikey=\(apiKey)")
        
        return url
    }

 

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("TableViewCell", owner: self, options: nil)?.first as! TableViewCell
        
        cell.lblPrice.text = "$\(arr[indexPath.row].price)"
        cell.lblSymbol.text = arr[indexPath.row].symbol
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            //let stock = arr[indexPath.row]
            arr.remove(at: indexPath.row)
            tblView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    

}

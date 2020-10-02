//
//  StockData.swift
//  StockUpdate
//
//  Created by Ashish Ashish on 10/1/20.
//

import Foundation
class StockData{
    var symbol : String! = ""
    var price : Double = 0.0
    var volume : Int64 = 0
    
    init(symbol: String!, price: Double, volume: Int64) {
        self.symbol = symbol
        self.price = price
        self.volume = volume
    }
}

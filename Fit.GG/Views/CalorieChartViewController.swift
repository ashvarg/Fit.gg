//
//  CalorieChartViewController.swift
//  Fit.GG
//
//  Created by Ashwin George on 1/6/2023.
//

import UIKit
import SwiftUI
import Charts

class CalorieChartViewController: UIViewController, DatabaseListener {

    
    var listenerType = ListenerType.entries
    var totalEntries: [Entry] = []
    weak var databaseController: CoreDatabaseProtocol?
    var chartData: [(Date, Double)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.CoreDatabaseController
        
        

        // Do any additional setup after loading the view.
    }
    
    func convertEntriesToData() -> [(Date,Double)]{
        var tuples: [(Date,Double)] = []
        for entry in totalEntries{
            tuples.append((entry.date!, Double(entry.weight)))
            
            
        }
        return tuples
    }
    
    
    func onEntryListChange(change: DatabaseChange, entries: [Entry]) {
        totalEntries = entries
    }
    
    func onBreakfastListChange(change: DatabaseChange, entryFood: [Food]) {
        
    }
    
    func onLunchListChange(change: DatabaseChange, entryFood: [Food]) {
        
    }
    
    func onDinnerListChange(change: DatabaseChange, entryFood: [Food]) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        chartData = convertEntriesToData()
        let chartView = CalorieChartUIView(data: chartData)
        let hostingController = UIHostingController(rootView: chartView)
        guard let chartViewHost = hostingController.view else{
            return
        }
        
        view.addSubview(chartViewHost)
        addChild(hostingController)
        
        chartViewHost.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([chartViewHost.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12.0),
                                    chartViewHost.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12.0), chartViewHost.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12.0), chartViewHost.widthAnchor.constraint(equalTo: chartViewHost.heightAnchor)])
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
}

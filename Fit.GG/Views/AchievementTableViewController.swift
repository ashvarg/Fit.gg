//
//  AchievementTableViewController.swift
//  Fit.GG
//
//  Created by Ashwin George on 9/6/2023.
//  Reference: https://youtu.be/eZ5xiGNegho (IOS 11, Swift 4, Tutorial : How To Create Custom Cell Tableview ( with Image & Text ))

import UIKit

class AchievementTableViewController: UITableViewController {

    let namesRef = [("Shred Master"), ("Shred King"), ("Shred Legend")]
    let desRef = [("Lost 2kg weight in the current month"), ("Lost 5kg weight in past 2 months"), ("Lost 10kg weight in the past 3 months")]
    let imageRef = [UIImage(named: "bronze_trophy"), UIImage(named: "silver_trophy"), UIImage(named: "gold_trophy")]
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return namesRef.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "achieveCell", for: indexPath as IndexPath) as! AcheivementTableViewCell
        cell.achieveImage.image = self.imageRef[indexPath.row]
        cell.nameLabel.text = self.namesRef[indexPath.row]
        cell.descriptionLabel.text = self.desRef[indexPath.row]


        return cell
    }
    

}

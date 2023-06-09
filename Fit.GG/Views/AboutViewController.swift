//
//  AboutViewController.swift
//  Fit.GG
//
//  Created by Ashwin George on 9/6/2023.
// Page for the About section

import UIKit

class AboutViewController: UIViewController {


    @IBOutlet weak var aboutField: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        aboutField.text = createReferences()
    }
    
    func createReferences() -> String{
        let referenceText = "Throughout the development of this app, multiple references have been used to create final functionality that can be seen in this current iteration.\n\nHere is a list of references based on each view controller:\n\nAchievementViewController:https://youtu.be/eZ5xiGNegho (IOS 11, Swift 4, Tutorial : How To Create Custom Cell Tableview ( with Image & Text ))\n\nEntryViewController:https://youtu.be/chROnJIF7dY UI DatePicker for UITextField | 2020\n\nCalorieChartUIView: https://youtu.be/ZMe6Xq2gCGs (Drawing Line Graph in SwiftUI)\n\nPackage Dependencies: Firebase"
        return referenceText
    }

    
   

}

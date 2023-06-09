//
//  AcheivementTableViewCell.swift
//  Fit.GG
//
//  Created by Ashwin George on 9/6/2023.
//

import UIKit

class AcheivementTableViewCell: UITableViewCell {

    @IBOutlet weak var achieveImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

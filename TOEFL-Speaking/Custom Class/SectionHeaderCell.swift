//
//  SectionHeaderCell.swift
//  TOEFL-Speaking
//
//  Created by Parth Tamane on 03/08/18.
//  Copyright © 2018 Parth Tamane. All rights reserved.
//

import UIKit

class SectionHeaderCell: UITableViewCell {

    weak var delegate: ViewController?
    
    
    @IBOutlet weak var sectionNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func shareRecordingsTapped(_ sender: UIButton) {
    }
    
    func configureCell(date:String) {
        sectionNameLbl.text = date
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

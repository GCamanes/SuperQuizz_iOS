//
//  QuestionTableViewCell.swift
//  SuperQuizz
//
//  Created by formation7 on 04/12/2018.
//  Copyright © 2018 formation7. All rights reserved.
//

import UIKit

class QuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionAuthorImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

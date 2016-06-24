//
//  TextTalkCell.swift
//  App
//
//  Created by Laan on 2016. 6. 22..
//  Copyright © 2016년 Laan. All rights reserved.
//

import UIKit

class TextTalkCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var user_image: UIView!
    
    @IBOutlet weak var image_view: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

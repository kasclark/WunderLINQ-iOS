//
//  TaskCollectionViewCell.swift
//  WunderLINQ
//
//  Created by Keith Conger on 12/5/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import UIKit

class TaskCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var taskImage: UIImageView!
    @IBOutlet weak var taskLabel: UILabel!
    public var icon: UIImageView!
    public var label: UILabel!
    
    func displayContent(icon: UIImage, label: String) {
        taskImage.image = icon
        taskLabel.text = label
    }
    
    func highlightEffect(){
        taskImage.backgroundColor = UIColor(red:0.00, green:0.35, blue:1.00, alpha:1.0)
        taskLabel.backgroundColor = UIColor(red:0.00, green:0.35, blue:1.00, alpha:1.0)
        taskLabel.textColor = UIColor.white
        contentView.backgroundColor = UIColor(red:0.00, green:0.35, blue:1.00, alpha:1.0)
    }
    
    func removeHighlight(color: UIColor){
        taskImage.backgroundColor = color
        taskLabel.backgroundColor = color
        if (color == UIColor.white){
            taskLabel.textColor = UIColor.black
        } else {
            taskLabel.textColor = UIColor.white
        }
        contentView.backgroundColor = color
    }
    
}

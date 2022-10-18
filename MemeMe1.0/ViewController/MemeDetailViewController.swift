//
//  MemeDetailViewController.swift
//  MemeMe1.0
//
//  Created by David Koch on 18.10.22.
//

import Foundation
import UIKit

class MemeDetailViewController: UIViewController{
    
    var meme: Meme!
    
    
    @IBOutlet weak var memedImage: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.memedImage.image = self.meme.memedImage
    }
    
}

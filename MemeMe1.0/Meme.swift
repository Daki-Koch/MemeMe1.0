//
//  Meme.swift
//  MemeMe1.0
//
//  Created by David Koch on 22.09.22.
//

import Foundation
import UIKit



let memeTextAttributes: [NSAttributedString.Key: Any] = [
    
    NSAttributedString.Key.foregroundColor: UIColor.white,
    NSAttributedString.Key.strokeColor: UIColor.black,
    NSAttributedString.Key.font: UIFont(name: "Impact", size: 40)!,
    NSAttributedString.Key.strokeWidth: -3,

    
]


struct Meme {
    var topText: String
    var bottomText: String
    var originalImage: UIImage
    var memedImage: UIImage
}


//
//  UIScrollView.swift
//  iSocial
//
//  Created by Jean Pierre Matteo on 9/2/16.
//  Copyright © 2016 tghsistemas. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView{
    func setContentViewSize(offset:CGFloat = 0.0) {
        print("RESIZING THE SCROLL")
        // dont show scroll indicators
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        var maxHeight : CGFloat = 0
        for view in subviews {
            if view.hidden {
                continue
            }
            let newHeight = view.frame.origin.y + view.frame.height
            if newHeight > maxHeight {
                maxHeight = newHeight
            }
        }
        // set content size
        contentSize = CGSize(width: contentSize.width, height: maxHeight + offset)
        // show scroll indicators
        showsHorizontalScrollIndicator = true
        showsVerticalScrollIndicator = true
    }
}
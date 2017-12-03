//
//  PresHelpers.swift
//  PresBrowser
//
//  Created by alex on 12/2/17.
//  Copyright © 2017 Oz Michaeli. All rights reserved.
//

import Foundation

func calculateScale(size: CGSize, into: CGSize) -> CGFloat{
    //we want to make a layer that is size:into scale to size:size
    if size == CGSize.zero || into == CGSize.zero{
        return 1.0
    }
    let widthRatio = size.width / into.width
    let heightRatio = size.height / into.height
    if(heightRatio < widthRatio){
        return heightRatio
    }
    return widthRatio
}

func center(_ size: CGSize, containedIn: CGSize) -> CGPoint{
    let diffWidth = containedIn.width - size.width
    let diffHeight = containedIn.height - size.height
    return CGPoint(x:diffWidth/2, y:diffHeight/2)
}

//
//  Constants.swift
//  Never Late
//
//  Created by parker amundsen on 5/18/20.
//  Copyright © 2020 Parker Buhler Amundsen. All rights reserved.
//

import UIKit
final public class Constants {
    // MARK:- TableView identifiers
    static let entryVCCellIdentifier = "eventCell"
    static let mapVCCellIdentifier = "searchSuggestionCell"
    
    // MARK:- Color Scheme Constants
    static let primaryColor : UIColor = #colorLiteral(red: 0.9338286519, green: 0.9739060998, blue: 0.9988136888, alpha: 1)
    static let secondaryColor : UIColor  = #colorLiteral(red: 0.7450980392, green: 0.7058823529, blue: 0.5647058824, alpha: 1)
    static let accentColor : UIColor = #colorLiteral(red: 0.7802982234, green: 0.7802982234, blue: 0.7802982234, alpha: 0.7533711473)
    static let backGroundColor : UIColor = #colorLiteral(red: 0.9338286519, green: 0.9739060998, blue: 0.9988136888, alpha: 1)
    static let highLightColor : UIColor = #colorLiteral(red: 1, green: 0.9752991796, blue: 0, alpha: 0.3498501712)
    
    // MARK:- API Constants
    static let maximumArrivalTimeToleranceInSeconds : Int = 300
    static let maximumAPICalls : Int = 5
    
    // MARK:- Notification-Observer Constants
    static let reloadEventsNotificationIdenifier = "reloadEvents"
    static let invalidRequestNotificationIdentifier = "invalidRequest"
    static let networkErrorNotificationIdentifier = "networkError"
}

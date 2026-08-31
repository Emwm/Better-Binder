//
//  FontUI.swift
//  BLE Tutorials
//
//  Created by Reese Brogden on 4/3/26.
//

import SwiftUI

// note to find the post script name to put in the "" go to font book on your computer and search up cabin, then click the i icon

extension Font {
    static func appHeader() -> Font {
        // Scales along with the system "Large Title"
        return .custom("Cabin-Regular_Bold", size: 35, relativeTo: .largeTitle)
    }
    
    static func appSubHeader() -> Font {
        // Scales along with the system "Large Title"
        return .custom("Cabin-Regular", size: 25, relativeTo: .largeTitle)
    }
    
    static func appBody() -> Font {
        return .custom("Cabin-Regular", size: 20, relativeTo: .body)
    }
    
    static func appBodyBold() -> Font {
        return .custom("Cabin-Regular_Bold", size: 20, relativeTo: .body)
    }
    
    static func appBodyMedium() -> Font {
        return .custom("Cabin-Regular_Medium", size: 20, relativeTo: .body)
    }
    
    static func appSmallCaption() -> Font {
        return .custom("Cabin-Regular", size: 15, relativeTo: .caption)
    }
    
    static func appSmallCaptionBold() -> Font {
        return .custom("Cabin-Regular_Bold", size: 15, relativeTo: .caption)
    }
    
    static func appTableHeader() -> Font {
        return .custom("Cabin-Regular_Bold", size: 18, relativeTo: .body)
    }
    
    static func appTableBody() -> Font {
        return .custom("Cabin-Regular", size: 16, relativeTo: .body)
    }
    
    static func appYearView() -> Font {
        return .custom("Cabin-Regular", size: 12, relativeTo: .body)
    }
}

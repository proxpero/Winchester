//
//  Endgame.h
//  Endgame
//
//  Created by Todd Olsen on 7/19/16.
//
//

#if TARGET_OS_MAC
@import AppKit;
#elseif TARGET_OS_IOS
@import UIKit;
//#elseif TARGET_OS_TVOS
//    @import TVKit;
#endif

//! Project version number for Endgame.
extern double EndgameVersionNumber;

//! Project version string for Endgame.
extern const unsigned char EndgameVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Endgame/PublicHeader.h>

//
//  Chess.h
//  Chess
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

//! Project version number for ChessEngine.
extern double ChessEngineVersionNumber;

//! Project version string for ChessEngine.
extern const unsigned char ChessEngineVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <ChessEngine/PublicHeader.h>

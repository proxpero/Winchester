//
//  Engine.h
//  Engine
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

//! Project version number for Engine.
extern double EngineVersionNumber;

//! Project version string for Engine.
extern const unsigned char EngineVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Engine/PublicHeader.h>

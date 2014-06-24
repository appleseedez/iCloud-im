//
//  SoundManager.h
//  itelNSC
//
//  Created by nsc on 14-6-24.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
@interface SoundManager : NSObject
+(void) playSound:(NSString*)name;
+(void)stopPlaying;
@end

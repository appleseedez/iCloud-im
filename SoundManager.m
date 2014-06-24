//
//  SoundManager.m
//  itelNSC
//
//  Created by nsc on 14-6-24.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "SoundManager.h"

@implementation SoundManager
static SystemSoundID shake_sound_male_id = 0;


+(void) playSound:(NSString*)name

{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"comingCall" ofType:@"wav"];
    if (path) {
        //注册声音到系统
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&shake_sound_male_id);
        AudioServicesPlaySystemSound(shake_sound_male_id);
        //        AudioServicesPlaySystemSound(shake_sound_male_id);//如果无法再下面播放，可以尝试在此播放
    }
    
    AudioServicesPlaySystemSound(shake_sound_male_id);   //播放注册的声音，（此句代码，可以在本类中的任意位置调用，不限于本方法中）
    
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);   //让手机震动
}
+(void)stopPlaying{
    AudioServicesDisposeSystemSoundID(shake_sound_male_id);
}
@end

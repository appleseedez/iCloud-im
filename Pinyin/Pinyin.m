//
//  Pinyin.m
//  Pinyin
//
//  Created by nsc on 14-5-30.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "Pinyin.h"


char pinyinFirstLetter(unsigned short hanzi);
@implementation Pinyin
+(char)getFirstLetter:(NSString*)string{
    char s=pinyinFirstLetter([string characterAtIndex:0]);
    return s;
}
@end

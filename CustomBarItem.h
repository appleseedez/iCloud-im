//
//  CustomBarItem.h
//  itelNSC
//
//  Created by nsc on 14-5-8.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomBarItem : UIButton
@property (nonatomic) NSNumber *beSelected;
@property (nonatomic) UIImage *imgSelected;
@property (nonatomic) UIImage *imgNormal;
@property (nonatomic) UIColor *selectedColor;
@property (nonatomic) UIColor *normalColor;
@property (nonatomic) NSNumber *selIndex;
@end

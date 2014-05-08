//
//  CustomBarItem.m
//  itelNSC
//
//  Created by nsc on 14-5-8.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "CustomBarItem.h"

@implementation CustomBarItem

-(void)awakeFromNib{
    [super awakeFromNib];
      [RACObserve(self, beSelected) subscribeNext:^(NSNumber *x) {
          if ([x boolValue]) {
              [self setImage:self.imgSelected forState:UIControlStateNormal];
              [self setTitleColor:self.selectedColor forState:UIControlStateNormal];
          }else{
             [self setImage:self.imgNormal forState:UIControlStateNormal];
              [self setTitleColor:self.normalColor forState:UIControlStateNormal];
          }
      }];
    
}




@end

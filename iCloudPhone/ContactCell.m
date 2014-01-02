//
//  ContactCell.m
//  iCloudPhone
//
//  Created by nsc on 13-11-26.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "ContactCell.h"
#import "UIImageView+AFNetworking.h"
@interface ContactCell ()

@end

@implementation ContactCell




- (id)setup{
    if (self.lbCall==nil) {
        self.lbCall=[[UILabel alloc] initWithFrame:CGRectMake(3, 20, 90, 30)];
    }
    
    self.lbCall.text=@"打电话";
     self.lbCall.backgroundColor=[UIColor redColor];
    [self.backgroundView addSubview: self.lbCall];
    
    
    if (self.lbSend==nil) {
        self.lbSend=[[UILabel alloc] initWithFrame:CGRectMake(320-3-90, 20, 90, 30)];
        
        
    }
    
  
    self.lbSend.text=@"发短信";
    self.lbSend.backgroundColor=[UIColor greenColor];
    [self.lbSend setTextAlignment:NSTextAlignmentRight];
    [self.backgroundView addSubview:self.lbSend];

    
    
   
        self.lbNickName.backgroundColor=[UIColor clearColor];
        self.lbItelNumber.backgroundColor=[UIColor clearColor];
        [self.lbItelNumber setFont:[UIFont fontWithName:@"HeiTi SC" size:12]];
        self.lbItelNumber.numberOfLines=0;
        [self.lbItelNumber setTextColor:[UIColor grayColor]];
    
        [self.imgPhoto setRect:3.0 cornerRadius:self.imgPhoto.frame.size.width/4.0 borderColor:[UIColor whiteColor]];
     
        self.imgPhoto.clipsToBounds=YES;
  
    return self;
}


@end

//
//  AddressCell.m
//  itelNSC
//
//  Created by nsc on 14-5-13.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "AddressCell.h"
#import "AddressUser.h"
#import <UIImageView+AFNetworking.h>
#import "ItelUser+CRUD.h"
@implementation AddressCell



- (void)awakeFromNib
{
    [self.imgHead setClipsToBounds:YES];
    [self.imgHead.layer setCornerRadius:8.0];
}
-(void)loadWithUser:(AddressUser*)user{
    self.user=user;
    self.lbNickName.text=user.name;
    self.lbPhone.text=user.phone;
    [self.btnInvite addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
    if (user.user) {
        [self.btnInvite setImage:[UIImage imageNamed:@"addButton"] forState:UIControlStateNormal];
        [self.imgHead setImageWithURL:[NSURL URLWithString:user.user.telNum] placeholderImage:[UIImage imageNamed:@"standedHeader"]];
    }else{
        [self.btnInvite setImage:[UIImage imageNamed:@"inviteButton"] forState:UIControlStateNormal];
        [self.imgHead setImage:[UIImage imageNamed:@"standedHeader"]];
    }
}
-(void)action{
    if (self.user.user) {
        [self.delegate addUser:self.user.user];
    }else{
        [self.delegate  sendMessage:self.user];
    }
}

@end

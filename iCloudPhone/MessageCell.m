//
//  MessageCell.m
//  iCloudPhone
//
//  Created by nsc on 13-12-31.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(NewMessageView*)newMessage{
    if (_newMessage==nil) {
        _newMessage=[[NewMessageView alloc]initWithFrame:CGRectMake(40, 2.5, 10, 10)];
        [self.imgPhoto addSubview:_newMessage];
    }
    
    return _newMessage;
}

@end

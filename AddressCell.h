//
//  AddressCell.h
//  itelNSC
//
//  Created by nsc on 14-5-13.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AddressUser;
@class ItelUser;
@protocol AddressCellDelegate <NSObject>

-(void)addUser:(ItelUser*)user;
-(void)sendMessage:(AddressUser*)user;

@end

@interface AddressCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UILabel *lbNickName;
@property (weak, nonatomic) IBOutlet UILabel *lbPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnInvite;
@property (strong,nonatomic) AddressUser *user;
-(void)loadWithUser:(AddressUser*)user;
@property (nonatomic,weak) id <AddressCellDelegate> delegate;
@end

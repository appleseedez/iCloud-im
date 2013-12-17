//
//  ContactCell.m
//  iCloudPhone
//
//  Created by nsc on 13-11-26.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "ContactCell.h"

@interface ContactCell ()

@end

@implementation ContactCell




- (id)setup{
    if (self.lbCall==nil) {
        self.lbCall=[[UILabel alloc] initWithFrame:CGRectMake(3, 20, 90, 30)];
    }
    
    self.lbCall.text=@"打电话";
     self.lbCall.backgroundColor=[UIColor redColor];
    [self.contentView addSubview: self.lbCall];
    
    
    if (self.lbSend==nil) {
        self.lbSend=[[UILabel alloc] initWithFrame:CGRectMake(320-3-90, 20, 90, 30)];
        
        
    }
    
    self.topView.delegate=self;
    self.lbSend.text=@"发短信";
    self.lbSend.backgroundColor=[UIColor greenColor];
    [self.lbSend setTextAlignment:NSTextAlignmentRight];
    [self.contentView addSubview:self.lbSend];
    self.btnPush.backgroundColor=[UIColor clearColor];
    //[self.btnPush addTarget:self action:@selector(changeNormal) forControlEvents:UIControlEventTouchUpInside];
    //[self.btnPush addTarget:self action:@selector(changeNormal) forControlEvents:UIControlEventTouchUpOutside];
    [self.btnPush addTarget:self action:@selector(changeHigh) forControlEvents:UIControlEventTouchDown];
    self.topView.contentSize=CGSizeMake(self.bounds.size.width, 60) ;
    
    self.topView.backgroundColor=[UIColor clearColor];
    [self addSubview:self.topView];
    [self.topView addSubview:self.frontView];
        self.lbNickName.backgroundColor=[UIColor clearColor];
        self.lbItelNumber.backgroundColor=[UIColor clearColor];
        [self.lbItelNumber setFont:[UIFont fontWithName:@"HeiTi SC" size:12]];
        self.lbItelNumber.numberOfLines=0;
        [self.lbItelNumber setTextColor:[UIColor grayColor]];
        self.topView.cell=self;
        self.currenTranslate=0;
        [self.imgPhoto setRect:3.0 cornerRadius:self.imgPhoto.frame.size.width/4.0 borderColor:[UIColor whiteColor]];
     
        self.imgPhoto.clipsToBounds=YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNormal:) name:@"contactCellHigh" object:nil];
    return self;
}
-(void)changeNormal:(NSNotification*)notification{
    if (notification.object!=self) {
         self.btnPush.backgroundColor=[UIColor clearColor];
    }
   
}
-(void)changeHigh{

  static  float gray=0.3333;
  static  UIColor *high=[UIColor colorWithRed:gray green:gray     blue:gray alpha:0.1];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"contactCellHigh" object:self];
    self.btnPush.backgroundColor=high;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
   [super setSelected:selected animated:animated];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.contentOffset.x>80) {
        NSDictionary *userInfo=@{@"action":@"send",@"user":self.user};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cellAction" object:nil userInfo:userInfo];
    }
    else if(scrollView.contentOffset.x<-80){
        NSDictionary *userInfo=@{@"action":@"call",@"user":self.user};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cellAction" object:nil userInfo:userInfo];
    }
}

@end

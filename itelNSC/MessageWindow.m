//
//  MessageWindow.m
//  itelNSC
//
//  Created by nsc on 14-6-27.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MessageWindow.h"
#import "IMService.h"
@interface MessageWindow ()
@property (nonatomic) NSMutableArray *messageSequence;
@property (nonatomic) UILabel *textLabel;
@property (nonatomic,weak) IMService *imService;
@property (nonatomic) NSNumber *inBackground;
@end

@implementation MessageWindow
static MessageWindow *instace;

+ (void)initialize
{
    if (self == [MessageWindow class]) {
        BOOL didInit=NO;
        if (!didInit) {
            instace=[[MessageWindow alloc]init];
            instace.windowLevel=UIWindowLevelStatusBar;
            instace.frame=[UIScreen mainScreen].bounds;
            instace.backgroundColor=[UIColor clearColor];
            
            UIView *backView=[[UIView alloc]init];
            backView.frame=CGRectMake(60, 200, 200, 120);
            backView.backgroundColor=[UIColor colorWithRed:0.184 green:0.184 blue:0.184 alpha:0.8];
            
            
            instace.textLabel=[[UILabel alloc]init];
            instace.textLabel.frame=CGRectMake(20 , 20, 160, 80);
            instace.textLabel.backgroundColor=[UIColor clearColor];
            instace.textLabel.textColor=[UIColor whiteColor];
            instace.textLabel.numberOfLines=0;
            [backView addSubview:instace.textLabel];
            [instace addSubview:backView];
            instace.imService=[IMService defaultService];
           
            
        }
    }
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak id weakSelf=self;
         [RACObserve(self, imService.inBackground)subscribeNext:^(NSNumber *x) {
             self.inBackground=x;
             __strong MessageWindow* strongSelf=weakSelf;
             if (![x boolValue]) {
                 [strongSelf showNext];
             }
             
         }];
        self.userInteractionEnabled=NO;
    }
    return self;
}
+(void)showWithMessage:(NSString*)message{
    [instace.messageSequence addObject:message];
    if (![instace.inBackground boolValue]) {
        [instace showNext];
    }
}
-(void)showNext{
    if (![self.messageSequence count]) {
        return;
    }
    NSString *message=self.messageSequence[0];
    [self.messageSequence removeObject:message];
    [self showMessage:message];
}
-(void)showMessage:(NSString*)message{
  
    self.textLabel.text=message;
    CATransition *animation=[CATransition animation];
    animation.duration=0.5;
    animation.type=@"fade";
    [self setHidden:NO];
    [UIView commitAnimations];
    [self.layer addAnimation:animation forKey:@""];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:3];
}
-(void)dismiss{
   
    CATransition *animation=[CATransition animation];
    animation.duration=0.5;
    animation.type=@"fade";
    [self setHidden:YES];
    [self.layer addAnimation:animation forKey:@""];
    if ([self.messageSequence count]) {
        [self showNext];
    }
   
}
-(NSMutableArray*)messageSequence{
    if(_messageSequence==nil){
        _messageSequence=[[NSMutableArray alloc]init];
    }
    return _messageSequence;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

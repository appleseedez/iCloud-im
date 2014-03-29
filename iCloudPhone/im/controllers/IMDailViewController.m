//
//  IMDailViewController.m
//  im
//
//  Created by Pharaoh on 13-11-26.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import "IMDailViewController.h"
#import "IMRootTabBarViewController.h"
#import "ConstantHeader.h"
#import "IMSuggestResultCell.h"
#import "ItelAction.h"
#import <AudioToolbox/AudioToolbox.h>
#import "UIImageView+AFNetworking.h"

@interface IMDailViewController ()
@property(nonatomic) NSDictionary* touchToneMap; //按键的拨号音，系统默认就有的
@property(nonatomic) BOOL hidePan;// 标识出当前拨号盘是否可见。
@property(nonatomic) BOOL showSuggest; //标识当前是否显示建议面板
@property(nonatomic) UIView *addView;
@property(nonatomic) UIView *addFailureView;
@property(nonatomic) NSMutableArray* currentSuggestDataSource; //用于接收近似的itel号码
@property (nonatomic) UIButton *backButton;
@property (nonatomic) UILongPressGestureRecognizer *backRecognizer;
@end

@implementation IMDailViewController

-(UIView*)addFailureView{
    if (_addFailureView==nil) {
        _addFailureView=[[UIView alloc]init];
        _addFailureView.frame=CGRectMake(0, 0, 320, 45);
        _addFailureView.backgroundColor=[UIColor colorWithRed:1 green:0.8 blue:0.6 alpha:1];
        UIImageView *imgFailuer=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dial_addfailuer"]];
        imgFailuer.frame=CGRectMake(40, 8, 30, 30);
        
        [_addFailureView addSubview:imgFailuer];
        UILabel *lbFailure=[[UILabel alloc]init];
        lbFailure.frame=CGRectMake(70, 0, 320-70, 45);
        lbFailure.backgroundColor=[UIColor clearColor];
        lbFailure.text=@"未找到您输入的号码的相关信息";
        [lbFailure setFont:[UIFont fontWithName:@"HeiTi SC" size:15]];
        [lbFailure setTextColor:[UIColor colorWithRed:1 green:0.6 blue:0.2 alpha:1]];
        [_addFailureView addSubview:lbFailure];
        
        
        
    }
    return _addFailureView;
}
-(UIView*)addView{
    if (_addView==nil) {
        _addView=[[UIView alloc]init];
        _addView.frame=CGRectMake(40, 0, 230, 50);
        _addView.backgroundColor=[UIColor clearColor];
        UIImageView *imgAdd=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dial_addbtn"]];
        imgAdd.frame=CGRectMake(40, 8, 30, 30);
        [_addView addSubview:imgAdd];
        UIButton *btnAdd=[[UIButton alloc]init];
        btnAdd.frame=CGRectMake(55, 0, 150, 45);
        btnAdd.backgroundColor=[UIColor clearColor];
        [btnAdd setTitle:@"添加到通信录" forState:UIControlStateNormal];
        [btnAdd setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [btnAdd addTarget:self action:@selector(addUser) forControlEvents:UIControlEventTouchUpInside];
        [_addView addSubview:btnAdd];
        
    }
    return _addView;
}
-(void)addUser{
          
    [[ItelAction action]inviteItelUserFriend:self.peerAccount.text];
}
-(void)addUserResponse:(NSNotification*)notification{
    NSDictionary *info=notification.userInfo;
    int isNormal=[[info objectForKey:@"isNormal"]intValue];
    if (isNormal) {
        [[[UIAlertView alloc]initWithTitle:@"邀请已经发出" message:@"请等待对方确认" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }else{
        [self.addView removeFromSuperview];
        [self.suggestBtnView addSubview:self.addFailureView];
        [[[UIAlertView alloc]initWithTitle:@"邀请失败" message:[info objectForKey:@"reason"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *v=[self.view viewWithTag:28];
    v.backgroundColor=[UIColor clearColor];
    UIButton *btnBack=[[UIButton alloc] init];
    btnBack.frame=CGRectMake(10, 39, 40, 40);
    btnBack.backgroundColor=[UIColor clearColor];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"dial_back_button_normal"] forState:UIControlStateNormal];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"dial_back_button_high"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self.manager action:@selector(dismissDialRelatedPanel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBack];
    self.backButton=btnBack;
    
    UILongPressGestureRecognizer *backLongPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    backLongPress.allowableMovement=50.0;
    [self.backspaceButton addGestureRecognizer:backLongPress];
    self.backRecognizer=backLongPress;
    self.touchToneMap = @{
                          @"0":[NSNumber numberWithInt:1200],
                          @"1":[NSNumber numberWithInt:1201],
                          @"2":[NSNumber numberWithInt:1202],
                          @"3":[NSNumber numberWithInt:1203],
                          @"4":[NSNumber numberWithInt:1204],
                          @"5":[NSNumber numberWithInt:1205],
                          @"6":[NSNumber numberWithInt:1206],
                          @"7":[NSNumber numberWithInt:1207],
                          @"8":[NSNumber numberWithInt:1208],
                          @"9":[NSNumber numberWithInt:1209],
                          @"*":[NSNumber numberWithInt:1210],
                          @"#":[NSNumber numberWithInt:1211]
                          
                          };
    if (self.directNumber) {
        self.peerAccount.text=self.directNumber ;
        self.backspaceButton.hidden = NO;
        self.dialBackGroundView.backgroundColor = [UIColor colorWithRed:0.267 green:0.643 blue:0.859 alpha:1];
    }
    
    
    
    if (![self.peerAccount.text length]) {
        self.backspaceButton.hidden = YES;
    }else{
        self.backspaceButton.hidden = NO;
    }
    [self setup];

}

-(void)longPress:(UIButton*)sender{
    self.peerAccount.text=@"0";

    
    [self backspace:sender];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addUserResponse:) name:@"inviteItelUser" object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [self tearDown];
    self.directNumber=nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




- (IBAction)voiceDialing:(UIButton *)sender {

    [self.manager setIsVideoCall:NO];//告诉manager是音频通话
    NSString* peerAccount = self.peerAccount.text;
    if (!peerAccount || [peerAccount isEqualToString:BLANK_STRING] || [peerAccount isEqualToString:[self.manager myAccount]]) {
        return;
    }
//#if DEBUG
//    [[IMTipImp defaultTip]showTip:@"开启音频通话"];
//#endif
//    [[NSNotificationCenter defaultCenter] postNotificationName:PRESENT_CALLING_VIEW_NOTIFICATION object:nil userInfo:@{
//                                                                                                                       kDestAccount:peerAccount,
//                                                                                                                       kSrcAccount:[self.manager myAccount]
//                                                                                                                       }];
    [self.manager dial:peerAccount];
    
}
- (void) setup{
    [self registerNotifications];
    self.suggestBtnView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.suggestBtnView.layer.borderWidth = .5;
    self.searchResultView.hidden = YES;
    self.selfAccountLabel.text = @"";
    [[ItelAction action] getItelFriendList:0];
}
- (void) tearDown{
    [self removeNotifications];
    self.suggestBtnView.layer.borderColor = [UIColor clearColor].CGColor;
    self.suggestBtnView.layer.borderWidth = 0;
}
- (void) registerNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authOK:) name:CMID_APP_LOGIN_SSS_NOTIFICATION object:nil];


}
- (void) removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void) authOK:(NSNotification*) notify{
}



#pragma mark - table delegate & datasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.currentSuggestDataSource count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   IMSuggestResultCell * cell = [tableView dequeueReusableCellWithIdentifier:SUGGEST_CELL_VIEW_IDENTIFIER];
    if (!cell) {
        cell = [[IMSuggestResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SUGGEST_CELL_VIEW_IDENTIFIER];
    }
    ItelUser* userItem = self.currentSuggestDataSource[indexPath.row];
    cell.nameLabel.text = userItem.nickName;
    if ([cell.nameLabel.text isEqualToString:BLANK_STRING]) {
        cell.nameLabel.text = userItem.itelNum;
    }
    cell.numberLabel.text = userItem.itelNum;
    [cell.avatarView setImageWithURL:[NSURL URLWithString: userItem.imageurl ] placeholderImage:[UIImage imageNamed:@"standedHeader"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.hidePan)
    {
        [UIView animateWithDuration:.3 delay:.2 options:UIViewAnimationCurveEaseInOut animations:^{
            self.dialPanView.center = CGPointMake(self.dialPanView.center.x, self.dialPanView.center.y-self.dialPanView.bounds.size.height);
            self.suggestBtnView.center = CGPointMake(self.suggestBtnView.center.x, self.suggestBtnView.center.y-self.dialPanView.bounds.size.height);
            self.searchResultView.hidden = YES;
        } completion:nil];
        ItelUser* currentSelectUser = self.currentSuggestDataSource[indexPath.row];
        self.peerAccount.text = currentSelectUser.itelNum;
        self.backspaceButton.hidden = NO;
        self.hidePan = NO;
    }
}

#pragma mark - actions
- (IBAction)videoDialing:(UIButton *)sender {
    sender.enabled =NO;
    sender.backgroundColor =[UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1.0f];
    sender.titleLabel.textColor = [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1.0f];
    [self.manager setIsVideoCall:YES];
    NSString* peerAccount = self.peerAccount.text;
    if (!peerAccount || [peerAccount isEqualToString:BLANK_STRING] || [peerAccount isEqualToString:[self.manager myAccount]]) {
        sender.enabled = YES;
        
//        [TSMessage showNotificationWithTitle:NSLocalizedString(@"号码为空", nil)
//                                    subtitle:NSLocalizedString(@"请输入对方的iTel号码", nil)
//                                        type:TSMessageNotificationTypeError];
        
            [TSMessage showNotificationInViewController:[UIApplication sharedApplication].keyWindow.rootViewController title:NSLocalizedString(@"号码为空", nil) subtitle:NSLocalizedString(@"请输入对方的iTel号码", nil) type:TSMessageNotificationTypeError duration:0.5 canBeDismissedByUser:NO];
        return;
    }

       
    [self.manager dial:peerAccount];
    sender.enabled = YES;
}
- (IBAction)buttonPress:(UIButton*)sender{
    //高亮
    sender.backgroundColor =[UIColor colorWithRed:0/255.0f green:102/255.0f blue:255/255.0f alpha:1.0f];
    sender.titleLabel.textColor = [UIColor whiteColor];
}
- (void)buttonReleaseOutSide:(UIButton *)sender{
    sender.backgroundColor =[UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1.0f];
    sender.titleLabel.textColor = [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1.0f];
}
- (IBAction)dialNumber:(UIButton *)sender {
    sender.backgroundColor =[UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1.0f];
    sender.titleLabel.textColor = [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1.0f];
    if ([self.peerAccount.text length] >=13) {
        return;
    }
    NSString* currentDig = sender.titleLabel.text;
    AudioServicesPlaySystemSound([[self.touchToneMap valueForKey:currentDig] intValue]);
    NSMutableString* currentSequence =[self.peerAccount.text mutableCopy];
    [currentSequence appendString:currentDig];
    self.peerAccount.text = [currentSequence copy];


    if ([self.peerAccount.text length] > 0) {
        self.backspaceButton.hidden = NO;
        self.backButton.hidden=YES;
        self.dialBackGroundView.backgroundColor = [UIColor colorWithRed:0.267 green:0.643 blue:0.859 alpha:1];
    }else{
        self.backspaceButton.hidden = YES;
        self.backButton.hidden=NO;
    }
    // 从itelAction接口查询出符合条件的itelUser
    self.currentSuggestDataSource =  [[[ItelAction action] searchInFirendBook:self.peerAccount.text] mutableCopy];
    [self setupSuggestView];
    //显示建议面板
    if (!self.showSuggest) {
        [UIView animateWithDuration:.1 delay:.2 options:UIViewAnimationCurveEaseInOut animations:^{
            self.suggestBtnView.center = CGPointMake(self.suggestBtnView.center.x, self.suggestBtnView.center.y-self.suggestBtnView.bounds.size.height);
        } completion:nil];
        self.showSuggest = YES;
    }
}
- (void) setupSuggestView{
    //把其中的第一条数据放到建议面板
    [self.addFailureView removeFromSuperview];
    UIImageView* suggestClosestPeerAvatar = (UIImageView*) [self.suggestBtnView viewWithTag:1];
    UILabel* suggestClosestPeerNameLabel = (UILabel*) [self.suggestBtnView viewWithTag:2];
    UILabel* suggestClosestPeerItelNumber = (UILabel*) [self.suggestBtnView viewWithTag:3];
    UIButton* suggestExpandBtn = (UIButton*) [self.suggestBtnView viewWithTag:5];
    UILabel* itelTag = (UILabel*) [self.suggestBtnView viewWithTag:4];
    if ([self.currentSuggestDataSource count]) {
        [self.addView removeFromSuperview];
        ItelUser* firstSuggestUser = [self.currentSuggestDataSource firstObject];
        [suggestClosestPeerAvatar setImageWithURL:[NSURL URLWithString:firstSuggestUser.imageurl] placeholderImage:[UIImage imageNamed:@"standedHeader"]];
        [suggestClosestPeerNameLabel setText:firstSuggestUser.nickName];
        if ([firstSuggestUser.nickName isEqualToString:BLANK_STRING]) {
            [suggestClosestPeerNameLabel setText:firstSuggestUser.itelNum];
        }
        [suggestClosestPeerItelNumber setText:firstSuggestUser.itelNum];
        [suggestExpandBtn setTitle:[NSString stringWithFormat:@"%d",[self.currentSuggestDataSource count]] forState:UIControlStateNormal];
        [suggestExpandBtn setHidden:NO];
        itelTag.hidden = NO;
    }else{
        [suggestClosestPeerAvatar setImage:nil];
        [suggestClosestPeerItelNumber setText:nil];
        [suggestClosestPeerNameLabel setText:nil];
        itelTag.hidden = YES;
        [suggestExpandBtn setTitle:@"0" forState:UIControlStateNormal];
        [suggestExpandBtn setHidden:YES];
        [self.suggestBtnView addSubview:self.addView];
        
    }
}
- (IBAction)backspace:(UIButton *)sender {
    NSInteger length = [self.peerAccount.text length];
    if (length == 1) {
        self.backspaceButton.hidden = YES;
        self.backButton.hidden=NO;
        
        self.dialBackGroundView.backgroundColor = [UIColor whiteColor];
        if (self.showSuggest) {
            [UIView animateWithDuration:.1 delay:.1 options:UIViewAnimationCurveEaseInOut animations:^{
                self.suggestBtnView.center = CGPointMake(self.suggestBtnView.center.x, self.suggestBtnView.center.y+self.suggestBtnView.bounds.size.height);
            } completion:nil];
            self.showSuggest = NO;
        }
        if (self.hidePan) {
            [UIView animateWithDuration:.1 delay:.1 options:UIViewAnimationCurveEaseInOut animations:^{
                self.dialPanView.center = CGPointMake(self.dialPanView.center.x, self.dialPanView.center.y-self.dialPanView.bounds.size.height);
                self.suggestBtnView.center = CGPointMake(self.suggestBtnView.center.x, self.suggestBtnView.center.y-self.dialPanView.bounds.size.height);
                self.searchResultView.hidden = YES;
            } completion:nil];
            self.hidePan = NO;
        }
        
    }
    if (length>=1 ) {
        
    
    NSString* temp = [self.peerAccount.text substringToIndex:length-1];
    self.peerAccount.text = temp;
    // 从itelAction接口查询出符合条件的itelUser
    self.currentSuggestDataSource =  [[[ItelAction action] searchInFirendBook:self.peerAccount.text] mutableCopy];
    [self setupSuggestView];
    }
}

- (IBAction)showRecentContactList:(UIButton *)sender {
    [self.manager dismissDialRelatedPanel];
}
- (IBAction)autoFill:(UIButton *)sender {
    //如果有筛选结果
    UILabel* primityNumber =(UILabel*) [self.suggestBtnView viewWithTag:3];
    if (primityNumber.text) {
        self.peerAccount.text = primityNumber.text;
    }
}

- (IBAction)expandSuggestResults:(UIButton *)sender {
    if (self.showSuggest) {
        [UIView animateWithDuration:.1 delay:.2 options:UIViewAnimationCurveEaseInOut animations:^{
            self.suggestBtnView.center = CGPointMake(self.suggestBtnView.center.x, self.suggestBtnView.center.y+ self.suggestBtnView.bounds.size.height);
        } completion:^(BOOL hideSuggestFinished){
            if (hideSuggestFinished && !self.hidePan) {
                [UIView animateWithDuration:.1 delay:.2 options:UIViewAnimationCurveEaseInOut animations:^{
                    self.dialPanView.center = CGPointMake(self.dialPanView.center.x, self.dialPanView.center.y+self.dialPanView.bounds.size.height);
                    self.suggestBtnView.center = CGPointMake(self.suggestBtnView.center.x, self.suggestBtnView.center.y+self.dialPanView.bounds.size.height);
                    self.searchResultView.hidden = NO;
                } completion:^(BOOL finished) {
                    if (finished) {
                        [self.searchResultView reloadData];
                    }
                }];
                self.hidePan = YES;
            }
        }];
        self.showSuggest = NO;
    }


}
@end

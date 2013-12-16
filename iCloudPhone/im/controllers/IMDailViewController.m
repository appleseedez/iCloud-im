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
#import "ItelUser.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
@interface IMDailViewController ()
@property(nonatomic) NSDictionary* touchToneMap; //按键的拨号音，系统默认就有的
@property(nonatomic) BOOL hidePan;// 标识出当前拨号盘是否可见。
@property(nonatomic) BOOL showSuggest; //标识当前是否显示建议面板

@property(nonatomic) NSMutableArray* currentSuggestDataSource; //用于接收近似的itel号码
@end

@implementation IMDailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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


}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (![self.peerAccount.text length]) {
        self.backspaceButton.hidden = YES;
    }else{
        self.backspaceButton.hidden = NO;
    }
    [self setup];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self tearDown];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)voiceDialing:(UIButton *)sender {
    NSString* peerAccount = self.peerAccount.text;
    if (!peerAccount) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PRESENT_CALLING_VIEW_NOTIFICATION object:nil userInfo:@{
                                                                                                                       SESSION_INIT_REQ_FIELD_DEST_ACCOUNT_KEY:peerAccount,
                                                                                                                       SESSION_INIT_REQ_FIELD_SRC_ACCOUNT_KEY:[self.manager myAccount]
                                                                                                                       }];
    [self.manager dial:peerAccount];
    
}
- (void) setup{
    [self registerNotifications];
    self.suggestBtnView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.suggestBtnView.layer.borderWidth = .5;
    self.searchResultView.hidden = YES;
    self.selfAccountLabel.text = [NSString stringWithFormat:@"本机号码：%@", [self.manager myAccount]];
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
    /**
     *  test
     */
    ItelUser* userItem = self.currentSuggestDataSource[indexPath.row];
    cell.nameLabel.text = userItem.nickName;
    cell.numberLabel.text = userItem.itelNum;
    [cell.avatarView setImageWithURL:[NSURL URLWithString:@"http://img3.douban.com/icon/ul4659739-9.jpg"] placeholderImage:[UIImage imageNamed:@"peerAvatar"]];
    
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
    [[NSNotificationCenter defaultCenter] postNotificationName:PRESENT_CALLING_VIEW_NOTIFICATION object:nil userInfo:nil];
}
- (IBAction)dialNumber:(UIButton *)sender {
    if ([self.peerAccount.text length] >=13) {
        return;
    }
    NSString* currentDig = sender.titleLabel.text;
    AudioServicesPlaySystemSound([[self.touchToneMap valueForKey:currentDig] intValue]);
    NSMutableString* currentSequence =[self.peerAccount.text mutableCopy];
    [currentSequence appendString:currentDig];
    self.peerAccount.text = [currentSequence copy];
    // 从itelAction接口查询出符合条件的itelUser
    self.currentSuggestDataSource =  [[[ItelAction action] searchInFirendBook:self.peerAccount.text] mutableCopy];
    if ([self.peerAccount.text length] > 0) {
        self.backspaceButton.hidden = NO;
    }else{
        self.backspaceButton.hidden = YES;
    }
    
    if (!self.showSuggest) {
        [UIView animateWithDuration:.3 delay:.2 options:UIViewAnimationCurveEaseInOut animations:^{
            self.suggestBtnView.center = CGPointMake(self.suggestBtnView.center.x, self.suggestBtnView.center.y-self.suggestBtnView.bounds.size.height);
        } completion:nil];
        self.showSuggest = YES;
    }


}

- (IBAction)backspace:(UIButton *)sender {
    NSInteger length = [self.peerAccount.text length];
    if (length == 1) {
        self.backspaceButton.hidden = YES;
        if (self.showSuggest) {
            [UIView animateWithDuration:.3 delay:.2 options:UIViewAnimationCurveEaseInOut animations:^{
                self.suggestBtnView.center = CGPointMake(self.suggestBtnView.center.x, self.suggestBtnView.center.y+self.suggestBtnView.bounds.size.height);
            } completion:nil];
            self.showSuggest = NO;
        }
        if (self.hidePan) {
            [UIView animateWithDuration:.3 delay:.2 options:UIViewAnimationCurveEaseInOut animations:^{
                self.dialPanView.center = CGPointMake(self.dialPanView.center.x, self.dialPanView.center.y-self.dialPanView.bounds.size.height);
                self.suggestBtnView.center = CGPointMake(self.suggestBtnView.center.x, self.suggestBtnView.center.y-self.dialPanView.bounds.size.height);
                self.searchResultView.hidden = YES;
            } completion:nil];
            self.hidePan = NO;
        }
        
    }
    NSString* temp = [self.peerAccount.text substringToIndex:length-1];
    self.peerAccount.text = temp;
}

- (IBAction)showRecentContactList:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)autoFill:(UIButton *)sender {
}

- (IBAction)expandSuggestResults:(UIButton *)sender {
    if (self.showSuggest) {
        [UIView animateWithDuration:.3 delay:.2 options:UIViewAnimationCurveEaseInOut animations:^{
            self.suggestBtnView.center = CGPointMake(self.suggestBtnView.center.x, self.suggestBtnView.center.y+ self.suggestBtnView.bounds.size.height);
        } completion:^(BOOL hideSuggestFinished){
            if (hideSuggestFinished && !self.hidePan) {
                [UIView animateWithDuration:.3 delay:.2 options:UIViewAnimationCurveEaseInOut animations:^{
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

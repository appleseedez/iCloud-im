//
//  IMDailViewController.h
//  im
//
//  Created by Pharaoh on 13-11-26.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMManager.h"
@interface IMDailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
- (IBAction)voiceDialing:(UIButton *)sender;
- (IBAction)videoDialing:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *backspaceButton;
@property (weak, nonatomic) IBOutlet UILabel *peerAccount;
- (IBAction)dialNumber:(UIButton *)sender;
- (IBAction)buttonReleaseOutSide:(UIButton*)sender;
- (IBAction)buttonPress:(UIButton*)sender;
- (IBAction)backspace:(UIButton *)sender;
- (IBAction)showRecentContactList:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *dialBackGroundView;
@property (weak, nonatomic) IBOutlet UILabel *selfAccountLabel;
@property (weak,nonatomic) id<IMManager> manager;
@property (weak, nonatomic) IBOutlet UITableView *searchResultView;
@property (weak, nonatomic) IBOutlet UIView *suggestBtnView;
@property (weak, nonatomic) IBOutlet UIView *dialPanView;
- (IBAction)autoFill:(UIButton *)sender;
- (IBAction)expandSuggestResults:(UIButton *)sender;
@property (nonatomic,copy)NSString *directNumber;
@end

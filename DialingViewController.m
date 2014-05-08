//
//  DialingViewController.m
//  DIalViewSence
//
//  Created by nsc on 14-4-23.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "DialingViewController.h"
#import "DialNumberButton.h"
#import "DialTableViewModel.h"
@interface DialingViewController ()
@property (nonatomic) DialTableViewModel *tableModel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *numPanView;
@property (weak, nonatomic) IBOutlet UIButton *btnBackSpace;
@property (weak, nonatomic) IBOutlet UILabel *lbNumPan;
@property (nonatomic,strong) RACSubject *padButtonPressed;
@property (weak, nonatomic) IBOutlet UIButton *btnExit;
@property (weak, nonatomic) IBOutlet UIView *sugestResultView;
@property (weak, nonatomic) IBOutlet UIView *suggestAddView;
@property (weak, nonatomic) IBOutlet UIView *suggestNoneView;
@property (nonatomic,strong) NSString *dialNumber;
@property (weak, nonatomic) IBOutlet UILabel *lbSuggestResultNickname;
@property (weak, nonatomic) IBOutlet UILabel *lbSuggestResultItel;
@property (weak, nonatomic) IBOutlet UIButton *btnSuggestMore;
@property (weak, nonatomic) IBOutlet UIImageView *suggestResultImage;
@property (weak, nonatomic) IBOutlet UIButton *btnSuggest1;
- (IBAction)btnAddUser:(UIButton *)sender;
@property (atomic,strong) NSNumber *suggestViewType;
@end

@implementation DialingViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableModel=[DialTableViewModel new];
    self.tableView.delegate=self.tableModel;
    self.tableView.dataSource=self.tableModel;
    self.tableModel.tableViewhidden=@(YES);
    self.padButtonPressed = [RACSubject subject];
    self.dialNumber=@"";
    self.tableModel.selectedSuggestNumber=@"";
    self.suggestViewType=@(suggestViewTypeEmpty);
    [self.view bringSubviewToFront:self.tableView];
    //监听 隐藏 显示tableView
    [RACObserve(self, tableModel.tableViewhidden) subscribeNext:^(NSNumber *  x) {
        BOOL hidden=[x boolValue];
        self.tableView.alpha=!hidden;
    }];
    //自动更新tableView
    [RACObserve(self, tableModel.datasource) subscribeNext:^(id x) {
        [self.tableView reloadData];
    }];
    
    
    //显示 隐藏数字label
    RACSignal *dialNumberOb=RACObserve(self, dialNumber);
    [dialNumberOb subscribeNext:^(NSString *x) {
       self.lbNumPan.text=x;
       if (x.length==0) {
           self.numPanView.alpha=0;
           self.suggestViewType=@(suggestViewTypeEmpty);
           
       }else {
           self.numPanView.alpha=1;
           [self.tableModel searchSuggest:x];
           
        }
       self.btnExit.alpha=!self.numPanView.alpha;
        
   }];
    //数字键被按了
    [self.padButtonPressed subscribeNext:^(NSString *x) {
        if (self.dialNumber.length<13) {
            self.dialNumber =[NSString stringWithFormat:@"%@%@",self.dialNumber,x];
        }
        
    }];
    //backspace被按了
    [[self.btnBackSpace rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSRange range;
        range.location=0;
        range.length=self.dialNumber.length-1;
        NSString *last=[self.dialNumber substringWithRange:range];
        self.dialNumber=last;
    }];
    //添加长按手势
    UILongPressGestureRecognizer *longPressrd=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressed:)];
    [self.btnBackSpace addGestureRecognizer:longPressrd];
    
    //绑定suggestView
    [RACObserve(self, suggestViewType) subscribeNext:^(NSNumber *x) {
        suggestViewType type=[x integerValue];
        switch (type) {
            case suggestViewTypeEmpty:{
                self.sugestResultView.alpha=0;
                self.suggestAddView.alpha=0;
                self.suggestNoneView.alpha=0;
            }
                
                break;
            case suggestViewTypeNone:{
                self.sugestResultView.alpha=0;
                self.suggestAddView.alpha=0;
                self.suggestNoneView.alpha=1;
            }
                
                break;
            case suggestViewTypeAdd:{
                self.sugestResultView.alpha=0;
                self.suggestAddView.alpha=1;
                self.suggestNoneView.alpha=0;
            }
                
                break;
            case suggestViewTypeResult:{
                self.sugestResultView.alpha=1;
                self.suggestAddView.alpha=0;
                self.suggestNoneView.alpha=0;
            }
                
                break;
                
            default:
                break;
        }
    }];
    //设定suggestView
     [[RACSignal combineLatest:@[dialNumberOb ,RACObserve(self, tableModel.datasource)]] subscribeNext:^(RACTuple *x) {
         NSString *dialNumber=[x objectAtIndex:0];
         NSArray *suggestResult=[x objectAtIndex:1];
         BOOL result=NO;
         
         if ([suggestResult isEqual:[NSNull null]]) {
             result =NO;
         }else if([suggestResult count]){
             result=YES;
         }
         if (result) {
            self.suggestViewType=@(suggestViewTypeResult);
             id user=suggestResult[0];
             NSInteger count=[suggestResult count];
            //这里需要设置resultView
             [self.btnSuggestMore setTitle:[NSString stringWithFormat:@"%ld",(long)count] forState:UIControlStateNormal];
             self.suggestResultImage.image=[user objectForKey:@"image"];
             self.lbSuggestResultNickname.text=[user objectForKey:@"nickname"];
             self.lbSuggestResultItel.text=[user objectForKey:@"itel"];
             
             
         }else{
             self.tableModel.tableViewhidden=@(YES);
             if (dialNumber.length>=3) {
                 self.suggestViewType=@(suggestViewTypeAdd);
             }else if(dialNumber.length<3&&dialNumber.length>0){
                 self.suggestViewType=@(suggestViewTypeEmpty);
             }
         }
         
     }];
    
    //判断suggest添加失败还是成功
         [RACObserve(self, tableModel.addFail) subscribeNext:^(NSNumber *x) {
             BOOL isAddFail= [x boolValue];
             if (isAddFail) {
                 self.suggestViewType=@(suggestViewTypeNone);
             }
         }];
    
    //显示tableView
      [[self.btnSuggestMore rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
          self.tableModel.tableViewhidden=@(NO);
      }];
    //绑定选中建议号码
      [RACObserve(self, tableModel.selectedSuggestNumber) subscribeNext:^(NSString *x) {
          if (x.length>0) {
              self.dialNumber=x;
          }
      }];
    //建议View
    
    [[self.btnSuggest1 rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        if (![self.dialNumber isEqualToString: self.lbSuggestResultItel.text]) {
            self.dialNumber=self.lbSuggestResultItel.text ;
        }
    }];
}
- (IBAction)padButton:(UIButton *)sender {
    
    NSString *num= sender.titleLabel.text;
   // NSLog(@"%@",num);
    [self.padButtonPressed sendNext:num];
}
-(void)longPressed:(id)sender{
    self.dialNumber=@"";
}
- (IBAction)btnAddUser:(UIButton *)sender {
    [self.tableModel addUser:self.dialNumber];
}
//隐藏拨号盘
- (IBAction)hidePan:(id)sender {
    [self.viewModel hideDialingSessionView];
}
//语音拨打
- (IBAction)voiceDial:(id)sender {
    [self.viewModel dial:self.dialNumber useVideo:NO];
}
// 视频拨打
- (IBAction)videoDial:(id)sender {
    [self.viewModel dial:self.dialNumber useVideo:YES];
}
@end

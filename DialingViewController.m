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
    
    __weak id weakSelf=self;
    //监听 隐藏 显示tableView
    [RACObserve(self, tableModel.tableViewhidden) subscribeNext:^(NSNumber *  x) {
        __strong DialingViewController *strongSelf=weakSelf;
        BOOL hidden=[x boolValue];
        strongSelf.tableView.alpha=!hidden;
    }];
    //自动更新tableView
    [RACObserve(self, tableModel.datasource) subscribeNext:^(id x) {
        __strong DialingViewController *strongSelf=weakSelf;

        [strongSelf.tableView reloadData];
    }];
    
    
    //显示 隐藏数字label
    RACSignal *dialNumberOb=RACObserve(self, dialNumber);
    [dialNumberOb subscribeNext:^(NSString *x) {
        __strong DialingViewController *strongSelf=weakSelf;

       strongSelf.lbNumPan.text=x;
       if (x.length==0) {
           strongSelf.numPanView.alpha=0;
           strongSelf.suggestViewType=@(suggestViewTypeEmpty);
           
       }else {
           strongSelf.numPanView.alpha=1;
           [strongSelf.tableModel searchSuggest:x];
           
        }
       strongSelf.btnExit.alpha=!strongSelf.numPanView.alpha;
        
   }];
    //数字键被按了
    [self.padButtonPressed subscribeNext:^(NSString *x) {
        __strong DialingViewController *strongSelf=weakSelf;

        if (strongSelf.dialNumber.length<13) {
            strongSelf.dialNumber =[NSString stringWithFormat:@"%@%@",strongSelf.dialNumber,x];
        }
        
    }];
    //backspace被按了
    [[self.btnBackSpace rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        __strong DialingViewController *strongSelf=weakSelf;

        NSRange range;
        range.location=0;
        range.length=strongSelf.dialNumber.length-1;
        NSString *last=[strongSelf.dialNumber substringWithRange:range];
        strongSelf.dialNumber=last;
    }];
    //添加长按手势
    UILongPressGestureRecognizer *longPressrd=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressed:)];
    [self.btnBackSpace addGestureRecognizer:longPressrd];
    
    //绑定suggestView
    [RACObserve(self, suggestViewType) subscribeNext:^(NSNumber *x) {
        __strong DialingViewController *strongSelf=weakSelf;

        NSInteger type=[x integerValue];
        switch (type) {
            case suggestViewTypeEmpty:{
                strongSelf.sugestResultView.alpha=0;
                strongSelf.suggestAddView.alpha=0;
                strongSelf.suggestNoneView.alpha=0;
            }
                
                break;
            case suggestViewTypeNone:{
                strongSelf.sugestResultView.alpha=0;
                strongSelf.suggestAddView.alpha=0;
                strongSelf.suggestNoneView.alpha=1;
            }
                
                break;
            case suggestViewTypeAdd:{
                strongSelf.sugestResultView.alpha=0;
                strongSelf.suggestAddView.alpha=1;
                strongSelf.suggestNoneView.alpha=0;
            }
                
                break;
            case suggestViewTypeResult:{
                strongSelf.sugestResultView.alpha=1;
                strongSelf.suggestAddView.alpha=0;
                strongSelf.suggestNoneView.alpha=0;
            }
                
                break;
                
            default:
                break;
        }
    }];
    //设定suggestView
     [[RACSignal combineLatest:@[dialNumberOb ,RACObserve(self, tableModel.datasource)]] subscribeNext:^(RACTuple *x) {
         __strong DialingViewController *strongSelf=weakSelf;

         NSString *dialNumber=[x objectAtIndex:0];
         NSArray *suggestResult=[x objectAtIndex:1];
         BOOL result=NO;
         
         if ([suggestResult isEqual:[NSNull null]]) {
             result =NO;
         }else if([suggestResult count]){
             result=YES;
         }
         if (result) {
             
            strongSelf.suggestViewType=@(suggestViewTypeResult);
             id user=suggestResult[0];
             NSInteger count=[suggestResult count];
            //这里需要设置resultView
             [strongSelf.btnSuggestMore setTitle:[NSString stringWithFormat:@"%ld",(long)count] forState:UIControlStateNormal];
             strongSelf.suggestResultImage.image=[user objectForKey:@"image"];
             strongSelf.lbSuggestResultNickname.text=[user objectForKey:@"nickname"];
             strongSelf.lbSuggestResultItel.text=[user objectForKey:@"itel"];
             
             
         }else{
             strongSelf.tableModel.tableViewhidden=@(YES);
             if (dialNumber.length>=3) {
                 strongSelf.suggestViewType=@(suggestViewTypeAdd);
             }else if(dialNumber.length<3&&dialNumber.length>0){
                 strongSelf.suggestViewType=@(suggestViewTypeEmpty);
             }
         }
         
     }];
    
    //判断suggest添加失败还是成功
         [RACObserve(self, tableModel.addFail) subscribeNext:^(NSNumber *x) {
             __strong DialingViewController *strongSelf=weakSelf;

             BOOL isAddFail= [x boolValue];
             if (isAddFail) {
                 strongSelf.suggestViewType=@(suggestViewTypeNone);
             }
         }];
    
    //显示tableView
      [[self.btnSuggestMore rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
          __strong DialingViewController *strongSelf=weakSelf;

          strongSelf.tableModel.tableViewhidden=@(NO);
      }];
    //绑定选中建议号码
      [RACObserve(self, tableModel.selectedSuggestNumber) subscribeNext:^(NSString *x) {
          __strong DialingViewController *strongSelf=weakSelf;

          if (x.length>0) {
              strongSelf.dialNumber=x;
          }
      }];
    //建议View
    
    [[self.btnSuggest1 rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        __strong DialingViewController *strongSelf=weakSelf;

        if (![strongSelf.dialNumber isEqualToString: strongSelf.lbSuggestResultItel.text]) {
            strongSelf.dialNumber=strongSelf.lbSuggestResultItel.text ;
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
-(void)dealloc{
    NSLog(@"%@被销毁",self);
}
@end

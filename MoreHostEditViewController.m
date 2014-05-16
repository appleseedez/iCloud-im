//
//  MoreHostEditViewController.m
//  itelNSC
//
//  Created by nsc on 14-5-15.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MoreHostEditViewController.h"
#import "MoreViewModel.h"
@interface MoreHostEditViewController ()

@property (weak, nonatomic) IBOutlet UITextField *txtEdit;
@end

@implementation MoreHostEditViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.txtEdit.delegate=self;
    [self.txtEdit setPlaceholder:self.placeHolder];
    [self setTitle:self.titleText];
    [self.txtEdit setKeyboardType:self.keyboardType];
    self.txtEdit.text=self.oldValue;
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(finishButtonClicked)];
}
-(void)finishButtonClicked{
    [self.moreViewModel modifyHoseSetting:self.key value:self.txtEdit.text];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.txtEdit becomeFirstResponder];
   
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (string.length>0) {
        if (textField.text.length+string.length>self.limitInput) {
            return NO;
        }
    }
    return YES;
}

@end

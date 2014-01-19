//
//  HostEditSignViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-19.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "HostEditSignViewController.h"
#import "ItelAction.h"
@interface HostEditSignViewController ()

@property (weak, nonatomic) IBOutlet UITextView *signEditView;

@end

@implementation HostEditSignViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(finishButtonClicked)];
    self.signEditView.delegate=self;
}
-(void)finishButtonClicked{
//     NSString * encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)(self.signEditView.text), NULL, NULL,  kCFStringEncodingUTF8 ));
    [[ItelAction action] modifyPersonal:@"recommend" forValue:self.signEditView.text];
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.signEditView becomeFirstResponder];
    self.signEditView.text=[[ItelAction action]getHost].personalitySignature ;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (range.location>=50) {
        return NO;
    }
    else return YES;
    }
@end

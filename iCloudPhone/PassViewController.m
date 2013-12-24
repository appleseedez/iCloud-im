//
//  PassViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-21.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "PassViewController.h"
#import "RegNextButton.h"
@interface PassViewController ()
@property (weak, nonatomic) IBOutlet RegNextButton *nextButton;

@end

@implementation PassViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.nextButton setUI];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"登陆" style:UIBarButtonItemStyleDone target:self action:@selector(pop)];
	// Do any additional setup after loading the view.
}
-(IBAction)pushNext:(id)sender{
    
    
}

-(void)pop{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end

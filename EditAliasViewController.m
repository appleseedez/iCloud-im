//
//  EditAliasViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-11-26.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "EditAliasViewController.h"
#import "ContactUserViewModel.h"
@interface EditAliasViewController ()

@end

@implementation EditAliasViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.txtEditAlias becomeFirstResponder];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
	// Do any additional setup after loading the view.
}
-(void)cancel{
    [self dismissViewControllerAnimated:YES completion:^{
          
    }];
}

- (IBAction)didEnd:(UITextField *)sender {
    
   
    
    [self dismissViewControllerAnimated:YES completion:^{
             //这里编辑备注
        [self.userViewModel editAlias:self.txtEditAlias.text];
    }];
    
    
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.txtEditAlias resignFirstResponder];
    
}


@end

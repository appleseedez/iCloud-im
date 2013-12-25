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
@property (weak, nonatomic) IBOutlet UIImageView *codeImage;

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
    NSString *strurl=@"http://10.0.0.150:8080/CloudCommunity/printImage";
    
    NSURL *url  =[NSURL URLWithString:strurl];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    
    NSOperationQueue *queue=[[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"%@",connectionError);
        }
        else{
            UIImage *image=[UIImage imageWithData:data];
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.codeImage.image=image;
             });
        }
        
    }];
    
    
}

-(void)pop{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end

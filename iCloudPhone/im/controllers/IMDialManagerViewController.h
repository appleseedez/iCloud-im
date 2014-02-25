//
//  IMDialPanelViewController.h
//  iCloudPhone
//
//  Created by Pharaoh on 2/21/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMManager.h"
@interface IMDialManagerViewController : UIViewController
@property(nonatomic,weak) id<IMManager> manager;
@end

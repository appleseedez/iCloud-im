//
//  CustomTabbar.m
//  iCloudPhone
//
//  Created by nsc on 13-11-28.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "CustomTabbar.h"
#import "CustonTarbarItem.h"



#define WINSIZE [UIScreen mainScreen].bounds.size
#define SHADOW_WIDTH 0.5
@implementation CustomTabbar
static float width=62.5;
-(NSMutableArray*)items{
    if (_items==nil) {
        _items=[[NSMutableArray alloc]init];
    }
    return _items;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        UIColor *tabBackColor=[UIColor colorWithRed:0.93333 green:0.93333 blue:0.93333 alpha:0.93333];
        CALayer *upsetShadow=[CALayer layer];
        upsetShadow.frame=CGRectMake(0, SHADOW_WIDTH, 320, SHADOW_WIDTH);
        upsetShadow.backgroundColor=[UIColor grayColor].CGColor;
        self.backgroundColor=tabBackColor;
        [self.layer addSublayer:upsetShadow];

        CustonTarbarItem *itel=[[CustonTarbarItem alloc]initWithFrame:CGRectMake(0, 0,  width, frame.size.height)];
 
        itel.cusImageView.frame=CGRectMake(17.5, 0, 27.5, 24);
        [self.items addObject:itel];
        [self addSubview:itel];
        itel.normalImage=[UIImage imageNamed:@"tab_1"];
        itel.selectedImage=[UIImage imageNamed:@"tab_1a"];
     

        CustonTarbarItem *contact=[[CustonTarbarItem alloc]initWithFrame:CGRectMake(width, 0,  width, frame.size.height)];
 
      
        
        contact.cusImageView.frame=CGRectMake(21, 0, 20.5, 24);
        [self.items addObject:contact];
        [self addSubview:contact];
        contact.normalImage=[UIImage imageNamed:@"tab_2"];
        contact.selectedImage=[UIImage imageNamed:@"tab_2a"];
        
        
        CustonTarbarItem *main=[[CustonTarbarItem alloc]initWithFrame:CGRectMake(120, -25,  70, 70)];
        [main setImageViewFrame:main.bounds];
        main.center=CGPointMake(WINSIZE.width/2, frame.size.height-70/2.0);
        main.normalImage=[UIImage imageNamed:@"tab_3"];
        main.selectedImage=[UIImage imageNamed:@"tab_3a"];
        
        [self.items addObject:main];
        [self addSubview:main];
        
        CustonTarbarItem *message=[[CustonTarbarItem alloc]initWithFrame:CGRectMake(320-width*2, 0,  width, frame.size.height)];
        [message setImageViewFrame:CGRectMake(0, 0, width, frame.size.height)];
       
        message.normalImage=[UIImage imageNamed:@"tab_4"];
        message.selectedImage=[UIImage imageNamed:@"tab_4a"];
        [self.items addObject:message];
        [self addSubview:message];
        message.cusImageView.frame=CGRectMake(19.75, 0, 24, 21);
        CustonTarbarItem *more=[[CustonTarbarItem alloc]initWithFrame:CGRectMake(320-width, 0,  width, frame.size.height)];
        [more setImageViewFrame:CGRectMake(0, 0, width, frame.size.height)];
        
        
        
        
        more.normalImage=[UIImage imageNamed:@"tab_5"];
        more.selectedImage=[UIImage imageNamed:@"tab_5a"];
        more.cusImageView.frame=CGRectMake(19.75, 0, 24, 6);
        
        [self.items addObject:more];
        [self addSubview:more];
        
         CGRect lbFrame=CGRectMake(0, 32, 62.5, 15);
        UIColor *textHigh=[UIColor colorWithRed:0.1216 green:0.3961 blue:1.00 alpha:1];
        UIColor *textNormal=[UIColor colorWithRed:0.4745 green:0.4745 blue:0.4745 alpha:1];
        NSArray *titles=@[@"拨号盘",@"通信录",@"",@"消息",@"更多"];
        for (CustonTarbarItem *item in self.items) {
            int i= [self.items indexOfObject:item];
            if (i!=2) {
                item.labelTextColorNormal=textNormal;
                item.labelTextColorHigh =textHigh;
                [item setLabelFrame:lbFrame];
                NSString *title=[titles objectAtIndex:i];
                [item setLabelTitle:title];
                [item.label setFont:[UIFont fontWithName:@"HeiTi SC" size:13]];
                [item.label setTextAlignment:NSTextAlignmentCenter];
                item.cusImageView.center=CGPointMake(item.cusImageView.center.x, item.center.y-(item.frame.size.height - item.label.frame.origin.y)/2.0);
            }
            
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

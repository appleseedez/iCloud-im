//
//  DialTableViewModel.h
//  DIalViewSence
//
//  Created by nsc on 14-4-29.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DialTableViewModel : NSObject <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic) NSArray *datasource;
@property (nonatomic) NSNumber *tableViewhidden;
@property (nonatomic) NSNumber *addFail;
@property (nonatomic) NSString *selectedSuggestNumber;//用户选中的提示号码

-(void)searchSuggest:(NSString*)itel;
-(void)addUser:(NSString*)itel;
@end

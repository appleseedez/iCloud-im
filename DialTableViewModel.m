//
//  DialTableViewModel.m
//  DIalViewSence
//
//  Created by nsc on 14-4-29.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "DialTableViewModel.h"
#import "DialTableViewCell.h"
@implementation DialTableViewModel
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.datasource count];
}



- (DialTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DialTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SuggestCellView"];
    [cell setPro:[self.datasource objectAtIndex:indexPath.row]];
    
    return cell;
}
-(void)searchSuggest:(NSString*)itel{
    self.addFail=@(NO);
    
    if ([itel isEqualToString:@"1234"]) {
        NSMutableArray *arr=[NSMutableArray new];
        for (int i=0; i<10; i++) {
            NSDictionary *user=@{@"itel": [NSString stringWithFormat:@"1234%d",i],@"nickname":[NSString stringWithFormat:@"流浪的猫%d",i],@"image":[UIImage imageNamed:@"mao"]};
            [arr addObject:user];
        }
        self.datasource= [arr copy];
        
    }else{
        self.datasource=[NSArray new];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedSuggestNumber=[[self.datasource objectAtIndex:indexPath.row] valueForKey:@"itel"];
    self.tableViewhidden=@(YES);
}
-(void)addUser:(NSString*)itel{
    NSLog(@"添加好友：%@",itel);
    self.addFail=@(YES);
}
@end

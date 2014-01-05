//
//  IMDBManager.h
//  iCloudPhone
//
//  Created by Pharaoh on 12/31/13.
//  Copyright (c) 2013 NX. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IMDBManager <NSObject>
- (void) createTable;
- (void) dumpDataWithDic:(NSDictionary*) dic intoTable:(NSString*) tableName;
@end

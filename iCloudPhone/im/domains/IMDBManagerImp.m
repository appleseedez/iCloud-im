//
//  IMDBManagerImp.m
//  iCloudPhone
//
//  Created by Pharaoh on 1/3/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import "IMDBManagerImp.h"
#import "FMDatabase.h"
#import "ConstantHeader.h"
@implementation IMDBManagerImp
- (id)init
{
    self = [super init];
    if (self) {
        self.dbDateFormatter = [[NSDateFormatter alloc] init];
        [self.dbDateFormatter setDateFormat:@"yyyy-MM-dd"];
        self.dbPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"rencent_contacts.db"];
        NSLog(@"沙盒位置:%@",self.dbPath);
    }
    return self;
}
- (void) createTable{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.dbPath] == NO) {
        FMDatabase* db = [FMDatabase databaseWithPath:self.dbPath];
        [db setDateFormat:self.dbDateFormatter];
        if ([db open]) {
            NSString* createTableSQL = @"CREATE TABLE 'recents' ('id' INTEGER PRIMARY KEY  NOT NULL , 'peer_nick' TEXT, 'peer_real_name' TEXT, 'peer_number' TEXT, 'peer_avatar' TEXT, 'create_date' DATETIME, 'duration' NUMERIC, 'start_time' DATETIME, 'status' TEXT)";
            [db executeUpdate:createTableSQL];
            [db close];
        }
    }
}

- (void) dumpDataWithDic:(NSDictionary*) dic intoTable:(NSString*) tableName{
    FMDatabase* db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        NSString* insterSQL =[NSString stringWithFormat:@"INSERT INTO %@ ( peer_nick,peer_real_name,peer_number,peer_avatar,create_date,duration,start_time,status ) VALUES (:peerNick,:peerRealName,:peerNumber,:peerAvatar,:createDate,:duration,:startTime,:status)",tableName ];
        [db executeUpdate:insterSQL withParameterDictionary:dic];
        [db close];
    }
}

@end

//
//  IMCoreDataManager+IMCoreDataManager_FMDB_TO_COREDATA.m
//  iCloudPhone
//
//  Created by nsc on 14-1-14.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "IMCoreDataManager+FMDB_TO_COREDATA.h"
#import "Area.h"
#import "FMDatabase.h"
@implementation IMCoreDataManager (FMDB_TO_COREDATA)

-(void)isAreaInCoreData{
   
    NSFetchRequest* areaRequest = [NSFetchRequest fetchRequestWithEntityName:@"Area"];
    areaRequest.predicate = [NSPredicate predicateWithFormat:@"areaId = %@",[NSNumber numberWithInt:1]];
    NSError *error=nil;
    NSArray* match = [[IMCoreDataManager defaulManager].managedObjectContext executeFetchRequest:areaRequest error:&error];
    if (![match count]) {
        [self insertAreaToCoreData];
    }
    
}

-(void)insertAreaToCoreData
{
    NSString *createSQL=@"SeLeCt * from area";
    NSString *dbPath=[[NSBundle mainBundle]pathForResource:@"area" ofType:@"sqlite"];
   
    FMDatabase *db=[FMDatabase databaseWithPath:dbPath];
   
     [db open];
    FMResultSet *result=[db executeQuery:createSQL];
  
    NSManagedObjectContext* currentContext = self.managedObjectContext;
   
    while (result.next) {
        Area *area=[NSEntityDescription insertNewObjectForEntityForName:@"Area" inManagedObjectContext:currentContext];
         area.areaId=[NSNumber numberWithInt: [result intForColumn:@"id"]];
        area.name=[result stringForColumn:@"name"];
        area.parentId=[NSNumber numberWithInt: [result intForColumn:@"parent_id"]];
        area.sequence=[result stringForColumn:@"sequence"];
        area.code=[result stringForColumn:@"code"];
        area.capital=[NSNumber numberWithInt: [result intForColumn:@"capital"]];
    }
    [self saveContext:currentContext];
    [db close];
    


}
@end

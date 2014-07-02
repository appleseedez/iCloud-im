//
//  DBService.m
//  itelNSC
//
//  Created by nsc on 14-5-10.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "DBService.h"
#import <FMDB/FMDB.h>
#import "Area+toString.h"
@implementation DBService
static DBService *instance;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
+(instancetype)defaultService{
    return instance;
}
+ (void)initialize
{
    if (self == [DBService class]) {
        static BOOL initialized=NO;
        if (initialized==NO) {
            instance=[[[self class] alloc]init];
            initialized=YES;
        }
    }
}
-(void)isAreaInCoreData{
    
    NSFetchRequest* areaRequest = [NSFetchRequest fetchRequestWithEntityName:@"Area"];
    areaRequest.predicate = [NSPredicate predicateWithFormat:@"areaId = %@",[NSNumber numberWithInt:1]];
    NSError *error=nil;
    NSArray* match = [[DBService defaultService].managedObjectContext executeFetchRequest:areaRequest error:&error];
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


- (void)saveContext:(NSManagedObjectContext*)context
{
    NSError *error = nil;
    if (context != nil) {
        if ([context hasChanges] && ![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void) deletObject:(NSManagedObject*) obj inContext:(NSManagedObjectContext*) context{
    if (context) {
        [context deleteObject:obj];
    }
    
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"itelDB" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"itel.sqlite"];
    BOOL firstRun = ![storeURL checkResourceIsReachableAndReturnError:NULL];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    
    if (firstRun) {
        //
        //
        //        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        //        [context setPersistentStoreCoordinator:_persistentStoreCoordinator];
        //
        //        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        //        [dateComponents setYear:2013];
        //
        //        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        //        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        //
        //        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        //        [dateFormatter setCalendar:calendar];
        //
        //        for (NSInteger day = 1; day < 365; day += 7)
        //        {
        //            [dateComponents setDay:day];
        //            NSDate *date = [calendar dateFromComponents:dateComponents];
        //
        //            Recent* test = [NSEntityDescription insertNewObjectForEntityForName:@"Recent" inManagedObjectContext:context];
        //            test.peerAvatar = @"peerAvatar";
        //            test.peerNick = @"appleseedez";
        //            test.peerNumber = @"123456";
        //            test.peerRealName = @"领域";
        //            test.createDate = date;
        //            test.status = @"called";
        //            Recent* test2 = [NSEntityDescription insertNewObjectForEntityForName:@"Recent" inManagedObjectContext:context];
        //            test2.peerAvatar = @"callerAvatar";
        //            test2.peerNick = @"Emma";
        //            test2.peerNumber = @"12345121416";
        //            test2.peerRealName = @"爱玛";
        //            test2.createDate = date;
        //            test2.status = @"missed";
        //        }
        //
        //        [context save:NULL];
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end

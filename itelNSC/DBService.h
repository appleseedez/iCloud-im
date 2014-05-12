//
//  DBService.h
//  itelNSC
//
//  Created by nsc on 14-5-10.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBService : NSObject
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext:(NSManagedObjectContext*) context;
- (void)deletObject:(NSManagedObject*) obj inContext:(NSManagedObjectContext*) context;
- (NSURL *)applicationDocumentsDirectory;
+(instancetype)defaultService;
@end

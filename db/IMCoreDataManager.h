//
//  IMCoreDataManager.h
//  iCloudPhone
//
//  Created by Pharaoh on 1/3/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext:(NSManagedObjectContext*) context;
- (void) deletObject:(NSManagedObject*) obj inContext:(NSManagedObjectContext*) context;
- (NSURL *)applicationDocumentsDirectory;
+ (instancetype) defaulManager;
@end

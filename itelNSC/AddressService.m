//
//  AddressService.m
//  itelNSC
//
//  Created by nsc on 14-5-13.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "AddressService.h"
#import <AddressBook/AddressBook.h>
#import "NXInputChecker.h"
#import "AddressUser.h"
#import "NXInputChecker.h"
#import "HTTPRequestBuilder+AddressBook.h"
#import "ItelUser+CRUD.h"
#import "DBService.h"
@implementation AddressService
static AddressService *instance;
+(AddressService*)defaultService{
    
    return instance;
}

+(void)initialize{
    static BOOL initialized=NO;
    if (initialized==NO) {
        instance=[[AddressService alloc]init];
        initialized=YES;
    }
}
-(void)loadItels{
    self.busy=@(YES);
    NSArray *phones=[self.addressList valueForKeyPath:@"phone"];
    NSString *strPhones=[NXInputChecker changeArrayToString:phones];
    NSDictionary *parameters=@{@"hostUserId":[self hostUserID], @"numbers":strPhones};
    
   [[self.requestBuilder loadAddressBook:parameters] subscribeNext:^(NSDictionary *x) {
       int code=[x[@"code"]intValue];
       if (code==200) {
           
           
               NSArray *arr=x[@"data"];
               NSManagedObjectContext *contex=[DBService defaultService].managedObjectContext;
          
               for (NSDictionary *dic in arr) {
                   
                   ItelUser *user=[ItelUser userWithDictionary:dic inContext:contex];
                   for (AddressUser *addressUser in self.addressList) {
                       if ([addressUser.phone isEqualToString:user.telNum]) {
                           addressUser.user=user;
                       }
                   }
                   
               }
           

           
          
       }
   }error:^(NSError *error) {
       self.busy=@(NO);
   }completed:^{
       self.busy=@(NO);
   }];
    
}
-(void)loadAddressBook{
    //监听 通讯录
    
    
    
    
    CFErrorRef error=NULL;
    ABAddressBookRef addressBook=ABAddressBookCreateWithOptions(NULL, &error);
    
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if (version>=7.0) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (error) {
                NSLog(@"%@",error);
            }
            else if(granted){
                self.isLoading=@(YES);
                [self getPeopleInAddressBook];
            }else{
                self.isLoading = @(NO);
                return;
            }
            
        });
    }
    else {
        self.isLoading=@(YES);
        [self getPeopleInAddressBook];
    }
    if (addressBook!=NULL) {
        CFRelease(addressBook);
    }
    
}


-(void)getPeopleInAddressBook{
    CFErrorRef error=NULL;
    
    
    
    ABAddressBookRef addressBook=ABAddressBookCreateWithOptions(NULL, &error);
    CFArrayRef arrayRef= ABAddressBookCopyArrayOfAllPeople(addressBook)   ;
    NSMutableArray *arr=[[NSMutableArray alloc]init];
    NSArray *array=(NSArray*)CFBridgingRelease(arrayRef);
    for (id person in array)
    {
        
        NSString *firstName = (NSString *)CFBridgingRelease(ABRecordCopyValue(CFBridgingRetain(person), kABPersonFirstNameProperty));
        firstName = [firstName stringByAppendingFormat:@" "];
        NSString *lastName = (NSString *)CFBridgingRelease(ABRecordCopyValue(CFBridgingRetain(person), kABPersonLastNameProperty));
        if (lastName==nil) {
            lastName=@"";
        }
        NSString *fullName = [NSString stringWithFormat:@"%@%@",lastName,firstName];
        //NSLog(@"%@",fullName);
        
        ABMultiValueRef phones = (ABMultiValueRef) ABRecordCopyValue(CFBridgingRetain(person), kABPersonPhoneProperty);
        
        for(int i = 0 ;i < ABMultiValueGetCount(phones); i++)
        {
            
            NSString *phone = (NSString *)CFBridgingRelease(ABMultiValueCopyValueAtIndex(phones, i));
            
           
            NSString *mobilePhone=[NXInputChecker resetPhoneNumber11:phone];
            if ([NXInputChecker checkPhoneNumberIsMobile:mobilePhone]) {
               
                
                
                AddressUser *user=[AddressUser new];
                user.name=fullName;
                user.phone=mobilePhone;
                [arr addObject:user];
                // NSLog(@"%@:%@",p.name,p.tel);
            }
            
        }
       
        
        
        
        
    }
     self.addressList=[arr copy];
    [self loadItels];
    self.isLoading=@(NO);
    
  
    
    
}

@end

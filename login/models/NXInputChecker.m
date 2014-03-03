//
//  NXInputChecker.m
//  social
//
//  Created by nsc on 13-11-5.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import "NXInputChecker.h"
#import "NSString+MD5.h"
@implementation NXInputChecker
+(BOOL)checkCloudNumber:(NSString*)cloudNumber{
   //非空检测
    if (![NXInputChecker checkEmpty:cloudNumber]) {
        return NO;
    }
    
    //云号码 首位非0检测
    int firstNum=[[cloudNumber substringWithRange:NSMakeRange(0, 1)] intValue];
    if (firstNum==0) {
        return NO;
    }
     //云号码位数检测（11位）
    NSUInteger length=[cloudNumber length];
    if ((length>11)) {
        return NO;
    }
    
    return YES;
}


+(BOOL)checkPassword:(NSString*)password{
    //非空检测
    if (![NXInputChecker checkEmpty:password]) {
        return NO;
    }
    
    
    NSUInteger passLength=[password length];
    if (passLength<6) {
        return NO;
    }
    
    
    return YES;
}
+(BOOL)checkEmail:(NSString *)email

{
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    
    return [emailTest evaluateWithObject:email];
    
}
//非空检测
+(BOOL)checkEmpty:(NSString *)string{
    if (string==nil) {
        return NO;
    }
//    NSString *filteEmpty = [NXInputChecker filterStringWithString:string targetString:@" " replaceWithString:@""];
//    if ([filteEmpty isEqualToString:@""]||[filteEmpty isEqualToString:@" "]||[filteEmpty isEqualToString:@"  "]||[filteEmpty isEqualToString:@"   "]) {
//        return NO;
//    }
//    return YES;
  
    
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    
    NSArray *parts = [string componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    string = [filteredArray componentsJoinedByString:@""];
    return string.length;
}
#pragma mark - 字符串过滤
+(NSString *)filterStringWithString:(NSString*)string targetString:(NSString*)targetString replaceWithString:(NSString*)newString{
    NSMutableString *oldStr=[string mutableCopy];
    NSUInteger lenth=[targetString length];
    NSInteger count=[oldStr length]-lenth;
    for (int i=0; i<count; i++) {
        
        NSRange range;
        range.location=i; range.length=lenth;
        NSString *s =  [oldStr substringWithRange:range];
        if ([s isEqualToString:targetString]) {
            [oldStr replaceCharactersInRange:range withString:newString];
            count = count-(range.length-[newString length]);
        }
        
    }
    NSString *newStr=[oldStr copy];
    //NSLog(@"newStr = %lu",(unsigned long)[newStr length]);
    return newStr;
}

//检查是否为手机号码
+(BOOL)checkPhoneNumberIsMobile:(NSString*)phoneNumber{
    if (![NXInputChecker checkEmpty:phoneNumber]) {
        return NO;
    }
    if (phoneNumber.length!=11) {
        return NO;
    }
    else {
        NSRange range;
        range.length=1;
        range.location=0;
        int head=[[phoneNumber substringWithRange:range] intValue];
        if (head!=1) {
            return NO;
        }
    }
        return YES;
}
//把手机号码设置为标准11位
+(NSString*)resetPhoneNumber11:(NSString*)phoneNumber;{
    phoneNumber =[NXInputChecker filterStringWithString:phoneNumber targetString:@" " replaceWithString:@""];
    phoneNumber =[NXInputChecker filterStringWithString:phoneNumber targetString:@"+86" replaceWithString:@""];
    phoneNumber =[NXInputChecker filterStringWithString:phoneNumber targetString:@"-" replaceWithString:@""];
    return phoneNumber;
    
}
//加密显示手机号码
+(NSString*)encodeTelNumber:(NSString*)telNum{
    if ([NXInputChecker checkPhoneNumberIsMobile:telNum]) {
        NSRange hRange;
        hRange.location=0;
        hRange.length=3;
        NSRange bRange;
        bRange.location=7;
        bRange.length=4;
        NSString *head=[telNum substringWithRange:hRange];
        NSString *middle=@"****";
        NSString *end=[telNum substringWithRange:bRange];
        return [NSString stringWithFormat:@"%@%@%@",head,middle,end];
        
    }
   else return nil;
}
#pragma mark - 数组转化为字符串
+(NSString*)changeArrayToString:(NSArray*)array{
       NSString *result=@"";
    for (NSString *s in array) {
        if ([s isKindOfClass:[NSString class]]) {
            if (![array indexOfObject:s] ) {
               result = [result stringByAppendingString:s];
            }
            else{
                result=[NSString stringWithFormat:@"%@,%@",result,s];
            }
        }
    }
     
    return result;
}

#pragma mark - url编解码
+(NSDictionary*)parmetersInUrl:(NSURL*)url{
    NSString *strUrl=[url.query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:[strUrl dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    
    return dic;
}



#pragma mark - 字节编解码
+(NSData*)dataForByteString:(NSString*)byteString{
    int start = 0;
    int end = 0 ;
    BOOL isEnd=NO;
    NSMutableData *objectData=[[NSMutableData alloc] init];
    while (end < byteString.length) {
        if (isEnd) {
            break;
        }
        int length=1;
        BOOL isByte=NO;
        NSMutableString *byte=[[NSMutableString alloc]init];
        //读取一个字节
        while (!isByte) {
            NSRange range;
            range.length=1;
            range.location=start+length;
            NSString *n=[byteString substringWithRange:range];
            if ([n isEqualToString:@"E"]) {
                isEnd=YES;
                break;
            }else
            if ([n isEqualToString:@"%"]) {
                end=range.location;
                isByte=YES;
                length=1;
            }else{
                length++;
                [byte appendString:n];
            }
            
            
        }
        uint8_t b=(uint8_t)[byte intValue];
        [objectData appendByte:b];
        NSLog(@"%@",byte);
        start=end;
        
        
       
        
        
    }
    
    return objectData;
}
+(NSString*)encodePassWord:(NSString*)password{
    return [password MD5];
}
@end

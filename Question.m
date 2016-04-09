//
//  Question.m
//  GuessPicture
//
//  Created by HuberySun on 16/3/28.
//  Copyright © 2016年 HuberySun. All rights reserved.
//

#import "Question.h"
#import <objc/runtime.h>

@interface Question()
@end

@implementation Question
- (instancetype)initWithDic:(NSDictionary *)dic{
    self=[super init];
    if (self) {
        unsigned int count;
        objc_property_t *properties=class_copyPropertyList([self class], &count);
        NSMutableArray *names=[NSMutableArray array];
        for (unsigned int i=0; i<count; i++) {
            objc_property_t property=properties[i];
            const char *propertyName= property_getName(property);
            [names addObject:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
        }
        
        for (NSString *name in names) {
            [self setValue:[dic objectForKey:name] forKey:name];
        }
    }
    return self;
}

+ (instancetype)questionWithDic:(NSDictionary *)dic{
    return  [[self alloc] initWithDic:dic];
}
@end

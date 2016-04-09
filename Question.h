//
//  Question.h
//  GuessPicture
//
//  Created by HuberySun on 16/3/28.
//  Copyright © 2016年 HuberySun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Question : NSObject
-(instancetype) initWithDic:(NSDictionary *)dic;
+(instancetype)questionWithDic:(NSDictionary *)dic;

@property(nonatomic, copy, readonly)NSString *answer;
@property(nonatomic, copy, readonly)NSString *icon;
@property(nonatomic, copy, readonly)NSString *title;
@property(nonatomic, strong, readonly)NSArray *options;
@end

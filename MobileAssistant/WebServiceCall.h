//
//  WebServiceCall.h
//  finder
//
//  Created by Joshua Balogun on 12/18/14.
//  Copyright (c) 2014 Etisalat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebServiceCall : NSObject

- (NSDictionary *)query;
- (NSDictionary *)verify;
- (NSDictionary *)subscribe;
- (NSDictionary *)unsubscribe;
- (NSDictionary *)enable;
- (NSDictionary *)disable;
- (NSDictionary *)addsubscriber;
- (NSDictionary *)setupassistant:(NSString *)msisdn :(NSString *)asstType :(NSString *)asstTime;

@end

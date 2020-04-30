//
//  WebServiceCall.m
//  finder
//
//  Created by Joshua Balogun on 9/1/14.
//  Copyright (c) 2014 Booking.com. All rights reserved.
//

#import "WebServiceCall.h"
#import <Foundation/NSJSONSerialization.h>

//  Test URL
// #define mobileAssistantApiURL @"http://41.190.16.55:8080/mobile-api/mobile-assistant/"
// #define token @"ha57ghTr$!LkTfrBN202664Q"
// #define osType @"iOS"
// #define version @"1.06"

#define mobileAssistantApiURL @"http://41.190.16.170:8080/mobile-api/mobile-assistant/"
#define token @"06f323ff6534b927938134353f5fa8e7"
#define osType @"iOS"
#define version @"1.1.2"

@implementation WebServiceCall



- (NSDictionary *)query
{
    
    NSMutableString *URLString = [[NSMutableString alloc] initWithString:mobileAssistantApiURL];
    
    [URLString appendString:@"query"];
    
    id json = [self processRequestNResponse:URLString];
    
    NSDictionary *result = json;
    
    return result;
    
}


- (NSDictionary *)verify
{
    
    NSMutableString *URLString = [[NSMutableString alloc] initWithString:mobileAssistantApiURL];
    
    [URLString appendString:@"verify"];
    
    id json = [self processRequestNResponse:URLString];
    
    NSDictionary *result = json;
    
    return result;
    
}


- (NSDictionary *)subscribe
{
    
    NSMutableString *URLString = [[NSMutableString alloc] initWithString:mobileAssistantApiURL];
    
    [URLString appendString:@"subscribe"];
    
    id json = [self processRequestNResponse:URLString];
    
    NSDictionary *result = json ;
    
    return result;
    
}


- (NSDictionary *)unsubscribe
{
    
    NSMutableString *URLString = [[NSMutableString alloc] initWithString:mobileAssistantApiURL];
    
    [URLString appendString:@"unsubscribe"];
    
    id json = [self processRequestNResponse:URLString];
    
    NSDictionary *result = json;
    
    return result;
    
}


- (NSDictionary *)enable
{
    
    NSMutableString *URLString = [[NSMutableString alloc] initWithString:mobileAssistantApiURL];
    
    [URLString appendString:@"enable"];
    
    id json = [self processRequestNResponse:URLString];
    
    NSDictionary *result = json ;
    
    return result;
    
}


- (NSDictionary *)disable
{
    
    NSMutableString *URLString = [[NSMutableString alloc] initWithString:mobileAssistantApiURL];
    
    [URLString appendString:@"disable"];
    
    id json = [self processRequestNResponse:URLString];
    
    NSDictionary *result = json;
    
    return result;
    
}


- (NSDictionary *)addsubscriber
{
    
    NSMutableString *URLString = [[NSMutableString alloc] initWithString:mobileAssistantApiURL];
    
    [URLString appendString:@"add-subscriber"];
    
    id json = [self processRequestNResponse:URLString];
    
    NSDictionary *result = json;
    
    return result;
    
}


- (NSDictionary *)setupassistant:(NSString *)msisdn :(NSString *)asstType :(NSString *)asstTime
{
   
    NSMutableString *URLString = [[NSMutableString alloc] initWithString:mobileAssistantApiURL];
    
    [URLString appendString:[NSString stringWithFormat:@"setup?asst-msisdn=%@&asst-type=%@&timeout=%@",msisdn,asstType,asstTime]];
    
    id json = [self processRequestNResponse:URLString];
    
    NSDictionary *result = json;
    
    return result;
    
}


- (id)processRequestNResponse:(NSMutableString *)URLString
{
    
    NSURL *URL = [NSURL URLWithString:URLString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    
    //Request

    [request setHTTPMethod:@"GET"];
    [request setValue:@"Content-Type" forHTTPHeaderField:@"application/json"];
    [request setValue:@"Accept" forHTTPHeaderField:@"application/json"];
    [request setValue:token forHTTPHeaderField:@"x-emts-app-token"];
    [request setValue:osType forHTTPHeaderField:@"x-emts-os-type"];
    [request setValue:version forHTTPHeaderField:@"x-emts-app-version"];
    
    //Response
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (data == nil)
    {
        NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
    }
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    
    //NSLog(@"%s: json: %@", __PRETTY_FUNCTION__, string);

    id json = [NSJSONSerialization JSONObjectWithData:jsonData
                                              options:NSJSONReadingAllowFragments
                                                error:&error];
    if (json == nil)
    {
        NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
    }
    
    return json;
    
}



@end

//
//  NSDataAdditions.h
//  http://stackoverflow.com/questions/392464/any-base64-library-on-iphone-sdk
//

#import <Foundation/Foundation.h>

@interface NSObject (NSDataAdditions) 

+(NSData *) base64DataFromString: (NSString *)string;

@end

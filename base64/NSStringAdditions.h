//
//  NSStringAdditions.h
//  http://stackoverflow.com/questions/392464/any-base64-library-on-iphone-sdk
//

#import <Foundation/NSString.h>

@interface NSString (NSStringAdditions)

+ (NSString *) base64StringFromData:(NSData *)data length:(int)length;

@end


//
//  NSStringAdditions.m
//  http://stackoverflow.com/questions/392464/any-base64-library-on-iphone-sdk
//

#import "NSStringAdditions.h"

static char base64EncodingTable[64] = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
	'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
	'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};

@implementation NSString (NSStringAdditions)

/*
+ (NSString *) base64StringFromData: (NSData *)data length: (int)length {
	unsigned long ixtext, lentext;
	long ctremaining;
	unsigned char input[3], output[4];
	short i, charsonline = 0, ctcopy;
	const unsigned char *raw;
	NSMutableString *result;
	
	lentext = [data length]; 
	if (lentext < 1)
		return @"";
	result = [NSMutableString stringWithCapacity: lentext];
	raw = [data bytes];
	ixtext = 0; 
	
	while (true) {
		ctremaining = lentext - ixtext;
		if (ctremaining <= 0) 
			break;        
		for (i = 0; i < 3; i++) { 
			unsigned long ix = ixtext + i;
			if (ix < lentext)
				input[i] = raw[ix];
			else
				input[i] = 0;
		}
		output[0] = (input[0] & 0xFC) >> 2;
		output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
		output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
		output[3] = input[2] & 0x3F;
		ctcopy = 4;
		switch (ctremaining) {
			case 1: 
				ctcopy = 2; 
				break;
			case 2: 
				ctcopy = 3; 
				break;
		}
		
		for (i = 0; i < ctcopy; i++)
			[result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
		
		for (i = ctcopy; i < 4; i++)
			[result appendString: @"="];
		
		ixtext += 3;
		charsonline += 4;
		
		if ((length > 0) && (charsonline >= length))
			charsonline = 0;
		
		return result;
	}
}
*/

+ (NSString *) base64StringFromData: (NSData *)data length: (int)length {
	int lentext = [data length]; 
	if (lentext < 1) return @"";
	
	char *outbuf = malloc(lentext*4/3+4); // add 4 to be sure
	
	if ( !outbuf ) return nil;
	
	const unsigned char *raw = [data bytes];
	
	int inp = 0;
	int outp = 0;
	int do_now = lentext - (lentext%3);
	
	for ( outp = 0, inp = 0; inp < do_now; inp += 3 )
	{
		outbuf[outp++] = base64EncodingTable[(raw[inp] & 0xFC) >> 2];
		outbuf[outp++] = base64EncodingTable[((raw[inp] & 0x03) << 4) | ((raw[inp+1] & 0xF0) >> 4)];
		outbuf[outp++] = base64EncodingTable[((raw[inp+1] & 0x0F) << 2) | ((raw[inp+2] & 0xC0) >> 6)];
		outbuf[outp++] = base64EncodingTable[raw[inp+2] & 0x3F];
	}
	
	if ( do_now < lentext )
	{
		char tmpbuf[2] = {0,0};
		int left = lentext%3;
		for ( int i=0; i < left; i++ )
		{
			tmpbuf[i] = raw[do_now+i];
		}
		
		/*
		raw = tmpbuf;
		outbuf[outp++] = base64EncodingTable[(raw[inp] & 0xFC) >> 2];
		outbuf[outp++] = base64EncodingTable[((raw[inp] & 0x03) << 4) | ((raw[inp+1] & 0xF0) >> 4)];
		if ( left == 2 ) outbuf[outp++] = base64EncodingTable[((raw[inp+1] & 0x0F) << 2) | ((raw[inp+2] & 0xC0) >> 6)];
		*/
		
		raw = tmpbuf;
		inp = 0;
		outbuf[outp++] = base64EncodingTable[(raw[inp] & 0xFC) >> 2];
		outbuf[outp++] = base64EncodingTable[((raw[inp] & 0x03) << 4) | ((raw[inp+1] & 0xF0) >> 4)];
		if ( left == 2 ) outbuf[outp++] = base64EncodingTable[((raw[inp+1] & 0x0F) << 2) | ((raw[inp+2] & 0xC0) >> 6)];
		else outbuf[outp++] = '=';
		outbuf[outp++] = '=';
	}
		
	NSString *ret = [[[NSString alloc] initWithBytes:outbuf length:outp encoding:NSASCIIStringEncoding] autorelease];
	free(outbuf);
	
	return ret;
}


+ (NSData *) base64DataFromString: (NSString *)string {
	unsigned long ixtext, lentext;
	unsigned char ch, input[4], output[3];
	short i, ixinput;
	Boolean flignore, flendtext = false;
	const char *temporary;
	NSMutableData *result;
	
	if (!string)
		return [NSData data];
	
	ixtext = 0;
	temporary = [string UTF8String];
	lentext = [string length];
	result = [NSMutableData dataWithCapacity: lentext];
	ixinput = 0;
	
	while (true) {
		if (ixtext >= lentext)
			break;
		ch = temporary[ixtext++];
		flignore = false;
		
		if ((ch >= 'A') && (ch <= 'Z'))
			ch = ch - 'A';
		else if ((ch >= 'a') && (ch <= 'z'))
			ch = ch - 'a' + 26;
		else if ((ch >= '0') && (ch <= '9'))
			ch = ch - '0' + 52;
		else if (ch == '+')
			ch = 62;
		else if (ch == '=')
			flendtext = true;
		else if (ch == '/')
			ch = 63;
		else
			flignore = true;
		
		if (!flignore) {
			short ctcharsinput = 3;
			Boolean flbreak = false;
			
			if (flendtext) {
				if (ixinput == 0)
					break;              
				if ((ixinput == 1) || (ixinput == 2))
					ctcharsinput = 1;
				else
					ctcharsinput = 2;
				ixinput = 3;
				flbreak = true;
			}
			
			input[ixinput++] = ch;
			
			if (ixinput == 4){
				ixinput = 0;
				output[0] = (input[0] << 2) | ((input[1] & 0x30) >> 4);
				output[1] = ((input[1] & 0x0F) << 4) | ((input[2] & 0x3C) >> 2);
				output[2] = ((input[2] & 0x03) << 6) | (input[3] & 0x3F);
				for (i = 0; i < ctcharsinput; i++)
					[result appendBytes: &output[i] length: 1];
			}
			if (flbreak)
				break;
		}
	}
	return result;
}

@end
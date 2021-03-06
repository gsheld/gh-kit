//
//  NSURL+UtilsTest.m
//  GHKit
//
//  Created by Gabriel Handford on 1/13/09.
//

#import "GHNSURL+Utils.h"
#import "GHNSDictionary+NSNull.h"

@interface NSURLUtilsTest : GHTestCase { }
@end

@implementation NSURLUtilsTest

- (void)testEncode {	
	NSString *test1 = @"~!@#$%^&*(){}[]=:/,;?+'\"\\";
	NSString *escaped1 = [NSURL gh_encode:test1];
	NSString *expected1 = @"~!@#$%25%5E&*()%7B%7D%5B%5D=:/,;?+'%22%5C";
	GHAssertEqualObjects(escaped1, expected1, nil);			
}

- (void)testEncodeComponent {	
	NSString *test1 = @"~!@#$%^&*(){}[]=:/,;?+'\"\\";
	NSString *escaped1 = [NSURL gh_encodeComponent:test1];
	NSString *expected1 = @"~!%40%23%24%25%5E%26*()%7B%7D%5B%5D%3D%3A%2F%2C%3B%3F%2B'%22%5C";
	GHAssertEqualObjects(escaped1, expected1, nil);		
}

- (void)testEscapeAll {	
	NSString *test1 = @"~!@#$%^&*(){}[]=:/,;?+'\"\\~!*()'";
	NSString *escaped1 = [NSURL gh_escapeAll:test1];
	NSString *expected1 = @"%7E%21%40%23%24%25%5E%26%2A%28%29%7B%7D%5B%5D%3D%3A%2F%2C%3B%3F%2B%27%22%5C%7E%21%2A%28%29%27";
	GHAssertEqualObjects(escaped1, expected1, nil);		
}

- (void)testDictionaryToQueryString {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"value1", @"key1", @"value2", @"key2", nil];
	NSString *s = [NSURL gh_dictionaryToQueryString:dict sort:YES];
	GHAssertEqualObjects(s, @"key1=value1&key2=value2", nil);
	
	NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:@"value1", @"AAA", @"value2", @"BBB", @"value3", @"CCC", nil];
	NSString *s2 = [NSURL gh_dictionaryToQueryString:dict2 sort:YES];
	GHAssertEqualObjects(s2, @"AAA=value1&BBB=value2&CCC=value3", nil);	
}

- (void)testDictionaryWithObjectsToQueryString {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:1], @"key1", @"[]", @"key2", nil];
	NSString *s = [NSURL gh_dictionaryToQueryString:dict sort:YES];
	GHAssertEqualObjects(s, @"key1=1&key2=%5B%5D", nil);
}

- (void)testDictionaryWithNSNull {
	NSDictionary *dict = [NSDictionary gh_dictionaryWithKeysAndObjectsMaybeNil:@"key1", @"value1", @"key2", nil, nil];
	NSString *s = [NSURL gh_dictionaryToQueryString:dict sort:YES];
	GHAssertEqualObjects(s, @"key1=value1", nil);
}

- (void)testQueryStringToDictionary {
	NSDictionary *dict = [NSURL gh_queryStringToDictionary:@"key1=value1&key2=value2"];
	GHAssertEqualObjects(@"value1", [dict objectForKey:@"key1"], nil);
	GHAssertEqualObjects(@"value2", [dict objectForKey:@"key2"], nil);
	
	NSDictionary *dict2 = [NSURL gh_queryStringToDictionary:@"key1==value1&&key2=value2%20&key3=value3=more"];
	GHAssertEqualObjects(@"=value1", [dict2 objectForKey:@"key1"], nil);
	GHAssertEqualObjects(@"value2 ", [dict2 objectForKey:@"key2"], nil);
	GHAssertEqualObjects(@"value3=more", [dict2 objectForKey:@"key3"], nil);
}

- (void)testDeriveWithQuery {
	NSURL *URL = [NSURL URLWithString:@"http://api.yelp.com/path?key1=value1&key2=value2"];
	NSURL *derivedURL = [URL gh_deriveWithQuery:@"key3=value3&key4=value4"];
	GHAssertEqualStrings([derivedURL description], @"http://api.yelp.com/path?key3=value3&key4=value4", nil);	
}

- (void)testDeriveComplexWithQuery {
	NSURL *URL = [NSURL URLWithString:@"https://user:pass@api.yelp.com:400/path?key1=value1&key2=value2#myfrag"];
	NSURL *derivedURL = [URL gh_deriveWithQuery:@"key3=value3&key4=value4"];
	GHAssertEqualStrings([derivedURL description], @"https://user:pass@api.yelp.com:400/path?key3=value3&key4=value4#myfrag", nil);	
}

- (void)testDeriveWithQueryUnicodeURL {
  NSString *URLString = @"http://api.yelp.com/events/%E6%B8%AF%E5%8C%BA-%E3%81%8B%E3%81%8D%E6%B0%B7%E3%82%B3%E3%83%AC%E3%82%AF%E3%82%B7%E3%83%A7%E3%83%B3-copen-local-base-roppongi";
  NSURL *URL = [NSURL URLWithString:URLString];
  NSURL *derivedURL = [URL gh_deriveWithQuery:nil];
  GHAssertEqualStrings(URLString, [derivedURL description], nil);
}

- (void)testDeriveWithQueryRedirectToEscapedURL {
  NSURL *URL = [NSURL URLWithString:@"http://www.yelp.com/redir"];
  NSURL *derivedURL = [URL gh_deriveWithQuery:@"url=http%3A%2F%2Fwww.google.com"];
  GHAssertEqualStrings([derivedURL description], @"http://www.yelp.com/redir?url=http%3A%2F%2Fwww.google.com", nil);
}

- (void)testCanonical {
	NSURL *URL = [NSURL URLWithString:@"https://user:pass@api.yelp.com:400/path?b=c&a=d#myfrag"];
	NSURL *canonical = [URL gh_canonical];
	GHAssertEqualObjects(canonical, [NSURL URLWithString:@"https://user:pass@api.yelp.com:400/path?a=d&b=c#myfrag"], nil);

	NSURL *URL2 = [NSURL URLWithString:@"https://user:pass@api.yelp.com:400/path?b=c&a=d&ignore=ignored#myfrag"];
	NSURL *canonical2 = [URL2 gh_canonicalWithIgnore:[NSArray arrayWithObject:@"ignore"]];
	GHAssertEqualObjects(canonical2, [NSURL URLWithString:@"https://user:pass@api.yelp.com:400/path?a=d&b=c#myfrag"], nil);
}

- (void)testFilter {
  NSURL *URL = [NSURL URLWithString:@"https://user:pass@api.yelp.com:400/path?b=c&a=d&ignore=ignored#myfrag"];
	NSURL *filtered = [URL gh_filterQueryParams:[NSArray arrayWithObjects:@"ignore", @"ignore2", nil] sort:YES];
	GHAssertEqualObjects(filtered, [NSURL URLWithString:@"https://user:pass@api.yelp.com:400/path?a=d&b=c#myfrag"], nil);
}

- (void)testQueryDictionaryWithArray {
	NSArray *array1 = [NSArray arrayWithObjects:@"va", @"vb", @"vc", nil];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:array1, @"key1", @"value2", @"key2", nil];
	NSString *s = [NSURL gh_dictionaryToQueryString:dict sort:YES];
	GHAssertEqualObjects(s, @"key1=va%2Cvb%2Cvc&key2=value2", nil);	
}

- (void)testQueryDictionaryWithSet {
	NSSet *set1 = [NSSet setWithObjects:@"va", @"vb", nil];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:set1, @"key1", nil];
	NSString *s = [NSURL gh_dictionaryToQueryString:dict sort:YES];
	GHAssertTrue([s isEqualToString:@"key1=va%2Cvb"] || [s isEqualToString:@"key1=vb%2Cva"], nil);	
}

@end

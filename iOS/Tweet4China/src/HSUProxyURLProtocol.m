//
//  HSUProxyURLProtocol.m
//  iWeb
//
//  Created by Jason Hsu on 3/28/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUProxyURLProtocol.h"

#define kProxyURL_key @"proxy_url"
#define kTwitterAPI_url @"https://api.twitter.com"

@implementation HSUProxyURLProtocol
{
    NSURLConnection *connection;
    NSMutableData *proRespData;
}

static NSString *sProxyUrl = nil;
+ (void)initialize
{
#ifdef PROXY_URL
    sProxyUrl = PROXY_URL;
#else
    sProxyUrl = [[NSUserDefaults standardUserDefaults] objectForKey:kProxyURL_key];
#endif
    if (sProxyUrl == nil) {
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
        cancelItem.action = ^{};
        RIButtonItem *doneItem = [RIButtonItem itemWithLabel:@"Done"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Proxy Found" message:@"Input below or define in source code" cancelButtonItem:cancelItem otherButtonItems:doneItem, nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
        doneItem.action = ^{
            NSString *text = [[alert textFieldAtIndex:0] text];
            [[NSUserDefaults standardUserDefaults] setObject:text forKey:kProxyURL_key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            sProxyUrl = text;
        };
    }
}

- (void)startLoading
{
    NSMutableURLRequest *proxyRequest = [self.request mutableCopy];
    
    // Method
    NSString *method = [proxyRequest HTTPMethod];
    [proxyRequest setHTTPMethod:@"POST"];
    
    // URL
    NSData *origPath = [[[proxyRequest URL] description] dataUsingEncoding:NSASCIIStringEncoding];
    NSString *base64edPath = [origPath base64EncodingWithLineLength:100];
    NSURL *proxyURL = [[NSURL alloc] initWithString:sProxyUrl];
    [proxyRequest setURL:proxyURL];
    
    // Header
    NSDictionary *headers = [proxyRequest allHTTPHeaderFields];
    NSMutableString *headerStr = [[NSMutableString alloc] init];
    for (NSString *head in headers) {
        [headerStr appendFormat:@"%@:%@\n", head, [headers valueForKey:head]];
    }
    NSData *headerData = [headerStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *base64edHeaderStr = [headerData base64EncodingWithLineLength:100];
    
    // Body
    NSData *origBodyData = [proxyRequest HTTPBody];
    NSString *base64edBodyStr = [origBodyData base64EncodingWithLineLength:100];
    if (base64edBodyStr == NULL) {
        base64edBodyStr = @"";
    }
    
    // ProxyBody
    NSString *proxyBodyStr = S(@"method=%@&encoded_path=%@&headers=%@&postdata=%@",
                                method, base64edPath, base64edHeaderStr, base64edBodyStr);
    NSData *proxyBody = [proxyBodyStr dataUsingEncoding:NSASCIIStringEncoding];
    [proxyRequest setHTTPBody:proxyBody];
    [proxyRequest setValue:S(@"%d", proxyBody.length) forHTTPHeaderField:@"Content-Length"];
    
    connection = [NSURLConnection connectionWithRequest:proxyRequest delegate:self];
    [HSUNetworkActivityIndicatorManager show];
}

- (void)stopLoading
{
    [connection cancel];
    [HSUNetworkActivityIndicatorManager hide];
}

- (void)connection:(NSURLConnection *)_connection didReceiveData:(NSData *)data
{
    if (proRespData == nil) {
        proRespData = [data mutableCopy];
    } else {
        [proRespData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
    [HSUNetworkActivityIndicatorManager hide];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *proRespStr = [[NSString alloc] initWithData:proRespData encoding:1];
    NSData *sourceData = [NSData dataWithBase64EncodedString:proRespStr];
    
    [self.client URLProtocol:self didLoadData:sourceData];
    [self.client URLProtocolDidFinishLoading:self];
    [HSUNetworkActivityIndicatorManager hide];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if (sProxyUrl == nil) return NO;
    if ([request.URL.absoluteString rangeOfString:sProxyUrl].location != NSNotFound) return NO;
    if ([request.URL.absoluteString rangeOfString:kTwitterAPI_url].location != NSNotFound) return YES;
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

@end

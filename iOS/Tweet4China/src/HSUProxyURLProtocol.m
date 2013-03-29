//
//  HSUProxyURLProtocol.m
//  iWeb
//
//  Created by Jason Hsu on 3/28/13.
//  Copyright (c) 2013 Xu Ke. All rights reserved.
//

#import "HSUProxyURLProtocol.h"
#import "Base64.h"

@implementation HSUProxyURLProtocol
{
    NSURLConnection *connection;
    NSMutableData *proRespData;
    NSString *proxyUrl;
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client
{
    self = [super initWithRequest:request cachedResponse:cachedResponse client:client];
    if (self) {
#ifdef PROXY_URL
        proxyUrl = PROXY_URL;
#endif
    }
    return self;
}

- (void)startLoading
{
    NSMutableURLRequest *proxyRequest = [self.request mutableCopy];
    
    // Method
    NSString *method = [proxyRequest HTTPMethod];
    [proxyRequest setHTTPMethod:@"POST"];
    
    // URL
    NSData *origPath = [[[proxyRequest URL] description] dataUsingEncoding:NSASCIIStringEncoding];
    NSString *base64edPath = [origPath base64EncodedString];
    NSURL *proxyURL = [[NSURL alloc] initWithString:proxyUrl];
    [proxyRequest setURL:proxyURL];
    
    // Header
    NSDictionary *headers = [proxyRequest allHTTPHeaderFields];
    NSMutableString *headerStr = [[NSMutableString alloc] init];
    for (NSString *head in headers) {
        [headerStr appendFormat:@"%@:%@\n", head, [headers valueForKey:head]];
    }
    NSData *headerData = [headerStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *base64edHeaderStr = [headerData base64EncodedString];
    
    // Body
    NSData *origBodyData = [proxyRequest HTTPBody];
    NSString *base64edBodyStr = [origBodyData base64EncodedString];
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
}

- (void)stopLoading
{
    [connection cancel];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
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
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];  // We cache ourselves.
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *proRespStr = [[NSString alloc] initWithData:proRespData encoding:1];
    NSData *sourceData = [NSData dataWithBase64EncodedString:proRespStr];
    
    [self.client URLProtocol:self didLoadData:sourceData];
    [self.client URLProtocolDidFinishLoading:self];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
#ifdef PROXY_URL
    return [request.URL.absoluteString rangeOfString:PROXY_URL].location == NSNotFound;
#endif
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

@end

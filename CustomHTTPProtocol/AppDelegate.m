
#import "AppDelegate.h"

#import "WebViewController.h"

#import "CredentialsManager.h"
#import "CustomHTTPProtocol.h"


@interface AppDelegate () <CustomHTTPProtocolDelegate>

@property (nonatomic, strong, readwrite) WebViewController* viewController;

@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    #pragma unused(application)
    assert(self.window != nil);
    assert(self.navController != nil);

    [CustomHTTPProtocol setDelegate:self];
    [CustomHTTPProtocol start];
    
    // Create the web view controller and set up the UI.  We do this after setting 
    // up the core code in case this triggers any HTTP requests.
    
    self.viewController = [[WebViewController alloc] init];
    assert(self.viewController != nil);
    self.viewController.title = @"CustomHTTPProtocol";
    [self.navController pushViewController:self.viewController animated:NO];

    [self.window addSubview:self.navController.view];
	[self.window makeKeyAndVisible];
}

- (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol logWithFormat:(NSString *)format arguments:(va_list)argList
{
    #pragma unused(protocol)
    #pragma unused(format)
    #pragma unused(argList)
}

- (BOOL)customHTTPProtocol:(CustomHTTPProtocol *)protocol canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    assert(protocol != nil);
    #pragma unused(protocol)
    assert(protectionSpace != nil);
    
    return [[protectionSpace authenticationMethod] isEqual:NSURLAuthenticationMethodServerTrust];
}

- (void)customHTTPProtocol:(CustomHTTPProtocol *)protocol didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
    // A CustomHTTPProtocol delegate callback, called when the protocol has an authenticate 
    // challenge that the delegate accepts via -customHTTPProtocol:canAuthenticateAgainstProtectionSpace:. 
    // In this specific case it's only called to handle server trust authentication challenges. 
    // It evaluates the trust based on both the global set of trusted anchors and the list of trusted 
    // anchors returned by the CredentialsManager.
{
    assert(protocol != nil);
    assert(challenge != nil);
    assert([[[challenge protectionSpace] authenticationMethod] isEqual:NSURLAuthenticationMethodServerTrust]);

    SecTrustRef trust = [[challenge protectionSpace] serverTrust];
    NSURLCredential* credential = [self credentialForTrust:trust];
    
    [protocol resolveAuthenticationChallenge:challenge withCredential:credential];
}

- (NSURLCredential*)credentialForTrust:(SecTrustRef)trust {
    SecTrustResultType trustResult;
    
    if (trust == NULL)
        assert(false);
    
    OSStatus err = SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef) [CredentialsManager sharedManager].trustedAnchors);
    if (err != noErr)
        assert(false);
    
    err = SecTrustSetAnchorCertificatesOnly(trust, false);
    if (err != noErr)
        assert(false);
    
    err = SecTrustEvaluate(trust, &trustResult);
    if (err != noErr)
        assert(false);
    
    if ((trustResult != kSecTrustResultProceed) && (trustResult != kSecTrustResultUnspecified))
        return nil;
    
    NSURLCredential* credential = [NSURLCredential credentialForTrust:trust];
    assert(credential != nil);
    
    return credential;
}

@end

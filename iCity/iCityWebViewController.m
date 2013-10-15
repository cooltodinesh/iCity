//
//  iCityWebViewController.m
//  Indian Cities
//
//  Created by Dinesh Salve on 19/08/13.
//  Copyright (c) 2013 Dinesh salve. All rights reserved.
//

#import "iCityWebViewController.h"

@interface iCityWebViewController () <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) UIActivityIndicatorView *activity;


@end

@implementation iCityWebViewController

@synthesize url, webView, activity;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activity.center = self.view.center;
    
    CGRect webFrame = [[UIScreen mainScreen] applicationFrame];
    self.webView= [[UIWebView alloc] initWithFrame:webFrame];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;

    [self.view addSubview:self.webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    [self.view addSubview:self.activity];

    
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activity startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webViewLoaded
{
    [self.activity stopAnimating];

}


@end

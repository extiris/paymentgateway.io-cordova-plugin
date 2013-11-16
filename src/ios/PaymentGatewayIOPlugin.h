//
//  PaymentGatewayIOPlugin.h
//
//  Copyright 2005-2014 Merchant Paid, LLC
//  Extiris, LLC License
//

#import <Cordova/CDV.h>


@interface PaymentGatewayIOPlugin : CDVPlugin

    - (void)init:(CDVInvokedUrlCommand *)command;
    - (void)pay:(CDVInvokedUrlCommand *)command;

@end

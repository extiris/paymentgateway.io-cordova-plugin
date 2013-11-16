//
//  PaymentGatewayIOPlugin.m
//
//  Copyright 2005-2014 Merchant Paid, LLC
//  Extiris, LLC License
//

#import "PaymentGatewayIOPlugin.h"


#pragma mark -


@interface PaymentGatewayIOPlugin()

    @property (nonatomic, copy, readwrite) NSString *sApiUrl; 
    @property (nonatomic, copy, readwrite) NSString *sApiKey; //[ 73585071-df1e-2814-09be-87f6cb94419c
    @property (nonatomic, copy, readwrite) NSString *sJsCallbackId;

    - (void)sendSuccessTo:(NSString *)callbackId withObject:(id)objwithObject;
    - (void)sendFailureTo:(NSString *)callbackId;

@end


#pragma mark -


@implementation PaymentGatewayIOPlugin


    //----------------------------------------------------------------------
    // [api_key (0)]
    //----------------------------------------------------------------------
    -(void)init: (CDVInvokedUrlCommand *)command
    {
        NSString *sParam = [command.arguments objectAtIndex:0];
        
        self.sApiKey = (sParam) ? sParam : @"";
        self.sApiUrl = @"https://www.merchantpaid.com/api/payments/1.0/json/MakePayment";
    }

    
    
    //----------------------------------------------------------------------
    //   [card_info (0), amount (1), customer_id (2), options (3), gateway (4) ]
    //----------------------------------------------------------------------
    -(void)pay: (CDVInvokedUrlCommand *)command
    {
        @try
        {
            //[ PROGRESS: show
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            
            //[ SESSION: used later for callback
            self.sJsCallbackId = command.callbackId;
            
            
            //////////[ HANDLE JS PARAMS ]/////////
            
            //[ CARD INFO
            NSDictionary* dJsCardInfo = [command.arguments objectAtIndex:0];
            
            //[ AMOUNT
            NSString *sJsAmount = [command.arguments objectAtIndex:1];
            sJsAmount = (sJsAmount) ? sJsAmount : @"";
            
            //[ CUSTOMER ID
            NSString *sJsCustomerId = [command.arguments objectAtIndex:2];
            sJsCustomerId = (sJsCustomerId) ? sJsCustomerId : @"";
            
            //[ OPTIONS
            NSDictionary* dJsOptions = [command.arguments objectAtIndex:3];
            
            //[ GATEWAY
            NSString *sJsGateway = [command.arguments objectAtIndex:4];
            sJsGateway = (sJsGateway) ? sJsGateway : @"";
            
            
            
            //////////[ DATA VALIDATION ]/////////
            
            
            //[ TODO: minor data validation to ensure we have all the fields?
            NSError *error;
            NSData *dJsonData = [NSJSONSerialization dataWithJSONObject: dJsCardInfo
                                                                options: 0 //NSJSONWritingPrettyPrinted // or 0
                                                                  error: &error];
            
            if( !dJsonData )
            {
                #ifdef DEBUG
                    NSLog(@"Got an error: %@", error);
                #endif
                
                //[ TODO: throw exception
            }
            
            
            //[ encode our json data
            NSString *sJsonCardInfo = [[NSString alloc] initWithData:dJsonData encoding:NSUTF8StringEncoding];
            
            //[ OPTIONS: minor data validation to ensure we have all the fields?
            NSError *error2;
            NSData *dJsonOptionData = [NSJSONSerialization dataWithJSONObject: dJsOptions
                                                                      options: 0 //NSJSONWritingPrettyPrinted // or 0
                                                                        error: &error2];
            if( !dJsonOptionData )
            {
                #ifdef DEBUG
                    NSLog(@"Got an error: %@", error2);
                #endif
                
                //[ TODO: throw exception
            }
            
            //[ encode our json data
            NSString *sJsonOptions = [[NSString alloc] initWithData:dJsonOptionData encoding:NSUTF8StringEncoding];
            
            
            
            //////////[ PROCESS FORM DATA ]/////////
            
            //[ FORM DATA
            NSString *myFormData = [[NSString alloc] init];
            
            //[ NOTE: order matters
            myFormData = [NSString stringWithFormat: @"card_info=%@&amount=%@&customer_id=%@&options=%@&gateway=%@", urlEncode(sJsonCardInfo), sJsAmount, sJsCustomerId, sJsonOptions, sJsGateway];
            
            //NSLog(@"FORM DATA: %@", myFormData);

            
            //////////[ HTTP: PREPARE REQUEST ]//////////
            
            NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.sApiUrl]];
            
            
            // HEADERS: Set the request's content type to application/x-www-form-urlencoded
            [postRequest setValue:self.sApiKey forHTTPHeaderField:@"x-api-key"];
            [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            
            // Designate the request a POST request and specify its body data
            [postRequest setHTTPMethod:@"POST"];
            [postRequest setHTTPBody:[NSData dataWithBytes:[myFormData UTF8String] length:strlen([myFormData UTF8String])]];
            
            
            //////////[ SYNC: MAKE REQUEST ]//////////
            
            //[NSURLConnection sendSynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
            
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
            
            //////////[ ASYNC: MAKE REQUEST ]//////////
            
            [NSURLConnection sendAsynchronousRequest:postRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
             {
                 //[ need to decode
                 NSString *sResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                 
                 #ifdef DEBUG
                    NSLog(@"[RESPONSE] =%@", sResponse);
                 #endif
                 
                 //[ REFERENCE: CDVPlugin.h   -+>  stringByEvaluatingJavaScriptFromString
                 if ([data length] > 0 && error == nil)
                 {
                     // [delegate receivedData:data];
                     // [self sendSuccessTo:self.sJsCallbackId withObject:data];
                     CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:sResponse];
                     
                     // The sendPluginResult method is thread-safe.
                     [self.commandDelegate sendPluginResult:pluginResult callbackId:self.sJsCallbackId];
                 }
                 else if ([data length] == 0 && error == nil)
                 {
                     // [delegate emptyReply];
                 }
                 // else if (error != nil && error.code == ERROR_CODE_TIMEOUT)
                 // {
                 // [delegate timedOut];
                 // }
                 else if (error != nil)
                 {
                     //[delegate downloadError:error];
                     [self sendFailureTo:self.sJsCallbackId];
                 }
             }];
            
        }
        @catch (NSException *exception)
        {
            //[ TODO: send exeception to UI
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
            
            NSString *responseJavascript = [result toErrorCallbackString:command.callbackId];
            
            if( responseJavascript )
                [self writeJavascript:responseJavascript];
            
            
            #ifdef DEBUG
                NSLog(@"PaymentGatewayIO Exception: %@", exception.reason);
            #endif
        }
        @finally
        {
            //[ PROGRESS: hide
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }

    
#pragma mark - Helper methods


    //----------------------------------------------------------------------
    // INTERNAL: helper function: get the url encoded string form of an object
    //----------------------------------------------------------------------
    static NSString *urlEncode(id object) {
        return [[NSString stringWithFormat: @"%@", object] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    }



#pragma mark - Cordova callback helpers


    //----------------------------------------------------------------------
    // SUCCESS: call passed back to success js function
    //----------------------------------------------------------------------
    - (void)sendSuccessTo:(NSString *)callbackId withObject:(id)obj
    {
        CDVPluginResult *result = nil;
  
        if( [obj isKindOfClass:[NSString class]] )
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:obj];
        }
        else if( [obj isKindOfClass:[NSDictionary class]] )
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:obj];
        }
        else if ([obj isKindOfClass:[NSNumber class]])
        {
            // all the numbers we return are bools
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:[obj intValue]];
        }
        else if(!obj)
        {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
        else
        {
            NSLog(@"Success callback wrapper not yet implemented for class %@", [obj class]);
        }
  
        NSString *responseJavascript = [result toSuccessCallbackString:callbackId];
    
        if( responseJavascript )
        {
            [self writeJavascript:responseJavascript];
        }
    }

    
    
    //----------------------------------------------------------------------
    // FAILED: call passed back to failure js function
    //----------------------------------------------------------------------
    - (void)sendFailureTo:(NSString *)callbackId
    {
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];

        NSString *responseJavascript = [result toErrorCallbackString:callbackId];

        if( responseJavascript )
        {
            [self writeJavascript:responseJavascript];
        }
    }

@end



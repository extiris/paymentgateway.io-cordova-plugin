//
//  PaymentGatewayIOPlugin.h
//
//  Copyright 2005-2014 Merchant Paid, LLC
//  Extiris, LLC License
//

#import <Cordova/CDV.h>



@interface HttpForm : NSObject

    {
        NSString *sFormData;
    }

    @property(nonatomic, copy, readwrite)NSString *sFormData;

    -(id)init;
    -(void)addParam:(NSString *)sKey withValue: (NSString *)sValue;
    -(NSString *)getFormData;
    -(NSString *)urlEncode: (id)object;
@end

//////////

@implementation HttpForm

    @synthesize sFormData;

    //----------------------------------------------------------------------
    //
    //----------------------------------------------------------------------
    -(id)init
    {
        self.sFormData = @"";
        
        return self;
    }

    //----------------------------------------------------------------------
    //
    //----------------------------------------------------------------------
    -(void)addParam: (NSString *)sKey withValue: (NSString *)sValue
    {
        if( [self.sFormData length] == 0 )
            self.sFormData = [NSString stringWithFormat:@"%@=%@", sKey, [self urlEncode:sValue]];
        else
            self.sFormData = [NSString stringWithFormat:@"%@&%@=%@", self.sFormData, sKey, [self urlEncode:sValue]];
    }

    //----------------------------------------------------------------------
    //
    //----------------------------------------------------------------------
    -(NSString *) getFormData
    {
        return self.sFormData;
    }

    //----------------------------------------------------------------------
    // INTERNAL: helper function: get the url encoded string form of an object
    //----------------------------------------------------------------------
    -(NSString *) urlEncode: (id)object
    {
        //return object;
        return [[NSString stringWithFormat: @"%@", object] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    }

@end



@interface PaymentGatewayIOPlugin : CDVPlugin

    -(void)JsonRpc: (CDVInvokedUrlCommand *)command;
    -(void)httpPost: (NSString *)sCallbackId: (NSString *) sReqId :(NSString *) sUrl :(NSDictionary *) dParams :(NSDictionary *) dHeaders;

@end
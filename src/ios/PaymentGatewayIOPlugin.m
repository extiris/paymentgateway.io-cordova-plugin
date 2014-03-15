////////////////////////////////////////////////////////////////////////////////
/**
 *
 * @author 		Merchant Paid, LLC
 * @copyright 	Copyright (c) 2012-2014 Merchant Paid, LLC. All rights reserved.
 * @license 	http://paymentgateway.io/license
 * @version 	v1.0.1
 *
 * THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * EXTIRIS CORPORATION OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */
////////////////////////////////////////////////////////////////////////////////

#import "PaymentGatewayIOPlugin.h"


#pragma mark -


@interface PaymentGatewayIOPlugin()

    @property (nonatomic, copy, readwrite) NSString *sJsCallbackId;

@end


#pragma mark -


@implementation PaymentGatewayIOPlugin


    //----------------------------------------------------------------------
    // attempt to handle json rpc requests to pg.io service
    //----------------------------------------------------------------------
    -(void)JsonRpc: (CDVInvokedUrlCommand *)command
    {
        //////////[ HANDLE JS PARAMS ]/////////

        //[ METHOD
        NSString* sJsMethod = [command.arguments objectAtIndex:0];
        sJsMethod = (sJsMethod) ? sJsMethod : @"";
        
        
        //[ GATEWAY
        NSString* sJsGateway = [command.arguments objectAtIndex:1];
        sJsGateway = (sJsGateway) ? sJsGateway : @"";
        
        //[ JS REQ ID
        NSString *sJsReqId = [command.arguments objectAtIndex:2];
        sJsReqId = (sJsReqId) ? sJsReqId : @"";
        
        //[ PARAMS
        NSString *sJsParams = [command.arguments objectAtIndex:3];
        sJsParams = (sJsParams) ? sJsParams : @"[]";
        
        
        //////////[ FORM POST ]//////////
        
        HttpForm * form = [HttpForm alloc];
        
        [form addParam:@"jsonrpc" withValue:@"2.0"];
        [form addParam:@"method" withValue:sJsMethod];
        [form addParam:@"id" withValue:sJsReqId];
        [form addParam:@"params" withValue:sJsParams];
        

        #if TARGET_IPHONE_SIMULATOR
            NSString* sUrl = [NSString stringWithFormat:@"http://dev.paymentgateway.io/api/%@/1.0/jsonrpc", sJsGateway];
        #else
            NSString* sUrl = [NSString stringWithFormat:@"https://paymentgateway.io/api/%@/1.0/jsonrpc", sJsGateway];
        #endif
        
        
        //[ DO HTTP POST
        [self httpPost: command.callbackId :sJsReqId :sUrl : form.getFormData :nil];
    }

    
#pragma mark - Helper methods


    //----------------------------------------------------------------------
    //
    //----------------------------------------------------------------------
    - (void)httpPost: (NSString *)sCallbackId :(NSString *) sReqId :(NSString *) sUrl :(NSString *) sFormData :(NSDictionary *) dHeaders
    {
        @try
        {
            //[ PROGRESS: show network progress
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            
            //[ HTTP: prepare our request
            NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:sUrl]];
            
            // HEADERS: Set the request's content type to application/x-www-form-urlencoded
            [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            
            // Designate the request a POST request and specify its body data
            [postRequest setHTTPMethod:@"POST"];
            [postRequest setHTTPBody:[NSData dataWithBytes:[sFormData UTF8String] length:strlen([sFormData UTF8String])]];
            
            
            //////////[ ASYNC: MAKE REQUEST ]//////////
            
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            
            [NSURLConnection sendAsynchronousRequest:postRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
             {
                 //[ go data?
                 if( [data length] > 0 && error == nil )
                 {
                     //[ ASSERT: that we have json data
                     if( [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] != nil )
                     {
                         //[ JSON: attempt to decode data if json object
                         NSData *dJsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                         
                         if( dJsonData )
                         {
                             //[ SUCCESS
                             NSMutableDictionary* dmJsonObject = [dJsonData mutableCopy];

                             //[ CORDOVA: prepare our response
                             CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dmJsonObject];
                             
                             //[ send back to ui for js
                             [self.commandDelegate sendPluginResult:pluginResult callbackId:sCallbackId];
                         }
                     }
                     else
                     {
                         //[ JSON: need to decode
                         NSString *sResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                         
                         
                         NSMutableDictionary *dmResponseObject = [[NSMutableDictionary alloc] initWithObjectsAndKeys:sResponse, @"response", nil];
                         
                         //[ ATTACH: our request id
                         [dmResponseObject setObject:sReqId forKey:@"reqid"];
                         
                        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dmResponseObject];
                        
                         //[ send back to ui for js
                         [self.commandDelegate sendPluginResult:pluginResult callbackId:sCallbackId];
                     }
                 }
                 else if ([data length] == 0 && error == nil)
                 {
                     // [delegate emptyReply];
                 }
                 else if (error != nil)
                 {
                     //[self sendFailureTo:sCallbackId];
                 }
             }];
        }
        @catch( NSException *exception )
        {
            NSLog(@"PaymentGatewayIO Exception: %@", exception.reason);


            //[ send exeception to UI
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
            
            NSString *responseJavascript = [result toErrorCallbackString:sCallbackId];
            
            if( responseJavascript )
                [self writeJavascript:responseJavascript];
        }
        @finally
        {
            //[ PROGRESS: hide network progress
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }

@end
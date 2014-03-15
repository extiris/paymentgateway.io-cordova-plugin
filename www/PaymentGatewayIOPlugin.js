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

/**
 * PaymentGateway.IO
 * Copyright 2014 Merchant Paid, LLC
 */

/*/[   S A M P L E   U S A G E :

<script type="text/javascript">
    //[ STEP 1: create our message
     
    var message = {
        pgio_api_key: ""a092cd65-9ef0-4c84-3dd2-0d3eb702acb9"",
        gateway: "authorizenet",
        type:  "sale",
        credentials: {
            api_login_id: "2bGt4dgzA4",
            transaction_key: "8We2fE62q87sLQ9c",
            sandbox: true
        },
        card_info: {
            account_name: "Test User",
            account_number: "4111111111111111",
            account_type: "VISA",
            expires_month: "07",
            expires_year: "2014",
            secure_code: "028",
             
            company: "Extiris",
            address: "123 Somewhereout Tr",
            city: "Grand Rapids",
            state: "MI",
            zip: "49503"
        },
        amount: 1.31,
        options: {
            customer_id: "123456"
        },

        //////////
        loading: function(){
            // triggered before our payment request is sent
            console.log("TEST: PGIORequest.loading");
        },
     
        //////////
        response: function(data){
            // triggered upon successful request from server
            console.log("TEST: PGIORequest.response: ", data);
        },
 
        //////////
        exception: function(error){
            console.log("TEST: PGIORequest.exception: ", error);
        },
 
        //////////
        error: function(data){
            // triggered on a server failure
            console.log("TEST: PGIORequest.error: ", data);
        },
            
        //////////
        complete: function(){
            // triggered when everything is all complete
            console.log("TEST: PGIORequest.complete");
        }
    };


    //[ STEP 2: send payment request
    window.plugins.pgio.ajax(message);
</script>
/**/


//[ PGIO: class definition
function PaymentGatewayIO() {
    this.queue = new Object();
}


PaymentGatewayIO.prototype = {
    
	//----------------------------------------------------------------------
    // @static
    //----------------------------------------------------------------------
    ajax: function(config)
    {
        var reqid = Math.random().toString().replace('.', '');
        
        
        try
        {
            //[ QUEUE: add request to our queue
            window.plugins.pgio.queue[reqid] = config;
            
            
            if( config == undefined )
                throw("Missing ajax config.");
            
            if( config.gateway == undefined )
                throw("Missing payment gateway.");
            
            if( config.credentials == undefined )
                throw("Missing gateway credentials");
            
            
            //[ REQID: assign our request id
            config.reqid = reqid;
            
            //[ EVENT > PROCESSING
            if( typeof(config.loading) === 'function' )
                config.loading();


            //[ DETERMINE: the trans type SALE|VOID|RETURN etc. no card_info is void/refund
            if( config.card_info != undefined )
            {
                //[ IS SALE
                
                //[ AMOUNT
                if( config.amount == undefined )
                    throw("Missing amount.");
                
                
                //[ OPTIONS
                config.options = (config.options != undefined) ? config.options : {};

                
                var params = new Array();
                
                params.push( config.pgio_api_key );
                params.push( config.credentials );
                params.push( config.card_info );
                params.push( config.amount );
                params.push( config.options );
                
                
                //[ SALE: APACHE CORDOVA
                cordova.exec(window.plugins.pgio.onServerResponse, window.plugins.pgio.onServerFailed, "PaymentGatewayIOPlugin", "JsonRpc", ["Sale", config.gateway, config.reqid, JSON.stringify(params) ] );
            }
            else
            {
                throw("Not yet implemented.");

                
                //[ IS VOID SALE
                
                //[ IS INTUIT VOID: add extra param
                
                
                //[ SALE: APACHE CORDOVA
                cordova.exec(window.plugins.pgio.onServerResponse, window.plugins.pgio.onServerFailed, "PaymentGatewayIOPlugin", "JsonRpc", ["Void", config.gateway, config.reqid, JSON.stringify(params) ] );
            }
            
        }
        catch(e)
        {
            //[ TODO: throw clean exception?
            console.warn("INTERNAL: PGIORequest > Exception: " + e);

            //[ UN/DE-QUEUE: remove from our queue due to error
            delete window.plugins.pgio.queue[reqid];
        }
    },
    
	//----------------------------------------------------------------------
    // @static
    //----------------------------------------------------------------------
    onServerResponse: function(data)
    {
        try
        {
            if( !(typeof(data) == "object" && data.hasOwnProperty("id")) )
                throw("Unable to parse json-rpc response.");
            
            
            //[ grab our request from queue
            var req_obj = window.plugins.pgio.queue[data.id];
            
            
            //[ ASSERT: is object
            if( typeof(req_obj) != "object" )
                throw("Item in queue was no longer an object.");
            

            if( data.result != undefined )
            {
                obj = data.result;
                
            }
            else if( data.error != undefined )
            {
                obj = {
                    type: "Exception",
                    code: data.error.code,
                    message: data.error.message
                };
            }
            
            
            //////////[  PROCESS RESPONSE  ]//////////
            
            
            //---[ check to see if we have an exceptoin ]---
            var is_exception = (obj.hasOwnProperty("type") && obj.type.indexOf("Exception") > -1);
            
            
            //---[ FOUND JSON EXCEPTION ]---
            if( is_exception )
            {
                if( obj.type != "NullException" )
                {
                    //[ EVENT > EXCEPTION
                    if( typeof(req_obj.exception) === 'function' )
                        req_obj.exception(obj, data);
                    
                    return false;
                }
                
                //[ set as null data type ]---
                obj = null;
            }
            
            
            //[ EVENT > SUCCESS
            if( typeof(req_obj.response) === 'function' )
                req_obj.response(obj, data);
            
            //[ EVENT > COMPLETE
            if( typeof(req_obj.complete) === 'function' )
                req_obj.complete();
        }
        catch(e)
        {
            //[ EVENT > FAIL
            if( typeof(req_obj.error) === 'function' )
                req_obj.error(e, data);
        }
    },
    
	//----------------------------------------------------------------------
    // @static
    //----------------------------------------------------------------------
    onServerFailed: function(data)
    {
        //[ TODO: lookup our reqid in queue
        console.error("PGIORequest.ServerFailed: ", data);
    }
};


//----------------------------------------------------------------------
/**
 * Plugin setup boilerplate.
 */
cordova.addConstructor(function()
{
    //[ init global plugins
    window.plugins = (window.plugins) ? window.plugins  : {};
                       
    //[ publish our plugin
    window.plugins.pgio = (window.plugins.pgio ) ? window.plugins.pgio  : new PaymentGatewayIO();
});
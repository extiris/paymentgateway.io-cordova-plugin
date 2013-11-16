/**
 * PaymentGateway.IO
 * Copyright 2014 Merchant Paid, LLC
 */
/*/
 
 //
 //[ S A M P L E    U S A G E :
 //
 
 
 var card_info = {
    account_name: "Test User",
    account_number: "41111111111111119", //[ bad card
    account_type: "VISA",
 
    secure_code: "092",
    expires_month: "7",
    expires_year: "17",
 
    company: "Extiris",
    address: "123 Somewhereout Tr",
    city: "Grand Rapids",
    state: "MI",
    zip: "49503"
 };
 
//[ INIT AND BIND ON DEVICE READY
window.plugins.payment_gateway_io.init("73585071-df1e-2814-09be-87f6cb94419c");
 
document.addEventListener('payment.success', function(e){
 
        //[ UI: show transaction complete form
        jQuery('#trans_id').html(e.detail.transaction_id);
 
        //[ PAGE: show payment received
        jQuery.mobile.changePage('#payment_received');
 
});
 
 
document.addEventListener('payment.error', function(e){
        jQuery('#er_msg').html(e.detail.exception.message).slideDown();
});
 
//[ MAKE PAYMENT
window.plugins.payment_gateway_io.pay(card_info, "1.27", "157", null, "authorizenet");
/**/


//[ EXCEPTION: used to handle errors
function Exception(message, type, code)
{
    this.type = (type != undefined) ? type : "Exception";
    this.code = (code != undefined) ? code : 0;
    this.message = (message != undefined) ? message : "";
    
    if( typeof(message) == "object" )
    {
        for(var property in message)
        {
            if( typeof(property) != "function")
                this[property] = message[property];
        }
    }
}


//[ REQUEST: used to handle the gateway requests
var PaymentIORequest = {
    
    /**
     * Used to determine if a transaction is already processing
     * @param bool
     */
    processing: false,
    
    
    //--------------------------------------------------
    /**
     * Handles the response object from the gateway and routes
     * to the proper event handler
     */
    //--------------------------------------------------
    onResponse: function(response)
    {
        try
        {
            //---[ attempt to convert response text to object ]---
            var obj = JSON.parse(response);
            
            
            //---[ FOUND JSON EXCEPTION ]---
            if( PaymentIORequest.isException(obj) )
            {
                if( obj.type != "NullException" )
                {
                    var ex_obj = new Exception(obj);
                    
                    
                    var event = new CustomEvent("payment.error", {"detail":{"exception":ex_obj}} );
                    
                    document.dispatchEvent(event);
                    
                    
                    return false;
                }
                
                //[ set as null data type ]---
                obj = null;
            }
            
            //[ TRIGGER: payment.success
            var event = new CustomEvent("payment.success", {"detail":{"transaction_id":obj}} );
            
            document.dispatchEvent(event);
        }
        catch(e)
        {
            //[ not json object string do nothing
            console.warn("PaymentIORequest.Exception: " + e);
            
            //[ TODO: trigger exception event
            var event = new CustomEvent("payment.parseerror", {"detail":{"error":e}} );
            document.dispatchEvent(event);
        }
        
        //[ TRIGGER: payment.complete
        var event = new CustomEvent("payment.complete", {} );
        
        document.dispatchEvent(event);
        
        //[ free us up for more payments
        PaymentIORequest.processing = false;
    },

    //--------------------------------------------------
    /** 
     * Triggered when our transaction has a network level error
     * 
     * Event name triggered: payment.failed
     */
    //--------------------------------------------------
    onFailed: function(exception)
    {
        var event = new CustomEvent("payment.failed", {"detail":{"exception":exception}} );
        
        document.dispatchEvent(event);
    },
    
    //----------------------------------------------------------------------
    /**
     * checks to determine if an object is an exception or not
     * 
     * @param obj<object> The data we are testing
     */
    //----------------------------------------------------------------------
    isException: function(obj)
    {
        if( typeof(obj) == "object" )
        {
            if( obj instanceof Exception )
                return true;
            
            //---[ we found an exception of sorts ]---
            if( obj.hasOwnProperty("type") )
            {
                if( (obj.type.indexOf("Exception") > -1)  || (obj.type.indexOf("SoapFault") > -1) )
                    return true;    
            }
        }           
        
        
        return false;
    }
};





//----------------------------------------------------------------------
/**
 * This class exposes paymentgateway.io payment processing functionality to JavaScript.
 *
 * @constructor
 */
function PaymentGatewayIO(){}



//----------------------------------------------------------------------
/**
 * Used to activate the api layer with your account key. visit 
 * merchantpaid.com to get your free account api key.
 *
 * @parameter callback: a callback function accepting a string.
 */
PaymentGatewayIO.prototype.init = function(api_key)
{
    try
    {
        //[ DATA ASSERTION: data processing
        if( api_key == undefined )
            throw("Missing api key.");

        //[ pass to the os
        cordova.exec(PaymentIORequest.onResponse, PaymentIORequest.onFailed, "PaymentGatewayIOPlugin", "init", [api_key]);
    }
    catch(e)
    {
        //[ TODO: throw clean exception?
        console.warn("Exception: " + e);
    }
};



//----------------------------------------------------------------------
/**
 * Used to make a payment and transfer funds from the card to the selected 
 * payment gateway
 *
 * @param card_info<object> JSON object containing the card details.
 * @param amount<number> Decimal value of the amount to charge the card
 * @param customer_id<number> This transaction links to this customer id in your db
 * @param options<object> Reserved. Just pass null or {}
 * @param gateway<string> The name of the gateway processing the card. (ex. authorizenet,stripe,intuit,beanstream)
 * @return string Transaction id used at the payment gateway
 */
PaymentGatewayIO.prototype.pay = function(card_info, amount, customer_id, options, gateway)
{
    try
    {
        //[ ensure we can process
        if( PaymentIORequest.processing )
            throw("Payment is already processing...");
        
        
        //[ DATA ASSERTION: data processing
        if( card_info == undefined )
            throw("Missing card info.");
        
        if( amount == undefined )
            throw("Missing amount.");

        if( customer_id == undefined )
            throw("Missing customer id.");
        
        if( gateway == undefined )
            throw("Missing payment gateway.");


        //[ OPTIONS
        options = (options != undefined) ? options : {};

        //[ begin our request and mark as busy
        PaymentIORequest.processing = true;

        
        //[ APACHE CORDOVA
        cordova.exec(PaymentIORequest.onResponse, PaymentIORequest.onFailed, "PaymentGatewayIOPlugin", "pay", [card_info, amount, customer_id, options, gateway]);
    }
    catch(e)
    {
        //[ TODO: throw clean exception?
        console.warn("Exception: " + e);
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
    window.plugins.payment_gateway_io = (window.plugins.payment_gateway_io) ?
                       window.plugins.payment_gateway_io : new PaymentGatewayIO();
});

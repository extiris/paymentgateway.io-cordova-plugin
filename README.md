PaymentGateway.io iOS plug-in for Phone Gap
---------------------------------

This plug-in exposes PaymentGateway.io credit card payment gateway networks.


Integration instructions
------------------------

* Add the paymentgateway.io library:
    * Sign up for an account at http://www.paymentgateway.io/, create an app, and take note of your `app_token`.
    * Download the [paymentgateway.io iOS SDK](https://github.com/paymentgateway-io/paymentgateway.io-iOS-SDK).
    * Follow the instructions on creating your app: [Apache Cordova](http://cordova.apache.org/docs/en/3.0.0/guide_cli_index.md.html)

* Add this plug-in:
    * Add `PaymentGatewayIOPlugin.[h|m]` to your project (Plugins group).
    * Copy `PaymentGatewayIOPlugin.js` to your project's `www` folder. (If you don't have a `www` folder yet, run in the Simulator and follow the instructions in the build warnings.)
    * Add e.g. `<script type="text/javascript" src="js/PaymentGatewayIOPlugin.js"></script>` to your html.
    * See `PaymentGatewayIOPlugin.js` for detailed usage information.
    * Add the following to `config.xml`, for PhoneGap version 3.0+:

         ```xml
        <feature name="PaymentGatewayIOPlugin">
          <param name="ios-package" value="PaymentGatewayIOPlugin" />
        </feature>
       ```
    
      for older versions under the `plugins` tag:
       
       ```xml
       <plugin name="PaymentGatewayIOPlugin" value="PaymentGatewayIOPlugin" />
       ``` 

    * Sample `init` usage:

      ```javascript

       window.plugins.payment_gateway_io.init("73585af1-df1e-2882-09be-87f6cb1119b");
                    
      ```


    * Sample `pay` usage:

      ```javascript

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
                    
        //[ MAKE PAYMENT
        window.plugins.payment_gateway_io.pay(card_info, "1.27", "157", null, "authorizenet");

      ```

### Sample HTML + JS

```html

<h1>Payment Demo Example</h1>
<script type="text/javascript">

function onDeviceReady() 
{
    window.plugins.payment_gateway_io.init("73585af1-df1e-2882-09be-87f6cb1119b");

                    
    document.addEventListener('payment.success', function(e){
                          
                          alert("PAID: " + e.detail.transaction_id);

                          //[ TODO: UI: show transaction success page
                       });
    
    
    document.addEventListener('payment.error', function(e){

                            alert("PAYMENT ERROR: " + e.detail.exception.message);

                            //[ TODO: UI: show error page
                        });
}
</script>
```

License
-------
* This plugin is released under the MIT license: http://www.opensource.org/licenses/MIT

Notes
-----
* paymentgateway.io supports iOS 6.0+.
* Having trouble getting started? Check out the [Phone Gap plugin getting started guide](http://docs.phonegap.com/en/3.0.0/guide_getting-started_ios_index.md.html#Getting%20Started%20with%20iOS).
* http://docs.phonegap.com/en/1.0.0/phonegap_events_events.md.html



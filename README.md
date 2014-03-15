PaymentGateway.io iOS plug-in for iOS Apache Cordova/Adobe Phone Gap
---------------------------------

This plug-in provides access to all major payment gateways using the PaymentGateway.io api.


Integration instructions
------------------------

* Add the paymentgateway.io library:
    * Sign up for an account at https://paymentgateway.io, create a free account and take note of your `api_key`.
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


    * Sample `pay` usage:

      ```javascript

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
  

      ```


License
-------
* This plugin is released under the MIT license: http://www.opensource.org/licenses/MIT

Notes
-----
* paymentgateway.io supports iOS 6.0+.
* Having trouble getting started? Check out the [Phone Gap plugin getting started guide](http://docs.phonegap.com/en/3.0.0/guide_getting-started_ios_index.md.html#Getting%20Started%20with%20iOS).
* http://docs.phonegap.com/en/1.0.0/phonegap_events_events.md.html
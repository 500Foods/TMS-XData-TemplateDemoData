# Messaging Service
The Messaging Service endpoints provide access to send and recevie SMS messages, and potentially other messages (MMS and WhatsApp potentially), using third-party REST APIs. Currently, Twilio has been implemented, but others may soon follow.

### Configuration
In order for these endpoints to work, a number of configuration parameters must be passed to the XData application.  This is typically done by creating a suitably popupalted JSON file, and then using the CONFIG command-line parameter to tell the XData application where it is.

### Twilio
Here's what a configuration file might look like when using the OpenAI ChatGPT API.
```
    "Messaging Services":{ 
      "Twilio": { 
        "Service Name":"Twilio Messaging", 
        "Account": "AC5346342f844fc5b7dd41412ed8eXXXXX", 
        "Auth Token": "df21f3f76799992f8b52164021bXXXXX", 
        "Send URL":"https://api.twilio.com/2010-04-01/Accounts/AC5346342f844fc5b7dd41412ed8eXXXXX/Messages.json", 
        "Messaging Services":[ 
          {"500 Dashboards Notify":"MGec8ddf1c3187241921577f73f5XXXXX"},  
          {"500 Dashboards Support":"MGec8ddf1c3187241921577f73fYYYYY"},  
          {"500 Dashboards Billing":"MGec8ddf1c3187241921577f73f5ZZZZZ"}  
        ]  
      }  
    }  
```

### Additional Information
The details of this implementation first appeared as the subject of a blog post on the TMS Software website, which can be found [here](https://www.tmssoftware.com/site/blog.asp?post=1159)https://www.tmssoftware.com/site/blog.asp?post=1159.

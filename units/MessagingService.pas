unit MessagingService;

interface

uses
  System.Classes,
  XData.Security.Attributes,
  XData.Service.Common;

type
  [ServiceContract]
  IMessagingService = interface(IInvokable)
    ['{51CE7921-7949-40C2-ACB9-257998E2F054}']


    ///  <summary>
    ///    Twilio Webhook Callback
    ///  </summary>
    ///  <remarks>
    ///    After sending a message, Twilio issues a webhook callback to here
    ///    with the details of the transaction. Incoming messages arrive here
    ///    as well.
    ///  </remarks>
    ///  <param name="Incoming">
    ///    This is the body of the Twilio message which may contain a number
    ///    of URL-encoded parameters.
    ///  </param>
    [HttpPost] function Callback(Incoming: TStream):TStream;


    ///  <summary>
    ///    Handle Webhook Fallback - Same as Callback, reallly
    ///  </summary>
    ///  <remarks>
    ///    After sending a message, Twilio issues a webhook callback to here
    ///    with the details of the transaction if the callback doesn't get a
    ///    suitably formatted response
    ///  </remarks>
    ///  <param name="Incoming">
    ///    This is the body of the Twilio message which may contain a number
    ///    of URL-encoded parameters.
    ///  </param>
    [HttpPost] function Fallback(Incoming: TStream):TStream;

    ///  <summary>
    ///    Send an SMS via Twilio Programmable Messaging System
    ///  </summary>
    ///  <remarks>
    ///    This is used to send SMS messages from a central source.
    ///  </remarks>
    ///  <param name="MessageService">
    ///    The Twilio Messaging Service identifier, which in turn is linked to one or more phone numbers.
    ///  </param>
    ///  <param name="Destination">
    ///    The SMS number to send to (typically a 10-digit mobile phone number).
    ///  </param>
    ///  <param name="AMessage">
    ///    The body of the message.
    ///  </param>
    [HttpPost] function SendAMessage(MessageService: String; Destination: String; AMessage: String):TStream;

    ///  <summary>
    ///    Get incoming SMS messages
    ///  </summary>
    ///  <remarks>
    ///    This is used to receive SMS messages from a central source.
    ///  </remarks>
    ///  <param name="Destination">
    ///    The SMS number receiving from (same as the SendAMessage destionation). The idea here
    ///    is to have the inbound and outbound tagged with the same value so we can see a conversation.
    ///  </param>
    ///  <param name="Since">
    ///    Used to limit the messages to those received after a point in time, so as to reduce
    ///    the size of this request. yyyy-mm-dd hh:nn:ss format.
    ///  </param>
    [HttpPost] [Authorize] function GetMessages(Destination: String; Since: String):TStream;

  end;

implementation

initialization
  RegisterServiceType(TypeInfo(IMessagingService));

end.

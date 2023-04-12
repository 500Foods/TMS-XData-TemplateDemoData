unit ChatService;

interface

uses
  System.Classes,
  XData.Security.Attributes,
  XData.Service.Common;

type
  [ServiceContract]
  IChatService = interface(IInvokable)
    ['{F95E651C-DA7A-4997-8630-314587B1857F}']

    /// Chat
    ///  <summary>
    ///    Submit a conversation to OpenAI, along with context, get a response.
    ///  </summary>
    ///  <remarks>
    ///    There are limits to the overall conversation, typically 4096 tokens,
    ///    which includes the current conversation, the context, and the response.
    ///  </remarks>
    ///  <param name="Conversation">
    ///   The next part of our conversation.
    ///  </param>
    ///  <param name="Context">
    ///    The prior portions of the conversation that we would like to include to
    ///    give the model the opportunity to include it when coming up with a reponse.
    ///    This is what gives our chat the illusion of knowing about prior responses.
    ///    It doesn't, really, so we have to supply them each time.
    ///  </param>
    ///  <param name="ChatID">
    ///    A unique identifier for the chat.  This is used to store the chat, and subsequent
    ///    updates to the chat, in a server database, and helps ensure that we just end up
    ///    with a single copy of the conversation when we're done.
    ///  </param>
    [HttpGet] function Chat(Conversation:String; Context: String; ChatID: String):TStream;
  end;

implementation

initialization
  RegisterServiceType(TypeInfo(IChatService));

end.

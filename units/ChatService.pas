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
    ///    There are limits to the overall conversation, typically 4096 tokens, which includes the current conversation, the context, and the response.
    ///  </remarks>
    ///  <param name="Model">
    ///    The name of the model to use for this chat.  The model name should be selected from the list provided by GetChatInformation, which is the user-viewable name, not the internal chat model name.
    ///  </param>
    ///  <param name="Conversation">
    ///   The next part of the conversation.
    ///  </param>
    ///  <param name="Context">
    ///    The prior portions of the conversation that we would like to include to give the model the opportunity to include it when coming up with a reponse. This is what gives our chat the illusion of knowing about prior responses. It doesn't, really, so we have to supply them each time.
    ///  </param>
    ///  <param name="Choices">
    ///    An integer that indicates how many choices to return.  For normal chat conversations, this is typically going to be "1".  For images, this might be any value from 1 to 10.
    ///  </param>
    ///  <param name="ChatID">
    ///    A unique identifier for the chat.  This is used to store the chat, and subsequent updates to the chat, in a server database, and helps ensure that we just end up with a single copy of the conversation when we're done.
    ///  </param>
    [Authorize] [HttpPost] function Chat([XDefault('ChatGPT 3.5')] Model: String; Conversation: String; [XDefault('None')] Context: String; [XDefault(1)] Choices: Integer; [XDefault('Swagger Testing')] ChatID: String):TStream;

    /// GetChatInformation
    ///  <summary>
    ///    Returns JSON that describes various aspects of the chat subsystem, like what models are available, and other statistical information.
    ///  </summary>
    ///  <remarks>
    ///    No parameters here as the block of JSON is the same regardless.
    ///  </remarks>
    [Authorize] [HttpGet] function GetChatInformation:TStream;

    /// GetChatInformation
    ///  <summary>
    ///    Returns JSON that describes various aspects of the chat subsystem, like what models are available, and other statistical information.
    ///  </summary>
    ///  <remarks>
    ///    No parameters here as the block of JSON is the same regardless.
    ///  </remarks>
    [HttpGet] function GetChatImage(F: String):TStream;

  end;

implementation

initialization
  RegisterServiceType(TypeInfo(IChatService));

end.

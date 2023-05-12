# Chat Service
The Chat Service endpoints provide access to either the OpenAI ChatGPT service, or to GPT4All, depending on how the installation is configured.  These enpdoints facilitate back-and-forth chat conversations, logging chats, viewing past chats, and other chat-related statistics to be used in the main Chat Dashboard within the TMS WEB Core Template Demo project.

### Configuration
In order for these endpoints to work, a number of configuration parameters must be passed to the XData application.  This is typically done by creating a suitably popupalted JSON file, and then using the CONFIG command-line parameter to tell the XData application where it is.

### OpenAI
Here's what a configuration file might look like when using the OpenAI ChatGPT API.
```
  {
      "Name": "ChatGPT 3.5",
      "Default": true,
      "Model": "gpt-3.5-turbo",
      "Organization": "your-org-identifier-here",
      "API Key": "your-api-key-here",
      "Endpoint": "https://api.openai.com/v1/chat/completions",
      "Limit": 4096,
      "Cost Prompt": 0.000002,
      "Cost Completion": 0.000002
    }
```

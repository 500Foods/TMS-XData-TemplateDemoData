# Chat Service
The Chat Service endpoints provide access to either the OpenAI ChatGPT service, or to GPT4All, depending on how the installation is configured.  These enpdoints facilitate back-and-forth chat conversations, logging chats, viewing past chats, and other chat-related statistics to be used in the main Chat Dashboard within the TMS WEB Core Template Demo project.

## Configuration
In order for these endpoints to work, a number of configuration parameters must be passed to the XData application.  This is typically done by creating a suitably popupalted JSON file, and then using the CONFIG command-line parameter to tell the XData application where it is.

## OpenAI
Here's what a configuration file might look like when using the OpenAI ChatGPT API.
```
{
  "Chat Interface": {
    "Model":"gpt-3.5-turbo",
    "Organization":"org-1234rpR1abcdVuQp1m6qPXYZ",
    "API Key":"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",
    "Chat Endpoint":"https://api.openai.com/v1/chat/completions",
    "Image Endpoint":"https://api.openai.com/v1/images/generations"
  }
}
```

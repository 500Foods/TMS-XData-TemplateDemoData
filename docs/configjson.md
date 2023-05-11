## Config.json

When the XData server first starts, it checks to see if a configuration JSON file is available. XData first checks the application directory (wherever the application is launched from) for a .json file with the same name as the application (eg: project1.json). This location can be overriden by passsing a CONFIG parameter (eg: CONFIG=c:\data\config.json) to the XData application. If neither are available, defaults will provided for all values.  As a result, the configuration file is entirely optional. This is the expected configuration during intial development and testing.  However, once the project is deployed, a configuration JSON file will most likely be needed. This is how the BaseURL property is set, if it isn't otherwise altered in code.


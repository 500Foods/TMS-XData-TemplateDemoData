# TMS XData Template: Demo Data
This repository contains a [TMS XData](https://www.tmssoftware.com/site/xdata.asp) project - a REST API server - that serves up a variety of endpoints and sample data.  This may be useful for those first learning to use TMS XData in their own projects.  Or as a template for starting a new TMS XData project, with many core features, like Swagger and a Login endpoint, already in place. This project originated as part of a series of blog posts about using TMS XData and [TMS WEB Core](https://www.tmssoftware.com/site/tmswebcore.asp) with different kinds of templates, the first of which can be found [here](https://www.tmssoftware.com/site/blog.asp?post=1068).

A second repository, [TMS WEB Core Template Demo](https://github.com/500Foods/TMS-WEB-Core-TemplateDemo), contains the implementation of an example web client application that works specifically with this REST API.  It was created using a pre-release build of the [AdminLTE 4](https://github.com/ColorlibHQ/AdminLTE/tree/v4-dev) admin template, which works with Bootstrap 5.

## Getting Started
In order to get the most of this repository, you'll need [Delphi](https://www.embarcadero.com/products/delphi) version 10 or later, as well as a current version of [TMS XData](https://www.tmssoftware.com/site/xdata.asp). Note that these are licensed commercial products, but trial versions of both are available on their respective websites.  Please review [The Unlicense](https://github.com/500Foods/TMS-XData-TemplateDemoData/blob/main/LICENSE) that applies to this repository.

The contents of this repository consist of a fully funcitional TMS XData project.  It can be compiled and run as-is without further modification, which will generate a Win64 REST API server application.  Several endpoints, sample data, a SQLite database, and Swagger are already configured.  

![image](https://user-images.githubusercontent.com/41052272/222645643-2827211b-6750-45d5-ad8e-db758ed194e6.png)
*XData Server Application Running*

Not much to look at, honestly, but that's just the server application.  All it is primarily used for is starting and stopping the REST API server, and as it starts automatically, there's usually not much need to use it directly, hence the lack of much of a UI. The recommended way to test its functions is through the use of its Swagger interface, which is already configured in this project.

![image](https://user-images.githubusercontent.com/41052272/222646739-118e88fd-e47d-4bbf-b17a-90af3499b1da.png)
*Testing with Swagger Interface*

## Services
Most of the services are collections of endpoints that are intended to support a particular Dashboard. Many of the endpoints are used as a front-end to one or more SQL queries against one or more underlying databases.  As there is no ORM used here, the only access to these databases is through these endpoints.  This means there are likely to be endpoints needed to cover any CRUD operations that a client may want to issue. Many endpoints have parameters that allow more than one of these kinds of operations from the same endpoint.

Some services are also more complex, interfacing to other systems, as is the case with the Chat Service, or require additional configuration to be fully operational, which also happens to be the case with the Chat Service.  Please refer to the documentation for each individual service you plan on using for additional information.

* [Chat Service](https://github.com/500Foods/TMS-XData-TemplateDemoData/blob/main/docs/ChatService.md)
* [Dashboard Service](https://github.com/500Foods/TMS-XData-TemplateDemoData/blob/main/docs/DashboardService.md)
* [Messaging Service](https://github.com/500Foods/TMS-XData-TemplateDemoData/blob/main/docs/MessagingService.md)
* [Person Service](https://github.com/500Foods/TMS-XData-TemplateDemoData/blob/main/docs/PersonService.md)
* [System Service](https://github.com/500Foods/TMS-XData-TemplateDemoData/blob/main/docs/SystemService.md)

## Documentation
While the code is intended to be straightforward, and the blog is intended to be the primary introduction to this project, other documentation will be added as issues arise.  
- [Config.JSON](https://github.com/500Foods/TMS-XData-TemplateDemoData/blob/main/docs/ConfigJSON.md)
- [Accounts](https://github.com/500Foods/TMS-XData-TemplateDemoData/blob/main/docs/Accounts.md)

## Key Dependencies
As with any modern application, other libraries/dependencies have been used in this project.
- [TMS XData](https://www.tmssoftware.com/site/tmswebcore.asp) - This is a TMS XData project, after all
- [TMS Cryptography Pack](https://www.tmssoftware.com/site/tmscrypto.asp) - Supples the SHA-256 hash function
- [TZDB](https://github.com/pavkam/tzdb) - Comprehensive IANA TZ library for Delphi

## Usage Note: RandomDLL.DLL
This DLL needs to be included in the same folder as the project executable. It is needed by the SHA-256 hash function that is used in several places, that, in turn, comes from the [TMS Cryptography Pack](https://www.tmssoftware.com/site/tmscrypto.asp). A post-build event has been added to the project to do this automatically.  This assumes that a Win64 project is being built.  Please adjust accordingly.

## Contributions
Initially, this example uses SQLite as its database, as well as a collection of include files for all of the SQL operations that have been implemented so far.  Over time, this will be expanded to include support for more databases and more queries.  If there's a database you'd like to see included in the template, by all means please post an Issue or, if you're able, make a Pull Request and we'll see that it gets added.

## Repository Information
[![Count Lines of Code](https://github.com/500Foods/TMS-XData-TemplateDemoData/actions/workflows/main.yml/badge.svg)](https://github.com/500Foods/TMS-XData-TemplateDemoData/actions/workflows/main.yml)
<!--CLOC-START -->
```
Last Updated at 2023-12-24 05:18:19 UTC
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Pascal                          15           1524           2766          12948
Markdown                         8             36              2            218
Delphi Form                      3              0              0            155
YAML                             2              8             12             33
Text                             1              0              0              1
-------------------------------------------------------------------------------
SUM:                            29           1568           2780          13355
-------------------------------------------------------------------------------
```
<!--CLOC-END-->

## Sponsor / Donate / Support
If you find this work interesting, helpful, or valuable, or that it has saved you time, money, or both, please consider directly supporting these efforts financially via [GitHub Sponsors](https://github.com/sponsors/500Foods) or donating via [Buy Me a Pizza](https://www.buymeacoffee.com/andrewsimard500). Also, check out these other [GitHub Repositories](https://github.com/500Foods?tab=repositories&q=&sort=stargazers) that may interest you.

## More TMS WEB Core and TMS XData Content
If you're interested in other TMS WEB Core and TMS XData content, follow along on 𝕏 at [@WebCoreAndMore](https://x.com/WebCoreAndMore), join our 𝕏 [Web Core and More Community](https://twitter.com/i/communities/1683267402384183296), or check out the [TMS Software Blog](https://www.tmssoftware.com/site/blog.asp).

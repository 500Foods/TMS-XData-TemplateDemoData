# TMS XData Template: Demo Data
This repository contains a [TMS XData](https://www.tmssoftware.com/site/xdata.asp) project - a REST API server - that serves up a variety of endpoints and sample data.  This may be useful for those first learning to use TMS XData in their own projects.  Or as a template for starting a new TMS XData project, with many core features, like Swagger and a Login endpoint, already in place. This project originated as part of a series of blog posts about using TMS XData and [TMS WEB Core](https://www.tmssoftware.com/site/tmswebcore.asp) with different kinds of templates, the first of which can be found [here](https://www.tmssoftware.com/site/blog.asp?post=1068).

A second repository, [TMS WEB Core Template Demo](https://github.com/500Foods/TMS-WEB-Core-TemplateDemo), contains the implementation of an example web client application that works specifically with this REST API.  It was created using a pre-release build of the [AdminLTE 4](https://github.com/ColorlibHQ/AdminLTE/tree/v4-dev) admin template, which works with Bootstrap 5.

## Getting Started
In order to get the most of this repository, you'll need [Delphi](https://www.embarcadero.com/products/delphi) version 10 or later, as well as a current version of [TMS XData](https://www.tmssoftware.com/site/xdata.asp). Note that these are licensed commercial products, but trial versions of both are available on their respective websites.  Please review [The Unlicense](https://github.com/500Foods/TMS-XData-TemplateDemoData/blob/main/LICENSE) that applies to this repository.

The contents of this repository consist of a fully funcitional TMS XData project.  It can be compiled and run as-is without further modification, which will generate a Win64 REST API server application.  Several endpoints, sample data, a SQLite database, and Swagger are already configured. Please refer to the blog post referenced above for more information.

## Usage Note: RandomDLL.DLL
This DLL needs to be included in the same folder as the project executable. It is needed by the SHA-256 hash function that is used in several places, that, in turn, comes from the [TMS Cryptography Pack](https://www.tmssoftware.com/site/tmscrypto.asp).

## Key Dependencies
As with any modern application, other libraries/dependencies have been used in this project.
- [TMS XData](https://www.tmssoftware.com/site/tmswebcore.asp) - This is a TMS XData project, after all
- [TZDB](https://github.com/pavkam/tzdb) - Comprehensive IANA TZ library for Delphi
- [TMS Cryptography Pack](https://www.tmssoftware.com/site/tmscrypto.asp) - Supples the SHA-256 hash function

## Contributions
Initially, this example uses SQLite as its database, as well as a collection of include files for all of the SQL operations that have been implemented so far.  Over time, this will be expanded to include support for more databases and more queries.  If there's a database you'd like to see included in the template, by all means please post an Issue or, if you're able, make a Pull Request and we'll see that it gets added.

## Sponsor / Donate / Support
If you find this work interesting, helpful, or useful, or that it has sved you time, money, or both, please consider direclty supporting these efforts financially via [GitHub Sponsors](https://github.com/sponsors/500Foods) or donating via [Buy Me a Pizza](https://www.buymeacoffee.com/andrewsimard500). Also, be sure to check out these other [GitHub Repositories](https://github.com/500Foods?tab=repositories&q=&sort=stargazers) that may be of interest to you.

# Accounts
In order to login, the client application will need to use the PersonService to authenticate and retrieve the necessary authorization for a given account - essentially a JWT.

Briefly, this involves comparing a username/password with data contained in the ***person*** table. Sample data has been provided for this purpose, and is defined in the [DDL](https://github.com/500Foods/TMS-XData-TemplateDemoData/blob/main/ddl/person/person_sqlite.inc) for that table. 

In addition, the person needs to have the "login role" assigned, where the login role is defined as role_id = 0.  This is managed using the ***person_role*** table.

Default Administrator Credentials:
```
 Username: SYSINSTALLER
 Password: TMSWEBCore
```
Naturally, this sample content should be replaced with actual data before deploying this project anywhere publicly visible.

Note that the password is stored as an SHA-256 digest of the password, with the "XData-Password:" prefix added to the password before it is hashed.

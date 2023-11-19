// [table] person
//
// Names were randomly generated - any resemblance to actual people, living or dead, etc. etc.
// The first names were drawn from the following link
// https://www.babycenter.com/baby-names/most-popular/top-baby-names
// The last names were drawn from the following link
// https://selectsurnames.com/top-300-surnames/

TableName := 'person';

if (DatabaseEngine = 'sqlite') then
begin

  with Query1 do
  begin

    // Check if the table exists
    SQL.Clear;
    SQL.Add('select count(*) records from '+TableName+';');
    try
      Open;
      LogEvent('...'+TableName+' ('+IntToStr(FieldByName('records').AsInteger)+' records)');

    except on E:Exception do
      begin
        LogEvent('...'+TableName+' (CREATE)');
        SQL.Clear;
        SQL.Add('create table if not exists '+TableName+' ( '+
                '  person_id                  integer     NOT NULL, '+
                '  last_modified              text        NOT NULL, '+
                '  last_modifier              integer     NOT NULL, '+
                '  first_name                 text        NOT NULL, '+
                '  middle_name                text                , '+
                '  last_name                  text        NOT NULL, '+
                '  birthdate                  text                , '+
                '  account_name               text        NOT NULL, '+
                '  password_hash              text        NOT NULL, '+
                '  CONSTRAINT constraint_name PRIMARY KEY (person_id), '+
                '  UNIQUE(account_name)'+
                ');'
               );
        ExecSQL;

        // Try it again
        SQL.Clear;
        SQL.Add('select count(*) records from '+TableName+';');
        Open;
      end;
    end;

    // Populate empty table with sample data
    if (FieldByName('records').AsInteger = 0) then
    begin
      LogEvent('...'+TableName+' (POPULATE)');
      SQL.Clear;

      // Default password for SYSINSTALLER is "TMSWEBCore" - Passwords are SHA256 Hashes with a prefix of XData-Password:
      SQL.Add('insert into '+TableName+' values(0000000000, Datetime("now"), 0, "Original", "System", "Installer", "1971-05-25", "SYSINSTALLER", "f40154051817192179edb9dabaec056fdb0eacd977fb443b2fe69232cff23fd4" );'); // TMSWEBCore

      // Default password for SYSADMIN is not set - Deliberately.  This account is just used when logging system-level functions, and can't be used to login.
      SQL.Add('insert into '+TableName+' values(0000000001, Datetime("now"), 0, "Server", "", "Administration", "1977-01-17", "SYSADMIN", "NO PASSWORD SET" );');

      // Random data
      SQL.Add('insert into '+TableName+' values(0010010001, Datetime("now"), 0, "Olivia",    "A", "Smith",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "OSMITH",      "b2cc479bdcabf5bb5964321e9cdd6808c100289e3dcd68fb911d5145423ba706" );'); // hellothere
      SQL.Add('insert into '+TableName+' values(0010020002, Datetime("now"), 0, "Liam",      "B", "Jones",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LJONES",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0010030003, Datetime("now"), 0, "Emma",      "C", "Williams",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EWILLIAMS",   "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0010040004, Datetime("now"), 0, "Noah",      "D", "Brown",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "NBROWN",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0010050005, Datetime("now"), 0, "Amelia",    "E", "Johnson",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AJOHNSON",    "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0010060006, Datetime("now"), 0, "Oliver",    "F", "Taylor",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "OTAYLOR",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0010070007, Datetime("now"), 0, "Ava",       "G", "Davis",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ADAVIS",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0010080008, Datetime("now"), 0, "Elijah",    "H", "Miller",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EMILLER",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0010090009, Datetime("now"), 0, "Sophia",    "I", "Wilson",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "SWILSON",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0010000010, Datetime("now"), 0, "Mateo",     "J", "Thompson",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MTHOMPSON",   "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0010010011, Datetime("now"), 0, "Isabella",  "K", "Thomas",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ITHOMAS",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0010020012, Datetime("now"), 0, "Lucas",     "L", "Anderson",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LANDERSON",   "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0010030012, Datetime("now"), 0, "Luna",      "M", "White",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LWHITE",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0020040013, Datetime("now"), 0, "Levi",      "N", "Martin",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LMARTIN",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0020050014, Datetime("now"), 0, "Mia",       "O", "Moore",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MMOORE",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0020060015, Datetime("now"), 0, "Asher",     "P", "Jackson",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AJACKSON",    "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0020070016, Datetime("now"), 0, "Charlotte", "Q", "Clark",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "CCLARK",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0020080017, Datetime("now"), 0, "James",     "R", "Walker",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JWALKER",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0020090018, Datetime("now"), 0, "Evelyn",    "S", "Evans",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EEVANS",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0020000019, Datetime("now"), 0, "Leo",       "T", "Lee",         "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LLEE",        "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0020010020, Datetime("now"), 0, "Harper",    "U", "Lewis",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "HLEWIS",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0030020021, Datetime("now"), 0, "Grayson",   "V", "King",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "GKING",       "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0030030022, Datetime("now"), 0, "Scarlett",  "W", "Harris",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "SHARRIS",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0030040023, Datetime("now"), 0, "Ezra",      "X", "Roberts",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EROBERTS",    "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0030050024, Datetime("now"), 0, "Nova",      "Y", "Robinson",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "NROBINSON",   "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0030060025, Datetime("now"), 0, "Luca",      "Z", "Wright",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LWRIGHT",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0030070026, Datetime("now"), 0, "Aurora",    "A", "Young",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AYOUNG",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0030080027, Datetime("now"), 0, "Ethan",     "B", "Scott",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ESCOTT",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0030090028, Datetime("now"), 0, "Ella",      "C", "Reed",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EREED",       "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0040000029, Datetime("now"), 0, "Aiden",     "D", "Murphy",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AMURPHY",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0040010031, Datetime("now"), 0, "Mila",      "E", "Hill",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MHILL",       "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0040020032, Datetime("now"), 0, "Wyatt",     "F", "Wood",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "WWOOD",       "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0050030033, Datetime("now"), 0, "Aria",      "G", "Hall",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AHALL",       "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0050040034, Datetime("now"), 0, "Sebastian", "H", "Green",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "SGREEN",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0050050035, Datetime("now"), 0, "Ellie",     "I", "Allen",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EALLEN",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0070060036, Datetime("now"), 0, "Benjamin",  "J", "Kelly",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "BKELLY",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0070070037, Datetime("now"), 0, "Gianna",    "K", "Campbell",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "GCAMPBELL",   "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0070080038, Datetime("now"), 0, "Mason",     "L", "Edwards",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MEDWARDS",    "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0080090039, Datetime("now"), 0, "Sofia",     "M", "Adams",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "SADAMS",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0080000040, Datetime("now"), 0, "Henry",     "N", "Baker",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "HBAKER",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0080010041, Datetime("now"), 0, "Violet",    "O", "Watson",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "VWATSON",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0080010042, Datetime("now"), 0, "Hudson",    "P", "Mitchell",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "HMITCHELL",   "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0090010043, Datetime("now"), 0, "Layla",     "Q", "Phillips",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LPHILLIPS",   "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0090010044, Datetime("now"), 0, "Jack",      "R", "Cooper",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JCOOPER",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0090020045, Datetime("now"), 0, "Willow",    "S", "Turner",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "WTURNER",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0090020046, Datetime("now"), 0, "Jackson",   "T", "Morris",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JMORRIS",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0090030047, Datetime("now"), 0, "Lily",      "U", "Carter",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LCARTER",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0090040048, Datetime("now"), 0, "Owen",      "V", "Morgan",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "OMORGAN",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0090040049, Datetime("now"), 0, "Hazel",     "W", "Hughes",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "HHUGHES",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0090050051, Datetime("now"), 0, "Daniel",    "X", "Cook",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "DCOOK",       "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0090060052, Datetime("now"), 0, "Camila",    "Y", "Ward",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "CWARD",       "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0090060053, Datetime("now"), 0, "Alexander", "Z", "Collins",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ACOLLINS",    "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0090070054, Datetime("now"), 0, "Avery",     "A", "James",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AJAMES",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0100080055, Datetime("now"), 0, "Maverick",  "B", "Parker",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MPARKER",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0100080056, Datetime("now"), 0, "Chloe",     "C", "Bell",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "CBELL",       "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0100080057, Datetime("now"), 0, "Kai",       "D", "Nelson",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "KNELSON",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110080058, Datetime("now"), 0, "Elena",     "E", "Stewart",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ESTEWART",    "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110090059, Datetime("now"), 0, "Gabriel",   "F", "Bailey",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "GBAILEY",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110090061, Datetime("now"), 0, "Paisley",   "G", "Stevens",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "PSTEVENS",    "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110090062, Datetime("now"), 0, "Carter",    "H", "Cox",         "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "CCOX",        "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110000063, Datetime("now"), 0, "Eliana",    "I", "Bennett",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EBENNETT",    "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110010064, Datetime("now"), 0, "William",   "J", "Murray",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "WMURRAY",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110010065, Datetime("now"), 0, "Penelope",  "K", "Rogers",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "PROGERS",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110010066, Datetime("now"), 0, "Logan",     "L", "Gray",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LGRAY",       "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110010067, Datetime("now"), 0, "Eleanor",   "M", "Price",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EPRICE",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110010068, Datetime("now"), 0, "Michael",   "N", "Ryan",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MRYAN",       "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110010069, Datetime("now"), 0, "Ivy",       "O", "McDonald",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "IMCDONALD",   "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110010070, Datetime("now"), 0, "Samuel",    "P", "Russell",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "SRUSSELL",    "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110010071, Datetime("now"), 0, "Elizabeth", "Q", "Richardson",  "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ERICHARDSON", "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110010072, Datetime("now"), 0, "Muhammad",  "R", "Harrison",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MHARRISON",   "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110010073, Datetime("now"), 0, "Riley",     "S", "Sanders",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "RSANDERS",    "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110110074, Datetime("now"), 0, "Waylon",    "T", "Walsh",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "WWALSH",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110110075, Datetime("now"), 0, "Isla",      "U", "O''Connor",   "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "IOCONNOR",    "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110210076, Datetime("now"), 0, "Ezekiel",   "V", "Simpson",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ESIMPSON",    "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110210077, Datetime("now"), 0, "Abigail",   "W", "Marshall",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AMARSHALL",   "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110310078, Datetime("now"), 0, "Jayden",    "X", "Ross",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JROSS",       "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110310079, Datetime("now"), 0, "Nora",      "Y", "Perry",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "NPERRY",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110410080, Datetime("now"), 0, "Luke",      "Z", "O''Brien",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LOBRIEN",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110510081, Datetime("now"), 0, "Stella",    "A", "Kennedy",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "SKENNEDY",    "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110010082, Datetime("now"), 0, "Lincoln",   "B", "Graham",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LGRAHAM",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110610083, Datetime("now"), 0, "Grace",     "C", "Foster",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "GFOSTER",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0110610084, Datetime("now"), 0, "Theo",      "D", "Shaw",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "TSHAW",       "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0120610085, Datetime("now"), 0, "Zoey",      "E", "Ellis",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ZELLIS",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0012710086, Datetime("now"), 0, "Jacob",     "F", "Griffiths",   "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JGRIFFITHS",  "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0120810087, Datetime("now"), 0, "Emily",     "G", "Fisher",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EFISHER",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0120810088, Datetime("now"), 0, "Josiah",    "H", "Butler",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JBUTLER",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0120910089, Datetime("now"), 0, "Emilia",    "I", "Reynolds",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EREYNOLDS",   "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0120910090, Datetime("now"), 0, "David",     "J", "Fox",         "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "DFOX",        "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0120910091, Datetime("now"), 0, "Leilani",   "K", "Robertson",   "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LROBERTSON",  "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0120910092, Datetime("now"), 0, "Jaxon",     "L", "Barnes",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JBARNES",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0120910093, Datetime("now"), 0, "Everly",    "M", "Chapman",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ECHAPMAN",    "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0120910094, Datetime("now"), 0, "Elias",     "N", "Powell",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EPOWELL",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0120910095, Datetime("now"), 0, "Kinsley",   "O", "Fraser",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "KFRASER",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0120910096, Datetime("now"), 0, "Julian",    "P", "Mason",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JMASON",      "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0120910097, Datetime("now"), 0, "Athena",    "Q", "Henderson",   "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AHENDERSON",  "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0120910098, Datetime("now"), 0, "Theodore",  "R", "Hamilton",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "THAMILTON",   "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0120910099, Datetime("now"), 0, "Delilah",   "S", "Peterson",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "DPETERSON",   "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0120910100, Datetime("now"), 0, "Isaiah",    "T", "Howard",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "IHOWARD",     "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0120910101, Datetime("now"), 0, "Naomi",     "U", "O''Sullivan", "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "NOSULLIVAN",  "NO PASSWORD SET" );');
      SQL.Add('insert into '+TableName+' values(0120910102, Datetime("now"), 0, "Matthew",   "V", "Brooks",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MBROOKS",     "NO PASSWORD SET" );');

      ExecSQL;
    end;
  end;
end;































































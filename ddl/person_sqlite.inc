  // person
  with FDQuery1 do
  begin

    SQL.Clear;
    SQL.Add('create table if not exists person ( '+
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

    SQL.Clear;
    SQL.Add('select '+
            '  count(*) records '+
            'from '+
            '  person;'
           );
    Open;

    if FieldByName('records').AsInteger = 0 then
    begin
      SQL.Clear;

      // Default password for SYSINSTALLER is "TMSWEBCore" - Passwords are SHA256 Hashes with a prefix of TMS-XData-PASSWORD:
      SQL.Add('insert into person values(0000000000, current_timestamp, 0, "Original", "System", "Installer", current_timestamp, "SYSINSTALLER", "b3722d30bdf265bb16a9b7835dc963558803452320930cf9ff7956ae1ba836ba" );');

      // Default password for SYSADMIN is not set - Deliberately.  This account is just used when logging system-level functions, and can't be used to login.
      SQL.Add('insert into person values(0000000001, current_timestamp, 0, "Server", "", "Administration", current_timestamp, "SYSADMIN", "NO PASSWORD SET" );');

      // Random data
      SQL.Add('insert into person values(0010010001, current_timestamp, 0, "Olivia",    "A", "Smith",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "OSMITH",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0010020002, current_timestamp, 0, "Liam",      "B", "Jones",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LJONES",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0010030003, current_timestamp, 0, "Emma",      "C", "Williams",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EWILLIAMS",   "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0010040004, current_timestamp, 0, "Noah",      "D", "Brown",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "NBROWN",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0010050005, current_timestamp, 0, "Amelia",    "E", "Johnson",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AJOHNSON",    "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0010060006, current_timestamp, 0, "Oliver",    "F", "Taylor",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "OTAYLOR",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0010070007, current_timestamp, 0, "Ava",       "G", "Davis",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ADAVIS",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0010080008, current_timestamp, 0, "Elijah",    "H", "Miller",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EMILLER",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0010090009, current_timestamp, 0, "Sophia",    "I", "Wilson",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "SWILSON",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0010000010, current_timestamp, 0, "Mateo",     "J", "Thompson",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MTHOMPSON",   "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0010010011, current_timestamp, 0, "Isabella",  "K", "Thomas",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ITHOMAS",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0010020012, current_timestamp, 0, "Lucas",     "L", "Anderson",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LANDERSON",   "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0010030012, current_timestamp, 0, "Luna",      "M", "White",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LWHITE",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0020040013, current_timestamp, 0, "Levi",      "N", "Martin",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LMARTIN",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0020050014, current_timestamp, 0, "Mia",       "O", "Moore",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MMOORE",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0020060015, current_timestamp, 0, "Asher",     "P", "Jackson",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AJACKSON",    "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0020070016, current_timestamp, 0, "Charlotte", "Q", "Clark",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "CCLARK",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0020080017, current_timestamp, 0, "James",     "R", "Walker",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JWALKER",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0020090018, current_timestamp, 0, "Evelyn",    "S", "Evans",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EEVANS",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0020000019, current_timestamp, 0, "Leo",       "T", "Lee",         "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LLEE",        "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0020010020, current_timestamp, 0, "Harper",    "U", "Lewis",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "HLEWIS",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0030020021, current_timestamp, 0, "Grayson",   "V", "King",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "GKING",       "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0030030022, current_timestamp, 0, "Scarlett",  "W", "Harris",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "SHARRIS",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0030040023, current_timestamp, 0, "Ezra",      "X", "Roberts",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EROBERTS",    "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0030050024, current_timestamp, 0, "Nova",      "Y", "Robinson",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "NROBINSON",   "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0030060025, current_timestamp, 0, "Luca",      "Z", "Wright",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LWRIGHT",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0030070026, current_timestamp, 0, "Aurora",    "A", "Young",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AYOUNG",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0030080027, current_timestamp, 0, "Ethan",     "B", "Scott",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ESCOTT",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0030090028, current_timestamp, 0, "Ella",      "C", "Reed",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EREED",       "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0040000029, current_timestamp, 0, "Aiden",     "D", "Murphy",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AMURPHY",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0040010031, current_timestamp, 0, "Mila",      "E", "Hill",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MHILL",       "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0040020032, current_timestamp, 0, "Wyatt",     "F", "Wood",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "WWOOD",       "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0050030033, current_timestamp, 0, "Aria",      "G", "Hall",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AHALL",       "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0050040034, current_timestamp, 0, "Sebastian", "H", "Green",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "SGREEN",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0050050035, current_timestamp, 0, "Ellie",     "I", "Allen",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EALLEN",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0070060036, current_timestamp, 0, "Benjamin",  "J", "Kelly",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "BKELLY",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0070070037, current_timestamp, 0, "Gianna",    "K", "Campbell",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "GCAMPBELL",   "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0070080038, current_timestamp, 0, "Mason",     "L", "Edwards",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MEDWARDS",    "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0080090039, current_timestamp, 0, "Sofia",     "M", "Adams",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "SADAMS",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0080000040, current_timestamp, 0, "Henry",     "N", "Baker",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "HBAKER",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0080010041, current_timestamp, 0, "Violet",    "O", "Watson",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "VWATSON",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0080010042, current_timestamp, 0, "Hudson",    "P", "Mitchell",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "HMITCHELL",   "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0090010043, current_timestamp, 0, "Layla",     "Q", "Phillips",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LPHILLIPS",   "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0090010044, current_timestamp, 0, "Jack",      "R", "Cooper",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JCOOPER",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0090020045, current_timestamp, 0, "Willow",    "S", "Turner",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "WTURNER",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0090020046, current_timestamp, 0, "Jackson",   "T", "Morris",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JMORRIS",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0090030047, current_timestamp, 0, "Lily",      "U", "Carter",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LCARTER",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0090040048, current_timestamp, 0, "Owen",      "V", "Morgan",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "OMORGAN",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0090040049, current_timestamp, 0, "Hazel",     "W", "Hughes",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "HHUGHES",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0090050051, current_timestamp, 0, "Daniel",    "X", "Cook",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "DCOOK",       "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0090060052, current_timestamp, 0, "Camila",    "Y", "Ward",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "CWARD",       "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0090060053, current_timestamp, 0, "Alexander", "Z", "Collins",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ACOLLINS",    "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0090070054, current_timestamp, 0, "Avery",     "A", "James",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AJAMES",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0100080055, current_timestamp, 0, "Maverick",  "B", "Parker",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MPARKER",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0100080056, current_timestamp, 0, "Chloe",     "C", "Bell",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "CBELL",       "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0100080057, current_timestamp, 0, "Kai",       "D", "Nelson",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "KNELSON",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110080058, current_timestamp, 0, "Elena",     "E", "Stewart",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ESTEWART",    "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110090059, current_timestamp, 0, "Gabriel",   "F", "Bailey",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "GBAILEY",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110090061, current_timestamp, 0, "Paisley",   "G", "Stevens",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "PSTEVENS",    "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110090062, current_timestamp, 0, "Carter",    "H", "Cox",         "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "CCOX",        "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110000063, current_timestamp, 0, "Eliana",    "I", "Bennett",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EBENNETT",    "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110010064, current_timestamp, 0, "William",   "J", "Murray",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "WMURRAY",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110010065, current_timestamp, 0, "Penelope",  "K", "Rogers",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "PROGERS",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110010066, current_timestamp, 0, "Logan",     "L", "Gray",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LGRAY",       "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110010067, current_timestamp, 0, "Eleanor",   "M", "Price",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EPRICE",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110010068, current_timestamp, 0, "Michael",   "N", "Ryan",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MRYAN",       "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110010069, current_timestamp, 0, "Ivy",       "O", "McDonald",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "IMCDONALD",   "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110010070, current_timestamp, 0, "Samuel",    "P", "Russell",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "SRUSSELL",    "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110010071, current_timestamp, 0, "Elizabeth", "Q", "Richardson",  "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ERICHARDSON", "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110010072, current_timestamp, 0, "Muhammad",  "R", "Harrison",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MHARRISON",   "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110010073, current_timestamp, 0, "Riley",     "S", "Sanders",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "RSANDERS",    "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110110074, current_timestamp, 0, "Waylon",    "T", "Walsh",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "WWALSH",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110110075, current_timestamp, 0, "Isla",      "U", "O''Connor",   "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "IOCONNOR",    "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110210076, current_timestamp, 0, "Ezekiel",   "V", "Simpson",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ESIMPSON",    "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110210077, current_timestamp, 0, "Abigail",   "W", "Marshall",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AMARSHALL",   "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110310078, current_timestamp, 0, "Jayden",    "X", "Ross",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JROSS",       "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110310079, current_timestamp, 0, "Nora",      "Y", "Perry",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "NPERRY",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110410080, current_timestamp, 0, "Luke",      "Z", "O''Brien",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LOBRIEN",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110510081, current_timestamp, 0, "Stella",    "A", "Kennedy",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "SKENNEDY",    "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110010082, current_timestamp, 0, "Lincoln",   "B", "Graham",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LGRAHAM",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110610083, current_timestamp, 0, "Grace",     "C", "Foster",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "GFOSTER",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0110610084, current_timestamp, 0, "Theo",      "D", "Shaw",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "TSHAW",       "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0120610085, current_timestamp, 0, "Zoey",      "E", "Ellis",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ZELLIS",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0012710086, current_timestamp, 0, "Jacob",     "F", "Griffiths",   "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JGRIFFITHS",  "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0120810087, current_timestamp, 0, "Emily",     "G", "Fisher",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EFISHER",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0120810088, current_timestamp, 0, "Josiah",    "H", "Butler",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JBUTLER",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0120910089, current_timestamp, 0, "Emilia",    "I", "Reynolds",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EREYNOLDS",   "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0120910090, current_timestamp, 0, "David",     "J", "Fox",         "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "DFOX",        "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0120910091, current_timestamp, 0, "Leilani",   "K", "Robertson",   "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LROBERTSON",  "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0120910092, current_timestamp, 0, "Jaxon",     "L", "Barnes",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JBARNES",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0120910093, current_timestamp, 0, "Everly",    "M", "Chapman",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ECHAPMAN",    "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0120910094, current_timestamp, 0, "Elias",     "N", "Powell",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EPOWELL",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0120910095, current_timestamp, 0, "Kinsley",   "O", "Fraser",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "KFRASER",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0120910096, current_timestamp, 0, "Julian",    "P", "Mason",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JMASON",      "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0120910097, current_timestamp, 0, "Athena",    "Q", "Henderson",   "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AHENDERSON",  "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0120910098, current_timestamp, 0, "Theodore",  "R", "Hamilton",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "THAMILTON",   "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0120910099, current_timestamp, 0, "Delilah",   "S", "Peterson",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "DPETERSON",   "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0120910100, current_timestamp, 0, "Isaiah",    "T", "Howard",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "IHOWARD",     "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0120910101, current_timestamp, 0, "Naomi",     "U", "O''Sullivan", "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "NOSULLIVAN",  "NO PASSWORD SET" );');
      SQL.Add('insert into person values(0120910102, current_timestamp, 0, "Matthew",   "V", "Brooks",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MBROOKS",     "NO PASSWORD SET" );');

      ExecSQL;
    end;
  end;


// NOTES:
// Names were randomly generated - any resemblance to actual people, living or dead, etc. etc.
// The first names were drawn from the following link
// https://www.babycenter.com/baby-names/most-popular/top-baby-names
// The last names were drawn from the following link
// https://selectsurnames.com/top-300-surnames/






























































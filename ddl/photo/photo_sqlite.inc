// [table] photo
//
// Names were randomly generated - any resemblance to actual people, living or dead, etc. etc.
// The first names were drawn from the following link
// https://www.babycenter.com/baby-names/most-popular/top-baby-names
// The last names were drawn from the following link
// https://selectsurnames.com/top-300-surnames/

TableName := 'photo';

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
                '  photo_id                   integer     NOT NULL, '+
                '  last_modified              text        NOT NULL, '+
                '  last_modifier              integer     NOT NULL, '+
                '  photo_type                 integer     NOT NULL, '+
                '  photo_datauri              text        NOT NULL, '+
                '  CONSTRAINT constraint_name PRIMARY KEY (person_id, photo_id) '+
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

      // Random photos generated via https://boredhumans.com/faces.php
      SQL.Clear;
      ImageFile.Text := '';
      SQL.Add('insert into '+TableName+' values(0, 1, Datetime("now"), 0, 1, :PHOTO );');
      ImageFile.LoadFromFile('ddl/photo/data/1.txt');
      ParamByName('PHOTO').AsString := ImageFile.Text;
      ExecSQL;

//      SQL.Clear;
//      ImageFile.Text := '';
//      SQL.Add('insert into '+TableName+' values(0010010001, 1, Datetime("now"), 0, 1, :PHOTO );');
//      ImageFile.LoadFromFile('ddl/photo/data/2.txt');
//      ParamByName('PHOTO').AsString := ImageFile.Text;
//      ExecSQL;
//
//      SQL.Clear;
//      ImageFile.Text := '';
//      SQL.Add('insert into '+TableName+' values(0010020002, 1, Datetime("now"), 0, 1, :PHOTO );');
//      ImageFile.LoadFromFile('ddl/photo/data/3.txt');
//      ParamByName('PHOTO').AsString := ImageFile.Text;
//      ExecSQL;

//      SQL.Add('insert into person values(0010030003, 1, Datetime("now"), 0, 1, "Emma",      "C", "Williams",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EWILLIAMS",   "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0010040004, 1, Datetime("now"), 0, 1, "Noah",      "D", "Brown",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "NBROWN",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0010050005, 1, Datetime("now"), 0, 1, "Amelia",    "E", "Johnson",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AJOHNSON",    "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0010060006, 1, Datetime("now"), 0, 1, "Oliver",    "F", "Taylor",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "OTAYLOR",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0010070007, 1, Datetime("now"), 0, 1, "Ava",       "G", "Davis",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ADAVIS",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0010080008, 1, Datetime("now"), 0, 1, "Elijah",    "H", "Miller",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EMILLER",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0010090009, 1, Datetime("now"), 0, 1, "Sophia",    "I", "Wilson",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "SWILSON",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0010000010, 1, Datetime("now"), 0, 1, "Mateo",     "J", "Thompson",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MTHOMPSON",   "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0010010011, 1, Datetime("now"), 0, 1, "Isabella",  "K", "Thomas",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ITHOMAS",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0010020012, 1, Datetime("now"), 0, 1, "Lucas",     "L", "Anderson",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LANDERSON",   "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0010030012, 1, Datetime("now"), 0, 1, "Luna",      "M", "White",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LWHITE",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0020040013, 1, Datetime("now"), 0, 1, "Levi",      "N", "Martin",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LMARTIN",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0020050014, 1, Datetime("now"), 0, 1, "Mia",       "O", "Moore",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MMOORE",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0020060015, 1, Datetime("now"), 0, 1, "Asher",     "P", "Jackson",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AJACKSON",    "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0020070016, 1, Datetime("now"), 0, 1, "Charlotte", "Q", "Clark",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "CCLARK",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0020080017, 1, Datetime("now"), 0, 1, "James",     "R", "Walker",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JWALKER",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0020090018, 1, Datetime("now"), 0, 1, "Evelyn",    "S", "Evans",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EEVANS",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0020000019, 1, Datetime("now"), 0, 1, "Leo",       "T", "Lee",         "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LLEE",        "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0020010020, 1, Datetime("now"), 0, 1, "Harper",    "U", "Lewis",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "HLEWIS",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0030020021, 1, Datetime("now"), 0, 1, "Grayson",   "V", "King",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "GKING",       "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0030030022, 1, Datetime("now"), 0, 1, "Scarlett",  "W", "Harris",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "SHARRIS",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0030040023, 1, Datetime("now"), 0, 1, "Ezra",      "X", "Roberts",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EROBERTS",    "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0030050024, 1, Datetime("now"), 0, 1, "Nova",      "Y", "Robinson",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "NROBINSON",   "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0030060025, 1, Datetime("now"), 0, 1, "Luca",      "Z", "Wright",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LWRIGHT",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0030070026, 1, Datetime("now"), 0, 1, "Aurora",    "A", "Young",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AYOUNG",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0030080027, 1, Datetime("now"), 0, 1, "Ethan",     "B", "Scott",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ESCOTT",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0030090028, 1, Datetime("now"), 0, 1, "Ella",      "C", "Reed",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EREED",       "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0040000029, 1, Datetime("now"), 0, 1, "Aiden",     "D", "Murphy",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AMURPHY",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0040010031, 1, Datetime("now"), 0, 1, "Mila",      "E", "Hill",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MHILL",       "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0040020032, 1, Datetime("now"), 0, 1, "Wyatt",     "F", "Wood",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "WWOOD",       "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0050030033, 1, Datetime("now"), 0, 1, "Aria",      "G", "Hall",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AHALL",       "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0050040034, 1, Datetime("now"), 0, 1, "Sebastian", "H", "Green",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "SGREEN",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0050050035, 1, Datetime("now"), 0, 1, "Ellie",     "I", "Allen",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EALLEN",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0070060036, 1, Datetime("now"), 0, 1, "Benjamin",  "J", "Kelly",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "BKELLY",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0070070037, 1, Datetime("now"), 0, 1, "Gianna",    "K", "Campbell",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "GCAMPBELL",   "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0070080038, 1, Datetime("now"), 0, 1, "Mason",     "L", "Edwards",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MEDWARDS",    "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0080090039, 1, Datetime("now"), 0, 1, "Sofia",     "M", "Adams",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "SADAMS",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0080000040, 1, Datetime("now"), 0, 1, "Henry",     "N", "Baker",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "HBAKER",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0080010041, 1, Datetime("now"), 0, 1, "Violet",    "O", "Watson",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "VWATSON",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0080010042, 1, Datetime("now"), 0, 1, "Hudson",    "P", "Mitchell",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "HMITCHELL",   "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0090010043, 1, Datetime("now"), 0, 1, "Layla",     "Q", "Phillips",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LPHILLIPS",   "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0090010044, 1, Datetime("now"), 0, 1, "Jack",      "R", "Cooper",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JCOOPER",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0090020045, 1, Datetime("now"), 0, 1, "Willow",    "S", "Turner",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "WTURNER",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0090020046, 1, Datetime("now"), 0, 1, "Jackson",   "T", "Morris",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JMORRIS",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0090030047, 1, Datetime("now"), 0, 1, "Lily",      "U", "Carter",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LCARTER",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0090040048, 1, Datetime("now"), 0, 1, "Owen",      "V", "Morgan",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "OMORGAN",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0090040049, 1, Datetime("now"), 0, 1, "Hazel",     "W", "Hughes",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "HHUGHES",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0090050051, 1, Datetime("now"), 0, 1, "Daniel",    "X", "Cook",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "DCOOK",       "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0090060052, 1, Datetime("now"), 0, 1, "Camila",    "Y", "Ward",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "CWARD",       "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0090060053, 1, Datetime("now"), 0, 1, "Alexander", "Z", "Collins",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ACOLLINS",    "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0090070054, 1, Datetime("now"), 0, 1, "Avery",     "A", "James",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AJAMES",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0100080055, 1, Datetime("now"), 0, 1, "Maverick",  "B", "Parker",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MPARKER",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0100080056, 1, Datetime("now"), 0, 1, "Chloe",     "C", "Bell",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "CBELL",       "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0100080057, 1, Datetime("now"), 0, 1, "Kai",       "D", "Nelson",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "KNELSON",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110080058, 1, Datetime("now"), 0, 1, "Elena",     "E", "Stewart",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ESTEWART",    "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110090059, 1, Datetime("now"), 0, 1, "Gabriel",   "F", "Bailey",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "GBAILEY",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110090061, 1, Datetime("now"), 0, 1, "Paisley",   "G", "Stevens",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "PSTEVENS",    "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110090062, 1, Datetime("now"), 0, 1, "Carter",    "H", "Cox",         "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "CCOX",        "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110000063, 1, Datetime("now"), 0, 1, "Eliana",    "I", "Bennett",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EBENNETT",    "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110010064, 1, Datetime("now"), 0, 1, "William",   "J", "Murray",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "WMURRAY",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110010065, 1, Datetime("now"), 0, 1, "Penelope",  "K", "Rogers",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "PROGERS",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110010066, 1, Datetime("now"), 0, 1, "Logan",     "L", "Gray",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LGRAY",       "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110010067, 1, Datetime("now"), 0, 1, "Eleanor",   "M", "Price",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EPRICE",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110010068, 1, Datetime("now"), 0, 1, "Michael",   "N", "Ryan",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MRYAN",       "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110010069, 1, Datetime("now"), 0, 1, "Ivy",       "O", "McDonald",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "IMCDONALD",   "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110010070, 1, Datetime("now"), 0, 1, "Samuel",    "P", "Russell",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "SRUSSELL",    "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110010071, 1, Datetime("now"), 0, 1, "Elizabeth", "Q", "Richardson",  "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ERICHARDSON", "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110010072, 1, Datetime("now"), 0, 1, "Muhammad",  "R", "Harrison",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MHARRISON",   "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110010073, 1, Datetime("now"), 0, 1, "Riley",     "S", "Sanders",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "RSANDERS",    "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110110074, 1, Datetime("now"), 0, 1, "Waylon",    "T", "Walsh",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "WWALSH",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110110075, 1, Datetime("now"), 0, 1, "Isla",      "U", "O''Connor",   "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "IOCONNOR",    "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110210076, 1, Datetime("now"), 0, 1, "Ezekiel",   "V", "Simpson",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ESIMPSON",    "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110210077, 1, Datetime("now"), 0, 1, "Abigail",   "W", "Marshall",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AMARSHALL",   "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110310078, 1, Datetime("now"), 0, 1, "Jayden",    "X", "Ross",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JROSS",       "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110310079, 1, Datetime("now"), 0, 1, "Nora",      "Y", "Perry",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "NPERRY",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110410080, 1, Datetime("now"), 0, 1, "Luke",      "Z", "O''Brien",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LOBRIEN",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110510081, 1, Datetime("now"), 0, 1, "Stella",    "A", "Kennedy",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "SKENNEDY",    "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110010082, 1, Datetime("now"), 0, 1, "Lincoln",   "B", "Graham",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LGRAHAM",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110610083, 1, Datetime("now"), 0, 1, "Grace",     "C", "Foster",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "GFOSTER",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0110610084, 1, Datetime("now"), 0, 1, "Theo",      "D", "Shaw",        "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "TSHAW",       "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0120610085, 1, Datetime("now"), 0, 1, "Zoey",      "E", "Ellis",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ZELLIS",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0012710086, 1, Datetime("now"), 0, 1, "Jacob",     "F", "Griffiths",   "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JGRIFFITHS",  "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0120810087, 1, Datetime("now"), 0, 1, "Emily",     "G", "Fisher",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EFISHER",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0120810088, 1, Datetime("now"), 0, 1, "Josiah",    "H", "Butler",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JBUTLER",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0120910089, 1, Datetime("now"), 0, 1, "Emilia",    "I", "Reynolds",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EREYNOLDS",   "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0120910090, 1, Datetime("now"), 0, 1, "David",     "J", "Fox",         "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "DFOX",        "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0120910091, 1, Datetime("now"), 0, 1, "Leilani",   "K", "Robertson",   "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "LROBERTSON",  "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0120910092, 1, Datetime("now"), 0, 1, "Jaxon",     "L", "Barnes",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JBARNES",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0120910093, 1, Datetime("now"), 0, 1, "Everly",    "M", "Chapman",     "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "ECHAPMAN",    "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0120910094, 1, Datetime("now"), 0, 1, "Elias",     "N", "Powell",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "EPOWELL",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0120910095, 1, Datetime("now"), 0, 1, "Kinsley",   "O", "Fraser",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "KFRASER",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0120910096, 1, Datetime("now"), 0, 1, "Julian",    "P", "Mason",       "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "JMASON",      "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0120910097, 1, Datetime("now"), 0, 1, "Athena",    "Q", "Henderson",   "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "AHENDERSON",  "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0120910098, 1, Datetime("now"), 0, 1, "Theodore",  "R", "Hamilton",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "THAMILTON",   "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0120910099, 1, Datetime("now"), 0, 1, "Delilah",   "S", "Peterson",    "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "DPETERSON",   "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0120910100, 1, Datetime("now"), 0, 1, "Isaiah",    "T", "Howard",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "IHOWARD",     "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0120910101, 1, Datetime("now"), 0, 1, "Naomi",     "U", "O''Sullivan", "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "NOSULLIVAN",  "NO PASSWORD SET" );');
//      SQL.Add('insert into person values(0120910102, 1, Datetime("now"), 0, 1, "Matthew",   "V", "Brooks",      "'+FormatDateTime('yyyy-mm-dd',Now-(20*365)-Random(50 * 365))+'", "MBROOKS",     "NO PASSWORD SET" );');

    end;
  end;
end;































































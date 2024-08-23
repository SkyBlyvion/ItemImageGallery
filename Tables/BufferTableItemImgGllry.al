table 50101 "Item Picture Import Buffer"
{
    Caption = 'Item Picture Import Buffer';
    ReplicateData = false;
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "File Name"; Text[260])
        {
            Caption = 'File Name';
        }
        field(2; Picture; Media)
        {
            Caption = 'Picture';
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(5; "Picture Already Exists"; Boolean)
        {
            Caption = 'Picture Already Exists';
        }
        field(6; "File Size (KB)"; BigInteger)
        {
            Caption = 'File Size (KB)';
        }
        field(7; "File Extension"; Text[30])
        {
            Caption = 'File Extension';
        }
    }

    keys
    {
        key(Key1; "File Name")
        {
            Clustered = true;
        }
    }
}

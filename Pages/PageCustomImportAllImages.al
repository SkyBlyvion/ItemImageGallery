/* Item No.: The Item No. is extracted directly from the file name of the images in the ZIP. 
The code uses this Item No. to link the image to the correct item in the ItemPictureGallery table.*/

/* Image Number: The ImageNo is auto-incremented for each Item No. using the GetNextPictureNo function. 
This ensures that each image for an item has a unique identifier (Item Picture No.).*/

page 50103 "Custom Import Item Pictures"
{
    ApplicationArea = All;
    Caption = 'Custom Import Item Pictures';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Item Picture Import Buffer";
    SourceTableTemporary = true;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(ImportGroup)
            {
                ShowCaption = true;
                Caption = 'Import Options';

                field(ZipFileName; ZipFileName)
                {
                    ApplicationArea = All;
                    Caption = 'Select a ZIP File';
                    Editable = false;
                    ToolTip = 'Specifies a ZIP file with pictures for upload.';
                    Width = 60;

                    trigger OnAssistEdit()
                    begin
                        if ZipFileName <> '' then begin
                            Rec.DeleteAll(); // Clear the buffer before starting
                            ZipFileName := '';
                        end;
                        ZipFileName := LoadZIPFile('', TotalCount);
                        Rec.FindFirst();
                    end;
                }
            }

            repeater(PictureList)
            {
                Caption = 'Pictures';
                Editable = false;

                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the item that the picture is for.';
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the picture file.';
                    Width = 20;
                }
                field("File Extension"; Rec."File Extension")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the format of the picture file.';
                    Width = 10;
                }
                field("File Size (KB)"; Rec."File Size (KB)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the size of the picture file in KB.';
                    Width = 10;
                }
                field("Picture Already Exists"; Rec."Picture Already Exists")
                {
                    ApplicationArea = All;
                    ToolTip = 'Indicates whether the picture already exists in the item.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Functions';

                action(ImportPicturesFromZIP)
                {
                    ApplicationArea = All;
                    Caption = 'Import Pictures';
                    Image = ImportExport;
                    ToolTip = 'Import pictures into item cards.';

                    trigger OnAction()
                    begin
                        ImportPicturesFromZIP_Local();
                    end;
                }
            }
        }
    }

    var
        ZipFileName: Text;
        TempBlob: Codeunit "Temp Blob";
        DataCompression: Codeunit "Data Compression";
        TotalCount: Integer;

    local procedure LoadZIPFile(ZipFileName: Text; var TotalCount: Integer): Text
    var
        Item: Record Item;
        FileMgt: Codeunit "File Management";
        DataCompression: Codeunit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
        Window: Dialog;
        EntryList: List of [Text];
        EntryListKey: Text;
        InStream: InStream;
        EntryOutStream: OutStream;
        EntryInStream: InStream;
        BufferRec: Record "Item Picture Import Buffer";
        Length: Integer;
        ItemNo: Text[20];
        SuffixPos: Integer;
    begin
        if not UploadIntoStream('Select ZIP File', '', 'Zip Files|*.zip', ZipFileName, InStream) then
            Error('No ZIP file selected.');

        DataCompression.OpenZipArchive(InStream, false);
        DataCompression.GetEntryList(EntryList);

        if EntryList.Count() = 0 then
            Error('The ZIP file is empty or contains no valid entries.');

        Window.Open('Processing: #1##############################');

        TotalCount := 0;
        BufferRec.DeleteAll();  // Ensure buffer is clean before starting

        foreach EntryListKey in EntryList do begin
            Window.Update(1, EntryListKey);

            BufferRec.Init();
            BufferRec."File Name" := CopyStr(FileMgt.GetFileNameWithoutExtension(EntryListKey), 1, MaxStrLen(BufferRec."File Name"));
            BufferRec."File Extension" := CopyStr(FileMgt.GetExtension(EntryListKey), 1, MaxStrLen(BufferRec."File Extension"));

            // Debug Message
            Message('Processing file: %1', BufferRec."File Name");

            // Find the position of the suffix "_X" (if any)
            SuffixPos := StrPos(BufferRec."File Name", '_');
            if SuffixPos > 0 then
                ItemNo := CopyStr(BufferRec."File Name", 1, SuffixPos - 1)
            else
                ItemNo := BufferRec."File Name"; // No suffix, use the full name

            if StrLen(ItemNo) <= MaxStrLen(Item."No.") then begin
                if Item.Get(ItemNo) then begin
                    TempBlob.CreateOutStream(EntryOutStream);
                    Length := DataCompression.ExtractEntry(EntryListKey, EntryOutStream);
                    TempBlob.CreateInStream(EntryInStream);
                    BufferRec."File Size (KB)" := Round(Length / 1024, 1);
                    BufferRec."Item No." := Item."No.";
                    BufferRec."Picture Already Exists" := (Item.Picture.Count > 0);

                    // Import stream into BufferRec.Picture
                    BufferRec.Picture.ImportStream(EntryInStream, EntryListKey);

                    BufferRec.Insert();
                    TotalCount += 1;

                    // Debug Message
                    Message('Inserted picture for Item No: %1', BufferRec."Item No.");
                end else begin
                    // Debug Message
                    Message('No matching Item No. found for: %1', ItemNo);
                end;
            end else begin
                // Debug Message
                Message('File name exceeds allowed length: %1', BufferRec."File Name");
            end;
        end;

        DataCompression.CloseZipArchive();
        Window.Close();

        if TotalCount = 0 then
            Error('No valid images were found or imported.');

        exit(ZipFileName);
    end;

    local procedure ImportPicturesFromZIP_Local()
    var
        BufferRec: Record "Item Picture Import Buffer";
        ItemPictureGallery: Record "ItemPictureGallery";
        Window: Dialog;
        InStream: InStream;
        OutStream: OutStream;
        TempBlob: Codeunit "Temp Blob";
    begin
        Window.Open('Importing: #1##############################');

        if BufferRec.FindSet(true) then
            repeat
                if BufferRec."Item No." <> '' then begin
                    Window.Update(1, BufferRec."Item No.");

                    // Insert into ItemPictureGallery table
                    ItemPictureGallery.Init();
                    ItemPictureGallery."Item No." := BufferRec."Item No.";
                    ItemPictureGallery."Item Picture No." := GetNextPictureNo(BufferRec."Item No.");
                    ItemPictureGallery.Sequencing := ItemPictureGallery."Item Picture No.";

                    // Import picture from buffer to ItemPictureGallery
                    TempBlob.CreateOutStream(OutStream);
                    BufferRec.Picture.ExportStream(OutStream);
                    TempBlob.CreateInStream(InStream);
                    ItemPictureGallery.Picture.ImportStream(InStream, BufferRec."File Name");

                    ItemPictureGallery.Insert();

                    // Debug Message
                    Message('Imported picture for Item No: %1, Picture No: %2', ItemPictureGallery."Item No.", ItemPictureGallery."Item Picture No.");

                    BufferRec.Delete(); // Delete from the buffer after processing
                end;
            until BufferRec.Next() = 0;

        Window.Close();
        Message('Import completed successfully.');
    end;

    local procedure GetNextPictureNo(ItemNo: Code[20]): Integer
    var
        ItemPictureGallery: Record "ItemPictureGallery";
    begin
        ItemPictureGallery.SetRange("Item No.", ItemNo);
        if ItemPictureGallery.FindLast() then
            exit(ItemPictureGallery."Item Picture No." + 1);
        exit(1);
    end;
}

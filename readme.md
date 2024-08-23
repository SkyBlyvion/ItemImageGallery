## Old Parts 
    // layout
    // {
    //     area(content)
    //     {
    //         field(ImageCount; ImageCount) // affiche le nombre total d'images et la position de l'image actuellement affichée. TOP RIGHT
    //         {
    //             ApplicationArea = All;
    //             ShowCaption = false; // Cache la légende (caption) du champ
    //             Editable = false;
    //         }
    //         field(Picture; Rec.Picture) // affiche l'image associée à l'article.
    //         {
    //             ApplicationArea = All;
    //             ShowCaption = false;
    //         }
    //     }
    // }


    // layout
    // {
    //     area(content)
    //     {
    //         grid(ImageGalleryGrid)
    //         {
    //             ShowCaption = false;

    //             field(PrevArrow; Format('<-')) // Previous arrow field
    //             {
    //                 ApplicationArea = All;
    //                 ShowCaption = false;
    //                 Editable = false;
    //                 trigger OnDrillDown()
    //                 begin
    //                     ShowPreviousImage(); // Call procedure to show the previous image
    //                 end;
    //             }
    //             field(Picture; Rec.Picture) // Main image display
    //             {
    //                 ApplicationArea = All;
    //                 ShowCaption = false;
    //                 Editable = false;
    //             }
    //             field(NextArrow; Format('->')) // Next arrow field
    //             {
    //                 ApplicationArea = All;
    //                 ShowCaption = false;
    //                 Editable = false;
    //                 trigger OnDrillDown()
    //                 begin
    //                     ShowNextImage(); // Call procedure to show the next image
    //                 end;
    //             }
    //         }
    //         field(ImageCount; ImageCount) // Displays the image count
    //         {
    //             ApplicationArea = All;
    //             ShowCaption = false;
    //             Editable = false;
    //         }
    //     }
    // }


    // action(Next) // Action pour afficher l'image suivante
    // {
    //     ApplicationArea = All;
    //     Caption = 'Suivant';
    //     Image = NextRecord; // Icone pour afficher l'image suivante

    //     trigger OnAction()
    //     begin
    //         Rec.Next(1); // Passe à l'enregistrement (image) suivant
    //     end;
    // }
    // action(Previous) // Action pour afficher l'image précédente
    // {
    //     ApplicationArea = All;
    //     Caption = 'Précédent';
    //     Image = PreviousRecord;

    //     trigger OnAction()
    //     begin
    //         Rec.Next(-1); // Passe à l'enregistrement (image) précédent
    //     end;
    // }



namespace Microsoft.Inventory.Item.Picture;

using Microsoft.Inventory.Item;
using System.IO;
using System.Utilities;

table 31 "Item Picture Buffer"
{
    Caption = 'Item Picture Buffer';
    ReplicateData = false;
    DataClassification = CustomerContent;

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
        field(4; "Item Description"; Text[100])
        {
            CalcFormula = lookup(Item.Description where("No." = field("Item No.")));
            Caption = 'Item Description';
            FieldClass = FlowField;
        }
        field(5; "Import Status"; Option)
        {
            Caption = 'Import Status';
            Editable = false;
            OptionCaption = 'Skip,Pending,Completed';
            OptionMembers = Skip,Pending,Completed;
        }
        field(6; "Picture Already Exists"; Boolean)
        {
            Caption = 'Picture Already Exists';
        }
        field(7; "File Size (KB)"; BigInteger)
        {
            Caption = 'File Size (KB)';
        }
        field(8; "File Extension"; Text[30])
        {
            Caption = 'File Extension';
        }
        field(9; "Modified Date"; Date)
        {
            Caption = 'Modified Date';
        }
        field(10; "Modified Time"; Time)
        {
            Caption = 'Modified Time';
        }
    }

    keys
    {
        key(Key1; "File Name")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Brick; "File Name", "Item No.", "Item Description", Picture)
        {
        }
    }

    var
        SelectZIPFileMsg: Label 'Select ZIP File';

    [Scope('OnPrem')]
    procedure LoadZIPFile(ZipFileName: Text; var TotalCount: Integer; ReplaceMode: Boolean): Text
    var
        Item: Record Item;
        FileMgt: Codeunit "File Management";
        DataCompression: Codeunit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
        Window: Dialog;
        EntryList: List of [Text];
        EntryListKey: Text;
        ServerFile: File;
        InStream: InStream;
        EntryOutStream: OutStream;
        EntryInStream: InStream;
        ServerFileOpened: Boolean;
        Length: Integer;
    begin
        if ZipFileName <> '' then begin
            ServerFileOpened := ServerFile.Open(ZipFileName);
            ServerFile.CreateInStream(InStream)
        end else
            if not UploadIntoStream(SelectZIPFileMsg, '', 'Zip Files|*.zip', ZipFileName, InStream) then
                Error('');

        DataCompression.OpenZipArchive(InStream, false);
        DataCompression.GetEntryList(EntryList);

        Window.Open('#1##############################');

        TotalCount := 0;
        DeleteAll();
        foreach EntryListKey in EntryList do begin
            Init();
            "File Name" := CopyStr(FileMgt.GetFileNameWithoutExtension(EntryListKey), 1, MaxStrLen("File Name"));
            "File Extension" := CopyStr(FileMgt.GetExtension(EntryListKey), 1, MaxStrLen("File Extension"));
            if StrLen("File Name") <= MaxStrLen(Item."No.") then
                if Item.Get("File Name") then begin
                    TempBlob.CreateOutStream(EntryOutStream);
                    Length := DataCompression.ExtractEntry(EntryListKey, EntryOutStream);
                    TempBlob.CreateInStream(EntryInStream);
                    if not IsNullGuid(Picture.ImportStream(EntryInStream, FileMgt.GetFileName(EntryListKey))) then begin
                        Window.Update(1, "File Name");
                        "File Size (KB)" := Length;
                        TotalCount += 1;
                        "Item No." := Item."No.";
                        if Item.Picture.Count > 0 then begin
                            "Picture Already Exists" := true;
                            if ReplaceMode then
                                "Import Status" := "Import Status"::Pending;
                        end else
                            "Import Status" := "Import Status"::Pending;
                    end;
                    Insert();
                end;
        end;

        DataCompression.CloseZipArchive();
        Window.Close();

        if ServerFileOpened then
            ServerFile.Close();

        exit(ZipFileName);
    end;

    [Scope('OnPrem')]
    procedure ImportPictures(ReplaceMode: Boolean)
    var
        Item: Record Item;
        Window: Dialog;
        ImageID: Guid;
    begin
        Window.Open('#1############################################');

        if FindSet(true) then
            repeat
                if "Import Status" = "Import Status"::Pending then
                    if ("Item No." <> '') and ShouldImport(ReplaceMode, "Picture Already Exists") then begin
                        Window.Update(1, "Item No.");
                        Item.Get("Item No.");
                        ImageID := Picture.MediaId;
                        if "Picture Already Exists" then
                            Clear(Item.Picture);
                        Item.Picture.Insert(ImageID);
                        Item.Modify();
                        "Import Status" := "Import Status"::Completed;
                        Modify();
                    end;
            until Next() = 0;

        Window.Close();
    end;

    local procedure ShouldImport(ReplaceMode: Boolean; PictureExists: Boolean): Boolean
    begin
        if not ReplaceMode and PictureExists then
            exit(false);

        exit(true);
    end;

    [Scope('OnPrem')]
    procedure GetAddCount(): Integer
    var
        TempItemPictureBuffer2: Record "Item Picture Buffer" temporary;
    begin
        TempItemPictureBuffer2.Copy(Rec, true);
        TempItemPictureBuffer2.SetRange("Import Status", TempItemPictureBuffer2."Import Status"::Pending);
        TempItemPictureBuffer2.SetRange("Picture Already Exists", false);
        exit(TempItemPictureBuffer2.Count);
    end;

    [Scope('OnPrem')]
    procedure GetAddedCount(): Integer
    var
        TempItemPictureBuffer2: Record "Item Picture Buffer" temporary;
    begin
        TempItemPictureBuffer2.Copy(Rec, true);
        TempItemPictureBuffer2.SetRange("Import Status", TempItemPictureBuffer2."Import Status"::Completed);
        TempItemPictureBuffer2.SetRange("Picture Already Exists", false);
        exit(TempItemPictureBuffer2.Count);
    end;

    [Scope('OnPrem')]
    procedure GetReplaceCount(): Integer
    var
        TempItemPictureBuffer2: Record "Item Picture Buffer" temporary;
    begin
        TempItemPictureBuffer2.Copy(Rec, true);
        TempItemPictureBuffer2.SetRange("Import Status", TempItemPictureBuffer2."Import Status"::Pending);
        TempItemPictureBuffer2.SetRange("Picture Already Exists", true);
        exit(TempItemPictureBuffer2.Count);
    end;

    [Scope('OnPrem')]
    procedure GetReplacedCount(): Integer
    var
        TempItemPictureBuffer2: Record "Item Picture Buffer" temporary;
    begin
        TempItemPictureBuffer2.Copy(Rec, true);
        TempItemPictureBuffer2.SetRange("Import Status", TempItemPictureBuffer2."Import Status"::Completed);
        TempItemPictureBuffer2.SetRange("Picture Already Exists", true);
        exit(TempItemPictureBuffer2.Count);
    end;
}






// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item;

using Microsoft.Inventory.Item.Picture;

page 348 "Import Item Pictures"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Import Item Pictures';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Item Picture Buffer";
    SourceTableTemporary = true;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(Control6)
            {
                ShowCaption = false;
                field(ZipFileName; ZipFileName)
                {
                    ApplicationArea = Basic, Suite;
                    AssistEdit = true;
                    Caption = 'Select a ZIP File';
                    Editable = false;
                    ToolTip = 'Specifies a ZIP file with pictures for upload.';
                    Width = 60;

                    trigger OnAssistEdit()
                    begin
                        if ZipFileName <> '' then begin
                            Rec.DeleteAll();
                            ZipFileName := '';
                        end;
                        ZipFileName := Rec.LoadZIPFile('', TotalCount, ReplaceMode);
                        ReplaceModeEditable := ZipFileName <> '';
                        Rec.FindFirst();

                        UpdateCounters();
                    end;
                }
                field(ReplaceMode; ReplaceMode)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Replace Pictures';
                    Editable = ReplaceModeEditable;
                    ToolTip = 'Specifies if existing item pictures are replaced during import.';

                    trigger OnValidate()
                    begin
                        if ZipFileName = '' then
                            Error(SelectZIPFilenameErr);

                        Rec.Reset();
                        Rec.SetRange("Picture Already Exists", true);
                        if ReplaceMode then
                            Rec.ModifyAll("Import Status", Rec."Import Status"::Pending)
                        else
                            Rec.ModifyAll("Import Status", Rec."Import Status"::Skip);
                        Rec.SetRange("Picture Already Exists");

                        UpdateCounters();
                        CurrPage.Update();
                    end;
                }
            }
            group(Control23)
            {
                ShowCaption = false;
                field(AddCount; AddCount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pictures to Add';
                    Editable = false;
                    ToolTip = 'Specifies the number of item pictures that can be added with the selected ZIP file.';
                }
                field(ReplaceCount; ReplaceCount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Pictures to Replace';
                    Editable = false;
                    ToolTip = 'Specifies the number of existing item pictures that can be replaced with the selected ZIP file.';
                }
                field(TotalCount; TotalCount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total Pictures';
                    Editable = false;
                    ToolTip = 'Specifies the total number of item pictures that can be imported from the selected ZIP file.';
                }
                field(AddedCount; AddedCount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Added Pictures';
                    Editable = false;
                    ToolTip = 'Specifies how many item pictures were added last time you used the Import Pictures action.';
                }
                field(ReplacedCount; ReplacedCount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Replaced Pictures';
                    Editable = false;
                    ToolTip = 'Specifies how many item pictures were replaced last time you used the Import Pictures action.';
                }
            }
            repeater(Group)
            {
                Caption = 'Pictures';
                Editable = false;
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the item that the picture is for.';
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the item that the picture is for.';
                }
                field("Picture Already Exists"; Rec."Picture Already Exists")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if a picture already exists for the item card.';
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the picture file. It must be the same as the item number.';
                    Width = 20;
                }
                field("File Extension"; Rec."File Extension")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the format of the picture file.';
                    Width = 10;
                }
                field("File Size (KB)"; Rec."File Size (KB)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the size of the picture file.';
                    Width = 10;
                }
                field("Modified Date"; Rec."Modified Date")
                {
                    ApplicationArea = Basic, Suite;
                    Visible = false;
                }
                field("Modified Time"; Rec."Modified Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies when the picture was last modified.';
                    Visible = false;
                }
                field("Import Status"; Rec."Import Status")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the last import of the picture was been skipped, is pending, or is completed.';
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
                action(ImportPictures)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Import Pictures';
                    Image = ImportExport;
                    ToolTip = 'Import pictures into items cards. Existing pictures will be replaced if the Replace Pictures check box is selected.';

                    trigger OnAction()
                    begin
                        Rec.ImportPictures(ReplaceMode);
                        AddedCount := Rec.GetAddedCount();
                        ReplacedCount := Rec.GetReplacedCount();
                    end;
                }
                action(ShowItemCard)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show Item Card';
                    RunObject = Page "Item Card";
                    RunPageLink = "No." = field("Item No.");
                    ToolTip = 'Open the item card that contains the picture.';
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(ImportPictures_Promoted; ImportPictures)
                {
                }
                actionref(ShowItemCard_Promoted; ShowItemCard)
                {
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        Rec.SetRange("Import Status", Rec."Import Status"::Pending);
        if not Rec.IsEmpty() then
            if not Confirm(ImportIncompleteQst, false) then begin
                Rec.SetRange("Import Status");
                exit(false);
            end;

        exit(true);
    end;

    var
        ZipFileName: Text;
        TotalCount: Integer;
        AddCount: Integer;
        SelectZIPFilenameErr: Label 'You must select the ZIP file first.';
        ImportIncompleteQst: Label 'One or more pictures have not been imported yet. If you leave the page, you must upload the ZIP file again to import remaining pictures.\\Do you want to leave this page?';
        AddedCount: Integer;
        ReplaceCount: Integer;
        ReplacedCount: Integer;
        ReplaceMode: Boolean;
        ReplaceModeEditable: Boolean;

    local procedure UpdateCounters()
    begin
        AddCount := Rec.GetAddCount();
        ReplaceCount := Rec.GetReplaceCount();
        AddedCount := Rec.GetAddedCount();
        ReplacedCount := Rec.GetReplacedCount();
    end;
}


page 50102 "NL Item Picture Gallery"
{
    InsertAllowed = false; // Empêche l'insertion de nouvelles images directement via cette page
    LinksAllowed = false; // Empêche l'ajout de liens via cette page
    DeleteAllowed = false; // Empêche la suppression d'images via cette page
    Caption = 'Gallerie d''images d''articles';
    SourceTable = ItemPictureGallery; // Source de données
    PageType = CardPart; // factbox

    layout
    {
        area(content)
        {
            field(ImageCount; ImageCount) // affiche le nombre total d'images et la position de l'image actuellement affichée.
            {
                ApplicationArea = All;
                ShowCaption = false; // Cache la légende (caption) du champ
                Editable = false;
            }
            field(Picture; Rec.Picture) // affiche l'image associée à l'article.
            {
                ApplicationArea = All;
                ShowCaption = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ImportPicture)
            {
                ApplicationArea = All;
                Caption = 'Importer';
                Image = Import;
                ToolTip = 'Importer une image.'; // info-bulle au Survol ( Hover )

                trigger OnAction()
                begin
                    ImportFromDevice(); // Appelle la procédure d'importation 
                end;
            }
            action(ImportMultiplePictures)
            {
                ApplicationArea = All;
                Caption = 'Importer plusieurs images';
                Image = Import;
                ToolTip = 'Importer plusieurs images depuis un fichier ZIP.';

                trigger OnAction()
                var
                    ZipInStream: InStream;
                    FileName: Text;
                    DataCompression: Codeunit "Data Compression";
                    UploadFileMsg: Label 'Veuillez sélectionner un fichier ZIP à importer';
                    ItemPictureGallery: Record ItemPictureGallery;
                    Item: Record Item;
                    ImageStream: InStream;
                    ImageOutStream: OutStream;
                    EntryList: List of [Text];
                    EntryName: Text;
                    ItemNo: Code[20];
                    PictureNo: Integer;
                    TempBlob: Codeunit "Temp Blob";
                begin
                    if UploadIntoStream(UploadFileMsg, '', 'Zip files (*.zip)|*.zip', FileName, ZipInStream) then begin
                        DataCompression.OpenZipArchive(ZipInStream, false);
                        DataCompression.GetEntryList(EntryList);

                        foreach EntryName in EntryList do begin
                            if (StrPos(LowerCase(EntryName), '.jpg') > 0) or (StrPos(LowerCase(EntryName), '.png') > 0) then begin
                                // Assume file name format is 'ItemNo_PictureNo.ext'
                                ItemNo := CopyStr(EntryName, 1, StrPos(EntryName, '_') - 1);
                                Evaluate(PictureNo, CopyStr(EntryName, StrPos(EntryName, '_') + 1, StrPos(EntryName, '.') - StrPos(EntryName, '_') - 1));

                                if Item.Get(ItemNo) then begin
                                    TempBlob.CreateOutStream(ImageOutStream);
                                    DataCompression.ExtractEntry(EntryName, ImageOutStream);
                                    TempBlob.CreateInStream(ImageStream);

                                    ItemPictureGallery.Reset();
                                    ItemPictureGallery.SetRange("Item No.", ItemNo);
                                    ItemPictureGallery.SetRange("Item Picture No.", PictureNo);

                                    if not ItemPictureGallery.FindFirst() then begin
                                        ItemPictureGallery.Init();
                                        ItemPictureGallery."Item No." := ItemNo;
                                        ItemPictureGallery."Item Picture No." := PictureNo;
                                        ItemPictureGallery.Sequencing := PictureNo;
                                        ItemPictureGallery.Insert();
                                    end;

                                    ItemPictureGallery.Picture.ImportStream(ImageStream, EntryName);
                                    ItemPictureGallery.Modify();
                                end;
                            end;
                        end;

                        DataCompression.CloseZipArchive();
                        Message('Importation des images terminée.');
                    end else begin
                        Message('Aucun fichier sélectionné.');
                    end;
                end;
            }
            action(ExportSinglePicture)
            {
                ApplicationArea = All;
                Caption = 'Exporter l''image actuelle';
                Image = Export;
                ToolTip = 'Exporter l''image actuellement affichée.';

                trigger OnAction()
                var
                    TenantMedia: Record "Tenant Media";
                    PicInStream: InStream;
                    FileName: Text;
                begin
                    if Rec.Picture.Count > 0 then begin
                        if TenantMedia.Get(Rec.Picture.Item(1)) then begin
                            TenantMedia.CalcFields(Content);
                            if TenantMedia.Content.HasValue then begin
                                TenantMedia.Content.CreateInStream(PicInStream);
                                FileName := StrSubstNo('%1_%2.jpg', Rec."Item No.", Rec."Item Picture No.");
                                DownloadFromStream(PicInStream, 'Download Image', '', '', FileName);
                            end else begin
                                Message('Le contenu de l''image n''est pas disponible.');
                            end;
                        end else begin
                            Message('Impossible de récupérer l''image.');
                        end;
                    end else begin
                        Message('Aucune image à exporter.');
                    end;
                end;
            }
            //TODO: Enhance the Naming of the Zip(add Item Picture No), add error handling, also add support for differents formats
            action(ExportMultiplePictures)
            {
                ApplicationArea = All;
                Image = ExportAttachment;
                Caption = 'Exporter toutes les images dans un fichier Zip';
                ToolTip = 'Exporter toutes les images dans un fichier Zip';
                trigger OnAction()
                var
                    ItemPictureGallery: Record ItemPictureGallery;
                    TenantMedia: Record "Tenant Media";
                    datacompresion: Codeunit 425;
                    blobStorage: Codeunit "Temp Blob";
                    PicInStream, ZipInStream : InStream;
                    ZipOutStream: OutStream;
                    ZipFileName: Text;
                    ItemCnt, Index, PicCount : Integer;
                begin
                    ZipFileName := 'Pictures.zip';
                    datacompresion.CreateZipArchive();
                    ItemPictureGallery.Reset();
                    ItemPictureGallery.FindSet();
                    repeat
                        if ItemPictureGallery.Picture.Count > 0 then begin
                            ItemCnt := ItemCnt + 1;
                            for Index := 1 to ItemPictureGallery.Picture.Count do begin
                                PicCount := PicCount + 1;
                                if TenantMedia.Get(ItemPictureGallery.Picture.Item(Index)) then begin
                                    TenantMedia.CalcFields(Content);
                                    if TenantMedia.Content.HasValue then begin
                                        TenantMedia.Content.CreateInStream(PicInStream);
                                        datacompresion.AddEntry(PicInStream, StrSubstNo('%1_%2.jpg', ItemPictureGallery."Item No.", ItemPictureGallery."Item Picture No."));
                                    end;
                                end;
                            end;
                        end;
                    until ItemPictureGallery.Next() = 0;
                    Message('Items processed ' + Format(ItemCnt) + ' Pictures processed ' + Format(PicCount));
                    blobStorage.CreateOutStream(ZipOutStream);
                    datacompresion.SaveZipArchive(ZipOutStream);
                    datacompresion.CloseZipArchive();
                    blobStorage.CreateInStream(ZipInStream);
                    DownloadFromStream(ZipInStream, 'Download zip file', '', '', ZipFileName);
                end;
            }
            action(Next) // Action pour afficher l'image suivante
            {
                ApplicationArea = All;
                Caption = 'Suivant';
                Image = NextRecord; // Icone pour afficher l'image suivante

                trigger OnAction()
                begin
                    Rec.Next(1); // Passe à l'enregistrement (image) suivant
                end;
            }
            action(Previous) // Action pour afficher l'image précédente
            {
                ApplicationArea = All;
                Caption = 'Précédent';
                Image = PreviousRecord;

                trigger OnAction()
                begin
                    Rec.Next(-1); // Passe à l'enregistrement (image) précédent
                end;
            }
            action(DeletePicture) // Action pour supprimer l'image actuelle
            {
                ApplicationArea = All;
                Caption = 'Supprimer';
                Image = Delete;
                ToolTip = 'Supprimer l''image actuelle.';

                trigger OnAction()
                begin
                    DeleteItemPicture; // Appelle la procédure de suppression de l'image
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord() // Déclencheur après récupération de l'enregistrement actuel
    var
        ItemPictureGallery: Record ItemPictureGallery;
    begin
        ImageCount := ''; // Initialiser le compteur d'images
        ItemPictureGallery.Reset(); // Réinitialiser les filtres du record
        ItemPictureGallery.SetRange("Item No.", Rec."Item No."); // Appliquer un filtre sur le numéro d'article
        // Si des images sonts présentes, affiche la position de l'image actuelle, sinon 0/0
        if ItemPictureGallery.Count > 0 then
            ImageCount := Format(Rec.Sequencing) + ' / ' + Format(ItemPictureGallery.Count)
        else
            ImageCount := '0 / 0';
    end;

    // Variables globales pour les messages, compteur d'images et suppression
    var
        DeleteImageQst: Label 'Êtes-vous sur de vouloir supprimer cette image ?';
        NothingDel: Label 'Rien à supprimer';
        ImageCount: Text[100];


    procedure DeleteItemPicture()
    begin
        if not Confirm(DeleteImageQst) then
            exit;
        if Rec.Get(Rec."Item No.", Rec."Item Picture No.") then begin
            Clear(Rec.Picture);
            Rec.Delete();
            ResetOrdering();
            if Rec.Get(Rec."Item No.", Rec."Item Picture No." + 1) then
                exit
            else
                ImageCount := '0 / 0';
        end else begin
            Message(NothingDel);
        end;
    end;

    local procedure ImportFromDevice();
    var
        Item: Record Item;
        ItemPictureGallery: Record ItemPictureGallery;
        PictureInStream: InStream;
        FromFileName: Text;
        UploadFileMsg: Label 'Please select the image to upload';
    begin
        if Item.get(Rec."Item No.") then begin
            if UploadIntoStream('UploadFileMsg', '', 'All Files (*.*)|*.*', FromFileName, PictureInStream) then begin
                ItemPictureGallery.Init();
                ItemPictureGallery."Item No." := Item."No.";
                ItemPictureGallery."Item Picture No." := FindLastItemPictureNo(ItemPictureGallery."Item No.") + 1;
                ItemPictureGallery.Sequencing := ItemPictureGallery."Item Picture No.";
                ItemPictureGallery.Picture.ImportStream(PictureInStream, FromFileName);
                ItemPictureGallery.Insert();
                if ItemPictureGallery.Count <> ItemPictureGallery.Sequencing then
                    ResetOrdering();
                if Rec.Get(ItemPictureGallery."Item No.", ItemPictureGallery."Item Picture No.") then
                    exit;
            end;
        end;
    end;

    local procedure FindLastItemPictureNo(ItemNo: Code[20]): Integer
    var
        ItemPictureGallery: Record ItemPictureGallery;
    begin
        ItemPictureGallery.Reset();
        ItemPictureGallery.SetCurrentKey("Item No.", "Item Picture No.");
        ItemPictureGallery.Ascending(true);
        ItemPictureGallery.SetRange("Item No.", ItemNo);
        if ItemPictureGallery.FindLast() then
            exit(ItemPictureGallery."Item Picture No.");
    end;

    local procedure ResetOrdering()
    var
        ItemPictureGallery: Record ItemPictureGallery;
        Ordering: Integer;
    begin
        Ordering := 1;
        ItemPictureGallery.Reset();
        ItemPictureGallery.SetRange("Item No.", Rec."Item No.");
        if ItemPictureGallery.FindFirst() then
            repeat
                ItemPictureGallery.Sequencing := Ordering;
                Ordering += 1;
                ItemPictureGallery.Modify();
            until ItemPictureGallery.Next() = 0;
    end;
}
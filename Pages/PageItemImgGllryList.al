/* Cette section du code est trop longue, il faudrait utiliser des CodeUnits, EventSubscriber, et ou move les parties qui manipule table data vers tablextension ou tabletriggers */
/* Aprés rechrche, 300 a 400 lignes n'est pas mauvais, mais on peut tout a fait refactoriser les parties en suivant la (Single Resposability Principle) */
/* implémenter asynchrone processing ou buffer table pour les largeImports */
page 50102 "NL Item Picture Gallery"
{
    InsertAllowed = false; // Empêche l'insertion de nouvelles images directement via cette page
    LinksAllowed = false; // Empêche l'ajout de liens via cette page
    DeleteAllowed = false; // Empêche la suppression d'images via cette page
    Caption = 'Gallerie d''images d''articles';
    SourceTable = ItemPictureGallery; // Source de données
    PageType = CardPart; // factbox used to display detailed information related to a record within another page

    layout
    {
        area(content)
        {
            grid(ImageGalleryGrid)
            {
                ShowCaption = false;

                // Navigation arrows placed above the image
                group(NavigationGroup)
                {
                    ShowCaption = false;

                    field(PrevArrow; '<  ') // Previous arrow field
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Editable = false;
                        trigger OnDrillDown()
                        begin
                            ShowPreviousImage(); // Call procedure to show the previous image
                        end;
                    }
                    field(NextArrow; '>  ')
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Editable = false;
                        trigger OnDrillDown()
                        begin
                            ShowNextImage(); // Call procedure to show the next image
                        end;
                    }
                }

            }
            // Main image display
            field(Picture; Rec.Picture)
            {
                ApplicationArea = All;
                ShowCaption = false;
                Editable = false;
            }
            // Displays the image count below the image
            field(ImageCount; ImageCount)
            {
                ApplicationArea = All;
                ShowCaption = false;
                Editable = false;
            }
        }
    }
    // TODO: Faire des local procedures  ou codeunits pour les actions ( ameliorant la maintenance et rapidité d'éxécution)
    actions
    {
        area(processing)
        {
            // Pour cet import pas besoin de renommer l'image, elle sera automatiquement nommée ( Item No. + Item Picture No. )
            action(ImportOnePicture)
            {
                ApplicationArea = All;
                Caption = 'Importer une image';
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
                Caption = 'Importer plusieurs images pour cet article';
                Image = Import;
                ToolTip = 'Importer plusieurs images depuis un fichier ZIP vers l''article de la page.';

                trigger OnAction()
                begin
                    ImportMultiplePicturesFromZIP();
                end;
            }
            action(ImportMultiplePicturesForAllItems)
            {
                ApplicationArea = All;
                Caption = 'Importer plusieurs images pour tous les articles';
                Image = Import;
                ToolTip = 'Importer plusieurs images depuis un fichier ZIP pour tous les articles.';

                trigger OnAction()
                begin
                    ImportMultiplePicturesForAllItemsFromZIP();
                end;
            }
            action(ExportSinglePicture)
            {
                ApplicationArea = All;
                Caption = 'Exporter l''image actuelle';
                Image = ExportAttachment;
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
            action(ExportItemPictures)
            {
                ApplicationArea = All;
                Image = ExportAttachment;
                Caption = 'Exporter les images de cet article dans un fichier Zip';
                ToolTip = 'Exporter toutes les images de cet article dans un fichier Zip';

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
                    ZipFileName := StrSubstNo('%1_Pictures.zip', Rec."Item No.");
                    datacompresion.CreateZipArchive();

                    // Filter for the specific item
                    ItemPictureGallery.Reset();
                    ItemPictureGallery.SetRange("Item No.", Rec."Item No."); // Filter to only include images for the current item

                    if ItemPictureGallery.FindSet() then begin
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
                    end;

                    Message('Images traitées : %1', Format(PicCount));
                    blobStorage.CreateOutStream(ZipOutStream);
                    datacompresion.SaveZipArchive(ZipOutStream);
                    datacompresion.CloseZipArchive();
                    blobStorage.CreateInStream(ZipInStream);
                    DownloadFromStream(ZipInStream, 'Télécharger le fichier zip', '', '', ZipFileName);
                end;
            }
            //TODO: add error handling, also add support for differents formats and add duplicate verification
            // Cet export exporte toutes les images de la table Gallerie Images.
            action(ExportMultiplePictures)
            {
                ApplicationArea = All;
                Image = ExportAttachment;
                Caption = 'Exporter toutes les images de la table';
                ToolTip = 'Exporter toutes les images de la table Gallerie dans un fichier ZIP';
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

    local procedure ImportMultiplePicturesFromZIP()
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
        SuffixPos: Integer;
    begin
        if UploadIntoStream(UploadFileMsg, '', 'Zip files (*.zip)|*.zip', FileName, ZipInStream) then begin
            DataCompression.OpenZipArchive(ZipInStream, false);
            DataCompression.GetEntryList(EntryList);

            foreach EntryName in EntryList do begin
                if (StrPos(LowerCase(EntryName), '.jpg') > 0) or (StrPos(LowerCase(EntryName), '.png') > 0) then begin
                    // Determine ItemNo and PictureNo
                    SuffixPos := StrPos(EntryName, '_');
                    if SuffixPos > 0 then begin
                        ItemNo := CopyStr(EntryName, 1, SuffixPos - 1);
                        Evaluate(PictureNo, CopyStr(EntryName, SuffixPos + 1, StrPos(EntryName, '.') - SuffixPos - 1));
                    end else begin
                        ItemNo := CopyStr(EntryName, 1, StrPos(EntryName, '.') - 1);
                        PictureNo := GetNextPictureNo(ItemNo);
                    end;

                    // Check if an image with the same Item No. and Picture No. already exists
                    ItemPictureGallery.SetRange("Item No.", ItemNo);
                    ItemPictureGallery.SetRange("Item Picture No.", PictureNo);

                    if ItemPictureGallery.FindFirst() then begin
                        Message('Image doublon détectée pour l''article No: %1, Image No: %2. L''importation est ignorée.', ItemNo, PictureNo);
                    end else begin
                        TempBlob.CreateOutStream(ImageOutStream);
                        DataCompression.ExtractEntry(EntryName, ImageOutStream);
                        TempBlob.CreateInStream(ImageStream);

                        ItemPictureGallery.Init();
                        ItemPictureGallery."Item No." := ItemNo;
                        ItemPictureGallery."Item Picture No." := PictureNo;
                        ItemPictureGallery.Sequencing := PictureNo;

                        ItemPictureGallery.Picture.ImportStream(ImageStream, EntryName);
                        ItemPictureGallery.Insert();
                    end;
                end;
            end;

            DataCompression.CloseZipArchive();
            Message('Importation des images terminée.');
        end else begin
            Message('Aucun fichier sélectionné.');
        end;
    end;

    local procedure GetNextPictureNo(ItemNo: Code[20]): Integer
    var
        ItemPictureGallery: Record "ItemPictureGallery";
    begin
        ItemPictureGallery.SetRange("Item No.", ItemNo);
        if ItemPictureGallery.FindLast() then
            exit(ItemPictureGallery."Item Picture No." + 1);  // Start indexation at 1 
        exit(1);  // Start at 1 if no images exist
    end;

    local procedure ImportMultiplePicturesForAllItemsFromZIP()
    var
        ZipInStream: InStream;
        FileName: Text;
        DataCompression: Codeunit "Data Compression";
        UploadFileMsg: Label 'Veuillez sélectionner un fichier ZIP à importer';
        ItemPictureGallery: Record "ItemPictureGallery";
        Item: Record Item;
        ImageStream: InStream;
        ImageOutStream: OutStream;
        EntryList: List of [Text];
        EntryName: Text;
        ItemNo: Code[20];
        PictureNo: Integer;
        TempBlob: Codeunit "Temp Blob";
        Window: Dialog;
        ImportedCount: Integer;
        TotalCount: Integer;
        SuffixPos: Integer;
    begin
        if UploadIntoStream(UploadFileMsg, '', 'Zip files (*.zip)|*.zip', FileName, ZipInStream) then begin
            DataCompression.OpenZipArchive(ZipInStream, false);
            DataCompression.GetEntryList(EntryList);

            Window.Open('Traitement: #1##### sur #2#####\Fichier: #3##################');
            TotalCount := EntryList.Count();
            ImportedCount := 0;

            foreach EntryName in EntryList do begin
                ImportedCount += 1;
                Window.Update(1, ImportedCount);
                Window.Update(2, TotalCount);
                Window.Update(3, EntryName);

                if (StrPos(LowerCase(EntryName), '.jpg') > 0) or (StrPos(LowerCase(EntryName), '.png') > 0) then begin
                    // Determine ItemNo and PictureNo
                    SuffixPos := StrPos(EntryName, '_');
                    if SuffixPos > 0 then begin
                        ItemNo := CopyStr(EntryName, 1, SuffixPos - 1);
                        Evaluate(PictureNo, CopyStr(EntryName, SuffixPos + 1, StrPos(EntryName, '.') - SuffixPos - 1));
                    end else begin
                        ItemNo := CopyStr(EntryName, 1, StrPos(EntryName, '.') - 1);
                        PictureNo := GetNextPictureNo(ItemNo);  // Ensure unique PictureNo
                    end;

                    // Check if an image with the same Item No. and Picture No. already exists
                    ItemPictureGallery.SetRange("Item No.", ItemNo);
                    ItemPictureGallery.SetRange("Item Picture No.", PictureNo);

                    while ItemPictureGallery.Get(ItemNo, PictureNo) do begin
                        PictureNo += 1; // Increment PictureNo to avoid duplication
                    end;

                    // Import the image if the item exists
                    if Item.Get(ItemNo) then begin
                        TempBlob.CreateOutStream(ImageOutStream);
                        DataCompression.ExtractEntry(EntryName, ImageOutStream);
                        TempBlob.CreateInStream(ImageStream);

                        ItemPictureGallery.Init();
                        ItemPictureGallery."Item No." := ItemNo;
                        ItemPictureGallery."Item Picture No." := PictureNo;
                        ItemPictureGallery.Sequencing := PictureNo;

                        ItemPictureGallery.Picture.ImportStream(ImageStream, EntryName);
                        if ItemPictureGallery.Insert() then
                            Message('Image importée pour l''article No: %1, Image No: %2', ItemNo, PictureNo)
                        else
                            Message('Échec de l''importation pour l''article No: %1, Image No: %2', ItemNo, PictureNo);
                    end else begin
                        Message('Article No. %1 non trouvé. Import d''image ignoré.', ItemNo);
                    end;
                end;
            end;

            DataCompression.CloseZipArchive();
            Window.Close();
            Message('Importation des images terminée. %1 fichiers traités.', ImportedCount);
        end else begin
            Message('Aucun fichier sélectionné.');
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

    // Local procedures for navigating images
    local procedure ShowNextImage()
    var
        RecordsSkipped: Integer;
    begin
        RecordsSkipped := Rec.Next(1); // Move to the next record
        if RecordsSkipped > 0 then begin // Check if a record was found
            CurrPage.Update(false); // Refresh page to show the next image
        end;
    end;

    local procedure ShowPreviousImage()
    var
        RecordsSkipped: Integer;
    begin
        RecordsSkipped := Rec.Next(-1); // Move to the previous record
        if RecordsSkipped > 0 then begin // Check if a record was found
            CurrPage.Update(false); // Refresh page to show the previous image
        end;
    end;
}
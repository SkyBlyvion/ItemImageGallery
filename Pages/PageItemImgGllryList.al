/* Cette section du code est trop longue, il faudrait utiliser des CodeUnits, EventSubscriber, et ou move les parties qui manipule table data vers tablextension ou tabletriggers */
/* Aprés rechrche, 500 lignes n'est pas mauvais, mais on peut tout à fait refactoriser les parties en suivant la (Single Resposability Principle) */
/* implémenter asynchrone processing ou buffer table pour les largeImports */
/* Import limité a 350Mo*/
page 50102 "NL Item Picture Gallery"
{
    InsertAllowed = false; // Empêche l'insertion de nouvelles images directement via cette page
    LinksAllowed = false; // Empêche l'ajout de liens via cette page
    DeleteAllowed = false; // Empêche la suppression d'images via cette page
    Caption = 'Gallerie d''images d''articles';
    SourceTable = ItemPictureGallery; // Source de données
    PageType = CardPart; // Type de page

    layout
    {
        area(content)
        {
            grid(ImageGalleryGrid)
            {
                ShowCaption = false;

                // Fleches de navigation au dessus de l'image
                group(NavigationGroup)
                {
                    ShowCaption = false;

                    field(PrevArrow; '<  ') // Champ fléche precédente
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Editable = false;
                        trigger OnDrillDown()
                        begin
                            ShowPreviousImage(); // Appelle la procédure pour afficher l'image precedente
                        end;
                    }
                    field(NextArrow; '>  ')
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Editable = false;
                        trigger OnDrillDown()
                        begin
                            ShowNextImage(); // Appelle la procédure pour afficher l'image suivante
                        end;
                    }
                }
            }
            // Affichage de l'image
            field(Picture; Rec.Picture)
            {
                ApplicationArea = All;
                ShowCaption = false;
                Editable = false;
            }
            // Affichage du compteur d'image sous l'image
            field(ImageCount; ImageCount)
            {
                ApplicationArea = All;
                ShowCaption = false;
                Editable = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            // Pour cet import pas besoin de renommer l'image, elle sera automatiquement nommée ( Item No. + Item Picture No. )
            // Permet d'importer une seule image
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
            // Permet d'importer plusieurs images pour un article
            action(ImportMultiplePictures)
            {
                ApplicationArea = All;
                Caption = 'Importer plusieurs images pour cet article';
                Image = Import;
                ToolTip = 'Importer plusieurs images depuis un fichier ZIP vers l''article de la page.';

                trigger OnAction()
                begin
                    ImportMultiplePicturesFromZIP(); // Appelle la procédure d'importation
                end;
            }
            // Permet d'importer plusieurs images pour tous les articles
            action(ImportMultiplePicturesForAllItems)
            {
                ApplicationArea = All;
                Caption = 'Importer plusieurs images pour tous les articles';
                Image = Import;
                ToolTip = 'Importer plusieurs images depuis un fichier ZIP pour tous les articles.';

                trigger OnAction()
                begin
                    ImportMultiplePicturesForAllItemsFromZIP(); // Appelle la procédure d'importation
                end;
            }
            // Permet d'exporter une seule image
            action(ExportSinglePicture)
            {
                ApplicationArea = All;
                Caption = 'Exporter l''image actuelle';
                Image = ExportAttachment; // image de l'action
                ToolTip = 'Exporter l''image actuellement affichée.';

                trigger OnAction()
                var
                    TenantMedia: Record "Tenant Media"; // Enregistrement Tenant Media
                    PicInStream: InStream; // Flux d'entrée de l'image
                    FileName: Text;
                begin
                    if Rec.Picture.Count > 0 then begin // Si il y a au moins une image 
                        if TenantMedia.Get(Rec.Picture.Item(1)) then begin
                            TenantMedia.CalcFields(Content);
                            if TenantMedia.Content.HasValue then begin // Si le contenu de l'image est disponible, on l'exporte, sinon on affiche un message d'erreur
                                TenantMedia.Content.CreateInStream(PicInStream);
                                FileName := StrSubstNo('%1_%2.jpg', Rec."Item No.", Rec."Item Picture No.");
                                DownloadFromStream(PicInStream, 'Download Image', '', '', FileName);
                            end else
                                Message('Le contenu de l''image n''est pas disponible.');
                        end else
                            Message('Impossible de récupérer l''image.');
                    end else
                        Message('Aucune image à exporter.');
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
                    ItemPictureGallery: Record ItemPictureGallery; // Enregistrement ItemPictureGallery
                    TenantMedia: Record "Tenant Media"; // Enregistrement des ID's dans la Tenant Media
                    datacompresion: Codeunit 425; // Codeunit de compression ZIP
                    blobStorage: Codeunit "Temp Blob"; // Codeunit de stockage temporaire
                    PicInStream, ZipInStream : InStream; // Flux d'entrée de l'image
                    ZipOutStream: OutStream; // Flux de sortie du ZIP
                    ZipFileName: Text;
                    ItemCnt, Index, PicCount : Integer; // Compteur d'image
                begin
                    ZipFileName := StrSubstNo('%1_Pictures.zip', Rec."Item No."); // Nom du fichier ZIP
                    datacompresion.CreateZipArchive();

                    ItemPictureGallery.Reset(); // Reset des filtres
                    ItemPictureGallery.SetRange("Item No.", Rec."Item No."); // Appliquer un filtre sur le numéro d'article

                    if ItemPictureGallery.FindSet() then // Si des enregistrements correspondant au filtre sont trouvés, alors traiter chaque image
                        repeat

                            if ItemPictureGallery.Picture.Count > 0 then begin // Si l'enregistrement a des images associées, alors les ajouter à l'archive ZIP
                                ItemCnt := ItemCnt + 1; // Incrémenter le compteur d'articles traités

                                for Index := 1 to ItemPictureGallery.Picture.Count do begin // Parcourir toutes les images associées à cet enregistrement
                                    PicCount := PicCount + 1; // Incrémenter le compteur d'images traitées

                                    if TenantMedia.Get(ItemPictureGallery.Picture.Item(Index)) then begin // Si l'image est trouvée dans le record TenantMedia, alors la traiter
                                        TenantMedia.CalcFields(Content); // // Calculer les champs blob pour l'image

                                        if TenantMedia.Content.HasValue then begin // Si le contenu de l'image est disponible, alors l'ajouter à l'archive ZIP
                                            TenantMedia.Content.CreateInStream(PicInStream);
                                            datacompresion.AddEntry(PicInStream, StrSubstNo('%1_%2.jpg', ItemPictureGallery."Item No.", ItemPictureGallery."Item Picture No."));
                                        end;
                                    end;
                                end;
                            end;
                        until ItemPictureGallery.Next() = 0; // Répéter jusqu'à ce qu'il n'y ait plus d'images

                    Message('Images traitées : %1', Format(PicCount));

                    // Créer un flux de sortie pour le fichier ZIP et sauvegarder l'archive
                    blobStorage.CreateOutStream(ZipOutStream);
                    datacompresion.SaveZipArchive(ZipOutStream);
                    datacompresion.CloseZipArchive();

                    // Créer un flux d'entrée à partir du fichier ZIP et proposer le téléchargement
                    blobStorage.CreateInStream(ZipInStream);
                    DownloadFromStream(ZipInStream, 'Télécharger le fichier zip', '', '', ZipFileName);
                end;
            }
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
                    ZipFileName := 'Pictures.zip'; // Nom du fichier ZIP utilise un nom par defaut car plusieurs articles 
                    datacompresion.CreateZipArchive();
                    ItemPictureGallery.Reset();
                    ItemPictureGallery.FindSet();
                    repeat
                        if ItemPictureGallery.Picture.Count > 0 then begin // Si l'enregistrement a des images associées
                            ItemCnt := ItemCnt + 1;

                            for Index := 1 to ItemPictureGallery.Picture.Count do begin // Parcourir toutes les images associées à cet enregistrement
                                PicCount := PicCount + 1;

                                if TenantMedia.Get(ItemPictureGallery.Picture.Item(Index)) then begin // Si l'image est trouvée dans le record TenantMedia, alors la traiter
                                    TenantMedia.CalcFields(Content);

                                    if TenantMedia.Content.HasValue then begin // Si le contenu de l'image est disponible, alors l'ajouter à l'archive ZIP
                                        TenantMedia.Content.CreateInStream(PicInStream);
                                        datacompresion.AddEntry(PicInStream, StrSubstNo('%1_%2.jpg', ItemPictureGallery."Item No.", ItemPictureGallery."Item Picture No."));
                                    end;
                                end;
                            end;
                        end;
                    until ItemPictureGallery.Next() = 0;

                    Message('Items processed ' + Format(ItemCnt) + ' Pictures processed ' + Format(PicCount));

                    // Créer un flux de sortie pour le fichier ZIP et sauvegarder l'archive
                    blobStorage.CreateOutStream(ZipOutStream);
                    datacompresion.SaveZipArchive(ZipOutStream);
                    datacompresion.CloseZipArchive();

                    // Créer un flux d'entrée à partir du fichier ZIP et proposer le déchargement
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
                    DeleteItemPicture(); // Appelle la procédure de suppression de l'image
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

    // Variables globales pour les messages, compteur d'images et suppression
    var
        DeleteImageQst: Label 'Êtes-vous sur de vouloir supprimer cette image ?';
        NothingDelLbl: Label 'Rien à supprimer';
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
        end else
            Message(NothingDelLbl);
    end;

    local procedure ImportFromDevice();
    var
        Item: Record Item;
        ItemPictureGallery: Record ItemPictureGallery;
        PictureInStream: InStream;
        FromFileName: Text;
        UploadFileMsg: Label 'Please select the image to upload';
        LastItemPictureNo: Integer;
        FinalFileName: Text;
    begin
        if Item.Get(Rec."Item No.") then
            if UploadIntoStream(UploadFileMsg, '', 'All Files (*.*)|*.*', FromFileName, PictureInStream) then begin
                LastItemPictureNo := FindLastItemPictureNo(ItemPictureGallery."Item No.");

                ItemPictureGallery.Init();
                ItemPictureGallery."Item No." := Item."No.";

                // Determine the ItemPictureNo but do not use it directly for the first image's filename
                if LastItemPictureNo = 0 then begin
                    ItemPictureGallery."Item Picture No." := 1;  // First image
                    FinalFileName := Item."No."; // No suffix for first image
                end else begin
                    ItemPictureGallery."Item Picture No." := LastItemPictureNo + 1;
                    FinalFileName := StrSubstNo('%1_%2', Item."No.", ItemPictureGallery."Item Picture No.");
                end;

                ItemPictureGallery.Sequencing := ItemPictureGallery."Item Picture No.";
                ItemPictureGallery.Picture.ImportStream(PictureInStream, FinalFileName);
                ItemPictureGallery.Insert();

                if ItemPictureGallery.Count <> ItemPictureGallery.Sequencing then
                    ResetOrdering();

                if Rec.Get(ItemPictureGallery."Item No.", ItemPictureGallery."Item Picture No.") then
                    exit;
            end;
    end;

    local procedure ImportMultiplePicturesFromZIP()
    var
        // Item: Record Item;
        ItemPictureGallery: Record ItemPictureGallery;
        TempBlob: Codeunit "Temp Blob";
        DataCompression: Codeunit "Data Compression";
        ZipInStream: InStream;
        FileName: Text;
        UploadFileMsg: Label 'Veuillez sélectionner un fichier ZIP à importer';
        ImageStream: InStream;
        ImageOutStream: OutStream;
        EntryList: List of [Text];
        EntryName: Text;
        ItemNo: Code[20];
        PictureNo: Integer;
        SuffixPos: Integer;
    begin
        if UploadIntoStream(UploadFileMsg, '', 'Zip files (*.zip)|*.zip', FileName, ZipInStream) then begin
            DataCompression.OpenZipArchive(ZipInStream, false);
            DataCompression.GetEntryList(EntryList);

            foreach EntryName in EntryList do
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

                    if ItemPictureGallery.FindFirst() then
                        Message('Image doublon détectée pour l''article No: %1, Image No: %2. L''importation est ignorée.', ItemNo, PictureNo)
                    else begin
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


            DataCompression.CloseZipArchive();
            Message('Importation des images terminée.');
        end else
            Message('Aucun fichier sélectionné.');
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
        ItemPictureGallery: Record "ItemPictureGallery";
        Item: Record Item;
        DataCompression: Codeunit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
        ZipInStream: InStream;
        FileName: Text;
        ImageStream: InStream;
        ImageOutStream: OutStream;
        EntryList: List of [Text];
        EntryName: Text;
        ItemNo: Code[20];
        PictureNo: Integer;
    begin
        if UploadIntoStream('Select ZIP file to import', '', 'ZIP Files (*.zip)|*.zip', FileName, ZipInStream) then begin
            DataCompression.OpenZipArchive(ZipInStream, false);
            DataCompression.GetEntryList(EntryList);

            foreach EntryName in EntryList do
                if (StrPos(LowerCase(EntryName), '.jpg') > 0) or (StrPos(LowerCase(EntryName), '.png') > 0) then begin
                    ItemNo := GetItemNoFromFileName(EntryName);

                    if Item.Get(ItemNo) then begin
                        TempBlob.CreateOutStream(ImageOutStream);
                        DataCompression.ExtractEntry(EntryName, ImageOutStream);
                        TempBlob.CreateInStream(ImageStream);

                        ItemPictureGallery.Reset();
                        ItemPictureGallery.SetRange("Item No.", ItemNo);

                        // Determine next available PictureNo for this ItemNo
                        if not ItemPictureGallery.FindLast() then
                            PictureNo := 1
                        else
                            PictureNo := ItemPictureGallery."Item Picture No." + 1;

                        // Initialize and insert the new record
                        ItemPictureGallery.Init();
                        ItemPictureGallery."Item No." := ItemNo;
                        ItemPictureGallery."Item Picture No." := PictureNo;
                        ItemPictureGallery.Sequencing := PictureNo;

                        ItemPictureGallery.Picture.ImportStream(ImageStream, EntryName);
                        ItemPictureGallery.Insert(true);

                        // Message('Image imported for Item No: %1, Picture No: %2', ItemNo, PictureNo);
                    end;
                end;
        end;

        DataCompression.CloseZipArchive();
        Message('Image import completed.');
    end;


    local procedure GetItemNoFromFileName(FileName: Text): Code[20]
    var
        UnderscorePos: Integer;
        DotPos: Integer;
    begin
        UnderscorePos := StrPos(FileName, '_');
        DotPos := StrPos(FileName, '.');

        if UnderscorePos > 0 then
            exit(CopyStr(FileName, 1, UnderscorePos - 1))
        else if DotPos > 0 then
            exit(CopyStr(FileName, 1, DotPos - 1))
        else
            exit(FileName);
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
            exit(ItemPictureGallery."Item Picture No.")
        else
            exit(0); // Start at 0 if no images exist
    end;


    // Local procedures for navigating images
    local procedure ShowNextImage()
    var
        RecordsSkipped: Integer;
    begin
        RecordsSkipped := Rec.Next(1); // Move to the next record
        if RecordsSkipped > 0 then // Check if a record was found
            CurrPage.Update(false); // Refresh page to show the next image
    end;

    local procedure ShowPreviousImage()
    var
        RecordsSkipped: Integer;
    begin
        RecordsSkipped := Rec.Next(-1); // Move to the previous record
        if RecordsSkipped > 0 then  // Check if a record was found
            CurrPage.Update(false); // Refresh page to show the previous image      
    end;
}
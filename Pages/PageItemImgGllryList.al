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
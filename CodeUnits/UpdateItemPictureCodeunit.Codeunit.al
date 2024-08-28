codeunit 50101 "UpdateItemPictureCodeunit"
{
    trigger OnRun()
    var
        Item: Record Item;
        ItemPictureGallery: Record "ItemPictureGallery";
    begin
        // Parcourt tous les articles
        if Item.FindSet() then
            repeat
                // Récupère la première image associée dans ItemPictureGallery
                if ItemPictureGallery.Get(Item."No.", 1) then begin
                    Item.Picture := ItemPictureGallery.Picture; // Mise à jour de l'ID de l'image
                    Item.Modify();
                end;
            until Item.Next() = 0;
    end;
}

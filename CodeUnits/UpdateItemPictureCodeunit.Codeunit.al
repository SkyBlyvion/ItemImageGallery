/* Mettre à jour la table Picture avec les images de la table ItemPictureGallery
    afin de déclencher le traitement automatique des images par le système natif
    (création de thumbnails, mosaïques, etc.) */
codeunit 50101 "UpdateItemPictureCodeunit"
{
    trigger OnRun()
    var
        Item: Record Item;
        ItemPictureGallery: Record "ItemPictureGallery";
    begin
        // Loop through all items
        if Item.FindSet() then
            repeat
                // Apply a filter to get the first image associated with the item
                ItemPictureGallery.SetRange("Item No.", Item."No.");
                if ItemPictureGallery.FindFirst() then
                    // Compare MediaSet IDs to check if the image needs to be updated
                    if Item.Picture.MediaId <> ItemPictureGallery.Picture.MediaId then begin
                        Item.Picture := ItemPictureGallery.Picture; // Update the picture
                        Item.Modify(); // Modify the record only if the pictures are different
                    end;
            until Item.Next() = 0;
    end;
}

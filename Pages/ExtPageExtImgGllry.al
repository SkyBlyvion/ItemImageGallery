pageextension 50106 "NLItemCardExt" extends "Item Card"
{
    layout
    {
        addbefore(ItemPicture) // Ajoute une section avant le groupe "ItemPicture" sur la fiche article.
        {
            part(NLItemPicture; "NL Item Picture Gallery") // Ajoute une sous-page (part) qui est la galerie d'images pour l'article. Qui est notre page Crée.
            {
                ApplicationArea = All;
                SubPageLink = "Item No." = FIELD("No."); // Lien de sous-page pour lier la galerie d'images(Page Crée) à l'article actuellement affiché. Le lien se fait par le champ "No." de l'article.
            }
        }
    }
}
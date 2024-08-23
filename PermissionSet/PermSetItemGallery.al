permissionset 50104 "ItemGllryPermissions"
{
    Assignable = true;
    Caption = 'Permissions pour la gallerie d''images d''un article';

    Permissions =
        tabledata "ItemPictureGallery" = RIMD,
        tabledata "Item Picture Import Buffer" = RIMD,
        page "NL Item Picture Gallery" = X,
        page "Custom Import Item Pictures" = X;
}
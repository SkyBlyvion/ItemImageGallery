permissionset 50103 "ItemGllryPermissions"
{
    Assignable = true;
    Caption = 'Permissions pour la gallerie d''images d''un article';

    Permissions =
        tabledata "ItemPictureGallery" = RIMD,
        page "NL Item Picture Gallery" = X;
}
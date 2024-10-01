pageextension 50106 "ItemListWithActionExt" extends "Item List"
{
    actions
    {
        addfirst(Processing)
        {
            action("Update Item Pictures")
            {
                Caption = 'Mettre à Jour les Images des Articles';
                ToolTip = 'Mettre à Jour les Images des Articles';
                Image = Refresh; // Si cette ligne cause une erreur, supprimez-la
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Codeunit.Run(50101); // Exécute le Codeunit pour mettre à jour les images
                end;
            }
        }
    }
}

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
                Image = Refresh; // Si cette ligne cause une erreur, supprime-la
                ApplicationArea = All; // Assure-toi que cette propriété est définie

                trigger OnAction()
                begin
                    Codeunit.Run(50101); // Exécute le Codeunit pour mettre à jour les images
                end;
            }
        }
    }
}

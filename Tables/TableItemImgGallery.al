table 50100 ItemPictureGallery
{
    Caption = 'Gallerie d''images'; // Nom affiché dans l'interface user
    DataClassification = CustomerContent; // Classification de données

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'No. d''article'; // libellé du champ dans l'interface
            TableRelation = Item; // Relation avec la table Item pour assurer la liaison avec la table des articles existants
            DataClassification = CustomerContent;
        }
        field(2; "Item Picture No."; Integer) // Ce champ stocke un numéro unique pour chaque image associée à un article.
        {
            Caption = 'No. d''image d''article';
            DataClassification = CustomerContent;
        }
        field(3; Picture; MediaSet) // Ce champ utilise le type MediaSet, permettant de stocker plusieurs images pour un seul article. 
        {
            Caption = 'Image';
            DataClassification = CustomerContent;
        }
        field(5; Sequencing; Integer) // Ce champ est utilisé pour ordonner les images. Par exemple, si un article a plusieurs images, ce champ peut être utilisé pour déterminer l'ordre d'affichage des images.
        {
            Caption = 'Sequencing';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Item No.", "Item Picture No.")
        {
            Clustered = true; // Indique que cette clé primaire est clusterisée pour améliorer les performances de recherche.
        }
    }
}
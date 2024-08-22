## Old Parts 
    // layout
    // {
    //     area(content)
    //     {
    //         field(ImageCount; ImageCount) // affiche le nombre total d'images et la position de l'image actuellement affichée. TOP RIGHT
    //         {
    //             ApplicationArea = All;
    //             ShowCaption = false; // Cache la légende (caption) du champ
    //             Editable = false;
    //         }
    //         field(Picture; Rec.Picture) // affiche l'image associée à l'article.
    //         {
    //             ApplicationArea = All;
    //             ShowCaption = false;
    //         }
    //     }
    // }


    // layout
    // {
    //     area(content)
    //     {
    //         grid(ImageGalleryGrid)
    //         {
    //             ShowCaption = false;

    //             field(PrevArrow; Format('<-')) // Previous arrow field
    //             {
    //                 ApplicationArea = All;
    //                 ShowCaption = false;
    //                 Editable = false;
    //                 trigger OnDrillDown()
    //                 begin
    //                     ShowPreviousImage(); // Call procedure to show the previous image
    //                 end;
    //             }
    //             field(Picture; Rec.Picture) // Main image display
    //             {
    //                 ApplicationArea = All;
    //                 ShowCaption = false;
    //                 Editable = false;
    //             }
    //             field(NextArrow; Format('->')) // Next arrow field
    //             {
    //                 ApplicationArea = All;
    //                 ShowCaption = false;
    //                 Editable = false;
    //                 trigger OnDrillDown()
    //                 begin
    //                     ShowNextImage(); // Call procedure to show the next image
    //                 end;
    //             }
    //         }
    //         field(ImageCount; ImageCount) // Displays the image count
    //         {
    //             ApplicationArea = All;
    //             ShowCaption = false;
    //             Editable = false;
    //         }
    //     }
    // }


    // action(Next) // Action pour afficher l'image suivante
    // {
    //     ApplicationArea = All;
    //     Caption = 'Suivant';
    //     Image = NextRecord; // Icone pour afficher l'image suivante

    //     trigger OnAction()
    //     begin
    //         Rec.Next(1); // Passe à l'enregistrement (image) suivant
    //     end;
    // }
    // action(Previous) // Action pour afficher l'image précédente
    // {
    //     ApplicationArea = All;
    //     Caption = 'Précédent';
    //     Image = PreviousRecord;

    //     trigger OnAction()
    //     begin
    //         Rec.Next(-1); // Passe à l'enregistrement (image) précédent
    //     end;
    // }

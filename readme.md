pageextension 50108 "ItemListImageOverride" extends "Item List"
{
    layout
    {
        addfirst(Content)
        {
            field(CustomItemPicture; ItemPictureGallery.Picture)
            {
                ApplicationArea = All;
                ShowCaption = false;
            }
        }
    }

    var
        ItemPictureGallery: Record "ItemPictureGallery";

    trigger OnAfterGetRecord()
    begin
        // Set the filters to find the correct image in the ItemPictureGallery table
        ItemPictureGallery.SetRange("Item No.", Rec."No.");
        ItemPictureGallery.SetRange(Sequencing, 1); // Assuming the first image is the primary one

        if not ItemPictureGallery.FindFirst() then begin
            ItemPictureGallery.Init(); // Reset the record if no image is found
        end;
    end;

}


    // local procedure ImportMultiplePicturesForAllItemsFromZIP()
    // var
    //     ZipInStream: InStream;
    //     FileName: Text;
    //     DataCompression: Codeunit "Data Compression";
    //     UploadFileMsg: Label 'Veuillez sélectionner un fichier ZIP à importer';
    //     ItemPictureGallery: Record ItemPictureGallery;
    //     Item: Record Item;
    //     ImageStream: InStream;
    //     ImageOutStream: OutStream;
    //     EntryList: List of [Text];
    //     EntryName: Text;
    //     ItemNo: Code[20];
    //     PictureNo: Integer;
    //     TempBlob: Codeunit "Temp Blob";
    //     Window: Dialog;
    //     ImportedCount: Integer;
    //     TotalCount: Integer;
    //     SuffixPos: Integer;
    // begin
    //     if UploadIntoStream(UploadFileMsg, '', 'Zip files (*.zip)|*.zip', FileName, ZipInStream) then begin
    //         DataCompression.OpenZipArchive(ZipInStream, false);
    //         DataCompression.GetEntryList(EntryList);

    //         Window.Open('Traitement: #1##### sur #2#####\Fichier: #3##################');
    //         TotalCount := EntryList.Count();
    //         ImportedCount := 0;

    //         foreach EntryName in EntryList do begin
    //             ImportedCount += 1;
    //             Window.Update(1, ImportedCount);
    //             Window.Update(2, TotalCount);
    //             Window.Update(3, EntryName);

    //             if (StrPos(LowerCase(EntryName), '.jpg') > 0) or (StrPos(LowerCase(EntryName), '.png') > 0) then begin
    //                 // Determine ItemNo and PictureNo
    //                 SuffixPos := StrPos(EntryName, '_');
    //                 if SuffixPos > 0 then begin
    //                     ItemNo := CopyStr(EntryName, 1, SuffixPos - 1);
    //                     Evaluate(PictureNo, CopyStr(EntryName, SuffixPos + 1, StrPos(EntryName, '.') - SuffixPos - 1));
    //                 end else begin
    //                     ItemNo := CopyStr(EntryName, 1, StrPos(EntryName, '.') - 1);
    //                     PictureNo := GetNextPictureNo(ItemNo);  // Ensure unique PictureNo
    //                 end;

    //                 // Check if an image with the same Item No. and Picture No. already exists
    //                 ItemPictureGallery.SetRange("Item No.", ItemNo);
    //                 ItemPictureGallery.SetRange("Item Picture No.", PictureNo);

    //                 if ItemPictureGallery.FindFirst() then begin
    //                     Message('Image doublon détectée pour l''article No: %1, Image No: %2. L''importation est ignorée.', ItemNo, PictureNo);
    //                 end else begin
    //                     if Item.Get(ItemNo) then begin
    //                         TempBlob.CreateOutStream(ImageOutStream);
    //                         DataCompression.ExtractEntry(EntryName, ImageOutStream);
    //                         TempBlob.CreateInStream(ImageStream);

    //                         ItemPictureGallery.Init();
    //                         ItemPictureGallery."Item No." := ItemNo;
    //                         ItemPictureGallery."Item Picture No." := PictureNo;
    //                         ItemPictureGallery.Sequencing := PictureNo;

    //                         ItemPictureGallery.Picture.ImportStream(ImageStream, EntryName);
    //                         if ItemPictureGallery.Insert() then
    //                             Message('Image importée pour l''article No: %1, Image No: %2', ItemNo, PictureNo)
    //                         else
    //                             Message('Échec de l''importation pour l''article No: %1, Image No: %2', ItemNo, PictureNo);
    //                     end else
    //                         Message('Article No. %1 non trouvé. Import d''image ignoré.', ItemNo);
    //                 end;
    //             end;
    //         end;

    //         DataCompression.CloseZipArchive();
    //         Window.Close();
    //         Message('Importation des images terminée. %1 fichiers traités.', ImportedCount);
    //     end else begin
    //         Message('Aucun fichier sélectionné.');
    //     end;
    // end;

    


    // local procedure ImportMultiplePicturesForAllItemsFromZIP()
    // var
    //     ZipInStream: InStream;
    //     FileName: Text;
    //     DataCompression: Codeunit "Data Compression";
    //     UploadFileMsg: Label 'Veuillez sélectionner un fichier ZIP à importer';
    //     ItemPictureGallery: Record "ItemPictureGallery";
    //     Item: Record Item;
    //     ImageStream: InStream;
    //     ImageOutStream: OutStream;
    //     EntryList: List of [Text];
    //     EntryName: Text;
    //     ItemNo: Code[20];
    //     PictureNo: Integer;
    //     TempBlob: Codeunit "Temp Blob";
    //     Window: Dialog;
    //     ImportedCount: Integer;
    //     TotalCount: Integer;
    //     SuffixPos: Integer;
    // begin
    //     if UploadIntoStream(UploadFileMsg, '', 'Zip files (*.zip)|*.zip', FileName, ZipInStream) then begin
    //         DataCompression.OpenZipArchive(ZipInStream, false);
    //         DataCompression.GetEntryList(EntryList);

    //         Window.Open('Traitement: #1##### sur #2#####\Fichier: #3##################');
    //         TotalCount := EntryList.Count();
    //         ImportedCount := 0;

    //         foreach EntryName in EntryList do begin
    //             ImportedCount += 1;
    //             Window.Update(1, ImportedCount);
    //             Window.Update(2, TotalCount);
    //             Window.Update(3, EntryName);

    //             if (StrPos(LowerCase(EntryName), '.jpg') > 0) or (StrPos(LowerCase(EntryName), '.png') > 0) then begin
    //                 // Determine ItemNo and PictureNo
    //                 SuffixPos := StrPos(EntryName, '_');
    //                 if SuffixPos > 0 then begin
    //                     ItemNo := CopyStr(EntryName, 1, SuffixPos - 1);
    //                     Evaluate(PictureNo, CopyStr(EntryName, SuffixPos + 1, StrPos(EntryName, '.') - SuffixPos - 1));
    //                 end else begin
    //                     ItemNo := CopyStr(EntryName, 1, StrPos(EntryName, '.') - 1);
    //                     PictureNo := GetNextPictureNo(ItemNo); // Ensure unique PictureNo
    //                 end;

    //                 // Check if an image with the same Item No. and Picture No. already exists
    //                 ItemPictureGallery.SetRange("Item No.", ItemNo);
    //                 ItemPictureGallery.SetRange("Item Picture No.", PictureNo);

    //                 if not ItemPictureGallery.FindFirst() then begin
    //                     TempBlob.CreateOutStream(ImageOutStream);
    //                     DataCompression.ExtractEntry(EntryName, ImageOutStream);
    //                     TempBlob.CreateInStream(ImageStream);

    //                     ItemPictureGallery.Init();
    //                     ItemPictureGallery."Item No." := ItemNo;
    //                     ItemPictureGallery."Item Picture No." := PictureNo;
    //                     ItemPictureGallery.Sequencing := PictureNo;

    //                     ItemPictureGallery.Picture.ImportStream(ImageStream, EntryName);
    //                     ItemPictureGallery.Insert();

    //                     Message('Image importée pour l''article No: %1, Image No: %2', ItemNo, PictureNo);
    //                 end else begin
    //                     Message('Image doublon détectée pour l''article No: %1, Image No: %2. L''importation est ignorée.', ItemNo, PictureNo);
    //                 end;
    //             end;
    //         end;

    //         DataCompression.CloseZipArchive();
    //         Window.Close();
    //         Message('Importation des images terminée. %1 fichiers traités.', ImportedCount);
    //     end else begin
    //         Message('Aucun fichier sélectionné.');
    //     end;
    // end;


    /* Output 02-0201_1 02-0201_2 02-0201_3 
    Input  02-0201 02-0201_1 02-0201_2 02-0201_3 1.0.3.2*/
    // local procedure ImportMultiplePicturesForAllItemsFromZIP()
    // var
    //     ItemPictureGallery: Record "ItemPictureGallery";
    //     Item: Record Item;
    //     DataCompression: Codeunit "Data Compression";
    //     TempBlob: Codeunit "Temp Blob";
    //     ZipInStream: InStream;
    //     FileName: Text;
    //     UploadFileMsg: Label 'Veuillez sélectionner un fichier ZIP à importer';
    //     ImageStream: InStream;
    //     ImageOutStream: OutStream;
    //     EntryList: List of [Text];
    //     EntryName: Text;
    //     ItemNo: Code[20];
    //     PictureNo: Integer;
    //     Window: Dialog;
    //     ImportedCount: Integer;
    //     TotalCount: Integer;
    //     SuffixPos: Integer;
    // begin
    //     if UploadIntoStream(UploadFileMsg, '', 'Zip files (*.zip)|*.zip', FileName, ZipInStream) then begin
    //         DataCompression.OpenZipArchive(ZipInStream, false);
    //         DataCompression.GetEntryList(EntryList);

    //         Window.Open('Traitement: #1##### sur #2#####\Fichier: #3##################');
    //         TotalCount := EntryList.Count();
    //         ImportedCount := 0;

    //         foreach EntryName in EntryList do begin
    //             ImportedCount += 1;
    //             Window.Update(1, ImportedCount);
    //             Window.Update(2, TotalCount);
    //             Window.Update(3, EntryName);

    //             if (StrPos(LowerCase(EntryName), '.jpg') > 0) or (StrPos(LowerCase(EntryName), '.png') > 0) then begin
    //                 // Determine ItemNo and PictureNo
    //                 SuffixPos := StrPos(EntryName, '_');
    //                 if SuffixPos > 0 then begin
    //                     ItemNo := CopyStr(EntryName, 1, SuffixPos - 1);
    //                     Evaluate(PictureNo, CopyStr(EntryName, SuffixPos + 1, StrPos(EntryName, '.') - SuffixPos - 1));
    //                 end else begin
    //                     ItemNo := CopyStr(EntryName, 1, StrPos(EntryName, '.') - 1);
    //                     PictureNo := GetNextPictureNo(ItemNo);  // Ensure unique PictureNo
    //                 end;

    //                 // Check if an image with the same Item No. and Picture No. already exists
    //                 ItemPictureGallery.SetRange("Item No.", ItemNo);
    //                 ItemPictureGallery.SetRange("Item Picture No.", PictureNo);

    //                 while ItemPictureGallery.Get(ItemNo, PictureNo) do
    //                     PictureNo += 1; // Increment PictureNo to avoid duplication

    //                 // Import the image if the item exists
    //                 if Item.Get(ItemNo) then begin
    //                     TempBlob.CreateOutStream(ImageOutStream);
    //                     DataCompression.ExtractEntry(EntryName, ImageOutStream);
    //                     TempBlob.CreateInStream(ImageStream);

    //                     ItemPictureGallery.Init();
    //                     ItemPictureGallery."Item No." := ItemNo;
    //                     ItemPictureGallery."Item Picture No." := PictureNo;
    //                     ItemPictureGallery.Sequencing := PictureNo;

    //                     ItemPictureGallery.Picture.ImportStream(ImageStream, EntryName);
    //                     if ItemPictureGallery.Insert() then
    //                         Message('Image importée pour l''article No: %1, Image No: %2', ItemNo, PictureNo)
    //                     else
    //                         Message('Échec de l''importation pour l''article No: %1, Image No: %2', ItemNo, PictureNo);
    //                 end else
    //                     Message('Article No. %1 non trouvé. Import d''image ignoré.', ItemNo);
    //             end;
    //         end;

    //         DataCompression.CloseZipArchive();
    //         Window.Close();
    //         Message('Importation des images terminée. %1 fichiers traités.', ImportedCount);
    //     end else
    //         Message('Aucun fichier sélectionné.');
    // end;

    /* 1.0.3.3 */
    // local procedure ImportMultiplePicturesForAllItemsFromZIP()
    // var
    //     ItemPictureGallery: Record "ItemPictureGallery";
    //     Item: Record Item;
    //     DataCompression: Codeunit "Data Compression";
    //     TempBlob: Codeunit "Temp Blob";
    //     ZipInStream: InStream;
    //     FileName: Text;
    //     UploadFileMsg: Label 'Veuillez sélectionner un fichier ZIP à importer';
    //     ImageStream: InStream;
    //     ImageOutStream: OutStream;
    //     EntryList: List of [Text];
    //     EntryName: Text;
    //     ItemNo: Code[20];
    //     PictureNo: Integer;
    //     Window: Dialog;
    //     ImportedCount: Integer;
    //     TotalCount: Integer;
    //     SuffixPos: Integer;
    //     IsFirstImage: Boolean; // Added to track the first image
    // begin
    //     if UploadIntoStream(UploadFileMsg, '', 'Zip files (*.zip)|*.zip', FileName, ZipInStream) then begin
    //         DataCompression.OpenZipArchive(ZipInStream, false);
    //         DataCompression.GetEntryList(EntryList);

    //         Window.Open('Traitement: #1##### sur #2#####\Fichier: #3##################');
    //         TotalCount := EntryList.Count();
    //         ImportedCount := 0;

    //         foreach EntryName in EntryList do begin
    //             ImportedCount += 1;
    //             Window.Update(1, ImportedCount);
    //             Window.Update(2, TotalCount);
    //             Window.Update(3, EntryName);

    //             if (StrPos(LowerCase(EntryName), '.jpg') > 0) or (StrPos(LowerCase(EntryName), '.png') > 0) then begin
    //                 // Determine ItemNo and PictureNo
    //                 SuffixPos := StrPos(EntryName, '_');
    //                 if SuffixPos > 0 then begin
    //                     ItemNo := CopyStr(EntryName, 1, SuffixPos - 1);
    //                     Evaluate(PictureNo, CopyStr(EntryName, SuffixPos + 1, StrPos(EntryName, '.') - SuffixPos - 1));
    //                 end else begin
    //                     ItemNo := CopyStr(EntryName, 1, StrPos(EntryName, '.') - 1);
    //                     PictureNo := 1;  // Start with PictureNo 1
    //                 end;

    //                 // Initialize IsFirstImage flag for each new item
    //                 if not ItemPictureGallery.Get(ItemNo, PictureNo) then
    //                     IsFirstImage := true;

    //                 // Check if an image with the same Item No. and Picture No. already exists
    //                 ItemPictureGallery.SetRange("Item No.", ItemNo);
    //                 ItemPictureGallery.SetRange("Item Picture No.", PictureNo);

    //                 while ItemPictureGallery.Get(ItemNo, PictureNo) do
    //                     PictureNo += 1; // Increment PictureNo to avoid duplication

    //                 // Import the image if the item exists
    //                 if Item.Get(ItemNo) then begin
    //                     TempBlob.CreateOutStream(ImageOutStream);
    //                     DataCompression.ExtractEntry(EntryName, ImageOutStream);
    //                     TempBlob.CreateInStream(ImageStream);

    //                     ItemPictureGallery.Init();
    //                     ItemPictureGallery."Item No." := ItemNo;

    //                     if IsFirstImage then begin
    //                         // First image, no suffix
    //                         ItemPictureGallery."Item Picture No." := 1;
    //                         ItemPictureGallery.Sequencing := 1;
    //                         IsFirstImage := false; // Set flag to False after first image is processed
    //                     end else begin
    //                         // Subsequent images, add suffix starting from 2
    //                         PictureNo := 2; // Start sequencing from 2
    //                         ItemPictureGallery."Item Picture No." := PictureNo;
    //                         ItemPictureGallery.Sequencing := PictureNo;
    //                         PictureNo += 1;
    //                     end;

    //                     ItemPictureGallery.Picture.ImportStream(ImageStream, EntryName);
    //                     if ItemPictureGallery.Insert() then
    //                         Message('Image importée pour l''article No: %1, Image No: %2', ItemNo, PictureNo)
    //                     else
    //                         Message('Échec de l''importation pour l''article No: %1, Image No: %2', ItemNo, PictureNo);
    //                 end else
    //                     Message('Article No. %1 non trouvé. Import d''image ignoré.', ItemNo);
    //             end;
    //         end;

    //         DataCompression.CloseZipArchive();
    //         Window.Close();
    //         Message('Importation des images terminée. %1 fichiers traités.', ImportedCount);
    //     end else
    //         Message('Aucun fichier sélectionné.');
    // end;

    /* 1.0.3.4 */
    // local procedure ImportMultiplePicturesForAllItemsFromZIP()
    // var
    //     ItemPictureGallery: Record "ItemPictureGallery";
    //     Item: Record Item;
    //     DataCompression: Codeunit "Data Compression";
    //     TempBlob: Codeunit "Temp Blob";
    //     ZipInStream: InStream;
    //     FileName: Text;
    //     UploadFileMsg: Label 'Veuillez sélectionner un fichier ZIP à importer';
    //     ImageStream: InStream;
    //     ImageOutStream: OutStream;
    //     EntryList: List of [Text];
    //     EntryName: Text;
    //     ItemNo: Code[20];
    //     PictureNo: Integer;
    //     Window: Dialog;
    //     ImportedCount: Integer;
    //     TotalCount: Integer;
    //     SuffixPos: Integer;
    //     IsFirstImage: Boolean;
    // begin
    //     if UploadIntoStream(UploadFileMsg, '', 'Zip files (*.zip)|*.zip', FileName, ZipInStream) then begin
    //         DataCompression.OpenZipArchive(ZipInStream, false);
    //         DataCompression.GetEntryList(EntryList);

    //         Window.Open('Traitement: #1##### sur #2#####\Fichier: #3##################');
    //         TotalCount := EntryList.Count();
    //         ImportedCount := 0;

    //         foreach EntryName in EntryList do begin
    //             ImportedCount += 1;
    //             Window.Update(1, ImportedCount);
    //             Window.Update(2, TotalCount);
    //             Window.Update(3, EntryName);

    //             if (StrPos(LowerCase(EntryName), '.jpg') > 0) or (StrPos(LowerCase(EntryName), '.png') > 0) then begin
    //                 // Determine ItemNo and PictureNo
    //                 SuffixPos := StrPos(EntryName, '_');
    //                 if SuffixPos > 0 then begin
    //                     ItemNo := CopyStr(EntryName, 1, SuffixPos - 1);
    //                     Evaluate(PictureNo, CopyStr(EntryName, SuffixPos + 1, StrPos(EntryName, '.') - SuffixPos - 1));
    //                 end else begin
    //                     ItemNo := CopyStr(EntryName, 1, StrPos(EntryName, '.') - 1);
    //                     PictureNo := 1;  // This is the first picture, no suffix needed
    //                 end;

    //                 // Initialize IsFirstImage flag for each new item
    //                 if not ItemPictureGallery.Get(ItemNo, 1) then
    //                     IsFirstImage := true;

    //                 // Import the image if the item exists
    //                 if Item.Get(ItemNo) then begin
    //                     TempBlob.CreateOutStream(ImageOutStream);
    //                     DataCompression.ExtractEntry(EntryName, ImageOutStream);
    //                     TempBlob.CreateInStream(ImageStream);

    //                     ItemPictureGallery.Init();
    //                     ItemPictureGallery."Item No." := ItemNo;

    //                     if IsFirstImage then begin
    //                         // First image, no suffix
    //                         ItemPictureGallery."Item Picture No." := 1; // Picture number remains 1
    //                         ItemPictureGallery.Sequencing := 1; 
    //                         IsFirstImage := false; // Set flag to False after first image is processed
    //                     end else begin
    //                         // Subsequent images, add suffix starting from 2
    //                         PictureNo := GetNextPictureNo(ItemNo); // Ensure unique PictureNo, starting from 2
    //                         ItemPictureGallery."Item Picture No." := PictureNo;
    //                         ItemPictureGallery.Sequencing := PictureNo;
    //                     end;

    //                     ItemPictureGallery.Picture.ImportStream(ImageStream, EntryName);
    //                     if ItemPictureGallery.Insert() then
    //                         Message('Image importée pour l''article No: %1, Image No: %2', ItemNo, PictureNo)
    //                     else
    //                         Message('Échec de l''importation pour l''article No: %1, Image No: %2', ItemNo, PictureNo);
    //                 end else
    //                     Message('Article No. %1 non trouvé. Import d''image ignoré.', ItemNo);
    //             end;
    //         end;

    //         DataCompression.CloseZipArchive();
    //         Window.Close();
    //         Message('Importation des images terminée. %1 fichiers traités.', ImportedCount);
    //     end else
    //         Message('Aucun fichier sélectionné.');
    // end;

    // local procedure ImportMultiplePicturesForAllItemsFromZIP()
    // var
    //     ItemPictureGallery: Record "ItemPictureGallery";
    //     Item: Record Item;
    //     DataCompression: Codeunit "Data Compression";
    //     TempBlob: Codeunit "Temp Blob";
    //     ZipInStream: InStream;
    //     FileName: Text;
    //     UploadFileMsg: Label 'Veuillez sélectionner un fichier ZIP à importer';
    //     ImageStream: InStream;
    //     ImageOutStream: OutStream;
    //     EntryList: List of [Text];
    //     EntryName: Text;
    //     ItemNo: Code[20];
    //     PictureNo: Integer;
    //     Window: Dialog;
    //     ImportedCount: Integer;
    //     TotalCount: Integer;
    // begin
    //     if UploadIntoStream(UploadFileMsg, '', 'Zip files (*.zip)|*.zip', FileName, ZipInStream) then begin
    //         DataCompression.OpenZipArchive(ZipInStream, false);
    //         DataCompression.GetEntryList(EntryList);

    //         Window.Open('Traitement: #1##### sur #2#####\Fichier: #3##################');
    //         TotalCount := EntryList.Count();
    //         ImportedCount := 0;

    //         foreach EntryName in EntryList do begin
    //             ImportedCount += 1;
    //             Window.Update(1, ImportedCount);
    //             Window.Update(2, TotalCount);
    //             Window.Update(3, EntryName);

    //             if (StrPos(LowerCase(EntryName), '.jpg') > 0) or (StrPos(LowerCase(EntryName), '.png') > 0) then begin
    //                 ItemNo := GetItemNoFromFileName(EntryName);
    //                 PictureNo := GetPictureNoFromFileName(EntryName);

    //                 if Item.Get(ItemNo) then begin
    //                     TempBlob.CreateOutStream(ImageOutStream);
    //                     DataCompression.ExtractEntry(EntryName, ImageOutStream);
    //                     TempBlob.CreateInStream(ImageStream);

    //                     ItemPictureGallery.Init();
    //                     ItemPictureGallery."Item No." := ItemNo;
    //                     ItemPictureGallery."Item Picture No." := PictureNo;
    //                     ItemPictureGallery.Sequencing := PictureNo;
    //                     ItemPictureGallery.Picture.ImportStream(ImageStream, EntryName);

    //                     if ItemPictureGallery.Insert() then
    //                         Message('Image importée pour l''article No: %1, Image No: %2', ItemNo, PictureNo)
    //                     else
    //                         Message('Échec de l''importation pour l''article No: %1, Image No: %2', ItemNo, PictureNo);
    //                 end else
    //                     Message('Article No. %1 non trouvé. Import d''image ignoré.', ItemNo);
    //             end;
    //         end;

    //         DataCompression.CloseZipArchive();
    //         Window.Close();
    //         Message('Importation des images terminée. %1 fichiers traités.', ImportedCount);
    //     end else
    //         Message('Aucun fichier sélectionné.');
    // end;

    // local procedure GetItemNoFromFileName(FileName: Text): Code[20]
    // var
    //     ItemNo: Code[20];
    //     UnderscorePos: Integer;
    //     DotPos: Integer;
    // begin
    //     UnderscorePos := StrPos(FileName, '_');
    //     DotPos := StrPos(FileName, '.');

    //     if UnderscorePos > 0 then
    //         ItemNo := CopyStr(FileName, 1, UnderscorePos - 1)
    //     else 
    //     if DotPos > 0 then
    //         ItemNo := CopyStr(FileName, 1, DotPos - 1)
    //     else
    //         ItemNo := FileName;

    //     exit(ItemNo);
    // end;

    // local procedure GetPictureNoFromFileName(FileName: Text): Integer
    // var
    //     UnderscorePos: Integer;
    //     DotPos: Integer;
    //     PictureNoText: Text;
    //     PictureNo: Integer;
    // begin
    //     UnderscorePos := StrPos(FileName, '_');
    //     DotPos := StrPos(FileName, '.');

    //     if UnderscorePos > 0 then begin
    //         PictureNoText := CopyStr(FileName, UnderscorePos + 1, DotPos - UnderscorePos - 1);
    //         if Evaluate(PictureNo, PictureNoText) then
    //             exit(PictureNo)
    //         else
    //             exit(1);  // If evaluation fails, assume it's the first picture
    //     end else
    //         exit(1);  // No underscore means it's the first picture
    // end;
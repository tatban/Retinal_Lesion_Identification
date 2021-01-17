function processImage(imgNameWithPath,outFolderPath,verbose)
    img = imread(imgNameWithPath);%original rgb image
    imwrite(img, strcat(outFolderPath,filesep,'1_ORIGINAL_RGB_IMG.jpg'));
    if verbose
        figure('Name','Original RGB Image');imshow(img);pause(3);close;
    end
    img_g = img(:,:,2);%extract green channel as it has more contrast
    img_g_adj = imadjust(img_g);%adjust contrast
    imwrite(img_g_adj,strcat(outFolderPath,filesep,'2_CONTRAST_ADJ_GREEN_CHANNEL_IMG.jpg'));
    if verbose
        figure('Name','Contrast Adjusted Green Channel Image');imshow(img_g_adj);pause(3);close;
    end
    T = adaptthresh(img_g_adj,'ForegroundPolarity','dark','Statistic','median');%calculating median based local threshold map
    adaptBW = imbinarize(img_g_adj,T);%adaptive binarization
    imwrite(adaptBW, strcat(outFolderPath,filesep,'6_AFTER_ADAPTIVE_BINARIZATION_OF_IMG_2.jpg'));
    if verbose
        figure('Name','After Adaptive Binarization of Green Channel');imshow(adaptBW);pause(3);close;
    end
    adaptBW2 = imcomplement(imfill(imcomplement(adaptBW),'holes'));%filling the noisy portions inside the lesion regions
    %%%figure;imshow(adaptBW2);
    adaptBW3 = medfilt2(adaptBW,[10,10]);%removing small dots like noisy regions
    %%%figure;imshow(adaptBW3);
    adaptBW4 = adaptBW2 | adaptBW3;%after median filtering and morphological operation
    %%%figure;imshow(adaptBW4);
    adaptBW5 = imerode(adaptBW4,strel('square',3));%smoothing the boundaries of the patches
    imwrite(adaptBW5,strcat(outFolderPath,filesep,'7_AFTER_MORPHOLOGICAL_OPERATIONS_ON_BINARIZED_IMG.jpg'));
    if verbose
        figure('Name','After morphological operations on binarized image');imshow(adaptBW5);pause(3);close;
    end
    adaptBW5a = imfill(adaptBW5,'holes');%complete disk region
    %%%figure;imshow(adaptBW5a);
    adaptBW5b = imcomplement(adaptBW5);
    %%%figure;imshow(adaptBW5b);
    adaptBW6 = adaptBW5a & adaptBW5b;
    imwrite(adaptBW6, strcat(outFolderPath,filesep,'8_INITIAL_MASK.jpg'));
    if verbose
        figure('Name','Intial Mask');imshow(adaptBW6);pause(3);close;
    end
    %use SURF features to detect blobs
    filterdImg = medfilt2(img_g_adj,[12,12]);
    imwrite(filterdImg,strcat(outFolderPath,filesep,'3_MEDIAN_FILTERED_GREEN_CHANNEL.jpg'));
    keyPoints=detectSURFFeatures(filterdImg,'NumOctaves',4,'NumScaleLevels',4,'MetricThreshold',500);%put metric threshold close to 500 to 600
    if(~verLessThan('matlab','9.4.0.813654'))
        figure('Name','SURF locations on median filtered Green Channel Image','WindowState','fullscreen');imshow(filterdImg);hold on; plot(keyPoints);
        export_fig(strcat(outFolderPath,filesep,'4_SURF_LOCATIONS_ON_FILTERED_IMAGE.jpg'));
        pause(1);close;
    else
        figure('Name','SURF locations on median filtered Green Channel Image');imshow(filterdImg);hold on; plot(keyPoints);
        export_fig(strcat(outFolderPath,filesep,'4_SURF_LOCATIONS_ON_FILTERED_IMAGE.jpg'));
        pause(1);close;
    end
    locations = round(keyPoints.Location);
    %keeping the surf locations contained by white regions of binaryImge
    keeperLocations = diag(adaptBW6(locations(:,2),locations(:,1))==1);
    confirmedLesions = find(keeperLocations);
    updatedLocations = locations(confirmedLesions,:);
    
    blobNumbers = zeros(1,length(updatedLocations(:,1)));
    labelledBinaryImage = bwlabel(adaptBW6);%labeling 
    significantBlobNumber = labelledBinaryImage(updatedLocations(1,2),updatedLocations(1,1));%this is the blob with strongest SURF centered in white patch in the binaryImage 
    for i =1: length(blobNumbers)
        blobNumbers(1,i) = labelledBinaryImage(updatedLocations(i,2),updatedLocations(i,1));
    end
    blobNumbers = unique(blobNumbers);%for the confirmed lesions
    confirmedLesionsBinImg = ismember(labelledBinaryImage,blobNumbers)>0;
    imwrite(confirmedLesionsBinImg,strcat(outFolderPath,filesep,'9_CONFIRMED_LESIONS.jpg'));
    if verbose
        figure('Name','Confirmed Lesion Regions (White Patches Which Corresponds to SURF locations)');imshow(confirmedLesionsBinImg);pause(3);close;
    end
    
    clusteredRgns = clusterRegion(labelledBinaryImage,2);%grouping the regions based on their morphological properties
    
    %find the cluster index that is associated with significant confirmed lesions regions
    clusterIndexOfSignificantBlob = clusteredRgns(significantBlobNumber);%used as index picker for other regions
    probableBlobs = find(clusteredRgns == clusterIndexOfSignificantBlob);%find the regions which are sturcturally similar to mostSignificantBlob location
    probableBlobsFromAmbiguiousBlobs = setdiff(probableBlobs,blobNumbers,'stable');%filtering the probable blobs from ambiguious blobs
    binImgProbableBlobsFromAmbiguiousBlobs = ismember(labelledBinaryImage,probableBlobsFromAmbiguiousBlobs)>0;
    imwrite(binImgProbableBlobsFromAmbiguiousBlobs,strcat(outFolderPath,filesep,'12_PROBABLE_LESIONS_NOT_DETECTED_BY_SURF.jpg'));
    if verbose
        figure('Name','Regions Structuraly Similar to Lesions but not corresponding to SURF points');imshow(binImgProbableBlobsFromAmbiguiousBlobs);pause(3);close;
    end
    finalMask = confirmedLesionsBinImg | binImgProbableBlobsFromAmbiguiousBlobs;
    imwrite(finalMask,strcat(outFolderPath,filesep,'14_FINAL_MASK.jpg'));
    if verbose
        figure('Name','Final Mask');imshow(finalMask);pause(3);close;
    end
    segmentedLesionsFromImage = img.*repmat(uint8(finalMask),[1,1,3]);
    imwrite(segmentedLesionsFromImage,strcat(outFolderPath,filesep,'SEGMENTED_LESIONS.jpg'));
    if verbose
       figure('Name','Segmented Lesions');imshow(segmentedLesionsFromImage);pause(3);close;
    end
        
    if(~verLessThan('matlab','9.4.0.813654'))
        figure('Name','Segmentation Result at a Glance','WindowState','FullScreen');
    else
        figure('Name','Segmentation Result at a Glance');
    end
    subplot(1,3,1);
    imshow(img);
    title('Original Image');
    subplot(1,3,2);
    s = regionprops(finalMask, 'Centroid'); 
    imshow(finalMask)
    hold on
    for lesionCount = 1:numel(s)
        c = s(lesionCount).Centroid;
        text(c(1), c(2), sprintf('%d', lesionCount), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle','Color','red','FontWeight','bold');
    end
    text(25,452,sprintf('Total Count: %d',lesionCount),'Color','green');
    hold off
    title('Segmentation Mask');
    subplot(1,3,3);
    imshow(segmentedLesionsFromImage);
    title('Segmented Regions from the original image');
    export_fig(strcat(outFolderPath,filesep,'SegmentationSummary.jpg'));
    pause(3);close;
    save(strcat(outFolderPath,filesep,'outputSnapshot.mat'));%saving a snapshot of all the variables used in processing current image
    clearvars;close all;
end
%==========================================================================
%  => This code is used to automatically segment out the lesions from retinal 
%     images. 
%
%  => This code can be used in two modes: 
%       i) Single Mode: One image at a time.
%      ii) Bulk Mode: Multiple images from a folder in a batch processing.
%     Enter the path including the file name to do a single processing. 
%     Exclude the filename in the path to do batch processing of all the 
%     images present in that folder.  
%
%  => The program should run perfectly fine on Matlab 2016a or later. To make
%     it work in lower versions(not tested below Matlab 2014b) keep the files
%     imbinarize.m and adaptthresh.m from the 'lowerVersion' folder to 'Main'
%     folder.
%
%  => While processing each image, the code creates a folder for each images
%     with image name and in that folder it saves all intermediate images and
%     necessarry output results for that particular image.
%
%  => To show the step wise figures while processing set 'verbose' flag to true.
%     Default is false. Setting verbose to true slows down the code.
%  -----------------------------------------------------------------------
%  Author: Tathagata Bandyopadhyay
%  Written on: June 3, 2018
%  Last Updated: June 18, 2018 (By Tathagata)
%  For any issue please contact Tathagata at gata.tatha14@gmail.com
%==========================================================================
function retinalLesionSegmentation(imPath,verbose)
    %default flag values
    if nargin < 1
        str ={'Select an Image File(To process a single Image)','Select a Folder(To process many image in bulk)'};
        s = listdlg('PromptString','Choose a selection mode:','SelectionMode','single','ListString',str);
        if s==1
            [file,folder] = uigetfile('*.jpg');
            imPath = strcat(folder,file);
        elseif s==2
            imPath = uigetdir; 
        end
        answer = questdlg({'Would you like to see intermediate iamges?','(this will slow down the process)'},'Verbose','Yes','No','No');
        switch answer
            case 'Yes'
                verbose = true;
            case 'No'
                verbose = false;                
            case ''
                verbose = false;                
        end
    elseif nargin < 2
        verbose = false;
    end
    %check whether the input path exists and whether it is a file or folder
    existVal = exist(imPath);
    if existVal == 0
        error('Path not found. Check the path proprly and make sure that matlab has access to it. If entering file path make sure to include file extention');
    elseif existVal == 2 %path is a file path
        %do single processing
        disp('Processing a single image. Please wait untill the success message comes');
        %get file name and path
        [filePath,fileName,~]=fileparts(imPath);
        %create a folder with image name for storing the intermediate output
        outFolderNm = strcat(filePath,filesep,'OUTPUT',filesep,fileName);
        mkdir(outFolderNm);
        processImage(imPath,outFolderNm,verbose);
    elseif existVal == 7 %path is a folder path
        %do batch processing
        disp('Processing images in bulk. Please wait untill the success message comes');
        filesList = dir(fullfile(imPath,'*.jpg'));%change here extension to process other type of image files
        numberOfFiles = length(filesList);
        for i = 1 : numberOfFiles
            [~,fileName,~]=fileparts(filesList(i).name);
            outFolderNm = strcat(imPath,filesep,'OUTPUT',filesep,fileName);
            mkdir(outFolderNm);
            processImage(strcat(imPath,filesep,filesList(i).name),outFolderNm,verbose);
        end
    end
    disp('<=*****Finished with Success*****=>');
end
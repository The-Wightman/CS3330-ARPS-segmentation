% generate_results is a void function called to generate visual outputs of
% the foreground detection algorithm precise_foreground

% The function creates a number of arrays and cells to store image files from local
% directories. Using regular expressions it takes a small subeste of the
% images, loads the array with strings and reads them into precise
% foreground, storing each result in a cell array of logical images. The
% groundtruths of the original images are then loaded, for comparison
% through the PSNR_calc function. Four 3 by 3 tile sets of the logical
% outputs are generated in figures 1-4 for subjective analysis. figure 5 is
% a bar chart for each image in the nine image sequence psnr versus the
% equivalent groundtruth for objective analysis.

function generate_results()
               
        Loaded_Images = strings(4,10);
        PSNR_Values = zeros(9,4);
        
        brd_Images = cell(1,11);
        hwy_Images = cell(1,11);
        IMB_Images = cell(1,11);
        SNL_Images = cell(1,11);
        
        img_names = dir('Coursework_Sequences_19_20/Board/input/in00000*.png');
        gt_names =  dir('Coursework_Sequences_19_20/Board/groundtruth/gt00000*.png');
        
        img_names = [img_names.name];
        gt_names = [gt_names.name];
        
        img_names = split(img_names,".png");
        gt_names = split(gt_names,".png");
        
        name_seq = 1:10;
                        
        Loaded_Images(1,name_seq) = string(strcat('./Coursework_Sequences_19_20/Board/input/', img_names(name_seq),".png"));
        Loaded_Images(2,name_seq) = string(strcat('./Coursework_Sequences_19_20/HighwayI/input/', img_names(name_seq),".png"));
        Loaded_Images(3,name_seq) = string(strcat('./Coursework_Sequences_19_20/IBMtest2/input/', img_names(name_seq),".png"));
        Loaded_Images(4,name_seq) = string(strcat('./Coursework_Sequences_19_20/Snellen/input/', img_names(name_seq),".png"));
        
               
       for index = 1 : 9
        brd_Images{index} = precise_foreground(imread(Loaded_Images(1,index)),imread(Loaded_Images(1,index+1)));
        hwy_Images{index} = precise_foreground(imread(Loaded_Images(2,index)),imread(Loaded_Images(2,index+1)));
        IMB_Images{index} = precise_foreground(imread(Loaded_Images(3,index)),imread(Loaded_Images(3,index+1)));
        SNL_Images{index} = precise_foreground(imread(Loaded_Images(4,index)),imread(Loaded_Images(4,index+1)));
       end
       
       Loaded_Images(1,name_seq) = string(strcat('./Coursework_Sequences_19_20/Board/groundtruth/', gt_names(name_seq),".png"));
       Loaded_Images(2,name_seq) = string(strcat('./Coursework_Sequences_19_20/HighwayI/groundtruth/', gt_names(name_seq),".png"));
       Loaded_Images(3,name_seq) = string(strcat('./Coursework_Sequences_19_20/IBMtest2/groundtruth/', gt_names(name_seq),".png"));
       Loaded_Images(4,name_seq) = string(strcat('./Coursework_Sequences_19_20/Snellen/groundtruth/', gt_names(name_seq),".png"));
       
       for index = 1 : 9
        PSNR_Values(index,1) = PSNR_calc(imread(Loaded_Images(1,index)),brd_Images{index});
        PSNR_Values(index,2) = PSNR_calc(imread(Loaded_Images(2,index)),hwy_Images{index});
        PSNR_Values(index,3) = PSNR_calc(imread(Loaded_Images(3,index)),IMB_Images{index});
        PSNR_Values(index,4) = PSNR_calc(imread(Loaded_Images(4,index)),SNL_Images{index});       
       end
       
       board = imtile(brd_Images ,'gridsize' , [1 9]);
       highway = imtile(hwy_Images ,'gridsize',[1 9]);
       IMB = imtile(IMB_Images ,'gridsize',[1 9]);
       Snell = imtile(SNL_Images ,'gridsize',[1 9]);
       
       figure, imshow(board);
       figure, imshow(highway);
       figure, imshow(IMB);
       figure, imshow(Snell);
       figure, bar(PSNR_Values);       
       title('PSNR values of Ground truth versus result');
       legend('Board','Highway','IBM','Snell');

end

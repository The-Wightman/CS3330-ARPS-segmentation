% vector_image is function which takes motion vectors found by ARPS and
% creates a logical image representing all detected motion.

% The function takes the image and creates a vector of its dimensions to
% use as limits for the internal loop. This loop retrieves the values from
% the vectors array to define a possible range of values. This range is
% then used to write all values on the passed image (Image_cur) on to a new
% image, providing only elements of the image detected by the motion
% estimation. Finally the new image is filtered for noise through
% morphological operations and reconstructed before being passed back as
% Vector_recon.
%
% Inputs Vectors = array of motion vectors, Image_cur = the image from
% motion estimation was called on, MB_size = macro block size
% Output = Vector_recon = Image_cur filtered for only areas with motion

function Vector_recon = vector_image(Vectors,Image_cur,MB_size) 

[row,col] = size(Image_cur);
MB_count = 1;

%for each macro block sized chunk in the horizontal plane, check every
%macro block sized chunk in the vertical plane.
for row_inc = 1:MB_size:row-MB_size+1
    for col_inc = 1:MB_size:col-MB_size+1
        %Assign the vertical and horizontal reference values        
        dy = Vectors(1,MB_count);
        dx = Vectors(2,MB_count);
        %define the maximum values on the vertical and horizontal axis
        vert_Block = row_inc + dy;
        horz_Block = col_inc + dx;
        %Take all pixels within the reference values and the maximum value
        %from the current image and assign them to the to a new image containing
        %only motion vector pixels   
        imageComp(row_inc:row_inc+MB_size-1,col_inc:col_inc+MB_size-1) = Image_cur(vert_Block:vert_Block+MB_size-1, horz_Block:horz_Block+MB_size-1);
        
        MB_count = MB_count + 1;
    end
end
    %define a structuring element in the shape of the diamond 11 pixels in
    %radius
   SE = strel('diamond',11);
   %dilate the reconstructed image using the structure element
   Img_Dil = imdilate(imageComp,SE);
   %erode the dilated image using the structure element
   Image_Ero = imerode(Img_Dil,SE);
   %return the reconstruction of the eroded image and the block limited
   %image
   Vector_recon = imreconstruct(Image_Ero,imageComp);
     
end
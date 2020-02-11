%Precise_foreground performs precise foreground estimation through minima,
%maxima and Block-based motion estimation.
%
% The function takes two images of the current image frame and the previous
% frame. Both are converted to grayscale then passed to the block-based
% motion estimation.The result of which is used to create a motion vector
% filtered image. The minima and maxima functions are passed the current
% frame and then the results of both are logically OR'ed then added to the
% vector result. The image is then thresholded to remove excess background
% information and noise. finally, a set of morphological operations are
% performed to further reduce the noise in the image before returning the
% the final_img as a result.
%
% Input Image1 = The previous frame of the sequence, Image2 = The current
% frame in the sequence
% Output final_img = A logical image showing detected foreground elements

function final_img = precise_foreground(Image1,Image2) 
    %Convert the passed images to greyscale
    Image1 = rgb2gray(Image1);
    Image2 = rgb2gray(Image2);
    
    %Take the images and values for macro block and pattern size and call
    %the motion estimation algorithm.
    Motion_result = Motion_Estimation(Image1,Image2,2,2);
    %Take the vector array provided by motion estimation and reconstruct it
    %into an image
    Morph_result = vector_image(Motion_result,Image2,2);
    
    %Retreive the maxima and minima logical maps of the current image
    Max_result = Maxima(Image2);
    Min_result = Minima(Image2);
    
    % logically and the output of the or of minima and maxima with the
    % reconstructed image.
    Foreground = uint8(Morph_result) + uint8(Max_result | Min_result);
    
    %Threshold the foreground at a value of 85
    Foreground = Threshold(Foreground,85);
    
    %Convert the image matrix to a logical matrix and then perform bridging
    %cleaning and filling with the bridge and the clean occuring untill
    %changes stop, fill occurs five times.
    Foreground = logical(Foreground);    
    Foreground = bwmorph(Foreground,'bridge',inf);
    Foreground = bwmorph(Foreground,'clean',inf);  
    Foreground = bwmorph(Foreground,'fill',5);
    
    %complement the result to invert the colours
    Foreground = imcomplement(Foreground);
    
    %return the result
    final_img = Foreground;
    
    end
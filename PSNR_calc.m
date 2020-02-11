%PSNR_calc calculates MSE and then uses this value to calulate a PSNR value
%defined as the peak signal to noise ratio
%
% The input arguments are converted to double arrays, subtracted from one
% another and the difference is squared. The sum of this id divided by the
% total number of pixels to provide an MSE value. Finally thr square of
% number of possible values over MSE is logarithmically ultiplied to create
% a final value
%
% Input Img1,Img = two image arrays to be compared against each other
% Output PSNR_val = signal to noise ratio of the two images.
function PSNR_val = PSNR_calc(Img1,Img2)
    Img_diff = (double(Img1)-double(Img2)).^2;    
    Img_diff_sum = sum(Img_diff, 'all');
    
    [width,height] = size(Img1);
    Pixels = width * height;
    
    MSE = Img_diff_sum/Pixels;
    PSNR_val = 10. * log10(255*255/MSE);
end
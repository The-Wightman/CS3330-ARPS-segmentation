% The threshold function takes a value then searches a matrix modifying the
% existing pixel value based on the provided one
%
% Inputs img = image to threshold , t= pixel value with which all values
% below are removed
% Outputs img = thresholded image where all values are either 0 or 255.

function img = Threshold( img,t )
    img(img < t) = 0;
    img(img >= t) = 255;
end

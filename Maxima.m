function maxima = Maxima(Image)
%MAXIMA Summary of this function goes here
%  This function defines a structure element, then performs morphological
%  operations of opening and closing, the result is then dilated,then pre
%  and post dilation are complemented and reconstructed.finally this result
%  is complemented and thresholded via regionalmax to create an output of 
%  the regional maxima.
% Inputs : Image = Current Image frame
% Outputs : Maxima = black and white image mapping regional maxima
   
    SE = strel('diamond',5);
      
    Img_open = imopen(Image,SE);
    Img_close = imclose(Img_open,SE);
    
    Img_reconOC = imreconstruct(Img_open,Img_close);

    Img_reconD = imdilate(Img_reconOC,SE);
    
    Img_compD = imcomplement(Img_reconD);
    Img_compReconOC = imcomplement(Img_reconOC);
    
    Img_reconComps = imreconstruct(Img_compD,Img_compReconOC);
    Img_maximaFormat = imcomplement(Img_reconComps);
    
    maxima = imregionalmax(Img_maximaFormat);
    
 
    
 end


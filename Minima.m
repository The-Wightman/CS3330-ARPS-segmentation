function minima = Minima(Image)
%MINIMA Provides a black and white image showing the regional minima of the
%foreground
%   The function takes an image, erodes it and then reconstructs it with
%   the orginal, Dilating and then complementing the result. The predilate
%   version is then complemented and the two complements are reconstructed.
%   finally a complement of this is taken, a minimum value is found and the
%   image is thresholded to provide only the regional minima.
% Inputs : Image = Current Image frame
% Outputs : minima = black and white logical image mapping regional minima


    SE = strel('diamond',5);
        
    Image_E = imerode(Image,SE);
    Image_obr = imreconstruct(Image_E,Image);
    
    Image_obrd = imdilate(Image_obr,SE);
    
    Image_obrdc = imcomplement(Image_obrd);
    Image_obrc = imcomplement(Image_obr);
    
    Image_recon = imreconstruct(Image_obrdc,Image_obrc);
    
    Image_reconc = imcomplement(Image_recon);
    
    minima = imregionalmin(Image_reconc);
    

end


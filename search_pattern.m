%search_pattern defines diamond based search patterns used to find motion
%vectors.
%Create a new search pattern depending on search style
%Check the size of desired, values of zero are used to automatically define
%a Small diamond (lowest acceptable value) anything large is used to create
%a scaled Large diamond.
%Input = Step size between two center points of a search
%Output = Matrix of diamonds point positions
function New_diamond = search_pattern(stp_size)
   if (stp_size == 0)
       radius = 1;
   else
       radius = stp_size;
   end
        New_diamond(1,:) = [ 0 -radius];
        New_diamond(2,:) = [-radius 0]; 
        New_diamond(3,:) = [ 0  0];
        New_diamond(4,:) = [radius  0];
        New_diamond(5,:) = [ 0  radius];
   end
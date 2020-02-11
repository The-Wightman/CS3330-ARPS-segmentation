%MAD provides the mean absolute difference between the two regions
%When given two blocks calculate  the mean absolute difference, 
%Inputs Select_Block = defines the current block for which we want the mean
%absolute difference, Prev_Block = The block referenced by the current block
% mb_Size = size value of macro search blocks
%Output Minimum = The mean absolute difference of the two blocks

function Minimum = MAD(Select_Block,Prev_Block,mb_Size)
err_sum = 0;
%for each row in the defined block, take every value in the column.
for row_inc = 1:mb_Size
    for col_inc = 1:mb_Size 
        %assign the value in err sum as the previous value combined with
        %the absolute sum of current block at the given index, minus the
        %previous block at the same index.
        err_sum = err_sum + abs((Select_Block(row_inc,col_inc) - Prev_Block(row_inc,col_inc)));
    end
end
%Divide the total sum by the square of the size of the block.
Minimum = err_sum / (mb_Size^2);
end

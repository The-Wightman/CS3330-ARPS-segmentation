%Motion_Estimation provides an array of motion vectors which can be
%reconstructed to represent areas of an image in which motion was detected
%between two frames.
%
%The motion estimation system works using the advanced rood pattern search
%via recursive Large diamond and small diamond search patterns. For each
%macro block size chunk in each column on every row, we calculate a MAD
%value and then mark it as checked , we define the max index to set which
%local values we will check using LDSP. For the LDSP we check the
%surrounding blocks, disregarding those that would cause an exception. For
%each of the check the MAD value against the current block and then update
%the cost matrix. the lowest block detected here will then have the SDSP
%fixed pattern run on it to find the absolute minimum MAD value.The
%direction between out initial macroblock point and the minimum SDSP value
%is the direction of motion and is stored as a vector in the vector array.

%Inputs Img_Prev = the previous frame, Img_cur = current frame, mac_Blk_size =
%size value of macro search blocks ,pat_size = the search area defined in
%pixels within which values are checked 
%Outputs motionVect = the matrix of vectors for each detected block in
%Img_Cur


function motion_Vect = Motion_Estimation(img_Prev, img_Cur, mac_Blk_Size, pat_Size)


[row,col] = size(img_Cur);

%pre allocate matrix of zeros , 2 rows with a column for each macroblock
vectors = zeros(2,row*col/mac_Blk_Size^2);
% pre allocate logical matrix of zeros for when areas are costed using MAD
is_Checked = zeros(2*pat_Size+1,2*pat_Size+1);

costs = ones(1,6) * 50000;
mb_Count = 1;

%For each macroblock size chunk in the row, in each macro block size chunk
%of each column
for row_inc = 1 : mac_Blk_Size : row-mac_Blk_Size+1
    for col_inc = 1 : mac_Blk_Size : col-mac_Blk_Size+1
        
        %Define an area on the previous image the size of the macroblock and load its values  
        prev_mad = img_Prev(row_inc:row_inc+mac_Blk_Size-1,col_inc:col_inc+mac_Blk_Size-1);
        %Define an area on the current image the size of the macroblock and load its values
        cur_mad = img_Cur(row_inc:row_inc+mac_Blk_Size-1,col_inc:col_inc+mac_Blk_Size-1);
        %Calculate the mean absolute difference and store its value in costs.
        costs(3) = MAD(prev_mad,cur_mad,mac_Blk_Size);
        
        % set the representative block in is checked to 1 , marking it
        % checked
        is_Checked(pat_Size+1,pat_Size+1) = 1;
        
        %Check if a column exists to the left, if not, we must avoid
        %checking to our left as it does not exist.
        if (col_inc-1 < 1)
            stp_Size = 2;
            max_Index = 5;
        else 
            
            vector_1 = vectors(1,mb_Count-1);
            vector_2 = vectors(2,mb_Count-1);
            
            stp_Size = max(abs(vector_1), abs(vector_2));
           %check if the current point is going to be checked during the Large diamond search, if it is , avoid it. 
           if ( (abs(vector_1) == stp_Size && vector_2 == 0)|| (abs(vector_2) == stp_Size && vector_1 == 0)) 
                max_Index = 5;                
            else
                max_Index = 6;                
            end
        end
        %Call search pattern and define a new diamond search pattern
        LDSP = search_pattern(stp_Size);
        
        %if the index is six we now add in the 6th element to the created
        %search pattern.
        if (max_Index == 6)
            LDSP(6,:) = [ vector_2 vector_1];
        end
         
          ref_row = row_inc;
          ref_col = col_inc;
        
        %for the current value of the index reference, untill the newly
        %defined maximum index
        for cur_Index = 1:max_Index
            %find the co ordinates of the reference block and assign them
            r_Blk_Vert = ref_row + LDSP(cur_Index,2);   
            r_Blk_Horz = ref_col + LDSP(cur_Index,1);
            %check if this is the centre point ,we calculated this earlier.
            if (cur_Index == 3 || stp_Size == 0)
                continue; 
            end
            %check the co-orindates against the maximum boundaries do not
            %process if they exceed any of the possible ranges
            if ( r_Blk_Vert < 1 || r_Blk_Vert+mac_Blk_Size-1 > row || r_Blk_Horz < 1 || r_Blk_Horz+mac_Blk_Size-1 > col)             
                continue;
            end
            %Define an area on the previous image the size of the macroblock and load its values  
            prev_mad = img_Prev(row_inc:row_inc+mac_Blk_Size-1,col_inc:col_inc+mac_Blk_Size-1);
            %Define an area on the current image the size of the macroblock and load its values
            cur_mad = img_Cur(r_Blk_Vert:r_Blk_Vert+mac_Blk_Size-1, r_Blk_Horz:r_Blk_Horz+mac_Blk_Size-1);
            %Calculate the mean absolute difference and store its value in costs.
            costs(cur_Index) = MAD( prev_mad,cur_mad,mac_Blk_Size);
            % set the representative block in is checked to 1 , marking it
            % checked
            is_Checked(LDSP(cur_Index,2) + pat_Size+1, LDSP(cur_Index,1) + pat_Size+1) = 1;
        end
        
        %Call the small diamond search pattern function to search the area
        %again
        calc_SDSP(ref_col,ref_row,costs,is_Checked,LDSP,mac_Blk_Size);
        
        %define the new co ordinates for our vector in the vector matrix
        vectors(1,mb_Count) = ref_row - row_inc;    
        vectors(2,mb_Count) = ref_col - col_inc;
        
        %increase the count and reset the costs vector
        mb_Count = mb_Count + 1;
        costs = ones(1,6) * 50000;
        
        %reset the is checked matrix for the next iteration
        is_Checked = zeros(2*pat_Size+1,2*pat_Size+1);
    end
end
    
motion_Vect = vectors;

% The SDSP function is used to perform the small diamonds part of the ARPS
% within a defined area using a fixed size diamond pattern. 
%The search pattern is defined by calling the search_pattern with a value
%of zero for default, we check to see if the designated search area is
%within acceptable bounds (not outside image border, is previously checked
%, is the centre, or outside the block we are searching. We then for each
%block calculate the Mean absolute difference and store the value to find
%the minimum. this function does not return due to being nested and
%automatically updates variables in the main function.
%
%Inputs Ref_col = value from col index ,ref_row = value from row index ,
%is_Checked = is_checked matrix , LDSP = large diamonds search pattern,
%mac_Blk_Size = macro block size value.

function calc_SDSP(ref_col,ref_row,costs,is_Checked,LDSP,mac_Blk_Size)
        % Take the current minimum value in costs
        [cost, point] = min(costs);
        %call search pattern to define the smallest (deafult) size search pattern.        
        SDSP = search_pattern(0);
        %set up reference indexes for the area SDSP will be working using
        %the values from the LDSP
        ref_col = ref_col + LDSP(point, 1);
        ref_row = ref_row + LDSP(point, 2);
        % reset the costs matrix
        costs = ones(1,5) * 50000;
        costs(3) = cost;
       % set a finish value equal to zero and define a loop to continue
       % while it holds this value.
        finish = 0;   
        while (finish == 0)
            % for each values 1 through 5
            for SDSP_Index = 1:5
                %set the new reference row and column equal to the orginal
                %reference added with the values in the search pattern to
                %define co ordinates.
                r_Blck_Vert = ref_row + SDSP(SDSP_Index,2);  
                r_Blck_Horz = ref_col + SDSP(SDSP_Index,1);
                %check the co-orindates against the maximum boundaries do not
                %process if they exceed any of the possible ranges
                if ( r_Blck_Vert < 1 || r_Blck_Vert+mac_Blk_Size-1 > row || r_Blck_Horz < 1 || r_Blck_Horz+mac_Blk_Size-1 > col)
                      continue;
                end
                %If the index is three dont check as this value was already
                %handled by LDSP
                if (SDSP_Index == 3)
                    continue
                %check the co-ordinates against the boundaries of the
                %SDSP,do not process if they exceed the sdsp bvoundaries.
                elseif (r_Blck_Horz < col_inc-pat_Size || r_Blck_Horz > col_inc+pat_Size || r_Blck_Vert < row_inc-pat_Size || r_Blck_Vert > row_inc+pat_Size)
                    continue;
                % if the value of the current location is ischecked is
                % already set to 1 do not check for it already has been
                elseif (is_Checked(ref_row-row_inc+SDSP(SDSP_Index,2)+pat_Size+1 , ref_col-col_inc+SDSP(SDSP_Index,1)+pat_Size+1) == 1)
                    continue
                end
                %Define an area on the previous image the size of the macroblock and load its values
                prev_mad = img_Prev(row_inc:row_inc+mac_Blk_Size-1,col_inc:col_inc+mac_Blk_Size-1);
                %Define an area on the current image the size of the macroblock and load its values
                cur_mad = img_Cur(r_Blck_Vert:r_Blck_Vert+mac_Blk_Size-1,r_Blck_Horz:r_Blck_Horz+mac_Blk_Size-1);
                %Calculate the mean absolute difference and store its value in costs.
                costs(SDSP_Index) = MAD(prev_mad,cur_mad,mac_Blk_Size);
                % set the representative block in is checked to 1 , marking it
                % checked
                is_Checked(ref_row-row_inc+SDSP(SDSP_Index,2)+pat_Size+1, ref_col-col_inc+SDSP(SDSP_Index,1)+pat_Size+1) = 1;
                               
            end
            
            [cost,point] = min(costs);
            
            if (point == 3)
                finish = 1;
            else
                ref_col = ref_col + SDSP(point, 1);
                ref_row = ref_row + SDSP(point, 2);
                
                costs = ones(1,5) * 50000;
                costs(3) = cost;
            end            
        end
end

end



        

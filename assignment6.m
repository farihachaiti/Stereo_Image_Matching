function mainfunction
  
  clc
  
  
  #Reading Images
  printf("Reading Images\n")
  
  A = imread("left.png");
  B = imread("right.png");
  
  #Converting gray value intensities to float values
  printf("Converting gray value intensities to float values\n")
  
  I1 = double(A);
  I2 = double(B);
  
  #Calculating mean values
  printf("Calculating mean values\n")

 [A_mean,B_mean] = getMean(I1,I2)
 
   #Measuring Similarity
  printf("Measuring Similarity \n")
 
  [rows,columns] = size(I1)
  [rows,columns] = size(I2) 
  
  disparity = measure_similarity(5,I1,I2,A_mean,B_mean,rows,columns);
 
  # Generating Disparity Map
 printf("Generating Disparity Map \n")
 
 I = cell2mat(disparity);
 figure;
 imshow(I)
  
endfunction



 function disparity = measure_similarity(n,I1,I2,A_mean,B_mean,rows,columns)
   
  r = 2
  ncc = zeros(n*columns);
  disparity = {};
  reference = {};
  search = {};
  iterator = 1;
  lrow = round(rows/2);
  urow = lrow + n;
  for i = 1:rows
   for j = 1:columns
     lower_row = i-r;
     upper_row = i+r;
     lower_col = j-r;
     upper_col = j+r;
     condition = lower_row>=1 && lower_col>=1 && upper_row<=rows && upper_col<=columns;
     counter = 1;
     while(condition)
        reference_window = I1((lower_row : upper_row), (lower_col : upper_col));     
        search_window = I2((lower_row : upper_row), (lower_col : upper_col));
        reference{iterator} = reference_window;
        search{counter} = search_window;
        ncc(counter) = normalized_cross_correlation(reference_window,search_window,A_mean,B_mean,n);
        lower_row = lower_row + 1;
        upper_row = upper_row + 1;
        lower_col = lower_col + 1;
        upper_col = upper_col + 1;
        if (lower_row<1 || lower_col<1 || upper_row>rows || upper_col>columns)
          break
        else
          counter = counter + 1;
          continue
        endif
     endwhile
     if(iterator<columns-1)
      disparity{i,j} = disparity_map(reference,search,n,iterator,counter,ncc);
     endif
     iterator = iterator + 1;
   endfor
 endfor
 

endfunction


function disparity = disparity_map(reference,search,n,iterator,counter,ncc)
  max = ncc(1);
  disparity = zeros(n,n);
 if(any(counter))
   for k = 1:counter
     if(ncc(k)>max)
      max = ncc(k);
      final_counter = k;
     else
      max = ncc(1);
      final_counter = 1;
     endif
   endfor
 endif
  if (any(max) && any(final_counter))
    disparity = search{final_counter} - reference{iterator};
  endif
endfunction


function [A_mean,B_mean] = getMean(I1,I2)
  pkg load image
  A_mean = mean2(I1)
  B_mean = mean2(I2)
  
endfunction


function ncc = normalized_cross_correlation(A,B,A_mean,B_mean,n)
  sum = 0;
  sum1 = 0;
  sum2 = 0;
  for i = 1:n
    for j = 1:n
      sum = sum + A(i,j)*B(i,j);
      sum1 = sum1 + (A(i,j))^2;
      sum2 = sum2 + (B(i,j))^2;
    endfor
  endfor
  covariance = sum/n^2 - A_mean*B_mean;
  variance_A = sum1/n^2 - A_mean^2;
  variance_B = sum2/n^2 - B_mean^2;
  
  ncc = covariance/sqrt(variance_A*variance_B);
 
endfunction


function filterbin_txt(filt)
  format longg;
  switch(filt)
    case {2}
    filter_name = sprintf("second_filter.txt");
    A = importdata(filter_name, ',');
    for n=1:32
        for i=(1+(32*(n-1))):(n*32)
          for j=1:5
            C(i-(32*(n-1)),:,j) = float2bin(8,18,A(i,j));
            j++;
          endfor
          i++;
        endfor
     i=1;
     j=1;
     filename = sprintf("tested%d.txt", n);
     fid = fopen(filename, 'w');
     for i=1:32
      fprintf(fid,"(");
      for j=1:5
       if(j == 5)
        fprintf(fid, "\"%s\"", C(i,:,j));
       else
        fprintf(fid, "\"%s\",", C(i,:,j));
       endif 
       j++;
      endfor
      fprintf(fid,"),");
      i++;
     endfor
     fclose(fid);
    endfor 
    
    case {3}
    filter_name = sprintf("third_filter.txt");
    A = importdata(filter_name, ',');
    for n=1:32
        for i=(1+(32*(n-1))):(n*32)
          for j=1:3
            C(i-(32*(n-1)),:,j) = float2bin(8,18,A(i,j));
            j++;
          endfor
          i++;
        endfor
     i=1;
     j=1; 
     filename = sprintf("third_filter%dbin.txt", n);
     fid = fopen(filename, 'w');
     for i=1:32
      fprintf(fid,"(");
      for j=1:3
       if(j == 3)
        fprintf(fid, "\"%s\"", C(i,:,j));
       else
        fprintf(fid, "\"%s\",", C(i,:,j));
       endif        
       j++;
      endfor
      fprintf(fid,"),");
      i++;
     endfor
     fclose(fid);
    endfor 
    
    case {4}
    filter_name = sprintf("fourth_filter.txt");
    A = importdata(filter_name, ',');
    for n=1:32
        for i=(1+(32*(n-1))):(n*32)          
          C(i-(32*(n-1)),:) = float2bin(8,18,A(i,1));   
          i++;
        endfor
     i=1;  
     filename = sprintf("fourth_filter%dbin.txt", n);
     fid = fopen(filename, 'w');
     for i=1:32
       fprintf(fid,"(\"%s\"),", C(i,:));  
       i++;
     endfor
     fclose(fid);
    endfor 
  endswitch
endfunction
  
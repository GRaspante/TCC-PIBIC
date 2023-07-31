function biasbin_txt(bias) 
   bias = 4;
   format longg;  
  switch(bias)
    case {2}
    bias_name = sprintf("secondConvBias.txt");
    case {3}
    bias_name = sprintf("thirdConvBias.txt");
    case {4}
    bias_name = sprintf("fourthConvBias.txt");
  endswitch
  
  A = importdata(bias_name, ',');

  for i=1:32
    C(i,:) = float2bin(8,18,A(1,i));
    i++;
  endfor
i=1;
  switch(bias)
    case {2}
      filename = "secondConvBias_bin.txt";      
      fid = fopen(filename, 'w');
        for i=1:32
          fprintf(fid,"\"%s\",", C(i,:));
          i++;
        endfor
      fclose(fid);
    case {3}
      filename = "thirdConvBias_bin.txt";
      fid = fopen(filename, 'w');
        for i=1:32
            fprintf(fid,"\"%s\",", C(i,:));
            i++;
        endfor
        fclose(fid);
    case {4}
      filename = "fourthConvBias_bin.txt";
      fid = fopen(filename, 'w');    
        for i=1:32
            fprintf(fid,"\"%s\",", C(i,:));
            i++;
        endfor
      fclose(fid);
  endswitch  
  
endfunction
  
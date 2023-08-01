function out_bintxt(convo)  
   format longg;    
  switch(convo)
    case {2}
    conv_name = sprintf("secondConv_out.txt");
    case {3}
    conv_name = sprintf("thirdConv_out.txt");
    case {4}
    conv_name = sprintf("fourthConv_out.txt");
  endswitch
  
  A = importdata(conv_name, ',');

  for i=1:32
    for j=1:30
      B(i,j) = A(1,(i*j));
      j++;
    endfor
    i++;
  endfor
i=1;
j=1;
  for i=1:32
    for j=1:30
      C(i,:,j) = float2bin(8,18,B(i,j));
      j++;
    endfor
    i++;
  endfor
  
  switch(convo)
    case {2}
      filename = "secondConv_outbin.txt";      
      fid = fopen(filename, 'w');
        for i=1:32
          fprintf(fid,"(");
          for j=1:30
           if(j == 30)
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
    case {3}
      filename = "thirdConv_outbin.txt";
      fid = fopen(filename, 'w');
        for i=1:32
          fprintf(fid,"(");
          for j=1:30
           if(j == 30)
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
    case {4}
      filename = "fourthConv_outbin.txt";
      fid = fopen(filename, 'w');
        for i=1:32
          fprintf(fid,"(");
          for j=1:30
           if(j == 30)
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
  endswitch  
  
endfunction
  
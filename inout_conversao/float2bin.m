% Author: Daniel Mauricio Munoz Arboleda
% Institution: GRACO - UnB
% Date: 09 fev 2009

% This function receives a floating-point number
% and converts it to a binary floating-point representation
% using the IEEE-754-1985 standard.
% EW: number of bits of exponent word
% FW: number of bits of mantissa word

function [out] = float2bin(EW,FW,A)
  EW = 8;
  FW = 18;
  
bias = ((2^EW)/2)-1;
n_exp = 0;

% Takes signal and represents the signal bit
if A >= 0
    s = '0';
else    
    s = '1';
end    
 
% Takes the integer part and converts to binary
x=floor(abs(A));
x1=dec2bin(x);

% Takes the fractional part and converts to binary
B=abs(A)-x;
for i=1:1:8*FW
    B = B*2;
    if B >= 1
        M(i) = '1';
        B = B-1;
    else
        M(i) = '0';
    end    
end

% Counts the number of bits for the exponent word
if A == 0
    n_exp = -bias;
    Mn = zeros(1,FW+EW+1);
elseif x1(1) == '1'
    n_exp = length(x1)-1;
else
    for i=1:1:5*FW
        if M(i)== '0'
            n_exp = n_exp - 1;
        else
            n_exp=n_exp-1;
            break;
        end    
    end
    Mn=M(i+1:5*FW);
end

% Adds bias to exponent and converts to binary
n_exp = n_exp + bias;
exp = dec2bin(n_exp);
nz=length(exp);
for i=1:1:EW
    if nz < EW
        exp = ['0',exp];
        nz=length(exp);
    end    
end    

% Contatenates s|exp|x1(2:length)M
k=length(x1);
if abs(A) >= 1 
    x2=x1(2:k);
    h=[s,exp,x2,M];
else
    h=[s,exp,Mn];
end    

out =h(1:FW+EW+1);
printf("%c", out);
% for i=1:1:FW+EW+1
%     if Y(i) == '1';
%         out(i) = 1;
%     else
%         out(i) = 0;
%     end    
% end




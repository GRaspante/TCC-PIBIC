% Authors: Diego Felipe Sanchez and Daniel Mauricio Munoz Arboleda
% Institution: GRACO - UnB
% Date: 01 oct 2008

% This function receives a binary floating-point number
% and converts it to its decimal representation
% using the IEEE-754-1985 standard.
% EW: number of bits of exponent word
% FW: number of bits of mantissa word

function [f] = bin2float(EW,FW,num)

bias = ((2^EW)/2)-1;

A = num;
% A= '001111111100000000000000000'; % template 27bits
% A= '01000001100000111100100100001010'; % template 32bits

% Separates signal, exponent and mantissa words
S = A(1);
E = A(2:EW+1);
M = A(EW+2:FW+EW+1);

% initialize counters
e = 0;
m = 0;

% Takes signal and represents the signal bit
if S == '0'
    s = 1;
else    
    s = -1;
end 

% Computes the exponent
for i = 1:1:EW
    if E(i) == '1'
        e = e + 2^(EW-i);
    end
end 

% Subtract bias to the exponent
e = e - bias;

% Computes the mantissa
for i = 1:1:FW
    if M(i) == '1'
      m = m + 2^(-i);
    end
end

% represents the floating-point number
format long g;
f = s*(1 + m)*2^(e);

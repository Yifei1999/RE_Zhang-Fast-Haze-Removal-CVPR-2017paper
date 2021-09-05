function min_value = MIN_MatrixValue(a,b,c)
% this function gives the min value of input matrix at corresponding
% position
% 
% inputs:
% matrix a,b,c

min_value = min(a,b);
min_value = min(min_value,c);
end
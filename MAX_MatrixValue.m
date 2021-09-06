function max_value = MAX_MatrixValue(a,b,c)
% this function gives the max value of input matrix at corresponding
% position
% 
%     -inputs:
%     -matrix a,b,c

max_value = max(a,b);
max_value = max(max_value,c);
end
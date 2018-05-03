function [Z, min_Z, max_Z] = normalize_cleanIm(Z, min_Z, max_Z)

if nargin == 1
    min_Z = min(min(Z));
    max_Z = max(max(Z));
end

Z = (Z - min_Z)/(max_Z - min_Z);

end
%----------------------------------------------------------------
% Depth Map Super-Resolution by Deep Multi-Scale Guidance, ECCV16
%                     written by T.-W. HUI
%----------------------------------------------------------------
function Z = normalizeIm(Z, range)

if nargin < 2
    range = [0.01 1];
end

validMap = Z > 0;
Z = Z - min(Z(validMap));
Z = Z/max(Z(validMap));
Z(~validMap) = 0;
Z(validMap) = Z(validMap) + range(1);
Z = range(2)*Z/max(max(Z));

end
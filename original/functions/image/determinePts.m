function [p, dist] = determinePts(type, pts, pxtol, TF)
%determinePts Calls functions that order the points based on a specific
%pattern. This funciton is just a holder instead of creating a large
%amount of switch statements in the main code.
switch upper(type)
    case 'KCP'
        [p, dist] = determineKCPpts(pts, pxtol, TF);
    case 'CROSS'
        [p, dist] = determineCROSSpts(pts, pxtol, TF);
    case 'KTH02'
        [p, dist] = determineKTH02pts(pts, pxtol, TF);
end
end


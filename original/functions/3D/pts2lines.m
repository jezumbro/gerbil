function [lines] = pts2lines(pts)
%pts2line Summary of this function goes here
%   Detailed explanation goes here
la.arc = logical(pts(:,3));
if ~any(la.arc)
    lines = pts(:,1:2);
else
    lines = [];
    for n = 1:1:size(pts,1)
        if pts(n,3) ~= 0 && n ~= size(pts,1)
            [pts1] = bulge2arcPts(pts(n,1:2),pts(n+1,1:2),-pts(n,3),10) ;
            if isempty(lines)
                lines = vertcat(lines,b(n,1:2),pts1(1:end-1,:));
            else
                lines = vertcat(lines,pts1(1:end-1,:));
            end
        elseif pts(n,3) ~= 0 && n == size(pts,1)
            [pts1] = bulge2arcPts(pts(n,1:2),pts(1,1:2),-pts(n,3),10);
            lines = vertcat(lines,pts(n-1,1:2),pts1(1:end,:));
        else
            lines = vertcat(lines,pts(n,1:2));
        end
    end    
end


function polyOut = pts2polyshape(pts,openTF,linewidth)
%pts2polyshape Summary of this function goes here
%   pts - list of points for the polyshape taken from DXF file
%   openTF - if the polyshape is open or closed
%   linewidth - if the polyshape has a linewidth
la.arc = logical(pts(:,3));
if openTF % polygon is closed
    if ~any(la.arc)
        polyOut = polyshape(pts(:,1:2),'Simplify',false);
    else
        lines = [];
        for n = 1:1:size(pts,1)
            if pts(n,3) ~= 0 && n ~= size(pts,1) % check if n is not 1 or end of data
                [pts1] = bulge2arcPts(pts(n,1:2),pts(n+1,1:2),-pts(n,3)); % if there are a certain number of points
                if isempty(lines)
                    lines = vertcat(lines,pts1(1:end-1,:));
                else
                    lines = vertcat(lines,pts1(1:end-1,:));
                end
            elseif pts(n,3) ~= 0 && n == size(pts,1)
                [pts1] = bulge2arcPts(pts(n,1:2),pts(1,1:2),-pts(n,3));
                lines = vertcat(lines,pts1(1:end,:));
            else
                lines = vertcat(lines,pts(n,1:2));
            end
        end
        polyOut = polyshape(lines);
    end
elseif ~openTF && linewidth ~= 0 % polygon is open
    if ~any(la.arc)
        polyOut = polybuffer(pts(:,1:2),'lines',0.5*linewidth,'JointType','miter');
    else
    lines = [];ip = 1;
        for n = 1:1:size(pts,1)
            if pts(n,3) ~= 0 && n ~= size(pts,1) % check if n is not 1 or end of data
                [pts1] = bulge2arcPts(pts(n,1:2),pts(n+1,1:2),-pts(n,3)); % if there are a certain number of points
                if isempty(lines)
                    po(ip) = polybuffer(pts1(1:end-1,:),'lines',0.5*linewidth);ip = ip+1;
                else
                    lines = vertcat(lines,pts1(1:end-1,:));
                end
            elseif pts(n,3) ~= 0 && n == size(pts,1)
                [pts1] = bulge2arcPts(pts(n,1:2),pts(1,1:2),-pts(n,3));
                %po(ip) = polybuffer(pts1(1:end-1,:),'lines',0.5*linewidth);ip = ip+1;
            else
                lines = vertcat(lines,pts(n,1:2));
            end
        end
        polyOut = po.union;
    end
else
    polyOut = [];
end
end



function [masterPunchOrder] = punchLTCC(layer)
% punchLTCC - this function will take in a polyshape layer and then punch
% out the dimensions based on the tools avaiable 
%  
%  INPUT:
%    layer - polyshape input of layer that will be punched
%      dxf - circle locations on the DXF file
%  OUTPUT:
%    masterPunchOrder - this is an ordered list of the order that the
%     machine should punch the green tape
% 
%  GENERAL:
%  Author: John E Zumbro (Zeke)
%  Date: July 24, 2018
% 
%  NOTE: All units in this function will be in mm
% 
%  Version 0.0 - beta testing on small shapes to develop this code 
%  rugged and 

punchFactor = 1;
masterPunchOrder = [];
punchWheel = 0.5*[0; 12; 20; 94]*.0254; % mil to mm conversion
[orderPunch,punchNum] = sort(punchWheel,'descend');
region = layer.regions;
[~,i] = sort(region.area); region = region(i)
cla;plot(layer);hold on;
for regIndex = 1:size(region,1)
    fprintf('Area %d: %.3f\n',regIndex,region(regIndex).area)
    punchShape = region(regIndex);shape = punchShape;
    miniPunchOrder = []; punchArea = [];punchIndex = 1;
    clear l;
    while punchIndex < size(orderPunch,1)&& 0.005 < shape.area
        if orderPunch(punchIndex) > 0
            [xc,yc] = punchShape.centroid;
            dist = sum((punchShape.Vertices-[xc,yc]).^2,2);
            if std(dist) < 1e6 && all(abs(dist-mean(dist)) < 1e-6)&& 50 < size(dist,1)
                type = 'circle';
            else
                type = 'rectangle';
            end
            switch type
                case 'circle'
                    i = 1; l(i) = polybuffer(punchShape,-orderPunch(punchIndex));
                    if ~l(1).area % iterate from inside out placing punched holes
                        radius = mean(sqrt(sum((punchShape.Vertices-[xc,yc]).^2,2)));
                        if abs(radius - orderPunch(punchIndex)) < 1e-10
                            shape = subtract(shape,polybuffer([xc,yc],'points',orderPunch(punchIndex)));
                            miniPunchOrder = [miniPunchOrder;[xc,yc],punchNum(punchIndex)];
                        end
                    else
                        [x,y] = boundary(l(i)); [in,~] = intersect(shape,[x,y]);
                        while i < 100 && 0 < l(i).area && ~isempty(in)
                            i = i + 1;
                            l(i) = polybuffer(l(i-1),-orderPunch(punchIndex));
                            [x,y] = boundary(l(i));
                            if l(i).area
                                [in,~] = intersect(shape,[x,y]);
                            end
                        end
                        
                        % clear the unused buffered regions
                        if size(l,2) > 1
                            l(end) = [];
                        end
                        l(~l.area) = [];l = fliplr(l);
                        for numberArea = 1:size(l,2)
                            [xc,yc] = l(numberArea).centroid;
                            radius = mean(sqrt(sum((l(numberArea).Vertices-[xc,yc]).^2,2)));
                            ang = linspace(0,2*pi,ceil(2*pi*radius/(0.5*orderPunch(punchIndex))))';
                            if radius < orderPunch(punchIndex) && size(ang,1) <= 3
                                pts = [xc,yc];
                            else
                                if numberArea == 1
                                    pts = [xc,yc;radius.*[cos(ang) sin(ang)]+[xc,yc]]
                                else
                                    pts = radius.*[cos(ang) sin(ang)]+[xc,yc];
                                end
                            end
                            la = isinterior(shape,pts);
                            if any(la)
                                shape = subtract(shape,polybuffer(pts(la,:),'points',orderPunch(punchIndex)));
                                miniPunchOrder = [miniPunchOrder;pts,la.*punchNum(punchIndex)];
                            end
                            plot(shape)
                        end
                    end
                case 'rectangle'
                    
                    % figure out how many recursions occur to fill the shape with a punch
                    % of the given size go until the area of the shape no longer exists
                    i = 1; l(i) = polybuffer(punchShape,-orderPunch(punchIndex));
                    if ~l(1).area % iterate from inside out placing punched holes
                        disp('z')
                    else
                        [x,y] = boundary(l(1)); [in,~] = intersect(shape,[x,y]);
                        while i < 100 && 0 < l(i).area && ~isempty(in)
                            i = i + 1;
                            l(i) = polybuffer(l(i-1),-orderPunch(punchIndex));
                            [x,y] = boundary(l(i));
                            if l(i).area
                                [in,~] = intersect(shape,[x,y]);
                            end
                        end
                        
                        % clear the unused buffered regions
                        if size(l,2) > 1
                            l(end) = [];
                        end
                        l(~l.area) = [];l = fliplr(l);
                        for numberArea = 1:size(l,2)
                            [x,y] = l.boundingbox;
                            xnum = ceil(diff(x)/(punchFactor*orderPunch(punchIndex)));
                            ynum = ceil(diff(y)/(punchFactor*orderPunch(punchIndex)));
                            if xnum == 1; xnum = 2;end; if ynum == 1; ynum = 2;end
                            xsteps = linspace(x(1),x(2),xnum);
                            ysteps = linspace(y(1),y(2),ynum);
                            [X,Y] = meshgrid(xsteps,ysteps);
                            pts = [reshape(X,[],1),reshape(Y,[],1)];
                            mpts = [pts(:,1)-orderPunch(punchIndex),pts(:,2);...
                                pts(:,1)+orderPunch(punchIndex),pts(:,2);...
                                pts(:,1),pts(:,2)-orderPunch(punchIndex);...
                                pts(:,1),pts(:,2)+orderPunch(punchIndex)];
                            la_shape = isinterior(shape,mpts); la_punchShape = isinterior(punchShape,mpts);
                            la = any(reshape(la_shape,size(pts,1),4),2) & all(reshape(la_punchShape,size(pts,1),4),2);
                            if any(la)
                                shape = subtract(shape,polybuffer(pts(la,:),'points',orderPunch(punchIndex)));
                                miniPunchOrder = [miniPunchOrder;pts,la.*punchNum(punchIndex)];
                            end
                            plot(shape)
                        end
                    end
                otherwise
                    disp('otherwise case')
            end
        end
        punchIndex = punchIndex+1;
    end    
    miniPunchOrder(~miniPunchOrder(:,3),:) = [];
    plot(miniPunchOrder(:,1),miniPunchOrder(:,2),'.')
    masterPunchOrder = [masterPunchOrder;sortrows(miniPunchOrder,3)];
    miniPunchOrder = [];
end
masterPunchOrder(~masterPunchOrder(:,3),:) = [];
masterPunchOrder = round(masterPunchOrder,3);
end


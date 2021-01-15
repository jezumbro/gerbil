function [pts] = bulge2arcPts(point1,point2,bulge)
%bulget2arcPts - Creates a arc based on the number of points passed to the
%structure. This is vital for converting AutoCAD files to nScrypt or into
%postprocessor files. 
% point1 - (x,y) coordiantes
% point2 - (x,y) coordiantes
% bulge  - factor based on the radius of the arc
% numPts - number of points used in interpolation

% construct initial vector
vect = [point1 0; point2 bulge];

% calculate chord points
chord = vect(2,1:2)-vect(1,1:2);

% determine the radius of the chord
radius = abs((0.5*norm(chord))/(sin(2*atan(vect(2,3)))));
% calculate the inital rotation of the angle
theta1 = atan2(chord(2),chord(1));

theta2 = atan(vect(2,3));
sagitta.length = norm(chord/2)/cos(theta2);
sagitta.vector = sagitta.length*[cos(theta1+theta2) sin(theta1+theta2)];
sagitta.pt = sagitta.vector+vect(1,1:2);
mid.pt = mean(vect(1:2,1:2));
cPt.vector = mid.pt-sagitta.pt;
cPt.length = norm(cPt.vector);
cPt.Uvector = cPt.vector/cPt.length;
cPt.pt = sagitta.pt+radius*cPt.Uvector;
cPt.theta(1) = atan2(vect(1,2)-cPt.pt(2),vect(1,1)-cPt.pt(1));
cPt.theta(2) = atan2(sagitta.pt(2)-cPt.pt(2),sagitta.pt(1)-cPt.pt(1));
cPt.theta(3) = atan2(vect(2,2)-cPt.pt(2),vect(2,1)-cPt.pt(1));
if vect(2,3) > 0 && cPt.theta(1) < cPt.theta(3)
    cPt.theta(1) = cPt.theta(1)+2*pi;
elseif vect(2,3) < 0 && cPt.theta(1) > cPt.theta(3)
    cPt.theta(3) = cPt.theta(3) + 2*pi;
end
numPts = abs(ceil(2*pi*radius*(cPt.theta(3)-cPt.theta(1))/(0.25*norm(chord))));
if isempty(numPts); numPts = 3; end
ang = linspace(cPt.theta(1),cPt.theta(3),numPts)';

pts = [cPt.pt(1)+radius*cos(ang),cPt.pt(2)+radius*sin(ang)];
end


clear;
% test putting together a polyshape to create an STL file
layer = polyshape([0 0; 1 0; 1 1; 0 1]);
T = triangulation(layer);
nT.Points = T.Points;
nT.ConnectivityList = T.ConnectivityList+size(T.Points,1);
z = zeros(size(T.Points,1),1);
vertices = [[T.Points,z];[nT.Points,z+1]];
tempboundaries = T.freeBoundary;
faces = [fliplr(T.ConnectivityList);
    nT.ConnectivityList;
    fliplr(tempboundaries), tempboundaries(:,1)+size(T.Points,1);
    tempboundaries+size(T.Points,1),tempboundaries(:,2)];
patch('Faces',faces,'Vertices',vertices,...
    'FaceColor',       [0.8 0.8 1.0], ...
    'EdgeColor',       'none',        ...
    'FaceLighting',    'gouraud',     ...
    'AmbientStrength', 0.15);

% Add a camera light, and tone down the specular highlighting
camlight('headlight');
material('dull');

% Fix the axes scaling, and set a nice view angle
axis('image');
view([-135 35]);
stlwrite('cond.stl',faces,vertices,'MODE','ascii')
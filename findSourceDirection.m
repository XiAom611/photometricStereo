function [x, y, z] = findSourceDirection(imageName)
%Find the source direction from image name
%   get source direction from azimuth and elevation by reading image name

azimuth = extractBetween(imageName, "A", "E");
elevation = extractBetween(imageName, "E", ".");

azimuth = str2double(azimuth);
elevation = str2double(elevation);

x = sin(deg2rad(azimuth)) * cos(deg2rad(elevation));
z = cos(deg2rad(azimuth)) * cos(deg2rad(elevation));
y = sin(deg2rad(elevation));
end


clear;clc;
%%% GET IMAGE DIR
currentPath = pwd;
imageFolderPath = fullfile(currentPath, 'yaleB27','*.pgm');
imagesPath = dir(imageFolderPath);
imagesNum = size(imagesPath);
imagesNum = imagesNum(1);

sourceDir = zeros(imagesNum, 3);
images = cell(imagesNum, 1);
for i = 1:imagesNum
    %%% FIND SOURCE DIRECTION
    [x,y,z] = findSourceDirection(imagesPath(i).name);
    sourceDir(i,:) = [x,y,z];
    
    %%% READ IMAGES (GRAYSCALE)
    images{i} = im2double(imread(fullfile(imagesPath(i).folder,imagesPath(i).name)));
end

%%% GET IMAGE SIZE
imageSize = size(images{1});
imageWidth = imageSize(2);
imageHeight = imageSize(1);

%%% GET PIXEL NORMAL
normal = cell(imageHeight, imageWidth);
normalX = zeros(imageHeight, imageWidth);
normalY = zeros(imageHeight, imageWidth);
normalZ = zeros(imageHeight, imageWidth);
g = cell(imageHeight, imageWidth);
fx = zeros(imageHeight, imageWidth);
fy = zeros(imageHeight, imageWidth);
albedo = zeros(imageHeight, imageWidth);

for width = 1:imageWidth
    for height = 1:imageHeight
        %%% GET PIXEL VALUE
        pixelValue = zeros(imagesNum, 1);
        for i = 1:imagesNum
            pixelValue(i) = images{i}(height, width);
        end
        
        %%% SOLVE LINEAR SYSTEM PROBLEM
        g_xy = sourceDir \ pixelValue;
        g{height, width} = g_xy;
        albedo(height, width) = norm(g_xy);
        pixNorm = g_xy / albedo(height, width);
        normal{height, width} = pixNorm;
        normalX(height, width) = pixNorm(1);
        normalY(height, width) = pixNorm(2);
        normalZ(height, width) = pixNorm(3);
        fx(height, width) = g_xy(1)/g_xy(3);
        fy(height, width) = g_xy(2)/g_xy(3);
    end
end

%%% SHOW RECOVERED NORMAL FIELD
figure(1)
subplot(1,3,1)
imagesc(normalX)
colorbar; axis tight; axis off;
subplot(1,3,2)
imagesc(normalY)
colorbar; axis tight; axis off;
subplot(1,3,3)
imagesc(normalZ)
colormap jet
colorbar; axis tight; axis off;

%%% SHOW ALBEDO
figure(2)
imshow(albedo)
title('Albedo');

%%% RECOVER SURFACE FROM NORMAL
f = zeros(imageHeight, imageWidth);
for height = 1:imageHeight
    for width = 1:imageWidth
        f(height, width) = sum(fy(1:height, width)) + sum(fx(1, 1:width));
    end
end

%%% SHOW RECONSTRUCTED FACE
f(f(:,:)<0) = 0;
figure(3);
axis equal;
mesh(f, albedo);
colormap gray;




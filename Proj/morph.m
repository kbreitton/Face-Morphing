function morphed_im = morph(im1, im2, im1_pts, im2_pts, tri, warp_frac, dissolve_frac)

if warp_frac == 1 && dissolve_frac == 1
    morphed_im = im2;
elseif warp_frac == 0 && dissolve_frac == 0
    morphed_im = im1;
else

%compute intermediate shape
im_pts = (1-warp_frac) .* im1_pts + (warp_frac) .* im2_pts; %im_pts are in x,y

%get matrix of the indices (in i,j) of all pixels in im_pts shape
matrix = ones(round(max(im_pts(:,2))), round(max(im_pts(:,1))));
[pixel_index(:,1) pixel_index(:,2)] = find(matrix > -1);

%find the triangle that each pixel (in i,j) of the im_pts shape lies in
T = tsearchn(im_pts, tri, fliplr(pixel_index));

%get the A matrix for each possible triangle
for i = 1:size(tri,1)
    triangle = tri(i,:);
    col1 = [im_pts(triangle(1),:) 1]'; %x and y in im_pts are actually x,y coordinate in cartesian
    col2 = [im_pts(triangle(2),:) 1]';
    col3 = [im_pts(triangle(3),:) 1]';
    A(:,:,i) = [round(col1) round(col2) round(col3)];
end
        

%compute the barycentric co-coordinates for each pixel of the im_pts
%shape
pixels_in_tri = find(T>0); %for all pixels within the triangulation of the im_pts shape
for i = 1:length(pixels_in_tri);
    pixel_coord(:,i) = [pixel_index(pixels_in_tri(i),2); pixel_index(pixels_in_tri(i), 1); 1]; %in x,y
    bary_coord(:,i) = A(:,:,T(pixels_in_tri(i))) \ pixel_coord(:,i);
end


%find the source pixel for im1 and im2
%get the A matrix of each source image for each triangle
for i = 1:size(tri,1)
    triangle = tri(i,:);
    col1 = [im1_pts(triangle(1),:) 1]'; %x and y are actually x,y coordinate in cartesian
    col2 = [im1_pts(triangle(2),:) 1]';
    col3 = [im1_pts(triangle(3),:) 1]';
    A_source1(:,:,i) = [col1 col2 col3];
    
    col1 = [im2_pts(triangle(1),:) 1]';
    col2 = [im2_pts(triangle(2),:) 1]';
    col3 = [im2_pts(triangle(3),:) 1]';
    A_source2(:,:,i) = [col1 col2 col3];
end

%compute source pixel coordinates (in x and y, not matlab indices)
for i = 1:size(bary_coord,2)
pixel_coord1_source(:,i) = round(A_source1(:,:,T(pixels_in_tri(i))) * bary_coord(:,i));
end

for i = 1:size(bary_coord,2)
pixel_coord2_source(:,i) = round(A_source2(:,:,T(pixels_in_tri(i))) * bary_coord(:,i));
end

%make sure coordinates don't exceed bounds
x1 = pixel_coord1_source(1,:);
y1 = pixel_coord1_source(2,:);
x1(x1 > size(im1,2)) = size(im1,2);
x1(x1 < 1) = 1;


y1(y1 > size(im1,1)) = size(im1,1);
y1(y1 < 1) = 1;

pixel_coord1_source(1,:) = x1;
pixel_coord1_source(2,:) = y1;

x2 = pixel_coord2_source(1,:);
y2 = pixel_coord2_source(2,:);
x2(x2 > size(im2,2)) = size(im2,2);
x2(x2 < 1) = 1;

y2(y2 > size(im2,1)) = size(im2,1);
y2(y2 < 1) = 1;

pixel_coord2_source(1,:) = x2;
pixel_coord2_source(2,:) = y2;

%copy pixel value from source (swtiching back to i,j)
for i = 1:size(pixel_coord, 2)
    morphed_im(pixel_coord(2,i), pixel_coord(1,i),:) = (1-dissolve_frac) * im1(pixel_coord1_source(2,i), pixel_coord1_source(1,i),:) + (dissolve_frac) * im2(pixel_coord2_source(2,i), pixel_coord2_source(1,i), :);
end

%rescale morphed_im to smaller of source images
sizes(1) = sqrt(size(im1, 1) * size(im1, 2));
sizes(2) = sqrt(size(im2, 1) * size(im2, 2));

[mini index] = min(sizes);

if index == 1
blah = imresize(morphed_im, [size(im1, 1) size(im1, 2)]);
else
blah = imresize(morphed_im, [size(im2, 1) size(im2, 2)]);
end

morphed_im = blah;
end
end
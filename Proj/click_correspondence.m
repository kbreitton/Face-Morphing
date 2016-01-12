function [im1_pts, im2_pts, tri] = click_correspondence(im1, im2)

% %rescale images to same image size
% sizes(1) = sqrt(size(im1, 1) * size(im1, 2));
% sizes(2) = sqrt(size(im2, 1) * size(im2, 2));
% 
% [mini index] = min(sizes);
% 
% if index == 1
% im2 = imresize(im2, [size(im1,1) size(im1,2)]);
% else
%     im1 = imresize(im1, [size(im2,1) size(im2,2)]);
% end

%select control points
[im1_pts im2_pts] = cpselect(im1, im2, 'Wait', true); %make sure you name the output im1_pts and im2_pts


%find the 'average face' to use for a consistent delaunay triangulation
average = (im1_pts + im2_pts) .* 05;

%calculate delaunay triangulation
tri = delaunay(average(:,1), average(:,2));

end
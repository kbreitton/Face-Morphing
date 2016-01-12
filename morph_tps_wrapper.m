function [morphed_im] = morph_tps_wrapper(im1, im2, im1_pts, im2_pts, warp_frac, dissolve_frac)

if warp_frac == 1 && dissolve_frac == 1
    morphed_im = im2;
elseif warp_frac == 0 && dissolve_frac == 0
    morphed_im = im1;
else

%rescale larger image to smaller of source images
sizes(1) = sqrt(size(im1, 1) * size(im1, 2));
sizes(2) = sqrt(size(im2, 1) * size(im2, 2));

[mini index] = min(sizes);

if index == 1
im2 = imresize(im2, [size(im1, 1) size(im1, 2)]);
sz = [size(im1,1) size(im1,2)];
else
im1 = imresize(im1, [size(im2, 1) size(im2, 2)]);
sz = [size(im2,1) size(im2,2)];
end

%get intermediate shape
im_pts = (1-warp_frac) .* im1_pts + (warp_frac) .* im2_pts; %im_pts are in x,y

%get TPS coefficients
[a1_x_im1, ax_x_im1, ay_x_im1, w_x_im1] = est_tps(im_pts, im1_pts(:,1));
[a1_y_im1, ax_y_im1, ay_y_im1, w_y_im1] = est_tps(im_pts, im1_pts(:,2));

[a1_x_im2, ax_x_im2, ay_x_im2, w_x_im2] = est_tps(im_pts, im2_pts(:,1));
[a1_y_im2, ax_y_im2, ay_y_im2, w_y_im2] = est_tps(im_pts, im2_pts(:,2));

% %find min image size
% sizes(1) = sqrt(size(im1, 1) * size(im1, 2));
% sizes(2) = sqrt(size(im2, 1) * size(im2, 2));
% 
% [mini index] = min(sizes);
% 
% if index == 1
% sz = [size(im1,1) size(im1,2)];
% else
% sz = [size(im2,1) size(im2,2)];
% end

morphed_im1 = morph_tps(im1, a1_x_im1, ax_x_im1, ay_x_im1, w_x_im1, a1_y_im1, ax_y_im1, ay_y_im1, w_y_im1, im_pts, sz);
morphed_im2 = morph_tps(im2, a1_x_im2, ax_x_im2, ay_x_im2, w_x_im2, a1_y_im2, ax_y_im2, ay_y_im2, w_y_im2, im_pts, sz);

morphed_im = (1-dissolve_frac) .* morphed_im1 + (dissolve_frac) .* morphed_im2;
end
end
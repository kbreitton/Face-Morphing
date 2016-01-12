function [morphed_im] = morph_tps(im_source, a1_x, ax_x, ay_x, w_x, a1_y, ax_y, ay_y, w_y, ctr_pts, sz)
%ctr_pts = control points of intermediate shape

%U function
U = @(r) -r.^2.*log(r.^2);

%TPS function, where u = U(sqrt(sum((ctr_pts - repmat([x,y], [size(ctr_pts,1) 1])).^2')))'
fx = @(x,y,u) a1_x + ax_x*x + ay_x*y + (w_x' * u);

fy = @(x,y,u) a1_y + ax_y*x + ay_y*y + (w_y' * u);

%find every source pixel, and switch x,y to i,j
for i = 1:round(max(ctr_pts(:,2))) %y
    for j = 1:round(max(ctr_pts(:,1))) %x
        
%         flip_i = round(max(ctr_pts(:,2))) - i + 1;
%         flip_j = round(max(ctr_pts(:,1))) - j + 1;
        
        u = U(sqrt(sum((ctr_pts - repmat([j,i], [size(ctr_pts,1) 1])).^2')))';
        u(isnan(u)) = 0; %get rid of NaN
        
        y = round(fy(j, i,u));
        x = round(fx(j, i,u));
        
        
        %make sure dimensions arent exceeded
        if y < 1
            y = 1;
        end
        
        if y > size(im_source,1)
            y = size(im_source,1);
        end
        
%         y = size(im_source,1) - y + 1;
        
        if x < 1
            x = 1;
        end
        
        if x > size(im_source,2)
            x = size(im_source,2);
        end
        
%         x = size(im_source,2) - x + 1;
        
        morphed_im(i,j,:) = im_source(y, x, :); %copy source pixel value
    end
end

morphed_im = imresize(morphed_im, sz); %resize

end

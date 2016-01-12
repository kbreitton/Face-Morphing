function [a1,ax,ay,w] = est_tps(ctr_pts, target_value)
%ctr_pts = control points of intermediate shape
%target_value = x or y values of the control points of source image

%U function
U = @(r) -r.^2.*log(r.^2);

%create 37-element cell array of repeated ctr_pts, where each element is a 37 x 2 matrix of
%all the same control point coordinates
ctr_matrix = cell(size(ctr_pts,1), 1);
for i = 1:size(ctr_pts,1)
        ctr_matrix{i} = repmat(ctr_pts(i,:), [size(ctr_pts,1) 1]);
end

%compute K matrix
for i = 1:size(ctr_pts,1)
        dist = sqrt(sum((ctr_pts - ctr_matrix{i}).^2'));
        K(i,:) = U(dist);
        K(i,i) = 0; %get rid of the NaN's in the diagonal
end

%get P matrix
P = [ctr_pts ones(size(ctr_pts,1), 1)];

%compile A matrix
A = [K P; P' zeros(3)];


%find weights and coefficients
if det(A) == 0
    lambda = 0.0001;
else
    lambda = 0;
end

x = inv(A + lambda.*eye(size(ctr_pts,1) + 3)) * [target_value' 0 0 0]';

w = x(1:end-3);
ax = x(end-2);
ay = x(end-1);
a1 = x(end);

end

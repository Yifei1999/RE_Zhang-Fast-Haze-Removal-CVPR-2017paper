function [image_padded] = image_padding(image_org,patchsize_x,patchsize_y)
% padding the image suitable for the patch to operate block operation
%
% input:
%      -image_org: the original image
%      -patchsize_x: the patch size OMEGA along x 
%      -patchsize_y: the patch size OMEGA along y 

[image_sizey,image_sizex,~] = size(image_org);
padpixel_x = patchsize_x*ceil(image_sizex/patchsize_x) - image_sizex;
padpixel_y = patchsize_y*ceil(image_sizey/patchsize_y) - image_sizey;
% calculate the num of padding pixels on each position
padpixel_left = floor((padpixel_x+1)/2);
padpixel_right = padpixel_x - padpixel_left;
padpixel_up = floor((padpixel_y+1)/2);
padpixel_down = padpixel_y - padpixel_up;

block_left = repmat(image_org(:,1,:),1,padpixel_left,1);
block_right = repmat(image_org(:,end,:),1,padpixel_right,1);
image_padded = [block_left image_org block_right];

block_up = repmat(image_padded(1,:,:),padpixel_up,1,1);
block_down = repmat(image_padded(end,:,:),padpixel_down,1,1);
image_padded = [block_up; image_padded; block_down];
end
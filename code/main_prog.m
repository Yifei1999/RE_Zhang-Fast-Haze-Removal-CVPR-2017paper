clear
clc
close all
% parameters:
% patchsize_x: the size of patch along x pos
% patchsize_y: the size of patch along y pos
% GuidedFilter_size: the kernel size of the GuidedFilter
% GuidedFilter_para: the parameter epsilon of the GuidedFilter
% t_0: the boundary of reflection index in the dark channel method
patchsize_x = 15;
patchsize_y = 15;
GuidedFilter_size = 32;
GuidedFilter_para = 0.01;
t_0 = 0.05;

image_org = imread('flickr2.bmp');    % nighttime haze image
figure
imshow(image_org)
image_padded = image_padding(image_org,patchsize_x,patchsize_y);    % padding
image_grey = double( rgb2gray(image_padded) );    % calculate grey layer

%% the first part, estimate Eta
% calculate MPI
[Momega_chanR,Momega_chanG,Momega_chanB] =...
    MPI_calcu(image_padded(:,:,1),image_padded(:,:,2),image_padded(:,:,3),...
    patchsize_y,patchsize_x);
% figure 
% imshow( cat( 3,uint8(Momega_chanR),uint8(Momega_chanG),uint8(Momega_chanB) ) )

% Momega_chanRGB consist of blocks of the same value, 
% degrade the matrix to reduce the calculation
Momega_chanR = Momega_chanR(1:patchsize_y:end,1:patchsize_x:end);
Momega_chanG = Momega_chanG(1:patchsize_y:end,1:patchsize_x:end);
Momega_chanB = Momega_chanB(1:patchsize_y:end,1:patchsize_x:end);
% normalize
Lj = MAX_MatrixValue(Momega_chanR,Momega_chanG,Momega_chanB);
Eta_omegaR = Momega_chanR ./ Lj;
Eta_omegaG = Momega_chanG ./ Lj;
Eta_omegaB = Momega_chanB ./ Lj;
% recover the matrix to blocks
Eta_omegaR = kron(Eta_omegaR,ones(patchsize_y,patchsize_x));
Eta_omegaG = kron(Eta_omegaG,ones(patchsize_y,patchsize_x));
Eta_omegaB = kron(Eta_omegaB,ones(patchsize_y,patchsize_x));
% refine (using guided filter)
Eta_R = imguidedfilter(Eta_omegaR,image_grey,'NeighborhoodSize',GuidedFilter_size,'DegreeOfSmoothing',GuidedFilter_para);
Eta_G = imguidedfilter(Eta_omegaG,image_grey,'NeighborhoodSize',GuidedFilter_size,'DegreeOfSmoothing',GuidedFilter_para);
Eta_B = imguidedfilter(Eta_omegaB,image_grey,'NeighborhoodSize',GuidedFilter_size,'DegreeOfSmoothing',GuidedFilter_para);
% figure    
% imshow(uint8(255*cat(3,Eta_omegaR,Eta_omegaG,Eta_omegaB)))

% remove the color effect
imagehat_R = double( image_padded(:,:,1) ) ./ Eta_R;
imagehat_G = double( image_padded(:,:,2) ) ./ Eta_G;
imagehat_B = double( image_padded(:,:,3) ) ./ Eta_B;
% figure
% imshow(cat(3,uint8(imagehat_R),uint8(imagehat_G),uint8(imagehat_B) ))
%% the second part, estimate t
% calculate MPI
[Momegahat_chanR,Momegahat_chanG,Momegahat_chanB] =...
    MPI_calcu(imagehat_R,imagehat_G,imagehat_B,...
    patchsize_y,patchsize_x);
% estimate Lomega and refine
L_omega = MAX_MatrixValue(Momegahat_chanR,Momegahat_chanG,Momegahat_chanB);
Lj = imguidedfilter(L_omega,image_grey,'NeighborhoodSize',GuidedFilter_size,'DegreeOfSmoothing',GuidedFilter_para);
% estimate t
DarkDefuze_blockfun = @(block_struct) block_struct.data*0 + min( min(block_struct.data) );
Ihat_min = MIN_MatrixValue(imagehat_R,imagehat_G,imagehat_B);
fraction_up = blockproc(Ihat_min,[patchsize_y,patchsize_x],DarkDefuze_blockfun);
t_omega = 1 - ( fraction_up ./ blockproc(Lj,[patchsize_y,patchsize_x],DarkDefuze_blockfun) );
% refine (using guided filter)
tj = imguidedfilter(t_omega,image_grey,'NeighborhoodSize',GuidedFilter_size,'DegreeOfSmoothing',GuidedFilter_para);

%% rehaze
J_R = (imagehat_R - Lj) ./ max(tj,t_0) + Lj;
J_G = (imagehat_G - Lj) ./ max(tj,t_0) + Lj;
J_B = (imagehat_B - Lj) ./ max(tj,t_0) + Lj;

J_R = uint8(J_R);
J_G = uint8(J_G);
J_B = uint8(J_B);
figure
imshow(cat(3,J_R,J_G,J_B))


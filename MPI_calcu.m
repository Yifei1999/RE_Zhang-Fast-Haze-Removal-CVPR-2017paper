function [Omega_R,Omega_G,Omega_B] = MPI_calcu(image_R,image_G,image_B,patchsize_y,patchsize_x)
% calculate the MPI of the image
%     -inputs:
%     -image_R G B: CHANNELS
%     -patchsize_x: the patch size OMEGA along x 
%     -patchsize_y: the patch size OMEGA along y 
MPI_blockfun = @(block_struct) block_struct.data*0 + max( max(block_struct.data) );
Omega_R = blockproc( double(image_R),[patchsize_y,patchsize_x],MPI_blockfun);
Omega_G = blockproc( double(image_G),[patchsize_y,patchsize_x],MPI_blockfun);
Omega_B = blockproc( double(image_B),[patchsize_y,patchsize_x],MPI_blockfun);
end



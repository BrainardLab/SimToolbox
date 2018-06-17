function A_beta = BCCComputeA_beta(beta,N_x,B_light,N_beta,B_surface,R)% A_beta = BCCComputeA_beta(beta,N_x,B_light,N_beta,B_surface,R)%% Compute the A matrix that relates the generic% variable x to the data, given the vector beta.% 11/08/98     pxl		Changed names of functions% Copyright (c) 1999 David Brainard and Philippe Longere.   All rights reserved.% Find sizes we need[N_r,null] = size(R);[null,M_x] = size(B_light);[null,M_beta] = size(B_surface);% Allocate spaceA_beta = zeros(N_x*N_beta*N_r,N_x*M_x);A_betaj = zeros(N_r,N_x);% Loop over surfacesfor j = 1:N_beta  % Get A_betaj matrix  beta_j = BCCExtractOneWeights(j,beta,M_beta);  A_betaj = BCCComputeA(beta_j,B_surface,B_light,R);    % Pack it in appropriately  for i = 1:N_x    A_beta((i-1)*(N_beta*N_r)+(j-1)*N_r+1:(i-1)*(N_beta*N_r)+j*N_r,...           (i-1)*(M_x)+1:i*M_x) = ...      A_betaj;  endend
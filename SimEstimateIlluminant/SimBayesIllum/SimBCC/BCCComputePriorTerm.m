function T_prior = BCCComputePriorTerm(est,N,prior)% T_prior = BCCComputePriorTerm(est ,N,prior)%% Compute the prior likelihood term.% The computed value neglects the normalizing constant.% The passed N is ignored for chromaticity type priors.%% 8/30/94	dhb		Added this line.% 11/08/98  pxl		Changed names of functions.% 6/26/02   dhb     Changed to take prior structure.%           dhb     Added type normalChrom.  Only will work for lights.%           dhb     Chromaticities in uvY.% Copyright (c) 1999 David Brainard and Philippe Longere.   All rights reserved.switch(prior.priorType)	case 'truncNormalWeights';		u = BCCExpandMean(prior.u,N);		K = BCCExpandCov(prior.K,N);		dev = (est-u);		T_prior = exp(-0.5*(dev'*inv(K)*dev));	case 'normalChrom';		estuvY = XYZTouvY(prior.MToXYZ*est);		dev = prior.u-estuvY(1:2);		T_prior = exp(-0.5*dev'*inv(prior.K)*dev);	otherwise,		error('Unknown prior type passed');end
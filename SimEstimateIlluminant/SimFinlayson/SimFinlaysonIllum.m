function [outputImage,estimatedIlluminant,S] = SimFinlaysonIllum(inputImage,priorsFileName)% [outputImage,estimatedIlluminant,S] = SimFinlaysonIllum(inputImage,priorsFileName)%% Uses color correlation algorithm to estimate illuminant.% The basic idea is to chose the illuminant whose gamut is% the most correlated to the chromaticities present in the % image.%% The estimated Illuminant is put in a field of the image structure called% estimatedIlluminant.%% The information about the world should be accepted through the% color priors argument.  It is possible that the structure passed% should be different here from the other algorithms, but it is% important that the information be passed.  Currently it seems% to be loaded by SimComputeCorrelationTable.%% 09/15/98     pxl	Wrote it% 11/01/98     pxl	Removed a bug% 11/07/98     pxl	Changed output type% 11/15/98     pxl	Cleaned, commented the code% 11/25/98     pxl	Changed return type to structure w estimatedIlluminant% 12/29/98     dhb  Variable name changes.  Get rid of illuminant dump.% 12/29/98     dhb  Convert sensors so that they relate to physical units.% 12/31/98     dhb  Accept camera as a struct.  Return data differently.%              dhb  Require a colorPriors argument.  At the moment only S%                   field is used.% 4/23/99      dhb  Fixed some typos, now it runsnSamples=100;if (isstruct(inputImage))  outputImage = inputImage;else  outputImage = SimReadImage(inputImage); endclear inputImage;if (~isstruct(outputImage.cameraFile))	camera = SimReadCamera(outputImage.cameraFile);else	camera = outputImage.cameraFile;endR = SimAdjustSensors(outputImage,camera);% Load priors.if (isstruct(priorsFileName))	colorPriors = priorsFileName;else	colorPriors = SimLoadColorPriors(priorsFileName);end% Compute the gammut of the given sensor[table E] = SimComputeCorrelationTable(R,nSamples);height = size(outputImage.images,1);width = size(outputImage.images,2);outputImage.images = reshape(outputImage.images,outputImage.height*outputImage.width,3); outputImage = SimScale(outputImage);% Get rid of the [0 0 0] values which are zer = find(outputImage.images(:,1)==0 & outputImage.images(:,2)==0 &outputImage.images(:,3)==0);% Set to 0 (in chromaticity)if (~isempty(zer))  outputImage.images(zer,:) = [0 0 1];end% Compute the chromaticities map of the image (actually 1/10th of the image) x0 =  outputImage.images(:,1)./(outputImage.images(:,1)+outputImage.images(:,2)+outputImage.images(:,3)); y0 =  outputImage.images(:,2)./(outputImage.images(:,1)+outputImage.images(:,2)+outputImage.images(:,3));xy = nSamples*round(nSamples*x0(1:10:size(x0)))+round(nSamples*y0(1:10:size(y0)));outputImage.images = reshape(outputImage.images,outputImage.height,outputImage.width,3); for (k=1:size(E,2))  nb(k)=size(find(table(xy,k)>0),1);endbest = max(nb);% Find the best correlation between illuminants gamuts and image gamutNb = find(nb==best);estimatedIlluminant = E(:,Nb(1));outputImage.estimatedIlluminant.spd = estimatedIlluminant;S = colorPriors.S;outputImage.estimatedIlluminant.S = S;
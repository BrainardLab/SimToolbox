function [drawnPoints, points] = SimDrawPoints(inputImage,nPoints,nTrials,weightF)% [drawnPoints, points] = SimDrawPoints(inputImage,nPoints,nTrials,[weightF])%% Select some random points from the image to use for illuminant% estimation.  Points are weighted with a Gaussian according to weightF% unless specified standard deviation exceeds image dimension, in which % case a uniform spatial draw is used.%% 12/31/98  dhb  Added comments to pxl's routine.%           dhb  Deleted variable "whe", which wasn't doing anything.%           dhb  Seed generator randomly, not with zeros.%           dhb  Don't dump map variable here.%           dhb  Changed returned data format using power of MATLAB 5.%           dhb  Allow n dimensional input images.%           dhb  Disable quantized code.% 01/13/00  pxl  Added Quad Tree Quantization%           pxl  Added Deterministic Draw%           pxl  Got rid of N_Trials which is not used in new Bayesian% 03/20/00  pxl  Added quantization options description%                Added Segmentation.  % 01/29/01  pxl  Added weighted random draw.% 6/26/02   dhb  Added some comments, cleaned indentation.% 7/27/02   dhb  Don't return cell array, just matrix.% 8/31/02   dhb  Get rid of unused options -- simplify.% 2/10/07   dhb  Argument weightF optional.% Default argsif (nargin < 4 | isempty(weightF))    weightF.stddev = 10e6;end% Debug printouts?DEBUG = 0;% Seed random number generator from clockClockRandSeed;% Get image and camera if passed as nameif (~isstruct(inputImage))  inputImage = SimReadImage(inputImage); endif (~isstruct(inputImage.cameraFile))	camera = SimReadCamera(inputImage.cameraFile);else	camera = inputImage.cameraFile;endif (DEBUG) 	if (weightF.stddev>=max(size(inputImage.images)))		fprintf(1,'Random draw with mask\n')  else		fprintf(1,'Weighted random Draw, with mask\n');   endendif (~isfield(weightF,'mask') | isempty(weightF.mask))  weightF.mask = ones(size(inputImage.images));endl=0;while (l<nPoints)  l=l+1;  if (weightF.stddev>=max(size(inputImage.images)))		clear x		x(1) = Ranint(1,size(inputImage.images,1));  		x(2) = Ranint(1,size(inputImage.images,2));		x=x';  else		x = round(MultiNormalDraw(1,weightF.position',...                [weightF.stddev^2 0 ; 0 weightF.stddev^2]));  end  if ~((x(1)<=0) | (x(2)<=0) | (x(1)>size(inputImage.images,1)) | (x(2)>size(inputImage.images,2)))		if (weightF.mask(x(1),x(2)))		  weightF.mask(x(1),x(2)) = 0;		  drawnPoints(:,l) = squeeze(inputImage.images(x(1),x(2),:));		  points(:,l) = x;		else		  l=l-1;		end  else		l=l-1;  end end
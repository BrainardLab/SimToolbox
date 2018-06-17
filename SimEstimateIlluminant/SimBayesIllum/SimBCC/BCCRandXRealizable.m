function theXs = BCCRandXRealizable(x0,y,pTol,colorPriors,sensors,loss,maxIter,nReturn)% theXs = BCCRandXRealizable(x0,y,pTol,colorPriors,sensors,loss,maxIter,nReturn)%% Find x vectors that satisfy realizability constraint.%% Random draw on x vectors with checking.%% 11/08/98     pxl    Changed names of functions% 12/31/98     dhb    New method of passing prior information.%              dhb    Get rid of diagnostic code, it relied on routines%                     I don't want to update.% 05/25/00     pxl    Get rid of penalties that are not used.% 6/26/02      dhb    Clean comments.%			   dhb 	  Add switch on light prior type.%			   dhb	  Handle normalChrom prior type.% 7/28/02      dhb    For normalChrom prior, leave Y alone.% 9/2/02       dhb    Change to use random chromaticity independent of prior.% 9/2/02       dhb    Code to put intensity of starting point at a sensible place.% 2/10/07      dhb    Updated to get it to work for truncNormalWeights type.% Set some parametersN_x = size(x0,2);N_beta = size(y,2);% Loop to find satisfactory x vectorstheXs = [];nXs = 0;for i = 1:maxIter    % Get a random x    uv = rand(2,1);    switch (colorPriors.light.priorType)        case 'truncNormalWeights',            % Get a random x            x = MultiNormalDraw(1,x0,colorPriors.light.K);            T_physical = BCCCheckXRealizable(x,y,pTol,colorPriors,sensors);            if (T_physical)                if (T_physical)                    theXs = [theXs x];                    nXs = nXs+1;                    if (nXs == nReturn)                        break;                    end                end            end        case 'normalChrom',            XYZ0 = colorPriors.light.MToXYZ*x0;            Y0 = XYZ0(2);            uvY = [uv ; Y0];            x = inv(colorPriors.light.MToXYZ)*uvYToXYZ(uvY);            T_physical = BCCCheckXRealizable(x,y,pTol,colorPriors,sensors);            if (T_physical)                [nil,xStart] = BCCEvaluateChromPosterior(uvY(1:2),y,3,30,colorPriors,sensors,loss);                if (T_physical)                    theXs = [theXs xStart];                    nXs = nXs+1;                    if (nXs == nReturn)                        break;                    end                end            end        otherwise,            error('Unknown light prior type');    endend
function xy = SimDrawRandomIllumChrom(n,lightPrior)% xy = SimDrawRandomIllumChrom(n,colorPriors.light)%% Generate a set of random light chromaticities from% prior.  Don't worry about physical realizability.%% 9/2/02  dhb  Wrote it.% 8/15/03 dhb  Change to uvswitch (lightPrior.priorType)	case 'truncNormalWeights',		w = MultiNormalDraw(n,lightPrior.u,lightPrior.K);		XYZ = lightPrior.MToXYZ*w;		uvY = XYZTouvY(XYZ);		uv = uvY(1:2,:);	case 'normalChrom',		uv = MultiNormalDraw(n,lightPrior.u,lightPrior.K);end
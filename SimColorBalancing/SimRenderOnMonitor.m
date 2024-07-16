function [outImage,monitor] = SimRenderOnMonitor(inImage,monFile,scaleFactor,affineFactor,DEBUG_PRINT,COMPUTE_PRIMARY)% [outImage,monitor] = SimRenderOnMonitor(inImage,monFile,[scaleFactor],[affineFactor],[DEBUG_PRINT],[COMPUTE_PRIMARY])%% Creates an image file for the display, based on monitor% and camera data.  The principle used by this routine% is to find monitor settings that are metameric (for% the camera's sensors) to the light that produced the% camera's settings.%% Returns monitor structure appropirately adjusted for camera acquisition% parameters.%% If a positive scale factor is passed, image is scaled by this number.%% If a scale factor of -1 is passed, image is put into monitor range% using an affine scaling.  If a scale factor of -2 is passed, image is% put into monitor range by dividing by the max value, with negative values% clipped to zero.%% COMPUTE_PRIMARY: 0    Just compute the monitor settings.% COMPUTE_PRIMARY: 1    Just compute device primaries.% COMPUTE_PRIMARY: 2    Use input primaries and gamma correct only.%% 06/23/98   pxl  Wrote it from MakeXYZ.% 07/14/98   pxl  Added eyeorcam param that should not be used.%                   it regards beta version of ColorCorrection.% 08/03/98   pxl  Test if arg1 is a structure or a filename.% 10/30/98   dhb  More comments.% 11/09/98   dhb  Allow camera file to be a struct.%	         dhb  Change check for default scaleFactor to nargin < 4 from < 5.%            dhb  Allow monitor file to be a struct as well.%            dhb  Ablate eyeorcam, clear cameraFile on output.% 11/23/98   pxl  Added check and factor for Quantal spectral data.% 12/17/98   dhb  Rewrote debugging print.  Didn't test large image code.% 1/4/99     dhb  Remove waitbar. It seems to cause trouble on Macs if you crash%                   with the waitbar on.  You have to quit and restart MATLAB.%            dhb  Redefine BIG_IMAGE in terms of total image size.  One could%                   be more sophisticated and work in bigger blocks for the big%                   images.% 1/10/99    dhb  Fix calculation of minimum rendered value for big images.% 3/26/99    xmz  Somehow a fixed S [380 5 81] was used in the%                   line SetColorSpace(...). Changed to S of camera.% 4/23/99    dhb  If passed scale factor is -1, put image into device range%                   using affine scaling.  This is currently written so that%		            it forces rendering of entire image at once.  It may get%                   unhappy if called on big images.% 4/17/00    pxl  If scale factor is -1, then store the scaling%                   coefficients in the image structure (.minScale, .maxScale)% 4/17/00    pxl  Added affineFactor parameter.% 7/27/02    dhb  DEBUG_PRINT an optional arg.% 8/18/03    dhb  Change to new toolbox calling names.% 4/16/04    dhb  Compute and return device primary image, before gamma%                   correction.%            dhb  Add option of -2 for scaleFactor.% 5/27/04    dhb  Get rid of code for small computers.% 5/29/04    dhb  Return primaryGamut as well for COMPUTE_PRIMARY == 1.%            dhb  Apply scaling options to all primary settings.% 7/19/04    dhb  Return monitor structure.% 2/10/07    dhb  Modify for [0-1] calibration world and new gamma code.% Set default scale factorif (nargin < 3 | isempty(scaleFactor))  scaleFactor = 1;endif (nargin < 4 | isempty(affineFactor))  affineFactor = 0;endif (nargin < 5 | isempty(DEBUG_PRINT))	DEBUG_PRINT = 1;endif (nargin < 6 | isempty(COMPUTE_PRIMARY))    COMPUTE_PRIMARY = 0;end% Get the image, camera and monitor data.if (~isstruct(inImage))  inImage = SimReadImage(inImage); endif (~isstruct(inImage.cameraFile))  camera  = SimReadCamera(inImage.cameraFile);else  camera = inImage.cameraFile;endif (~isstruct(monFile))  monitor = SimReadMonitor(monFile);else  monitor = monFile;endoutImage = inImage;if (isfield(outImage,'images'))    rmfield(outImage,'images');endif (isfield(outImage,'primaryImages'))    rmfield(outImage,'primaryImages');end% Check that its not mosaicedif (inImage.mosaiced == 1)	error('Cannot render mosaiced image');end% Set the output image monitor file as% passed monitor information.outImage.monitorFile = monFile;% Get effective sensors, ready for use with Watts/sr-m2.T_camera = SimAdjustSensors(inImage,camera);S_camera = [camera.wavelengthSampling.start ...		    camera.wavelengthSampling.step ...            camera.wavelengthSampling.numberSamples];monitor.describe.S = monitor.S_device;monitor = SetSensorColorSpace(monitor,T_camera,S_camera);monitor = SetGammaMethod(monitor,0);% Scale the data.if (scaleFactor > 0)	inImage.images = scaleFactor*(inImage.images-affineFactor);end% Use PsychToolbox to do the rendering.height = size(inImage.images,1);width = size(inImage.images,2);nSensors = size(inImage.images,3);switch (COMPUTE_PRIMARY)    case 0,        inImage.images = reshape(inImage.images,height*width,1,nSensors);        temp = SensorToPrimary(monitor,squeeze(inImage.images)');		if (DEBUG_PRINT)            maxDevice = max(temp(:));            minDevice = min(temp(:));		end		if (scaleFactor == -1)            [temp, minval,maxval] = SimScale(temp);            outImage.minScale = minval;            outImage.maxScale = maxval;		elseif (scaleFactor == -2)            maxval = max(temp(:));            temp = temp/maxval;		end		outImage.images = PrimaryToSettings(monitor,temp);		outImage.images = reshape(outImage.images',height,width,3);        outImage.imageType = 'monitor';        outImage.bits = 8;        outImage.images = round(outImage.images*((2^outImage.bits)-1));    case 1,        inImage.images = reshape(inImage.images,height*width,1,nSensors);        temp = SensorToPrimary(monitor,squeeze(inImage.images)');        if (DEBUG_PRINT)            maxDevice = max(temp(:));            minDevice = min(temp(:));		end		if (scaleFactor == -1)            [temp, minval,maxval] = SimScale(temp);            outImage.minScale = minval;            outImage.maxScale = maxval;		elseif (scaleFactor == -2)            maxval = max(temp(:));            temp = temp/maxval;		end        outImage.primaryImages = reshape(temp',height,width,3);        temp1 = PrimaryToGamut(monitor,temp);        outImage.primaryGamut = reshape(temp1',height,width,3);        outImage.imageType = 'monitorPrimary';    case 2,        inImage.primaryImages = reshape(inImage.primaryImages,height*width,1,nSensors);        temp = PrimaryToSettings(monitor,squeeze(inImage.primaryImages)');        outImage.images = reshape(temp',height,width,3);          outImage.imageType = 'monitor';        outImage.bits = 8;        outImage.images = round(outImage.images*((2^outImage.bits)-1));end
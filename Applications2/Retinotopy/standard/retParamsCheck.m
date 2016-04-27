function params = retParamsCheck(params)
% params = retParamsCheck - sanity checks of parameters
%
% SOD 10/2005: wrote it.

% some checks -- there should be an integer number of temporal frames for
% the start scan countdown, the prescan duration, and the main stimulus
% period.  (I use the 1e-5 threshold, because differences in numeric class 
% may cause tiny roundoff errors which may make things not exactly zero.)
ratio = params.startScan/params.framePeriod;
if abs(ratio - round(ratio)) > 1e-5
	error('start scan period (%.1f) is not an integer multiple of frame period (%.1f)!',...
        params.startScan,params.frameperiod);
end

ratio = params.prescanDuration/params.framePeriod;
if abs(ratio - round(ratio)) > 1e-5
	error('Pre scan period (%.1f) is not an integer multiple of frame period (%.1f)!',...
        params.prescanDuration, params.framePeriod);
end

ratio = params.period/params.framePeriod;
if abs(ratio - round(ratio)) > 1e-5
	error('Scan period (%.1f) is not an integer multiple of frame period (%.1f)!',...
        params.period, params.framePeriod);
end

% priority check
if params.runPriority==0
	bn = questdlg('Warning: runPriority is 0!','warning','OK','Make it 7','Make it 1','OK');
	if strcmpi(bn,'Make it 7')
		params.runPriority = 7;
	elseif strcmpi(bn, 'Make it 1') 
		params.runPriority = 1;
	end
end

% HACK to get correct timing for 2 rings experiment, since this one is all
% hard coded.
switch params.experiment
    case '2 rings'
        params.numCycles = 1;
end;

% Check that the period is an integer multiple of the frame period (TR if
%       an fMRI experiment)
integerPeriod = round(params.period/params.framePeriod) * params.framePeriod;
if ~isequal(params.period, integerPeriod);
    fprintf('Warning: changing period from %5.3f to %5.3f to be a multiple of the frame period (%5.3f)\n', ...
        params.period,  integerPeriod, params.framePeriod);    
    params.period = integerPeriod;
end

% verification
message = sprintf(['\n\n\n\n*******************************************\n' ...
                   '[%s]:Scan time and MR time frames:\n' ...
                   'Duration without stimulus (junk frames 1): %5.1f sec [%3d MRtf]\n' ...
                   'Duration of prescan (junk frames 2):       %5.1f sec [%3d MRtf]\n' ...
                   'Duration of data to be collected:          %5.1f sec [%3d MRtf]\n' ...
                   'Total stimulus duration:                   %5.1f sec [%3d MRtf]\n' ...
                   'Total scan duration:                       %5.1f sec [%3d MRtf] (%.1f minutes).' ...
                   '\n*******************************************\n\n\n'], ...
               mfilename,...
               params.startScan,  params.startScan/params.framePeriod, ...
               params.prescanDuration,  params.prescanDuration/params.framePeriod,...
               params.period.*params.numCycles,  params.period.*params.numCycles/params.framePeriod,...
               params.prescanDuration + params.period.*params.numCycles,...
               params.prescanDuration/params.framePeriod + params.period.*params.numCycles/params.framePeriod,...
               params.startScan+params.prescanDuration+params.period.*params.numCycles,...
               (params.startScan+params.prescanDuration+params.period.*params.numCycles)/params.framePeriod,...
               (params.startScan+params.prescanDuration+params.period.*params.numCycles)/60);
disp(message);

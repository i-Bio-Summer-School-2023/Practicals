function pattparams = SetPattParams(Nav,Spk)
% SetPattParams - Define parameters for detecting cell assembly patterns.
%
% Usage:
%   pattparams = SetPattParams(Nav, Spk)
%
% Inputs:
%   Nav: Structure containing navigation data (e.g. timestamps, positions, speeds, etc.).
%   Spk: Structure containing spike train data for each neuron (spike counts, etc.).
%
% Outputs:
%   pattparams: Structure containing pattern analysis parameters with the folllowing fields:
%    - subset: a structure where field names correspond to the name of the
%       fields in Nav that we want to apply the condition on. Fields of subset
%       define the value of these fields of Nav that will be used to subset the
%       data. For instance, if we want to subset data corresponding to
%       Nav.Condition = 1 or 3 and Nav.Spd >= 5, pattparams.subset should be
%       defined as:
%       pattparams.subset.Condition = [1 3];
%       pattparams.subset.Condition_op = 'ismember';
%       pattparams.subset.Spd = 5;
%       pattparams.subset.Spd_op = '>=';
%   - cellidx: Subset of cells used for pattern detection.
%   - nspk_th: Minimal number of spikes over the train set to consider a cell.
%   - Marcenko: if true, the PCs will be selected based on the
%   Marcenko-Pastur law. Otherwise, they will be selected based on shuffle
%   controls (see below).
%   - nShuffle: number of shuffle control to perform to establish a
%   distribution of eigenvalues enabling us to select only the non-expected
%   eigenvalues.
%   - variablenames: cell array of names of variables in Nav used to build
%   the shuffle controls: shuffling across time will be performed within 
%   bins of these variables. If variablenames is empty, shuffling will be
%   performed by circularly shifting responses by a random amount > 1
%   second.
%   - binedges: cell array of bin edges to use for the variables indicated
%   in pattparams.variablenames.
%   - NoiseCov: If true, the signal covariance, defined as the covariance
%   matrix averaged across all shuffles, will be subtracted before
%   proceeding to the PCA and ICA.
%   - strength_th: Pattern activation threshold to convert strength into "spikes".
%   - sampleRate: Sampling rate of the data.
%   - timewin: Size of the spike count window in seconds.
%
% Written by J. Fournier in 08/2023 for the iBio Summer school.

%Conditions over the fields of Nav for which patterns will be detected
%pattparams.subset should be a structure where fields have names of the 
%fields of Nav to which the condition should apply to.
pattparams.subset = [];

%For instance, for the example data set, we can define the following fields
pattparams.subset.Condition = [1 3 5];
pattparams.subset.Condition_op = 'ismember';

pattparams.subset.XDir = [-1 1];
pattparams.subset.XDir_op = 'ismember';

pattparams.subset.laptype = [-1 0 1];
pattparams.subset.laptype_op = 'ismember';

pattparams.subset.Spd =  2.5;
pattparams.subset.Spd_op = '>=';

pattparams.subset.Xpos =  0;
pattparams.subset.Xpos_op = '>=';

pattparams.subset.Xpos =  100;
pattparams.subset.Xpos_op = '<=';

%Subset of cells used for pattern detection. By default we'll use only 
%pyramidal cells since interneurons with high firing rates can bias the
%covariance matrix.
pattparams.cellidx = Spk.PyrCell;

%Minimal number of spikes over the train set to consider a cell for 
%pattern detection
pattparams.nspk_th = 0;

%If true, the PC will be selected according to the Marcenko-Pastur law
pattparams.Marcenko = false;

%Number of shuffle controls to perform for randomization if Marcenko-Pastur
%law is not used to select PCs
pattparams.nShuffle = 100;

%Names of varaibles in Nav that will be used to build the shuffle
%distribution of eigenvalues. Time points will be shuffled wihtin bins of
%these variables. If empty, the shuffling procedure will simply circularly 
%shift the spike counts by a random amount > 1 second.
pattparams.variablenames{1} = 'Xpos';
pattparams.variablenames{2} = 'Spd';
pattparams.variablenames{3} = 'XDir';

%Bin edges to discretize variables indicated in pattparams.variablenames.
pattparams.binedges{1} = 0 : 2: 100;
pattparams.binedges{2} = [0 : 5 : 50 inf];
pattparams.binedges{3} = [-2 0 2];

%If true, the covariance average across all shuffle controls, which provide
%an estimate of the signal covariance, will be removed from the overall
%covariance before proceeding to the PCA and ICA.
pattparams.NoiseCov = true;

%P-value to use as a threshold when selecting the PCs using the shuffling
%approach
pattparams.pvalshf_th = 0.05;

%Pattern activation threshold to convert activation strength into
%activation "spikes".
pattparams.strength_th = 5;

%Sampling rate of the data
pattparams.sampleRate = 1 / nanmean(diff(Nav.sampleTimes));

%Size of the spike count window in seconds
pattparams.timewin = .02;
end
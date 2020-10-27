function [V_DATA, F_DATA] = Load_PMU_Data_func(DATASET_NUM)
%LOAD_PMU_DATA Loads one of the 3 datasets from the NMSU PMU dataset
%   Appropriate Dataset Names IDs:
%   - DATASET_1
%   - DATASET_2
%   - DATASET_3

% PMU Data paths
DATASET_1_PATH = '..\PSCC_DATA\DATASET_1_81_FIELD_FLT_GNL\';
DATASET_2_PATH = '..\PSCC_DATA\DATASET_2_3495_SIMULATED\';
DATASET_3_PATH = '..\PSCC_DATA\DATASET_3_1818_SIMULATED_FLT_GNL\';

DATASET_1_FILENAME = 'PNM_DATA_FLT_GNL.mat';
DATASET_2_FILENAME = '08HS41_2SEC_STRONGEST_PMU_DATA_60FPS_PMU_AT_EVERY_ZONE_NEW.mat';
DATASET_3_FILENAME = '08HS41_2SEC_STRONGEST_PMU_DATA_60FPS_PMU_AT_EVERY_ZONE_NEW_FLT_GNL_1818.mat';

switch DATASET_NUM
    case 'DATASET_1'
        disp('Loading Dataset 1 (Field Data)')
        load([DATASET_1_PATH DATASET_1_FILENAME]);
        disp('Done loading dataset 1')
    case 'DATASET_2'
        disp('Loading Dataset 2 (Simulated Data)')
        load([DATASET_2_PATH DATASET_2_FILENAME]);
        disp('Done loading dataset 2')
    case 'DATASET_3'
        disp('Loading Dataset 3 (Simulated Data)')
        load([DATASET_3_PATH DATASET_3_FILENAME]);
        disp('Done loading dataset 3')
    otherwise
        disp('Error:  Invalid PMU Dataset specified')
end
end


clear; clc;
scriptDir = fileparts(mfilename('fullpath'));
projectRoot = fullfile(scriptDir, '..', '..');
addpath(genpath(fullfile(projectRoot, 'matlab')));

port = "COM11";
modelFile = fullfile(projectRoot, 'data', 'models', 'phone_motion_csi_model.mat');
if ~exist(modelFile, 'file')
    run(fullfile(scriptDir, 'run_train_phone_realtime_model.m'));
end

realtimeCsiActivityMonitor(char(port), char(modelFile), ...
    baudrate=921600, maxSeconds=60, windowPackets=80, stepPackets=20);


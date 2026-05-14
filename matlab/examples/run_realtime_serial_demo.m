clear; clc;
addpath(genpath(fullfile(fileparts(mfilename('fullpath')), '..')));

% Edit the port to match your ESP32 serial device.
port = "COM3";
baudrate = 921600;

fprintf('Starting realtime CSI monitor. Change port if needed: %s\n', port);
realtimeSerialMonitor(char(port), baudrate, maxLines=500);


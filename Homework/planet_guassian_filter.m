% Dylan Shadduck
% Planet GFSK Pulse Shaping Filter Coefficients
 clear
 clc
 
%% Define parameters
symbol_rate = 5e4;
sps = 8;
bt_vals = [0.1:0.05:0.5];
span = 5;
gain = sps/2;

for bt=bt_vals
    h = gaussdesign(bt, span, sps);
    h = gain.*h;
    fvtool(h, "impulse")
    
    % Printing values for copying purposes
    fprintf("Gain: %.2f\n", gain)
    fprintf("BT: %.2f\n", bt)
    fprintf("Coefficients: [")
    fprintf("%.2E, ", h(1:length(h) - 1))
    fprintf("%.2E] \n", h(end))
end

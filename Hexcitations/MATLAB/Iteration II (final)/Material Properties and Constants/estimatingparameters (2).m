%% Zheng parameters 
% (they never say what like anything is so im estimating some of the values;

L_silicone = [12.3]; %In mm, looks roughly 2.5x the width.
G = 0.112*(10)^6; % in Pa
W = 5; %in mm
H = 5;%in mm
w = W/2; %for computing J
h = H/2; %for computing J
wh = w/h; %ratio that is useful
J = w^3*h*(16/3-3.36*wh*(1-1/12*wh^4))
C = (G*J./L_silicone)/(1000).^3 %J is in mm^4 and L is in mm, so I need 1000^(-3) to get to S.I units
Factive = 0.015; %in N
L = L_silicone/1000; %in m 
sigma = Factive.*(L)./C %im not sure what L they use, it should be the center to center between two hexbugs, their
%center to center is L + 0.045 (size of hexbug... I think).
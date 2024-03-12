function [q,c,d,Disp,Shear_Stress,InBallDisp,BallDisp]=ContactStressElliptical2(Sigma_yield,dc,R1,R2,E,v,Load,MajorAxis)
% Revised on 6/25/23 by M.Pharand
% Load is a 1x6 vector units of [N]
% MajorAxis is parallel to the Vee axis (True)
% Added BallDisp[m] use the same coordinate system as the K clamp
R1xx=R1(1); % minor radius of the ball, units [m]
R1yy=R1(2); % major radius of the ball, units [m]
R2xx=R2(1); % groove radius, units [m]
R2yy=R2(2); % groove radius, units [m]
E1=E(1);    % ball modulus of elasticity, units [Pa]
E2=E(2);    % groove modulus of elasticity, units [Pa]
v1=v(1);    % Poisson ratio of the ball
v2=v(2);    % Poisson ratio of the groove
alpha=dc(1,:); % directional cosines along the x-axis
beta=dc(2,:);  % directional cosines along the y-axis
gamma=dc(3,:); % directional cosines along the z-axis
P=abs(Load);   % Loads must be positive values 
%

if MajorAxis==1 
    phi=pi/2;
else
    phi=0;
end
Ee=1/(((1-v1^2)/E1)+((1-v2^2)/E2));             % units [Pa] equivalent modulus
Ge=.5*(((2+v1-v1^2)/E1)+((2+v2-v2^2)/E2))^(-1); % units [Pa] equivalent shear modulus
%
Re=1/((1/R1xx)+(1/R1yy)+(1/R2xx)+(1/R2yy));     % units [m]  equivalent radius
cos_theta=Re*(((1/R1xx)-(1/R1yy))^2 + ((1/R2xx)-(1/R2yy))^2 + ...
    2*((1/R1xx)-(1/R1yy))*((1/R2xx)-(1/R2yy))*cos(2*phi))^.5;

theta=acos(cos_theta);
Alpha=1.939*2.71831^(-5.26*theta)+1.78*2.71831^(-1.09*theta)+0.723/theta+0.221;
Beta=35.228*2.71831^(-0.98*theta) -32.424*2.71831^(-1.0475*theta) +1.486*theta-2.634;
Lambda=-0.214*2.71831^(-4.95*theta)-0.179*theta^2 + 0.555*theta+0.319;
%
for i=1:6
c(i)=Alpha*((3*P(i)*Re)/(2*Ee))^.333;
d(i)=Beta*((3*P(i)*Re)/(2*Ee))^.333;
delta(i)=(Lambda*((2*P(i)^2)/(3*Re*Ee^2))^.333);
q(i)=(3*P(i))/(2*pi*c(i)*d(i));
%
Delta_x(i)=alpha(i)*delta(i);
Delta_y(i)=beta(i)*delta(i);
Delta_z(i)=gamma(i)*delta(i);
%
Disp=[Delta_x;Delta_y;Delta_z];
%
end
%
Shear_Stress=0.3*q./(Sigma_yield*.5);
InBallDisp=delta;
BallDisp=[Delta_x(1)+Delta_x(2) Delta_x(3)+Delta_x(4) Delta_x(5)+Delta_x(6);...
          Delta_y(1)+Delta_y(2) Delta_y(3)+Delta_y(4) Delta_y(5)+Delta_y(6);...
          Delta_z(1)+Delta_z(2) Delta_z(3)+Delta_z(4) Delta_z(5)+Delta_z(6)];
end


function[DC, FB,clamp_separated]=ClampContactForce(BallContactLoc,BallCenter,B,F_P,F_L,FL_loc)
% Revised on 6/25/23 by M.Pharand
%
% function to compute the contact force between the ball/Vee at 6 contact
% locations
%
% BallContactLoc is the coordinate of each ball contact point where 0,0,0 is the clamp
% [m], is a 6x3 matrix
% BallCenter is a pointing vector for each ball from the contact point to
% the ball center [m], is a 6x3 matrix
% F_P is the preload force at each ball/vee location [N] is a 3x3 matrix 
% F_L is the applied force on the clamp in [N] is a 1x3 vector, downward is negative
% F_loc is the location of the of the applied force [m] is a 1x3 vector
% B matrix is used to compute the moments about the clamp it is the average 
% distance between the two contact points [m] 3x3 matrix
%
Bx=B(1,:);
By=B(2,:);
Bz=B(3,:);
%
% cartesian coordinates of the (6)contact points 
%
x_B=BallContactLoc(:,1)';
y_B=BallContactLoc(:,2)';
z_B=BallContactLoc(:,3)';
%

%
% calculating the vector between the center of the ball and the contact
% point
%
X_B=-BallCenter(:,1)';
Y_B=-BallCenter(:,2)';
Z_B=-BallCenter(:,3)';
%
% directionnal cosines for the 6 contact points
%
for i=1:6
    alpha(i)=X_B(i)/(X_B(i)^2 + Y_B(i)^2 + Z_B(i)^2)^(1/2);
    beta(i)=Y_B(i)/(X_B(i)^2 + Y_B(i)^2 + Z_B(i)^2)^(1/2);
    gamma(i)=Z_B(i)/(X_B(i)^2 + Y_B(i)^2 + Z_B(i)^2)^(1/2);
end

%
% Calculating forces
%
A=[alpha;beta;gamma;(-beta.*z_B+gamma.*y_B);(alpha.*z_B-gamma.*x_B);(-alpha.*y_B+beta.*x_B)];
% 3D Solution
% F_L, F_P, FL_loc, Bx, By, Bz
Forces=[F_L(1)+F_P(1,1)+F_P(2,1)+F_P(3,1); % (1)
        F_L(2)+F_P(1,2)+F_P(2,2)+F_P(3,2); % (2)
        F_L(3)+F_P(1,3)+F_P(2,3)+F_P(3,3); % (3)
        F_L(3)*FL_loc(2)-F_L(2)*FL_loc(3)-(F_P(1,2)*Bz(1)+F_P(2,2)*Bz(2)+F_P(3,2)*Bz(3))+(F_P(1,3)*By(1)+F_P(2,3)*By(2)+F_P(3,3)*By(3));
                                           % (4)
        F_L(1)*FL_loc(3)-F_L(3)*FL_loc(1)+(F_P(1,1)*Bz(1)+F_P(2,1)*Bz(2)+F_P(3,1)*Bz(3))-(F_P(1,3)*Bx(1)+F_P(2,3)*Bx(2)+F_P(3,3)*Bx(3));
                                           % (5)
        F_L(1)*FL_loc(2)-F_L(2)*FL_loc(1)-(F_P(1,1)*By(1)+F_P(2,1)*By(2)+F_P(3,1)*By(3))+(F_P(1,3)*Bx(1)+F_P(2,3)*Bx(2)+F_P(3,3)*Bx(3))];...
                                           % (6)    

FB=A\Forces;


%
% check for clamp separation
negF_idx = FB(FB<0); % Store indices where FB < 0
      if any(negF_idx == 1) % If any index == True, show error dialogue
          clamp_separated = 1;
%             f = errordlg('Clamp Separation, reduce the distance of the applied force relative to the center','Error'); % Display Error
      else
          clamp_separated = 0;
      end
    
%
% Directional Cosines into a Matrix
%
DC=[alpha;beta;gamma];
%
end
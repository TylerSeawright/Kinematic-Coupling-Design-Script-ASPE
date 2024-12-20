function[FB,clamp_separated]=ClampContactForce(DC,BallContactLoc,BallCenter,B,F_P,F_L,FL_loc)
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
% X_B=-BallCenter(:,1)';
% Y_B=-BallCenter(:,2)';
% Z_B=-BallCenter(:,3)';
%

alpha = DC(1,:);
beta = DC(2,:);
gamma = DC(3,:);
%
% Calculating forces
%
A=[alpha;beta;gamma;(-beta.*z_B+gamma.*y_B);(alpha.*z_B-gamma.*x_B);(-alpha.*y_B+beta.*x_B)];
% 3D Solution from Dr. Slocum Equations, Precision Machine Design (1992)

ForceBalance=[F_L(1)+F_P(1,1)+F_P(2,1)+F_P(3,1); % (1)
        F_L(2)+F_P(1,2)+F_P(2,2)+F_P(3,2); % (2)
        F_L(3)+F_P(1,3)+F_P(2,3)+F_P(3,3); % (3)
        F_L(3)*FL_loc(2)-F_L(2)*FL_loc(3)-(F_P(1,2)*Bz(1)+F_P(2,2)*Bz(2)+F_P(3,2)*Bz(3))+(F_P(1,3)*By(1)+F_P(2,3)*By(2)+F_P(3,3)*By(3));
                                           % (4)
        F_L(1)*FL_loc(3)-F_L(3)*FL_loc(1)+(F_P(1,1)*Bz(1)+F_P(2,1)*Bz(2)+F_P(3,1)*Bz(3))-(F_P(1,3)*Bx(1)+F_P(2,3)*Bx(2)+F_P(3,3)*Bx(3));
                                           % (5)
        F_L(1)*FL_loc(2)-F_L(2)*FL_loc(1)-(F_P(1,1)*By(1)+F_P(2,1)*By(2)+F_P(3,1)*By(3))+(F_P(1,3)*Bx(1)+F_P(2,3)*Bx(2)+F_P(3,3)*Bx(3))];...
                                           % (6)    

FB=A\ForceBalance;


% 3D Solution derived from Dr. Slocum Equations for multiple applied loads
% and moments - Tyler Seawright 10/7/24.
% 1) Sum forces in X Y and Z
% 2) Sum moments about X Y and Z
% szF_L = size(F_L);
% % Sum F
% F1 = 0; F2 = 0; F3 = 0; M1 = 0; M2 = 0; M3 = 0;
% F1 = F1 + sum(F_L(:,1)) + F_P(1,1)+F_P(2,1)+F_P(3,1); % (1)
% F2 = F2 + sum(F_L(:,2)) + F_P(1,2)+F_P(2,2)+F_P(3,2); % (2)
% F3 = F3 + sum(F_L(:,3)) + F_P(1,3)+F_P(2,3)+F_P(3,3); % (3)
% % Sum M
% for i = 1:szF_L(1)
%     M1 = M1 + F_L(i,3)*FL_loc(i,2)-F_L(i,2)*FL_loc(i,3);
%     M2 = M2 + F_L(i,1)*FL_loc(i,3)-F_L(i,3)*FL_loc(i,1);
%     M3 = M3 + F_L(i,1)*FL_loc(i,2)-F_L(i,2)*FL_loc(i,1);
% end
% M1 = M1 - (F_P(1,2)*Bz(1)+F_P(2,2)*Bz(2)+F_P(3,2)*Bz(3))+(F_P(1,3)*By(1)+F_P(2,3)*By(2)+F_P(3,3)*By(3)); % (4)
% M2 = M2 + (F_P(1,1)*Bz(1)+F_P(2,1)*Bz(2)+F_P(3,1)*Bz(3))-(F_P(1,3)*Bx(1)+F_P(2,3)*Bx(2)+F_P(3,3)*Bx(3)); % (5)
% M3 = M3 - (F_P(1,1)*By(1)+F_P(2,1)*By(2)+F_P(3,1)*By(3))+(F_P(1,3)*Bx(1)+F_P(2,3)*Bx(2)+F_P(3,3)*Bx(3)); % (6)

% Solve Force Balance
% ForceBalance = [F1, F2, F3, M1, M2, M3]'; % Assign force values to matrix.
% FB = A\ForceBalance; % Solve force balance.
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

% % Verify Sum of Forces
% Fcomp = FB'.*DC
% sumF = sum(Fcomp,2)

end
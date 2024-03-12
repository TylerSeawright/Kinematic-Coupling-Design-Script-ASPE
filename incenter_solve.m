function IC = incenter_solve(Pb)
    p1 = Pb(1:3,1);
    p2 = Pb(1:3,2);
    p3 = Pb(1:3,3);

    % Calculate the lengths of the sides of the triangle
    L_B2B1 = norm(p1 - p2);
    L_B3B2 = norm(p2 - p3);
    L_B1B3 = norm(p3 - p1);
    TR_leng = [L_B2B1,L_B3B2,L_B1B3]; % Store the lengths of each triangle side

    % Calculate area of the triangle using Heron's formula
    L_sum = sum(TR_leng);
    s = L_sum / 2;  % Semiperimeter of triangle
%     area = sqrt(s*(s - L_B2B1)*(s - L_B3B2)*(s - L_B1B3));

    % Calculate the Incenter of the triangle
    IC = (L_B2B1*p3 + L_B3B2*p1 + L_B1B3*p2) / L_sum; % Calculate coordinates of the incenter
end

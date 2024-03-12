% vee_plane_transform.m
% This function solves the HTMs for each vee flat arbitrarily oriented by
% vee_reorient. 
function [HTM, Tvreo] = vee_plane_transform(Pb, Db, Phi, orient, vr)
    
    HTM = cell(6,1);
    Phi = pi/2-Phi * pi/180;
    for i = 1:2:6
        j = (i+1)/2;
        % Start at origin point (ball center)
        p0 = [0,0,0];
        
        % Move p0 down in Y to touch bottom of ball.
        T1 = Tform([0,0,-Db(j)/2],0);
        p1 = data_transform(T1, p0);
        
        % Rotate by phi about X axis
        T2_1 = Tform(Phi(j),1);
        T2_2 = Tform(-Phi(j),1);
        
        % Rotate by orientation value
        T3 = Tform(orient(j),3);

        % Rotate by vee reorientation values
        T4{j} = Tform(vr(j,3),3) * Tform(vr(j,2),2) * Tform(vr(j,1),1);
        
        % Position by ball center
        T5 = Tform(Pb(1:3,j),0);
        % Plot (DEV TOOL)
        HTM{i} = T5*T3*T4{j}*T2_1*T1;
        HTM{i+1} = T5*T3*T4{j}*T2_2*T1;
        Tvreo{j} = T5*T3*T4{j};
    end
end
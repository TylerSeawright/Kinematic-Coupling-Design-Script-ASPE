function retvars=kct_seat(vars, params)
% This function evaluates the 24 functions that are thesystem of non-linear equations that can be solved for theseating position (transformation) of the ball body in thegroove body. When used with fsolve.m the system can besolved for the x,y,z,alpha,beta, and gamma pose coordinatesas well as the coordinates of the 6 contact points. Thisfunction must be sent the positions of the balls in acoordinate system located at the coupling centroid, thecontact normal vectors, and the ball diameter in thecomponents of the vector params.
alpha=vars(1); % Rotation angle about z-axis
beta=vars(2); % Rotation angle about y-axis
gamma=vars(3); % Rotation angle about x-axis
xr=vars(4); % Position in x-axis
yr=vars(5); % Position in y-axis
zr=vars(6); % Position in z-axis
Pc1(1:4)=[vars(7:9);1]; Pc1=Pc1'; % Contact point 1'scoordinates
Pc2(1:4)=[vars(10:12);1]; Pc2=Pc2'; % Contact point 2'scoordinates
Pc3(1:4)=[vars(13:15);1]; Pc3=Pc3'; % Contact point 3'scoordinates
Pc4(1:4)=[vars(16:18);1]; Pc4=Pc4'; % Contact point 4'scoordinates
Pc5(1:4)=[vars(19:21);1]; Pc5=Pc5'; % Contact point 5'scoordinates
Pc6(1:4)=[vars(22:24);1]; Pc6=Pc6'; % Contact point 6'scoordinates
% Extract values in params vector into meaningful notation
Pb1=[params(1:3)];Pb1(4)=1; % Position of ball 1 incoordinate system at coupling centroid in ball body
Pb2=[params(4:6)];Pb2(4)=1; % Position of ball 2 incoordinate system at coupling centroid in ball body
Pb3=[params(7:9)];Pb3(4)=1; % Position of ball 3 incoordinate system at coupling centroid in ball body
Pb4=[params(10:12)];Pb4(4)=1; % Position of ball 4 incoordinate system at coupling centroid in ball body
TG11_G=[params(13:15),params(16:18),params(19:21),params(22:24)]; % Transformation from surface 1_1 to Groove coordsystem
TG11_G(4,1:4)=[0,0,0,1];
TG12_G=[params(25:27),params(28:30),params(31:33),params(34:36)]; % Transformation from surface 1_2 to Groove coordsystem
TG12_G(4,1:4)=[0,0,0,1];
TG21_G=[params(37:39),params(40:42),params(43:45),params(46:48)]; % Transformation from surface 2_1 to Groove coordsystem
TG21_G(4,1:4)=[0,0,0,1];
TG22_G=[params(49:51),params(52:54),params(55:57),params(58:60)]; % Transformation from surface 2_2 to Groove coordsystem
TG22_G(4,1:4)=[0,0,0,1];
TG31_G=[params(61:63),params(64:66),params(67:69),params(70:72)]; % Transformation from surface 3_1 to Groove coordsystem
TG31_G(4,1:4)=[0,0,0,1];
TG32_G=[params(73:75),params(76:78),params(79:81),params(82:84)]; % Transformation from surface 3_2 to Groove coordsystem
TG32_G(4,1:4)=[0,0,0,1];
rB(1)=params(85)/2; % Radius of Balls
rB(2)=params(86)/2;
rB(3)=params(87)/2;
rB(4)=params(88)/2;
rB(5)=params(89)/2;
rB(6)=params(90)/2;
%Extract normal vectors at contact points from thetransformation matrices
n1=[TG11_G(1:3,3);1]; % Unit vector in direction ofcontact force 1 at contact point 1
n2=[TG12_G(1:3,3);1]; % Unit vector in direction ofcontact force 2 at contact point 2
n3=[TG21_G(1:3,3);1]; % Unit vector in direction ofcontact force 3 at contact point 3
n4=[TG22_G(1:3,3);1]; % Unit vector in direction ofcontact force 4 at contact point 4
n5=[TG31_G(1:3,3);1]; % Unit vector in direction ofcontact force 5 at contact point 5
n6=[TG32_G(1:3,3);1]; % Unit vector in direction ofcontact force 6 at contact point 6

% Calculate elements within the homogenous transformationmatrix representing resting position
T(1:4,1)=[cos(alpha)*cos(beta);sin(alpha)*cos(beta);-sin(beta);0];
T(1:4,2)=[cos(alpha)*sin(beta)*sin(gamma)-sin(alpha)*cos(gamma);sin(alpha)*sin(beta)*sin(gamma)+cos(alpha)*cos(gamma);cos(beta)*sin(gamma);0];
T(1:4,3)=[cos(alpha)*sin(beta)*cos(gamma)+sin(alpha)*sin(gamma);sin(alpha)*sin(beta)*cos(gamma)-cos(alpha)*sin(gamma);cos(beta)*cos(gamma);0];
T(1:4,4)=[xr;yr;zr;1];
retvars(1:24)=zeros(24,1);
retvars(1:4) =T*Pb1-Pc1-rB(1)*n1;
retvars(4:7) =T*Pb1-Pc2-rB(2)*n2;
retvars(7:10) =T*Pb2-Pc3-rB(3)*n3;
retvars(10:13)=T*Pb2-Pc4-rB(4)*n4;
retvars(13:16)=T*Pb3-Pc5-rB(5)*n5;
retvars(16:19)=T*Pb4-Pc6-rB(6)*n6;
retvars(19)=TG11_G(3,4)+1/TG11_G(3,3)*(TG11_G(1,3)*(TG11_G(1,4)-Pc1(1))+TG11_G(2,3)*(TG11_G(2,4)-Pc1(2)))-Pc1(3);
retvars(20)=TG12_G(3,4)+1/TG12_G(3,3)*(TG12_G(1,3)*(TG12_G(1,4)-Pc2(1))+TG12_G(2,3)*(TG12_G(2,4)-Pc2(2)))-Pc2(3);
retvars(21)=TG21_G(3,4)+1/TG21_G(3,3)*(TG21_G(1,3)*(TG21_G(1,4)-Pc3(1))+TG21_G(2,3)*(TG21_G(2,4)-Pc3(2)))-Pc3(3);
retvars(22)=TG22_G(3,4)+1/TG22_G(3,3)*(TG22_G(1,3)*(TG22_G(1,4)-Pc4(1))+TG22_G(2,3)*(TG22_G(2,4)-Pc4(2)))-Pc4(3);
retvars(23)=TG31_G(3,4)+1/TG31_G(3,3)*(TG31_G(1,3)*(TG31_G(1,4)-Pc5(1))+TG31_G(2,3)*(TG31_G(2,4)-Pc5(2)))-Pc5(3);
retvars(24)=TG32_G(3,4)+1/TG32_G(3,3)*(TG32_G(1,3)*(TG32_G(1,4)-Pc6(1))+TG32_G(2,3)*(TG32_G(2,4)-Pc6(2)))-Pc6(3);
retvars=retvars';
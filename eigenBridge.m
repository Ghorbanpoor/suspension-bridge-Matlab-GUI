function [fn,phi,phi_cables] = eigenBridge(Bridge,Ncoeff)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                   GOAL
% 
% Computation of a suspension bridge mode shape and eigen-frequency. 
% It is designed to be fast, even if it is less
% reliable than a FEM analysis.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%                                   INPUT:

% Bridge: type: structure (see file studyCase.m)
% Ncoeff: type: float [1 x 1] : number of "coefficients"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%                                   OUTPUT:

% fn: type: 2D matrix [3 x Nmodes] : eigen-modes of the suspension bridge
% fn(1,:) --> all the eigen-frequencies for the lateral displacement ( x axis)
% fn(2,:) --> all the eigen-frequencies for the vertical displacement ( z axis)
% fn(3,:) --> all the eigen-frequencies for the torsional angle (around y axis)

% phi: type: 3D matrix [3 x Nmodes x Nyy] : modes shapes of the bridge girder ( =deck)
% phi(1,i,:) --> mode shape for the i-th eigen frequency for the lateral bridge displacement ( x axis)
% phi(2,i,:) --> mode shape for the i-th eigen frequency for the vertical bridge displacement  ( z axis)
% phi(3,i,:) --> mode shape for the i-th eigen frequency for the torsional bridge angle (around y axis)

% phi_cables: type: 2D matrix [Nmodes x Nyy] : modes shapes of the bridge main cables
% phi(i,:) --> mode shape for the i-th eigen frequency for the lateral cable displacements ( x axis)
% No mode-shapes for displacements along z axis, or in torsion

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




% INITIALISATION

% preallocation
Nyy = Bridge.Nyy;
fn = zeros(3,Ncoeff); % eigen frequency matrix
phi = zeros(3,Ncoeff,Nyy); % mode shapes of bridge girder
phi_cables = zeros(Ncoeff,Nyy); % mode shapes of cables

% discretisation of bridge span
x = linspace(0,Bridge.L,Nyy); % vector bridge span
x = x./Bridge.L ;% reduced length

%--------------------------------------------------------------------------
%-----------------------  LATERAL BRIDGE DISPLACEMENT ---------------------
%--------------------------------------------------------------------------

% INITIALISATION
alpha = zeros(2*Ncoeff,2*Ncoeff); % reduced variable
beta = zeros(2*Ncoeff,2*Ncoeff); % reduced variable
gamma = zeros(2*Ncoeff,2*Ncoeff); % reduced variable

m_tilt= Bridge.m;
mc_tilt = 2.*Bridge.mc;

%% calculation of alpha, beta and gamma
% alpha and beta
% cf E.N. Strømmen "STRUCTURAL DYNAMICS" for explanations
for nn=1:2*Ncoeff,
    alpha(nn,nn) = (Bridge.E.*Bridge.Iz).*(nn*pi./Bridge.L).^4;
    beta(nn,nn) = 2*Bridge.H_cable.*(nn*pi./Bridge.L).^2; 
end

% gamma
% cf E.N. Strømmen "STRUCTURAL DYNAMICS" for explanations
for pp=1:2*Ncoeff,
    for nn=1:2*Ncoeff,
        if and(rem(pp,2)==1,rem(nn,2)==0)||and(rem(pp,2)==0,rem(nn,2)==1)
            gamma(pp,nn)=0;
        else
            gamma(pp,nn)= 2*Bridge.m*Bridge.g/(Bridge.L*Bridge.ec).*trapz(x.*Bridge.L,sin(pp.*pi.*x).*sin(nn.*pi.*x)./...
                (1+Bridge.hm/Bridge.ec-4.*(x).*(1-x)));
        end
    end
end

% matrix mass
M = diag(repmat([m_tilt;mc_tilt],[Ncoeff,1]));

% Matrix stifness K
for p=1:2:2*Ncoeff,
    for nn=1:2:2*Ncoeff,
        if p==nn,
               clear Omega
               Omega(1,1) = alpha((p+1)/2,(nn+1)/2)+gamma((p+1)/2,(nn+1)/2);
               Omega(1,2) = -gamma((p+1)/2,(nn+1)/2);
               Omega(2,1) = -gamma((p+1)/2,(nn+1)/2);
               Omega(2,2) = beta((p+1)/2,(nn+1)/2)+gamma((p+1)/2,(nn+1)/2);
               K(p:p+1,nn:nn+1) = Omega;
        else
               clear V
               V = gamma((p+1)/2,(nn+1)/2).*[1,-1;-1,1];
               K(p:p+1,nn:nn+1) = V;
        end
    end
end

% eigen-value problem solved for non-trivial solutions
[vector,lambda]=eig(K,M,'chol');

fn(1,:) = sqrt(diag(lambda(1:Ncoeff,1:Ncoeff))); % filling the matrix fn

for ii=1:Ncoeff,
    phi(1,ii,:) = vector(1:2:end,ii)'*sin([1:1:Ncoeff]'.*pi*x); % deck mode shape construction using series expansion
    phi_cables(ii,:) = vector(2:2:end,ii)'*sin([1:1:Ncoeff]'.*pi*x); % cables mode shape construction using series expansion
    phi_cables(ii,:) = phi_cables(ii,:)./max(abs(phi(1,ii,:))); % normalisation
    phi(1,ii,:) = phi(1,ii,:)./max(abs(phi(1,ii,:))); % normalisation
end


%--------------------------------------------------------------------------
%-----------------------  VERTICAL BRIDGE DISPLACEMENT ---------------------
%--------------------------------------------------------------------------

clear K M
% INITIALISATION
kappa = zeros(Ncoeff,Ncoeff); %reduced variable
lambda = zeros(Ncoeff,Ncoeff); %reduced variable
mu = zeros(Ncoeff,Ncoeff); %reduced variable

le = Bridge.L*(1+8*(Bridge.ec/Bridge.L)^2); % effective length 
% cf page 124  "STRUCTURAL DYNAMICS" of E.N. Strømmen



for nn=1:Ncoeff,
    kappa(nn,nn) = Bridge.E*Bridge.Iy.*(nn*pi./Bridge.L).^4;
    lambda(nn,nn) = 2*Bridge.H_cable.*(nn*pi./Bridge.L).^2;
end

for p=1:Ncoeff,
    for nn=1:Ncoeff,
        if and(rem(p,2)==1,rem(nn,2)==1) % sont impaires
            mu(p,nn)=(32*Bridge.ec/(pi*Bridge.L)).^2*(Bridge.Ec*Bridge.Ac)/(Bridge.L*le)/(p*nn);
        else
            mu(p,nn)= 0;
        end
    end
end

M  = (2*Bridge.mc+Bridge.m).*eye(Ncoeff); % mass matrix
K= kappa+lambda +mu; % stifness matrix


% eigen-value problem solved for non-trivial solutions
[vector,lambda]=eig(K,M,'chol');

fn(2,:) = sqrt(diag(lambda(1:Ncoeff,1:Ncoeff))); % filling of matrix fn

for ii=1:Ncoeff,
    phi(2,ii,:) = vector(1:Ncoeff,ii)'*sin([1:Ncoeff]'.*pi*x); % mode shape construction using series expansion
    phi(2,ii,:) = phi(2,ii,:)./max(abs(phi(2,ii,:))); % normalisation
end





%--------------------------------------------------------------------------
%-----------------------  TORSIONAL BRIDGE DISPLACEMENT -------------------
%--------------------------------------------------------------------------

clear K M
% INITIALISATION

omega = zeros(Ncoeff,Ncoeff);
v = zeros(Ncoeff,Ncoeff);
V = zeros(Ncoeff,Ncoeff);
xi = zeros(Ncoeff,Ncoeff);
m_tilt_theta_tot = zeros(Ncoeff,Ncoeff);
m_tilt = 2*Bridge.mc+Bridge.m;


m_theta_tot = Bridge.m_theta + Bridge.mc*(Bridge.bc^2/2);

for nn=1:Ncoeff,
    omega(nn,nn) = (nn*pi./Bridge.L).^2.*(Bridge.GIt+(nn*pi/Bridge.L)^2*(Bridge.E*Bridge.Iw));
    V(nn,nn) = Bridge.H_cable * (Bridge.bc^2/2)*(nn*pi./Bridge.L).^2;
    v(nn,nn) = (m_tilt)*Bridge.g*Bridge.hr;
    m_tilt_theta_tot(nn,nn) = m_theta_tot;
end

for p=1:Ncoeff,
    for nn=1:Ncoeff,
        if and(rem(p,2)==1,rem(nn,2)==1) % sont impaires
            xi(p,nn)=(16*Bridge.ec*Bridge.bc/(pi*Bridge.L)).^2*Bridge.Ec*Bridge.Ac/(Bridge.L*le)*1/(p*nn);
        else
            xi(p,nn)= 0;
        end
    end
end


K= omega+V+v+xi; % stifness matrix
M =  diag(diag(m_tilt_theta_tot)); % mass matrix

% eigen-value problem solved for non-trivial solutions
[vector,lambda]=eig(K,M,'chol');
fn(3,:) = sqrt(diag(lambda(1:Ncoeff,1:Ncoeff))); % filling the fn matrix

for ii=1:Ncoeff,
    phi(3,ii,:) = vector(1:Ncoeff,ii)'*sin([1:Ncoeff]'.*pi*x); % mode shape construction using series expansion
    phi(3,ii,:) = phi(3,ii,:)./max(abs(phi(3,ii,:))); % normalisation
end

end


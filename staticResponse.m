function [Displ] = staticResponse(Bridge,Wind)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% GOAL:
%  Calculate the static response of a suspension bridge assimilated to a
%  1-DOF system

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INPUT:
% two structures field: Bridge and Wind.

% Bridge: structure: all the bridge properties defined in the MAIN files
% Bridge =
%
%           B: [1x1  double]
%           D: [1x1  double]
%           L: [1x1  double]
%         Nyy: [1x1  double]
%           x: [1x30 double]
%           E: [1x1  double]
%          Ec: [1x1  double]
%          Ac: [1x1  double]
%           g: [1x1  double]
%           m: [1x1  double]
%          mc: [1x1  double]
%          ec: [1x1  double]
%          hm: [1x1  double]
%          hr: [1x1  double]
%          bc: [1x1  double]
%     H_cable: [1x1  double]
%          Cd: [1x1  double]
%         dCd: [1x1  double]
%          Cl: [1x1  double]
%         dCl: [1x1  double]
%          Cm: [1x1  double]
%         dCm: [1x1  double]
%          Iz: [1x1  double]
%          Iy: [1x1  double]
%     m_theta: [1x1  double]
%          Iw: [1x1  double]
%         GIt: [1x1  double]
%         DOF: string
%          wn: [1x12 double]
%         phi: [12x30 double]

% Wind :structure:Static wind properties defined in the MAIN files
% Wind =
%
%     U: [1x1  double]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% OUTPUT: Displ: vector [ 1 x Nyy] : static displacement at Nyy positions
% along the bridge deck

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  last updated: Etienne Cheynet 13.12.2015

%% check inputs
if ~isstruct(Bridge), error('"Bridge" must be a structure !'); end
if ~isstruct(Wind), error('"Wind" must be a structure !'); end

name = [{'B'},...
    {'D'},...
    {'L'},...
    {'Nyy'},...
    {'x'},...
    {'E'},...
    {'Ec'},...
    {'Ac'},...
    {'g'},...
    {'m'},...
    {'mc'},...
    {'ec'},...
    {'hm'},...
    {'hr'},...
    {'bc'},...
    {'H_cable'},...
    {'Cd'},...
    {'dCd'},...
    {'Cl'},...
    {'dCl'},...
    {'Cm'},...
    {'dCm'},...
    {'Iz'},...
    {'Iy'},...
    {'m_theta'},...
    {'Iw'},...
    {'GIt'},...
    {'DOF'},...
    {'wn'},...
    {'phi'}];

for ii=1:numel(name),
    if ~isfield(Bridge,name{ii}),
        error([' The field ',name{ii},' is missing in the structure "Bridge".'])
    end
end

if ~isfield(Wind,'U'),
    error([' The field "U" is missing in the structure "Wind".'])
end

if numel(Wind.U)>1,
    error('Wind.U must be of sie [1x1]')
end




%%
% density of air
rho = 1.25;
% get number of discrete point along girder
Nyy = numel(Bridge.x); %
% get number of mode shapes
Nmodes = numel(Bridge.wn);

switch Bridge.DOF,
    case 'lateral',
        Mtot = Bridge.m+2*Bridge.mc; % total mass of deck along y axis
        M_modal = diag(trapz(Bridge.x.*Bridge.L,Mtot.*Bridge.phi.^2,2)); % size is [Nmodes x Nmodes]
        K_modal = diag(Bridge.wn).^2.*M_modal; % size is [Nmodes x Nmodes]
        Kae_modal = zeros(Nmodes);
        Faero = diag(trapz(Bridge.x.*Bridge.L,1/2*rho*Bridge.D.*(Wind.U^2).*Bridge.Cd.*Bridge.phi,2));% size is [Nmodes x Nmodes]
        Displ_modal = diag(K_modal\Faero);
        Displ_modal = Displ_modal(:)';
        Displ = zeros(1,Nyy);
        
    case 'vertical',
        Mtot = Bridge.m+2*Bridge.mc; % total mass of deck along y axis
        M_modal = diag(trapz(Bridge.x.*Bridge.L,Mtot.*Bridge.phi.^2,2)); % size is [Nmodes x Nmodes]
        K_modal = diag(Bridge.wn).^2.*M_modal; % size is [Nmodes x Nmodes]
        Kae_modal = zeros(Nmodes);
        Faero = diag(trapz(Bridge.x.*Bridge.L,1/2*rho*Bridge.B.*(Wind.U^2).*Bridge.Cl.*Bridge.phi,2));
        Displ_modal = diag(K_modal\Faero);
        Displ_modal = Displ_modal(:)';
        Displ = zeros(1,Nyy);
        
    case 'torsional',
        Mtot = Bridge.m_theta;
        M_modal = diag(trapz(Bridge.x.*Bridge.L,Mtot.*Bridge.phi.^2,2)); % size is [Nmodes x Nmodes]
        K_modal = diag(Bridge.wn).^2.*M_modal; % size is [Nmodes x Nmodes]
        Kae_modal = diag(trapz(Bridge.x.*Bridge.L,1/2*rho*(Bridge.B^2).*(Wind.U^2).*Bridge.dCm.*Bridge.phi.^2,2)); % size is [Nmodes x Nmodes]
        Faero = diag(trapz(Bridge.x.*Bridge.L,1/2*rho*(Bridge.B^2).*(Wind.U^2).*Bridge.Cm.*Bridge.phi,2));
    otherwise
        error(' the field "DOF" is not recognized. Choose between "lateral","vertical" or "torsional"')
end



if any(diag(K_modal-Kae_modal)<0), % case where torsional divergence is reached
    fprintf(['Ucr = ',num2str(Wind.U,4),' m/s. Static torsional divergence is reached \n']);
    Displ = inf;
else
    Displ_modal = diag((K_modal-Kae_modal)\Faero);
    Displ_modal = Displ_modal(:)';
    Displ = zeros(1,Nyy);
    for ii=1:Nyy,
        Displ(ii) =Displ_modal*Bridge.phi(:,ii);
    end
end
end
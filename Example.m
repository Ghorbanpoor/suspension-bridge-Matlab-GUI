%% Example with a single span suspension bridge
% No coupling is introduced here, to keep calculations simple.

clear all;close all;clc;

%% Get the structural properties of the bridge
run('LysefjordBridge.m');
%% Get the eigen-frequencies and mode shapes
% call of the function "eigenBridge".
Ncoef= 20;
[wn,phi,~] = eigenBridge(Bridge,Ncoef);
% wn: eigen frequencies (rad/s)
% phi: mode shapes of the deck
%% Lateral static response
clear Wind
Wind.U = 20; % mean wind speed
Bridge.DOF = 'lateral';
 % eigen frequencies computed previously for lateral component
Bridge.wn = wn(1,:);
 % mode shapes computed previously for lateral component
Bridge.phi = squeeze(phi(1,:,:));
[Dox] = staticResponse(Bridge,Wind);

figure
hold on
plot(Bridge.x.*Bridge.L,Dox)
xlim([0,Bridge.L]);
xlabel('span (m)');
ylabel('Lateral static displacement (m)');box on
set(gcf,'color','w');


%% Vertical  static response
clear Wind
Wind.U = 20; % mean wind speed
% modification of Input:
Bridge.DOF = 'vertical';
% eigen frequencies computed previously for lateral component
Bridge.wn = wn(2,:); 
 % mode shapes computed previously for lateral component
Bridge.phi = squeeze(phi(2,:,:));
[Doz] = staticResponse(Bridge,Wind);


figure
hold on
plot(Bridge.x.*Bridge.L,Doz)
xlim([0,Bridge.L]);
xlabel(' span (m)');
ylabel('Vertical static displacement (m)');box on
set(gcf,'color','w');


%% Torsional  static response
clear Wind
Wind.U = 20; % mean wind speed
Bridge.DOF = 'torsional';
% eigen frequencies computed previously for lateral component
Bridge.wn = wn(3,:); 
% mode shapes computed previously for lateral component
Bridge.phi = squeeze(phi(3,:,:)); 
[Dot] = staticResponse(Bridge,Wind);

figure
hold on
plot(Bridge.x.*Bridge.L,180/pi.*Dot)
xlim([0,Bridge.L]);
xlabel(' span (m)');
ylabel('Torsional static displacement (^o)');
legend('Dot','location','south')
box on
set(gcf,'color','w');

%% Torsional static divergence (Ucr = 188 m/s)

U = linspace(0,188,100);
Dot_torsDiv = zeros(numel(U),Bridge.Nyy);

for ii=1:numel(U),
    Wind.U = U(ii); % mean wind speed
    [Dot_torsDiv(ii,:)] = staticResponse(Bridge,Wind);
end
figure
plot(U,180/pi.*Dot_torsDiv(:,15))
ylim([0,10]);
xlabel(' U (m/s)');
ylabel('Torsional static displacement (^o)');
box on
set(gcf,'color','w');

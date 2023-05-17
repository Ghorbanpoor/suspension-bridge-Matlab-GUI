function varargout = Lysefjord_Bridge(varargin)
% LYSEFJORD_BRIDGE MATLAB code for Lysefjord_Bridge.fig
%      LYSEFJORD_BRIDGE, by itself, creates a new LYSEFJORD_BRIDGE or raises the existing
%      singleton*.
%
%      H = LYSEFJORD_BRIDGE returns the handle to a new LYSEFJORD_BRIDGE or the handle to
%      the existing singleton*.
%
%      LYSEFJORD_BRIDGE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LYSEFJORD_BRIDGE.M with the given input arguments.
%
%      LYSEFJORD_BRIDGE('Property','Value',...) creates a new LYSEFJORD_BRIDGE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Lysefjord_Bridge_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Lysefjord_Bridge_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Lysefjord_Bridge

% Last Modified by GUIDE v2.5 23-Apr-2023 23:53:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Lysefjord_Bridge_OpeningFcn, ...
                   'gui_OutputFcn',  @Lysefjord_Bridge_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Lysefjord_Bridge is made visible.
function Lysefjord_Bridge_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Lysefjord_Bridge (see VARARGIN)

% Choose default command line output for Lysefjord_Bridge
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Lysefjord_Bridge wait for user response (see UIRESUME)
% uiwait(handles.figure1);


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


axes(handles.axes1)
cla(handles.axes1,'reset')
hold on
plot(Bridge.x.*Bridge.L,Dox)
xlim([0,Bridge.L]);
xlabel('span (m)');
ylabel('Lateral static displacement (m)');box on
% set(gcf,'color','w');


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


axes(handles.axes2)
cla(handles.axes2,'reset')
hold on
plot(Bridge.x.*Bridge.L,Doz)
xlim([0,Bridge.L]);
xlabel(' span (m)');
ylabel('Vertical static displacement (m)');box on
% set(gcf,'color','w');


%% Torsional  static response
clear Wind
Wind.U = 20; % mean wind speed
Bridge.DOF = 'torsional';
% eigen frequencies computed previously for lateral component
Bridge.wn = wn(3,:); 
% mode shapes computed previously for lateral component
Bridge.phi = squeeze(phi(3,:,:)); 
[Dot] = staticResponse(Bridge,Wind);

axes(handles.axes3)
cla(handles.axes3,'reset')
hold on
plot(Bridge.x.*Bridge.L,180/pi.*Dot)
xlim([0,Bridge.L]);
xlabel(' span (m)');
ylabel('Torsional static displacement (^o)');
legend('Dot','location','south')
% box on
% set(gcf,'color','w');

%% Torsional static divergence (Ucr = 188 m/s)

U = linspace(0,188,100);
Dot_torsDiv = zeros(numel(U),Bridge.Nyy);

for ii=1:numel(U)
    Wind.U = U(ii); % mean wind speed
    [Dot_torsDiv(ii,:)] = staticResponse(Bridge,Wind);
end
axes(handles.axes4)
cla(handles.axes4,'reset')
plot(U,180/pi.*Dot_torsDiv(:,15))
ylim([0,10]);
xlabel(' U (m/s)');
ylabel('Torsional static displacement (^o)');
% box on
% set(gcf,'color','w');



% --- Outputs from this function are returned to the command line.
function varargout = Lysefjord_Bridge_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit25_Callback(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit25 as text
%        str2double(get(hObject,'String')) returns contents of edit25 as a double


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% definition of the suspension Bridge that include many of its
% characteristics. The variable Bridge is a structure with the fields
% described below
% GENERAL INPUTS
Bridge.B = eval(get(handles.edit1,'String')); % deck width
Bridge.D = eval(get(handles.edit2,'String')); % Deck height
Bridge.L = eval(get(handles.edit3,'String'));  % length of main span (m) *
Bridge.Nyy=eval(get(handles.edit4,'String'));% Discretisation of bridge main span in Nyy points
Bridge.x = linspace(0,1,Bridge.Nyy); % discretisation of bridge axis into normalized coordinates


Bridge.E = eval(get(handles.edit5,'String')); % young modulus steel (Pa) *
Bridge.Ec = eval(get(handles.edit6,'String')); % young modulus steel (Pa) *
Bridge.Ac = eval(get(handles.edit7,'String')) ;% cross section main cable (m^2) *    
Bridge.g = eval(get(handles.edit8,'String'));
Bridge.m =eval(get(handles.edit9,'String')) ; % lineic mass of girder (kg/m)*
Bridge.mc =eval(get(handles.edit10,'String')); % lineic mass of cable (kg/m)*
Bridge.ec= eval(get(handles.edit11,'String')); % sag (m)*
Bridge.hm = eval(get(handles.edit12,'String')) ; % hanger length at mid span (m)*
Bridge.hr =eval(get(handles.edit13,'String')); % distance between shear center and hanger attachment
Bridge.bc = eval(get(handles.edit14,'String')); % distance betweem main cable (m)     
Bridge.H_cable = Bridge.m*Bridge.g*Bridge.L^2/(16*Bridge.ec)*(1+2*Bridge.mc/Bridge.m*(1+4/3*(Bridge.ec/Bridge.L)^2));


% aerodynamic coefficient (quasi steady terms)
Bridge.Cd = eval(get(handles.edit15,'String'));% drag coefficient
Bridge.dCd = eval(get(handles.edit16,'String'));% first derivative of drag coefficient

Bridge.Cl = eval(get(handles.edit17,'String'));% lift coefficient
Bridge.dCl = eval(get(handles.edit18,'String'));% first derivative of lift coefficient

Bridge.Cm = eval(get(handles.edit19,'String'));% pitching moment coefficient
Bridge.dCm = eval(get(handles.edit20,'String'));% first derivative of pitching moment coefficient

Ncoef=eval(get(handles.edit21,'String')); % The number of coefficients provides a high number gives a more accurate solutio
% modal structural damping ratio for the  Bridge deck:
% here, for simplicity, it is taken as equal to 0.5 % for all modes and all DOFs
zetaStruct = 5e-3.*ones(3,Ncoef);

% ADDITIONAL INPUTS FOR LATERAL MODES
Bridge.Iz = eval(get(handles.edit22,'String')); % Moment of inertia with respect to bending about y axis (used for lateral bridge analysis)

% ADDITIONAL INPUTS FOR VERTICAL MODES
Bridge.Iy = eval(get(handles.edit23,'String')); % Moment of inertia with respect to bending about z axis (used for vertical bridge analysis)

% ADDITIONAL INPUTS FOR TORSIONAL MODES
Bridge.m_theta = eval(get(handles.edit24,'String')); %kg.m^2/m*
Bridge.Iw = eval(get(handles.edit25,'String')); % WARPING RESISTANCE   
Bridge.GIt = eval(get(handles.edit26,'String')); % TORSIONAL STIFFNESS 



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

axes(handles.axes1)
cla(handles.axes1,'reset')
hold on
plot(Bridge.x.*Bridge.L,Dox)
xlim([0,Bridge.L]);
xlabel('span (m)');
ylabel('Lateral static displacement (m)');box on
% set(gcf,'color','w');


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


axes(handles.axes2)
cla(handles.axes2,'reset')
hold on
plot(Bridge.x.*Bridge.L,Doz)
xlim([0,Bridge.L]);
xlabel(' span (m)');
ylabel('Vertical static displacement (m)');box on
% set(gcf,'color','w');


%% Torsional  static response
clear Wind
Wind.U = 20; % mean wind speed
Bridge.DOF = 'torsional';
% eigen frequencies computed previously for lateral component
Bridge.wn = wn(3,:); 
% mode shapes computed previously for lateral component
Bridge.phi = squeeze(phi(3,:,:)); 
[Dot] = staticResponse(Bridge,Wind);

axes(handles.axes3)
cla(handles.axes3,'reset')
hold on
plot(Bridge.x.*Bridge.L,180/pi.*Dot)
xlim([0,Bridge.L]);
xlabel(' span (m)');
ylabel('Torsional static displacement (^o)');
legend('Dot','location','south')
% box on
% set(gcf,'color','w');

%% Torsional static divergence (Ucr = 188 m/s)

U = linspace(0,188,100);
Dot_torsDiv = zeros(numel(U),Bridge.Nyy);

for ii=1:numel(U)
    Wind.U = U(ii); % mean wind speed
    [Dot_torsDiv(ii,:)] = staticResponse(Bridge,Wind);
end
axes(handles.axes4)
cla(handles.axes4,'reset')
plot(U,180/pi.*Dot_torsDiv(:,15))
ylim([0,10]);
xlabel(' U (m/s)');
ylabel('Torsional static displacement (^o)');
% box on
% set(gcf,'color','w');


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.edit1,'String',num2str('12.3'));
set(handles.edit2,'String',num2str('2.76'));
set(handles.edit3,'String',num2str('446'));
set(handles.edit4,'String',num2str('30'));
set(handles.edit5,'String',num2str('210000e6'));
set(handles.edit6,'String',num2str('180000e6'));
set(handles.edit7,'String',num2str('0.038'));
set(handles.edit8,'String',num2str('9.81'));
set(handles.edit9,'String',num2str('5350'));
set(handles.edit10,'String',num2str('408'));
set(handles.edit11,'String',num2str('45'));
set(handles.edit12,'String',num2str('3'));
set(handles.edit13,'String',num2str('0.400'));
set(handles.edit14,'String',num2str('10.2500'));
set(handles.edit15,'String',num2str('1'));
set(handles.edit16,'String',num2str('0'));
set(handles.edit17,'String',num2str('0.1'));
set(handles.edit18,'String',num2str('3'));
set(handles.edit19,'String',num2str('0.02'));
set(handles.edit20,'String',num2str('1.12'));
set(handles.edit21,'String',num2str('12'));
set(handles.edit22,'String',num2str('4.952'));
set(handles.edit23,'String',num2str('0.429'));
set(handles.edit24,'String',num2str('82430'));
set(handles.edit25,'String',num2str('4.7619'));
set(handles.edit26,'String',num2str('0.75e11'));


% definition of the suspension Bridge that include many of its
% characteristics. The variable Bridge is a structure with the fields
% described below
% GENERAL INPUTS
Bridge.B = eval(get(handles.edit1,'String')); % deck width
Bridge.D = eval(get(handles.edit2,'String')); % Deck height
Bridge.L = eval(get(handles.edit3,'String'));  % length of main span (m) *
Bridge.Nyy=eval(get(handles.edit4,'String'));% Discretisation of bridge main span in Nyy points
Bridge.x = linspace(0,1,Bridge.Nyy); % discretisation of bridge axis into normalized coordinates


Bridge.E = eval(get(handles.edit5,'String')); % young modulus steel (Pa) *
Bridge.Ec = eval(get(handles.edit6,'String')); % young modulus steel (Pa) *
Bridge.Ac = eval(get(handles.edit7,'String')) ;% cross section main cable (m^2) *    
Bridge.g = eval(get(handles.edit8,'String'));
Bridge.m =eval(get(handles.edit9,'String')) ; % lineic mass of girder (kg/m)*
Bridge.mc =eval(get(handles.edit10,'String')); % lineic mass of cable (kg/m)*
Bridge.ec= eval(get(handles.edit11,'String')); % sag (m)*
Bridge.hm = eval(get(handles.edit12,'String')) ; % hanger length at mid span (m)*
Bridge.hr =eval(get(handles.edit13,'String')); % distance between shear center and hanger attachment
Bridge.bc = eval(get(handles.edit14,'String')); % distance betweem main cable (m)     
Bridge.H_cable = Bridge.m*Bridge.g*Bridge.L^2/(16*Bridge.ec)*(1+2*Bridge.mc/Bridge.m*(1+4/3*(Bridge.ec/Bridge.L)^2));


% aerodynamic coefficient (quasi steady terms)
Bridge.Cd = eval(get(handles.edit15,'String'));% drag coefficient
Bridge.dCd = eval(get(handles.edit16,'String'));% first derivative of drag coefficient

Bridge.Cl = eval(get(handles.edit17,'String'));% lift coefficient
Bridge.dCl = eval(get(handles.edit18,'String'));% first derivative of lift coefficient

Bridge.Cm = eval(get(handles.edit19,'String'));% pitching moment coefficient
Bridge.dCm = eval(get(handles.edit20,'String'));% first derivative of pitching moment coefficient

Ncoef=eval(get(handles.edit21,'String')); % The number of coefficients provides a high number gives a more accurate solutio
% modal structural damping ratio for the  Bridge deck:
% here, for simplicity, it is taken as equal to 0.5 % for all modes and all DOFs
zetaStruct = 5e-3.*ones(3,Ncoef);

% ADDITIONAL INPUTS FOR LATERAL MODES
Bridge.Iz = eval(get(handles.edit22,'String')); % Moment of inertia with respect to bending about y axis (used for lateral bridge analysis)

% ADDITIONAL INPUTS FOR VERTICAL MODES
Bridge.Iy = eval(get(handles.edit23,'String')); % Moment of inertia with respect to bending about z axis (used for vertical bridge analysis)

% ADDITIONAL INPUTS FOR TORSIONAL MODES
Bridge.m_theta = eval(get(handles.edit24,'String')); %kg.m^2/m*
Bridge.Iw = eval(get(handles.edit25,'String')); % WARPING RESISTANCE   
Bridge.GIt = eval(get(handles.edit26,'String')); % TORSIONAL STIFFNESS 



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

axes(handles.axes1)
cla(handles.axes1,'reset')
hold on
plot(Bridge.x.*Bridge.L,Dox)
xlim([0,Bridge.L]);
xlabel('span (m)');
ylabel('Lateral static displacement (m)');box on
% set(gcf,'color','w');


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


axes(handles.axes2)
cla(handles.axes2,'reset')
hold on
plot(Bridge.x.*Bridge.L,Doz)
xlim([0,Bridge.L]);
xlabel(' span (m)');
ylabel('Vertical static displacement (m)');box on
% set(gcf,'color','w');


%% Torsional  static response
clear Wind
Wind.U = 20; % mean wind speed
Bridge.DOF = 'torsional';
% eigen frequencies computed previously for lateral component
Bridge.wn = wn(3,:); 
% mode shapes computed previously for lateral component
Bridge.phi = squeeze(phi(3,:,:)); 
[Dot] = staticResponse(Bridge,Wind);

axes(handles.axes3)
cla(handles.axes3,'reset')
hold on
plot(Bridge.x.*Bridge.L,180/pi.*Dot)
xlim([0,Bridge.L]);
xlabel(' span (m)');
ylabel('Torsional static displacement (^o)');
legend('Dot','location','south')
% box on
% set(gcf,'color','w');

%% Torsional static divergence (Ucr = 188 m/s)

U = linspace(0,188,100);
Dot_torsDiv = zeros(numel(U),Bridge.Nyy);

for ii=1:numel(U)
    Wind.U = U(ii); % mean wind speed
    [Dot_torsDiv(ii,:)] = staticResponse(Bridge,Wind);
end
axes(handles.axes4)
cla(handles.axes4,'reset')
plot(U,180/pi.*Dot_torsDiv(:,15))
ylim([0,10]);
xlabel(' U (m/s)');
ylabel('Torsional static displacement (^o)');
% box on
% set(gcf,'color','w');



% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


set(handles.edit1,'String',num2str(''));
set(handles.edit2,'String',num2str(''));
set(handles.edit3,'String',num2str(''));
set(handles.edit4,'String',num2str(''));
set(handles.edit5,'String',num2str(''));
set(handles.edit6,'String',num2str(''));
set(handles.edit7,'String',num2str(''));
set(handles.edit8,'String',num2str(''));
set(handles.edit9,'String',num2str(''));
set(handles.edit10,'String',num2str(''));
set(handles.edit11,'String',num2str(''));
set(handles.edit12,'String',num2str(''));
set(handles.edit13,'String',num2str(''));
set(handles.edit14,'String',num2str(''));
set(handles.edit15,'String',num2str(''));
set(handles.edit16,'String',num2str(''));
set(handles.edit17,'String',num2str(''));
set(handles.edit18,'String',num2str(''));
set(handles.edit19,'String',num2str(''));
set(handles.edit20,'String',num2str(''));
set(handles.edit21,'String',num2str(''));
set(handles.edit22,'String',num2str(''));
set(handles.edit23,'String',num2str(''));
set(handles.edit24,'String',num2str(''));
set(handles.edit25,'String',num2str(''));
set(handles.edit26,'String',num2str(''));


axes(handles.axes1)
cla(handles.axes1,'reset')
axis on
grid on
xlabel('span (m)');
ylabel('Lateral static displacement (m)');

axes(handles.axes2)
cla(handles.axes2,'reset')
axis on
grid on
xlabel(' span (m)');
ylabel('Vertical static displacement (m)');

axes(handles.axes3)
cla(handles.axes3,'reset')
axis on
grid on
xlabel(' span (m)');
ylabel('Torsional static displacement (^o)');
legend('Dot','location','south')

axes(handles.axes4)
cla(handles.axes4,'reset')
axis on
grid on
xlabel(' U (m/s)');
ylabel('Torsional static displacement (^o)');



% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close

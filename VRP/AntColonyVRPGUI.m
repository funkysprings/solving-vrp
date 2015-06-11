function varargout = AntColonyVRPGUI(varargin)
% ANTCOLONYVRPGUI M-file for AntColonyVRPGUI.fig
%      ANTCOLONYVRPGUI, by itself, creates a new ANTCOLONYVRPGUI or raises the existing
%      singleton*.
%
%      H = ANTCOLONYVRPGUI returns the handle to a new ANTCOLONYVRPGUI or the handle to
%      the existing singleton*.
%
%      ANTCOLONYVRPGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANTCOLONYVRPGUI.M with the given input arguments.
%
%      ANTCOLONYVRPGUI('Property','Value',...) creates a new ANTCOLONYVRPGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AntColonyVRPGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AntColonyVRPGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AntColonyVRPGUI

% Last Modified by GUIDE v2.5 04-Jun-2015 15:52:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AntColonyVRPGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @AntColonyVRPGUI_OutputFcn, ...
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


% --- Executes just before AntColonyVRPGUI is made visible.
function AntColonyVRPGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AntColonyVRPGUI (see VARARGIN)

% Choose default command line output for AntColonyVRPGUI
handles.output = hObject;

%initialization
[vehicles,demands,dist_stations,dist_bases] = INIT();
handles.vehicles = vehicles;
handles.demands = demands;
handles.distances_stations = dist_stations;
handles.distances_bases = dist_bases;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AntColonyVRPGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AntColonyVRPGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in algorithmPopupmenu.
function algorithmPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to algorithmPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns algorithmPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from algorithmPopupmenu

%set invisible error messages
set(handles.errorMandatoryEditFields,'Visible','off');
%erase text in edit fields
set(handles.evaporationPheromoneEdit,'String','');
set(handles.attractStationEdit,'String','');
set(handles.increasePheromoneEdit,'String','');
set(handles.amountPheromoneEdit,'String','');
set(handles.eliteAntsEdit,'String','');
%set disabled all edit fields
set(handles.evaporationPheromoneEdit,'Enable','off');
set(handles.attractStationEdit,'Enable','off');
set(handles.increasePheromoneEdit,'Enable','off');
set(handles.amountPheromoneEdit,'Enable','off');
set(handles.eliteAntsEdit,'Enable','off');
%set disabled run button
set(handles.runButton,'Enable','off');
%set to 0 all results
set(handles.lengthWayText,'String','0');
set(handles.subroutesNText,'String','0');
set(handles.timeSpentText,'String','0');
%clear plot
cla;
%clear legend
legend('off');

val = get(hObject,'Value');
if val ~= 1 %not placeholder's text (not be executed)
    if val ~= 2 %not Clark-Wright algorithm
        %enable edit fields 
        if val == 5 %AntAlg with elite ants
            set(handles.eliteAntsEdit,'Enable','on');
        end
        set(handles.evaporationPheromoneEdit,'Enable','on');
        set(handles.attractStationEdit,'Enable','on');
        set(handles.increasePheromoneEdit,'Enable','on');
        set(handles.amountPheromoneEdit,'Enable','on');
    end
    %enable run button
    set(handles.runButton,'Enable','on');    
end


% --- Executes during object creation, after setting all properties.
function algorithmPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to algorithmPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function evaporationPheromoneEdit_Callback(hObject, eventdata, handles)
% hObject    handle to evaporationPheromoneEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of evaporationPheromoneEdit as text
%        str2double(get(hObject,'String')) returns contents of evaporationPheromoneEdit as a double


% --- Executes during object creation, after setting all properties.
function evaporationPheromoneEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to evaporationPheromoneEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function attractStationEdit_Callback(hObject, eventdata, handles)
% hObject    handle to attractStationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of attractStationEdit as text
%        str2double(get(hObject,'String')) returns contents of attractStationEdit as a double


% --- Executes during object creation, after setting all properties.
function attractStationEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to attractStationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function increasePheromoneEdit_Callback(hObject, eventdata, handles)
% hObject    handle to increasePheromoneEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of increasePheromoneEdit as text
%        str2double(get(hObject,'String')) returns contents of increasePheromoneEdit as a double


% --- Executes during object creation, after setting all properties.
function increasePheromoneEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to increasePheromoneEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function amountPheromoneEdit_Callback(hObject, eventdata, handles)
% hObject    handle to amountPheromoneEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of amountPheromoneEdit as text
%        str2double(get(hObject,'String')) returns contents of amountPheromoneEdit as a double


% --- Executes during object creation, after setting all properties.
function amountPheromoneEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amountPheromoneEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eliteAntsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to eliteAntsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eliteAntsEdit as text
%        str2double(get(hObject,'String')) returns contents of eliteAntsEdit as a double


% --- Executes during object creation, after setting all properties.
function eliteAntsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eliteAntsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in runButton.
function runButton_Callback(hObject, eventdata, handles)
% hObject    handle to runButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%clear legend
legend('off');
%clear plot
cla; 
%set invisible error messages
set(handles.errorMandatoryEditFields,'Visible','off');

indexAlg = get(handles.algorithmPopupmenu,'Value');
if indexAlg ~= 1 %not placeholder's text (not be executed)
    if indexAlg ~= 2 %not Clark-Wright algorithm
        if indexAlg == 5 %AntAlg with elite ants
            if isempty(get(handles.eliteAntsEdit,'String'))
                set(handles.errorMandatoryEditFields,'Visible','on');
                return;
            end
        end
        if  ( isempty(get(handles.evaporationPheromoneEdit,'String')) || ...
              isempty(get(handles.attractStationEdit,'String')) || ...
              isempty(get(handles.increasePheromoneEdit,'String')) || ...
              isempty(get(handles.amountPheromoneEdit,'String')) )
            
            set(handles.errorMandatoryEditFields,'Visible','on');
            return;
        end
    end
    %set disabled run button
    set(handles.runButton,'Enable','off');
    runAlgorithm(indexAlg, handles);
    %set enabled run button
    set(handles.runButton,'Enable','on');
    %set enabled zoom tools
    set(handles.toolZoomIn,'Enable','on');
    set(handles.toolZoomOut,'Enable','on');
    %set enabled pan tool
    set(handles.toolPan,'Enable','on');
    zoom reset;
end

function runAlgorithm(index, handles)
    if index ~= 1
        if index ~= 2
            e = str2double(get(handles.evaporationPheromoneEdit,'String'));
            alpha = str2double(get(handles.attractStationEdit,'String'));
            beta = str2double(get(handles.increasePheromoneEdit,'String'));
            tau0 = str2double(get(handles.amountPheromoneEdit,'String'));
            E = str2double(get(handles.eliteAntsEdit,'String'));
        end
        
        try
            tStart = tic; %start spent time
            switch index
                case 2 %Clark-Wright
                    [Route,RouteLength] = Clark_Wright_VRP( handles.demands, ...
                        handles.distances_stations, handles.distances_bases, handles.vehicles );
                case 3 %Ant-minpath
                    [Route,RouteLength] = ANT_colony_algorithm_VRP_minpath( handles.distances_stations,...
                        handles.distances_bases, handles.demands, [e alpha beta tau0], handles.vehicles);
                case 4 %Ant-partition
                    [Route,RouteLength] = ANT_colony_algorithm_VRP( handles.distances_stations, ...
                        handles.distances_bases, handles.demands, [e alpha beta tau0], handles.vehicles);
                case 5 %Ant-elite ants
                    [Route,RouteLength] = ANT_colony_algorithm_VRP_with_elite_ants( ...
                        handles.distances_stations, handles.distances_bases, handles.demands, ...
                        [e alpha beta tau0 E], handles.vehicles);
            end
            tElapsed = toc(tStart); %end spent time
        catch ME
            msgbox(strcat('Error occured: ',ME.message),'Error','error');
        end
        
        set(handles.lengthWayText,'String',num2str(RouteLength));
        set(handles.subroutesNText,'String',num2str(number_of_subroutes(Route)));
        set(handles.timeSpentText,'String',sprintf('%fs',tElapsed));
    end


% --------------------------------------------------------------------
function dataTooltip_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to dataTooltip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function algorithmTooltip_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to algorithmTooltip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

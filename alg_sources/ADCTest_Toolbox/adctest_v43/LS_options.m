function varargout = LS_options(varargin)
% LS_OPTIONS M-file for LS_options.fig
%      LS_OPTIONS, by itself, creates a new LS_OPTIONS or raises the existing
%      singleton*.
%
%      H = LS_OPTIONS returns the handle to a new LS_OPTIONS or the handle to
%      the existing singleton*.
%
%      LS_OPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LS_OPTIONS.M with the given input arguments.
%
%      LS_OPTIONS('Property','Value',...) creates a new LS_OPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LS_options_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LS_options_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LS_options

% Last Modified by GUIDE v2.5 02-Sep-2014 15:22:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LS_options_OpeningFcn, ...
                   'gui_OutputFcn',  @LS_options_OutputFcn, ...
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


% --- Executes just before LS_options is made visible.
function LS_options_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LS_options (see VARARGIN)

%Initialiying GUI objects
set(handles.popupmenu_initial_fr,'Value',1);
inital_fr_strings = get(handles.popupmenu_initial_fr,'String');
initial_fr_source = inital_fr_strings{get(handles.popupmenu_initial_fr,'Value')};
setappdata(get(0,'CurrentFigure'),'initial_fr_source',initial_fr_source);

set(handles.edit_initial_fr,'String','3.6241e-2');
initial_fr_value = str2double(get(handles.edit_initial_fr,'String'));
setappdata(get(0,'CurrentFigure'),'initial_fr_value',initial_fr_value);

set(handles.popupmenu_iteration_method,'Value',1);
iteration_method_strings = get(handles.popupmenu_iteration_method,'String');
iteration_method = iteration_method_strings{get(handles.popupmenu_iteration_method,'Value')};
setappdata(get(0,'CurrentFigure'),'iteration_method',iteration_method);

% Choose default command line output for LS_options
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LS_options wait for user response (see UIRESUME)
uiwait;


% --- Outputs from this function are returned to the command line.
function varargout = LS_options_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
initial_fr_source = getappdata(get(0,'CurrentFigure'),'initial_fr_source');
varargout{1} = initial_fr_source;
iteration_method = getappdata(get(0,'CurrentFigure'),'iteration_method');
varargout{2} = iteration_method;
initial_fr_value = getappdata(get(0,'CurrentFigure'),'initial_fr_value');
varargout{3} = initial_fr_value;
close(get(0,'CurrentFigure'));


% --- Executes on selection change in popupmenu_initial_fr.
function popupmenu_initial_fr_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_initial_fr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_initial_fr contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_initial_fr
inital_fr_strings = get(hObject,'String');
initial_fr_source = inital_fr_strings{get(hObject,'Value')};
setappdata(get(0,'CurrentFigure'),'initial_fr_source',initial_fr_source);


% --- Executes during object creation, after setting all properties.
function popupmenu_initial_fr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_initial_fr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_initial_fr_Callback(hObject, eventdata, handles)
% hObject    handle to edit_initial_fr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_initial_fr as text
%        str2double(get(hObject,'String')) returns contents of edit_initial_fr as a double
initial_fr_value = str2double(get(hObject,'String'));
setappdata(get(0,'CurrentFigure'),'initial_fr_value',initial_fr_value);


% --- Executes during object creation, after setting all properties.
function edit_initial_fr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_initial_fr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_iteration_method.
function popupmenu_iteration_method_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_iteration_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_iteration_method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_iteration_method
iteration_method_strings = get(hObject,'String');
iteration_method = iteration_method_strings{get(hObject,'Value')};
setappdata(get(0,'CurrentFigure'),'iteration_method',iteration_method);


% --- Executes during object creation, after setting all properties.
function popupmenu_iteration_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_iteration_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_OK.
function pushbutton_OK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;


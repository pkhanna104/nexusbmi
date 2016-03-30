function varargout = mini_bmi(varargin)
% MINI_BMI MATLAB code for mini_bmi.fig
%      MINI_BMI, by itself, creates a new MINI_BMI or raises the existing
%      singleton*.
%
%      H = MINI_BMI returns the handle to a new MINI_BMI or the handle to
%      the existing singleton*.
%
%      MINI_BMI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MINI_BMI.M with the given input arguments.
%
%      MINI_BMI('Property','Value',...) creates a new MINI_BMI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mini_bmi_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mini_bmi_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mini_bmi

% Last Modified by GUIDE v2.5 29-Mar-2016 21:45:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mini_bmi_OpeningFcn, ...
                   'gui_OutputFcn',  @mini_bmi_OutputFcn, ...
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


% --- Executes just before mini_bmi is made visible.
function mini_bmi_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mini_bmi (see VARARGIN)

% Choose default command line output for mini_bmi
handles.output = hObject;

%Set system:
%Assume config file is in current directory (same as one mini_bmi is run
%from). 

%Vargin are 1: patient_id and 2: add entry to db 3: character choice

if exist('config.txt','file')==2
    [label paths] = textread('config.txt', '%s %s',6);
    
    %Confirm labels are correct
    corr_labels = {'config','root','dec','dat','med','beep'};
    for l = 1:length(label)
        if ~strcmp(corr_labels{l}, label{l})
            errordlg('Re Run Config File Maker -- error in labels')
        end
    end
    
    handles.root_path = paths{2};
    handles.dec_path = paths{3};
    handles.dat_path = paths{4};
    handles.med_path = paths{5};
    handles.beep_path = paths{6};
        
else
    h = errordlg('Run Config File maker in /nexusbmi/config/make_config_file.m!');
end

addpath(genpath(handles.root_path));


%Load Default Values
handles = load_default(handles);

handles.tic = tic;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mini_bmi wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mini_bmi_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in go_button.
function go_button_Callback(hObject, eventdata, handles)
% hObject    handle to go_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global nex_init nex_inst;

load_dec = 1;
if and(handles.extractor_name(1:3) == 'Acc', get(handles.task_list_pulldown,'Value')==4)
    load_dec = 0;
end
handles = init_task(handles, load_dec);
keep_running = 1; 

%Set stop button to 'off'
setappdata(handles.figure1, 'stop',0);

%intro_display(handles);

while keep_running
    
    handles = run_task(handles, load_dec);
    [handles, keep_running] = update_handles_from_gui(handles);

end

disp('Cleaning up!')
cleanup_task(handles)

% Update handles structure
%guidata(hObject, handles);


function targetSizeBox_Callback(hObject, eventdata, handles)
% hObject    handle to targetSizeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of targetSizeBox as text
%        str2double(get(hObject,'String')) returns contents of targetSizeBox as a double
handles.window.target_radius = str2double(get(hObject,'String'));
disp(['targ rad: ' get(hObject,'String')])
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function targetSizeBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to targetSizeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cursorSizeBox_Callback(hObject, eventdata, handles)
% hObject    handle to cursorSizeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cursorSizeBox as text
%        str2double(get(hObject,'String')) returns contents of cursorSizeBox as a double

handles.window.cursor_radius = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function cursorSizeBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cursorSizeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in nexusSource_td.
function nexusSource_td_Callback(hObject, eventdata, handles)
% hObject    handle to nexusSource_td (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of nexusSource_td
nx = get(hObject,'Value');
handles.neural_source_name = 'nexus_td';
handles.extractor_params.nexus_domain = 'td';
if nx
    set(handles.simNexusSource_td,'Value',0);
    set(handles.accelSource,'Value',0);
    set(handles.nexusSource_pxx,'Value',0);
    set(handles.simNexusSource_pxx,'Value',0);
end

guidata(hObject, handles);


% --- Executes on button press in simNexusSource_td.
function simNexusSource_td_Callback(hObject, eventdata, handles)
% hObject    handle to simNexusSource_td (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of simNexusSource_td
sim_nx = get(hObject,'Value');
handles.neural_source_name = 'sim_nexus_td'; 
handles.extractor_params.nexus_domain = 'td';

if sim_nx
    set(handles.nexusSource_td,'Value',0);
    set(handles.accelSource,'Value',0);
    set(handles.nexusSource_pxx, 'Value', 0);
    set(handles.simNexusSource_pxx,'Value',0);
end
if sim_nx
    set(handles.serial_port_box,'String','')
end

guidata(hObject, handles);



function window_size_box_Callback(hObject, eventdata, handles)
% hObject    handle to window_size_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of window_size_box as text
%        str2double(get(hObject,'String')) returns contents of window_size_box as a double
handles.extractor_params.width_t = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function window_size_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to window_size_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function sampling_freq_box_Callback(hObject, eventdata, handles)
% hObject    handle to sampling_freq_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sampling_freq_box as text
%        str2double(get(hObject,'String')) returns contents of sampling_freq_box as a double
handles.extractor_params.fs = str2double(get(hObject,'String'));
disp('fs callback')
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sampling_freq_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sampling_freq_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function chan_idx_box_Callback(hObject, eventdata, handles)
% hObject    handle to chan_idx_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chan_idx_box as text
%        str2double(get(hObject,'String')) returns contents of chan_idx_box as a double
handles.extractor_params.used_chan = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function chan_idx_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan_idx_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stop_button.
function stop_button_Callback(hObject, eventdata, handles)
% hObject    handle to stop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% data = get(handles.figure1, 'UserData');
% data.stop= 1;
setappdata(handles.figure1, 'stop',1);
guidata(hObject, handles);


function serial_port_box_Callback(hObject, eventdata, handles)
% hObject    handle to serial_port_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of serial_port_box as text
%        str2double(get(hObject,'String')) returns contents of serial_port_box as a double
handles.nexus_serial_port = get(hObject,'String');

% --- Executes during object creation, after setting all properties.
function serial_port_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to serial_port_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function assist_level_Callback(hObject, eventdata, handles)
% hObject    handle to assist_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of assist_level as text
%        str2double(get(hObject,'String')) returns contents of assist_level as a double
handles.decoding.assist_level = str2double(get(hObject,'String'));
fprintf('update assist level to %d \n',handles.decoding.assist_level);
setappdata(handles.figure1,'assist_level',handles.decoding.assist_level)

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function assist_level_CreateFcn(hObject, eventdata, handles)
% hObject    handle to assist_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in train_decoder_button.
function train_decoder_button_Callback(hObject, eventdata, handles)
% hObject    handle to train_decoder_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
make_decoder(handles)


% --- Executes on selection change in decoder_list.
function decoder_list_Callback(hObject, eventdata, handles)
% hObject    handle to decoder_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns decoder_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from decoder_list
dec_list = get(hObject,'String');
if strcmp(dec_list,'Decoder List')
    return
else
    decoder_file = dec_list{get(hObject,'Value')};
    handles.decoding.file = decoder_file;
    guidata(hObject, handles)
end

% --- Executes during object creation, after setting all properties.
function decoder_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to decoder_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in refresh_button.
function refresh_button_Callback(hObject, eventdata, handles)
% hObject    handle to refresh_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dec_contents = dir(handles.dec_path);
dec = {};
for i = 1:length(dec_contents)
    if length(dec_contents(i).name)>2 && strcmp(dec_contents(i).name(1:3), 'dec')
        dec{end+1} = dec_contents(i).name;
    end
end

set(handles.decoder_list, 'String', dec)
guidata(hObject,handles)



function lp_filter_box_Callback(hObject, eventdata, handles)
% hObject    handle to lp_filter_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lp_filter_box as text
%        str2double(get(hObject,'String')) returns contents of lp_filter_box as a double

handles.decoding.lp_filter = str2double(get(hObject,'String'));
fprintf('update lp_filter to %d \n',handles.decoding.lp_filter);
 
% data = get(handles.figure1, 'UserData');
% data.lp_filter= handles.decoding.lp_filter;
% set(handles.figure1, 'UserData',data);
setappdata(handles.figure1,'lp_filter',handles.decoding.lp_filter)
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function lp_filter_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lp_filter_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function holdMean_Callback(hObject, eventdata, handles)
% hObject    handle to holdMean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of holdMean as text
%        str2double(get(hObject,'String')) returns contents of holdMean as a double

fprintf('update hold mean to %d \n', str2double(get(hObject, 'String')));
setappdata(handles.figure1,'hold_mean', str2double(get(hObject, 'String')))
guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function holdMean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to holdMean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function holdVar_Callback(hObject, eventdata, handles)
% hObject    handle to holdVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of holdVar as text
%        str2double(get(hObject,'String')) returns contents of holdVar as a double
fprintf('update hold var to %d \n', str2double(get(hObject, 'String')));
setappdata(handles.figure1,'hold_var', str2double(get(hObject, 'String')))
guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function holdVar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to holdVar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dat_suffix_Callback(hObject, eventdata, handles)
% hObject    handle to dat_suffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dat_suffix as text
%        str2double(get(hObject,'String')) returns contents of dat_suffix as a double
handles.data_suffix = get(hObject,'String');
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function dat_suffix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dat_suffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dec_suffix_Callback(hObject, eventdata, handles)
% hObject    handle to dec_suffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dec_suffix as text
%        str2double(get(hObject,'String')) returns contents of dec_suffix as a double
handles.decoder_suffix = get(hObject,'String');
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function dec_suffix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dec_suffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function low_frac_lim_box_Callback(hObject, eventdata, handles)
% hObject    handle to low_frac_lim_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of low_frac_lim_box as text
%        str2double(get(hObject,'String')) returns contents of low_frac_lim_box as a double
handles.low_frac_lim = str2double(get(hObject,'String'));
fprintf('Update low frac lim %d', handles.low_frac_lim);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function low_frac_lim_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to low_frac_lim_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function high_frac_lim_box_Callback(hObject, eventdata, handles)
% hObject    handle to high_frac_lim_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of high_frac_lim_box as text
%        str2double(get(hObject,'String')) returns contents of high_frac_lim_box as a double
handles.high_frac_lim = str2double(get(hObject,'String'));
fprintf('Update high frac lim %d', handles.high_frac_lim);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function high_frac_lim_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to high_frac_lim_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in task_list_pulldown.
function task_list_pulldown_Callback(hObject, eventdata, handles)
% hObject    handle to task_list_pulldown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns task_list_pulldown contents as cell array
%        contents{get(hObject,'Value')} returns selected item from task_list_pulldown


% --- Executes during object creation, after setting all properties.
function task_list_pulldown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to task_list_pulldown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function arduino_comport_Callback(hObject, eventdata, handles)
% hObject    handle to arduino_comport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of arduino_comport as text
%        str2double(get(hObject,'String')) returns contents of arduino_comport as a double


% --- Executes during object creation, after setting all properties.
function arduino_comport_CreateFcn(hObject, eventdata, handles)
% hObject    handle to arduino_comport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ard_check.
function ard_check_Callback(hObject, eventdata, handles)
% hObject    handle to ard_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ard_check


% --- Executes on button press in accelSource.
function accelSource_Callback(hObject, eventdata, handles)
% hObject    handle to accelSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
acc = get(handles.accelSource, 'Value');
handles.neural_source_name = 'accel';
if acc
    set(handles.simNexusSource_td,'Value',0);
    set(handles.nexusSource_td,'Value',0);
    set(handles.nexusSource_pxx,'Value',0);
    set(handles.simNexusSource_pxx,'Value',0);
end
guidata(hObject,handles);



% Hint: get(hObject,'Value') returns toggle state of accelSource


% --- Executes on selection change in extractor_drop.
function extractor_drop_Callback(hObject, eventdata, handles)
% hObject    handle to extractor_drop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns extractor_drop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from extractor_drop

contents = get(hObject,'String');
val = get(hObject,'Value');
handles.extractor_name = contents{val};
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function extractor_drop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to extractor_drop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in nexusSource_pxx.
function nexusSource_pxx_Callback(hObject, eventdata, handles)
% hObject    handle to nexusSource_pxx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nx = get(handles.nexusSource_pxx, 'Value');
handles.extractor_params.nexus_domain = 'pxx';
handles.neural_source_name = 'nexus_pxx';

if nx
    set(handles.simNexusSource_td,'Value',0);
    set(handles.nexusSource_td,'Value',0);
    set(handles.accelSource,'Value',0);
    set(handles.simNexusSource_pxx,'Value',0);
end
guidata(hObject,handles);

% Hint: get(hObject,'Value') returns toggle state of nexusSource_pxx


% --- Executes on button press in simNexusSource_pxx.
function simNexusSource_pxx_Callback(hObject, eventdata, handles)
% hObject    handle to simNexusSource_pxx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nx = get(handles.simNexusSource_pxx, 'Value');
handles.extractor_params.nexus_domain = 'pxx';
handles.neural_source_name = 'sim_nexus_pxx';

if nx
    set(handles.simNexusSource_td,'Value',0);
    set(handles.nexusSource_td,'Value',0);
    set(handles.accelSource,'Value',0);
    set(handles.nexusSource_pxx,'Value',0);
end
guidata(hObject,handles);


% Hint: get(hObject,'Value') returns toggle state of simNexusSource_pxx


% --- Executes on selection change in decoder_method.
function decoder_method_Callback(hObject, eventdata, handles)
% hObject    handle to decoder_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns decoder_method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from decoder_method


% --- Executes during object creation, after setting all properties.
function decoder_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to decoder_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in clda_box.
function clda_box_Callback(hObject, eventdata, handles)
% hObject    handle to clda_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of clda_box



function clda_sec_box_Callback(hObject, eventdata, handles)
% hObject    handle to clda_sec_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of clda_sec_box as text
%        str2double(get(hObject,'String')) returns contents of clda_sec_box as a double


% --- Executes during object creation, after setting all properties.
function clda_sec_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to clda_sec_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function half_life_box_Callback(hObject, eventdata, handles)
% hObject    handle to half_life_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of half_life_box as text
%        str2double(get(hObject,'String')) returns contents of half_life_box as a double


% --- Executes during object creation, after setting all properties.
function half_life_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to half_life_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in simAccelSource.
function simAccelSource_Callback(hObject, eventdata, handles)
% hObject    handle to simAccelSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sm_acc = get(handles.simAccelSource, 'Value');
handles.neural_source_name = 'sim_accel';
if sm_acc
    set(handles.simNexusSource_td,'Value',0);
    set(handles.nexusSource_td,'Value',0);
    set(handles.nexusSource_pxx,'Value',0);
    set(handles.simNexusSource_pxx,'Value',0);
    set(handles.accelSource,'Value',0);
end
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of simAccelSource

function timeoutTime_box_Callback(hObject, eventdata, handles)
% hObject    handle to timeoutTime_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeoutTime_box as text
%        str2double(get(hObject,'String')) returns contents of timeoutTime_box as a double
handles.timeoutTime = str2num(get(handles.timeoutTime_box,'String'));
setappdata(handles.figure1,'timeout', str2double(get(hObject, 'String')))
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function timeoutTime_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeoutTime_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bt_check_box.
function bt_check_box_Callback(hObject, eventdata, handles)
% hObject    handle to bt_check_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bt_check_box

% --- Executes on button press in testing_box.
function testing_box_Callback(hObject, eventdata, handles)
% hObject    handle to testing_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of testing_box

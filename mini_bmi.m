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

% Last Modified by GUIDE v2.5 07-May-2015 12:19:28

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

%Load Default Values
handles = load_default(handles);

%Set system:
%2 for pk-mbp, 1 for UCSF
handles.ucsf = 1;

if handles.ucsf == 1
    handles.root_path = 'C:\Nexus\Preeya\UCSF_minibmi4\';
    handles.dec_path = 'C:\Nexus\Preeya\UCSF_minibmi4\decoder\';
elseif handles.ucsf ==2;
    handles.root_path = '/Users/preeyakhanna/Dropbox/Carmena_Lab/UCSF_minibmi4/';
    handles.dec_path = '/Users/preeyakhanna/Dropbox/Carmena_Lab/UCSF_minibmi4/decoder/';
end

addpath(genpath(handles.root_path));

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
handles = init_task(handles, load_dec);
keep_running = 1; 

intro_display(handles);

while keep_running
    
    handles = run_task(handles);
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


% --- Executes on button press in nexusSource.
function nexusSource_Callback(hObject, eventdata, handles)
% hObject    handle to nexusSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of nexusSource
handles.neural_source_name.nexus = get(hObject,'Value');
set(handles.simNexusSource,'Value',~get(hObject,'Value'))
guidata(hObject, handles);


% --- Executes on button press in simNexusSource.
function simNexusSource_Callback(hObject, eventdata, handles)
% hObject    handle to simNexusSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of simNexusSource
handles.neural_source_name.sim_nexus = get(hObject,'Value'); 
set(handles.nexusSource,'Value',~get(hObject,'Value'))
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


function diff_ref_box_Callback(hObject, eventdata, handles)
% hObject    handle to diff_ref_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of diff_ref_box as text
%        str2double(get(hObject,'String')) returns contents of diff_ref_box as a double

handles.extractor_params.differential_chan = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function diff_ref_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diff_ref_box (see GCBO)
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


% --- Executes on button press in calibrate_button.
function calibrate_button_Callback(hObject, eventdata, handles)
% hObject    handle to calibrate_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Collect timeseries data for 1 minute:
iters = ceil(5/0.4);

load_dec = 0;
handles = init_task(handles, load_dec);

beep = wavread('beep-01a.wav');
beep_ok = 0;

for it = 1:iters
    if mod(beep_ok,5) == 0
        if rand(1) > .75
            soundsc(beep,140000)
            beep_ok = beep_ok + 1;
        end
    else
        beep_ok = beep_ok + 1;
    end
        
    handles = run_task(handles);
end

make_decoder(handles)
close(handles.window.task_display)


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

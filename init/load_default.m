function handles = load_default(handles)

% load default values into text boxes and dropdown menus
set(handles.targetSizeBox,'String',2);
set(handles.cursorSizeBox, 'String',.001);

handles.window.target_radius = 2;
handles.window.cursor_radius = .001;

% neural source;
% set(handles.simNexusSource_td, 'Value',0);
% set(handles.simNexusSource_pxx, 'Value',0);
% set(handles.nexusSource, 'Value',1);
% handles.neural_source_name.nexus = 1;
set(handles.serial_port_box, 'String', 'COM3');

% extractor params;
set(handles.window_size_box,'String',400);
set(handles.sampling_freq_box, 'String',422);
set(handles.chan_idx_box, 'String',1);
%set(handles.diff_ref_box, 'String',0);

% set(handles.low_frac_lim_box,'String',25);
% set(handles.high_frac_lim_box,'String',40);
% 
% handles.low_frac_lim = 25;
% handles.high_frac_lim = 40;
 
handles.extractor_params.width_t = 400;
handles.extractor_params.fs = 422;
handles.extractor_params.used_chan = 1;
handles.extractor_params.differential_chan = 2;

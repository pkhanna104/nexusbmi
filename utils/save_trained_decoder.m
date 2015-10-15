function save_trained_decoder(handles, lower_lim, upper_lim, decoder)

try
    if isfield(handles, 'decoder_suffix')
        handles.decoder_suffix = [handles.decoder_suffix '_' num2str(lower_lim) '-' num2str(upper_lim)];
    else
        handles.decoder_suffix = [num2str(lower_lim) '-' num2str(upper_lim)];
    end
catch
    handles.decoder_suffix = [num2str(lower_lim) '-' num2str(upper_lim)];
end

filename = get_data_fname('decoder',handles);
fnm = [filename(1:end-4) '_' handles.decoder_suffix '_' decoder.method '.mat'];
save(fnm, 'decoder')

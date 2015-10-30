function save_last_clda(it, decoder_old,handles)

decoder = struct();
decoder.feature_band = decoder_old.feature_band;
decoder.A = decoder_old.A; 
decoder.W = decoder_old.W;
decoder.C = squeeze(decoder_old.C_arr(it,:,:))';
decoder.Q = squeeze(decoder_old.Q_arr(it));
decoder.mn_sqrt_neur = decoder_old.mn_sqrt_neur;
decoder.R_init = 1/it*(decoder_old.x_tm_est_arr(1:it,:)'*decoder_old.x_tm_est_arr(1:it,:));
decoder.source = decoder_old.source;
decoder.method = 'KF';
val = get(handles.decoder_list,'Value');
str = get(handles.decoder_list,'String');
nm = str{val};

c = clock;
clk = [num2str(c(2)) '_' num2str(c(3)) '_' num2str(c(4)) '_' num2str(c(5))];

fnm = [handles.dec_path nm(1:end-4) '_CLDA_' clk '_its' num2str(it) '.mat'];
save(fnm, 'decoder')
end

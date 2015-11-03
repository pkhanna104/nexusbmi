function cue_aligned_data(block,day)

 [ft, raw_td_m1, raw_td_stn, raw_pxx, abs_t, targ, curs, rew_inds, state, dat] = parse_dat(block, day);
 
 %Beep trials: 
 sub_ix = find(dat.arduino.beep>0);
 dsub_ix = diff(sub_ix);
 sub_sub_ix = find(dsub_ix>1)+1;
 go_cue = [sub_ix(1); sub_ix(sub_sub_ix)];
 go_time = dat.arduino.t(go_cue);
 
 Fs = 10;
 M1_aligned = zeros(length(go_time), 6, 168);
 [Pxx, w] = pwelch(rand(169,1), 128, 0, 128);
 M1_spec = zeros(length(go_time), 6, length(w));
 Pxx_aligned = zeros(length(go_time), 6, 2);
 Acc_aligned = zeros(length(go_time), 6*Fs, 3);

 t = linspace(-2*.4, 4*.4, 7); 
 t_acc = linspace(-2*.4, 4*.4, 6*Fs+1);
 for g=1:length(go_time)
     [mega_tm, mega_tm_ix] = min(abs(dat.abs_time-go_time(g)));
     M1_aligned(g,:,:) = raw_td_m1(mega_tm_ix-2:mega_tm_ix+3, 1:168);
     Pxx_aligned(g,:,:) = raw_pxx(mega_tm_ix-2:mega_tm_ix+3, :);
     
     if 2*Fs>=go_cue(g)
         ix_tmp = -1*(go_cue(g) - 2*Fs);
        Acc_aligned(g,ix_tmp:end,:) = dat.arduino.acc(1:1+go_cue(g)+(4*Fs),:);
     else
         Acc_aligned(g,:, :) = dat.arduino.acc(go_cue(g)-(2*Fs)+1:go_cue(g)+(4*Fs),:);
     end
     
     for i=1:6
         [M1_spec(g,i,:), w] =  pwelch(M1_aligned(g,i,:), 128, 0, 128, 422);
     end
 end
 
 figure; subplot(3,1,1); hold on;
 pcolor(t(2:end), w, log10(squeeze(mean(M1_spec,1))'))
 shading interp
 plot([0, 0], [0, w(end)],'k-')
 
 subplot(3,1,2)
 plot(t(2:end), mean(Pxx_aligned(:,:,2),1),'b-')
 legend('Mean Pxx Signal 15+/- 2.5 Hz')
 
 subplot(3,1,3)
 plot( t_acc(2:end), mean(sum(abs(Acc_aligned),3),1),'.')
% plot(t(2:end), ([0 1 0 0 0 0]*100) + 300, 'k.-')
 legend('Accelerometer Signal', 'Movment Cue')
 
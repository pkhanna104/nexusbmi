function metrics = tapping_metrics(gyr, Fs)

% Filter from Paper: http://link.springer.com/article/10.1007%2Fs11517-010-0697-8
% "4th-order zero-phase digital bandpass filter (1–50 Hz) was used to
% eliminate baseline drift and noise in the gyrosensor signal."

[n,Wn] = buttord([.5, 5]/Fs, [.1, 10]/Fs, 3, 60);  % Gives mimimum order of filter
[b,a] = butter(4,Wn); 

% Take X-axis of gyr: 
gyro_x  = gyr(:, 1);
filt_gyro_x = filtfilt(b, a, gyro_x);

% Metrics: 
metrics = cell(8, 1);

% #1: [RT10, RT20, RT100]
% #2: Open or Close first
% #3: Number of Taps (+/- combos)
% #4: Amp of Taps
% #5: RMS Velocity
% #6: RMS Angle
% #7: Spectral Peak
% #8: Spectral Power @ Peak

% # 1: RT: 
% Get min and max
thresh = 20; perc_thresh = [.1, .2, 1];
rect = abs(filt_gyro_x);
xpos = findpeaks(rect, thresh);
xloc = xpos.loc;

rt = [];
if ~isempty(xloc)
    for pt = 1:length(perc_thresh)
        % Find first peak; 
        first_pos = xloc(1);
        amp_pk = rect(first_pos);
        amp = amp_pk;
        i = first_pos;
        while amp > (perc_thresh(pt)*amp_pk)
            i = i - 1;
            if i > 0
                amp = rect(i);
            else
                amp = 0;
            end
        end
        rt = [rt i*(1/Fs)];
    end
    if rt(1) > 0
        acc = (amp_pk - rect(round(rt(1)*Fs)))/(rt(end) - rt(1));
        rt = [rt acc];
    else
        rt = [rt 0];
    end
    metrics{1} = rt;

    % #2: Open or close first: 
    if filt_gyro_x(first_pos) > 0
        metrics{2} = 1;
    else
        metrics{2} = -1;
    end

    % #3: Number of taps
    ntaps = 0;
    pos = metrics{2};
    amps = {[filt_gyro_x(xloc(1))]};
    aix = 1;
    for i=2:length(xloc)
        if and((pos == 1), filt_gyro_x(xloc(i)) < 0)
            ntaps = ntaps + 0.5;
            aix = aix + 1;
            pos = -1;
            amps{aix} = [filt_gyro_x(xloc(i))];
        elseif pos == 1
            amps{aix} = [amps{aix} filt_gyro_x(xloc(i))];

        elseif and((pos == -1), filt_gyro_x(xloc(i)) > 0)
            ntaps = ntaps + 0.5;
            pos = 1;
            aix = aix + 1;
            amps{aix} = [filt_gyro_x(xloc(i))];
        elseif pos == -1
            amps{aix} = [amps{aix} filt_gyro_x(xloc(i))];
        end
    end
    metrics{3} = ntaps;

    % #4: Amp of taps
    amp = [];
    for i=1:aix
        [~, ix] = max(abs(amps{i}));
        amp = [amp amps{i}(ix)];
    end
    metrics{4} = amp;
end

% #5: RMS velocity
metrics{5} = sqrt(mean(filt_gyro_x.^2));

% #6: RMS angle
I = cumsum(filt_gyro_x);
metrics{6} = sqrt(mean(I.^2));

% #7: Spectral peak
Y = fft(filt_gyro_x);
L = length(gyro_x);
P2 = abs(Y/L);
P1 = 2*P2(1:L/2+1);
f = Fs*(0:(L/2))/L;
[mx_amp, fmx_ix] = max(P1);
metrics{7} = f(fmx_ix);

% #8: Spectral power @ peak
metrics{8} = mx_amp;

end

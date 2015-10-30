% Load Data File: 
dat_dec = dat.decoder;

figure;
subplot(2, 2, 1);
plot(dat_dec.x_ms_est_arr(:,1));
hold all;
plot(dat_dec.x_tm_est_arr(2:end,1));
legend('ms','tm')

subplot(2, 2, 2);
plot(dat.features(:,2));
title('Features')

for i = 1:2
    for j = 1:2
        subplot(4, 2, 2+(2*i)+j); 
        hold all;
        plot(dat_dec.cov_ms_est_arr(:,i,j));
        plot(dat_dec.cov_tm_est_arr(:,i,j));
    end
end

%PLOT CLDA
figure;
subplot(2,2,1)
plot(dat_dec.C_arr(:,1,1)); 
title('C1')

subplot(2,2,2);
plot(dat_dec.C_arr(:,1,2));
title('C2')

subplot(2,2,3);
plot(dat_dec.Q_arr);
title('Q')

%PLOT RML Params: 
figure;
hold all;
for i = 1:2
    for j= 1:2
        plot(dat_dec.R_arr(:,i,j), 'b-');
    end
    plot(dat_dec.S_arr(:,i), 'g-');
end
plot(dat_dec.T_arr, 'r-');
plot(dat_dec.EBS_arr,'m-')


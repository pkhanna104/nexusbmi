blocks = 'ai'; 
data = struct();
for b=1:length(blocks)
    d = load(strcat('dat092815',blocks(b),'_.mat'));
    dat = d.dat;
    n_its = length(dat.abs_time);
    pxx = dat.rawdata_power_ch4;
    td = dat.rawdata_timeseries_m1(1:n_its,1:168);
    td2 = reshape(td', [n_its*168, 1]);
    
    blk = strcat('blk_0928_',blocks(b));
    data.(blk).td = td2;
    data.(blk).px = pxx;
end

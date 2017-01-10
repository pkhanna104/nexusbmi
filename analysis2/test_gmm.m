dates = {'052016', '052316', '052416', '053016', '060816'};
blocks = { 'a', 'fgh', 'bcd', 'd', 'b'};

nbins = 100;
x = 0:floor(1024/50):1024;
data = {};
dataraw = {};

figure(1);
hold all;
for d = 1:length(dates)
    for b = 1:length(blocks{d})
        fn = strcat('dat', dates{d}, blocks{d}(b), '_');
        load(fn)
        
        g = dat.rawdata_power_ch4;
        for t = 1:length(g)
            if not(and(size(g{t}, 1) == 2, size(g{t}, 2) == 1))
                g{t} = [nan; nan];
            end
        end
        G = reshape(cell2mat(g), [size(g, 2)*2, 1]);
        if b == 1
            [N,xx] = hist(G, x);
            GG = G;
        else
            [n, xx] = hist(G, x);
            N = N + n;
            GG = [GG; G];
        end
    end
    data{d} = N/sum(N);
    dataraw{d} = GG;
    plot(xx, data{d}, '.-') 
end

%% fit GMM
mgmms = 5;
IC = zeros(length(dataraw), 2, mgmms);

for d = 1:length(dataraw)
    for k = 1:mgmms
        GMModel = fitgmdist(log10(dataraw{d}), k);
        IC(d, :, k) = [GMModel.AIC GMModel.BIC];
    end
    figure(2)
    bar(d:.2:d+(.2*(mgmms-1)), squeeze(IC(d, 1, :)))
    hold all
    figure(3)
    bar(d:.2:d+(.2*(mgmms-1)), squeeze(IC(d, 2, :)))
    hold all
end

%% Log + 2 GMMs plot: 
x = log10(0:10:1024);

for d = 1:length(dataraw);
    figure;
    [N, X] = hist(log10(dataraw{d}), x);
    plot(x, (N/sum(N)), '.-');
    hold all;
    
    GMModel = fitgmdist(log10(dataraw{d}), 5, 'Replicates', 5,...
        'CovType','diagonal');
    
    p = pdf(GMModel, x');
    plot(x, (p/sum(p)), 'r-');
end
    

        
        
    
        
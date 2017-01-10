function decoder = init_perc_pdf_dec(feats, decoder)

%Map features to percentiles to cursor position: 

keep_testing_bins = 1;
figure(1)
hold all

while keep_testing_bins
    nbins = input('Enter number of bins: \n');
    if or(~isnumeric(nbins), isempty(nbins))
        nbins = 10;
    end
    [n, x] = hist(feats, nbins);
    plot(x, n/sum(n), '.-')
    legend(num2str(nbins))
    keep_testing_bins = input('Keep testing nbins? (1 for yes, 0 for no): \n'); 
    if and(keep_testing_bins ~= 0, keep_testing_bins ~= 1)
        keep_testing_bins = 1;
    end
end

decoder.map = [x' cumsum(n)'/sum(n)];
decoder.nbins = nbins;

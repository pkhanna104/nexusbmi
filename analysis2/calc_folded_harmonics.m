%calculate folded harmonics
function artifacts = calc_folded_harmonics(Fs,fstim)

artifacts = [];

for n=1:17
    temp = abs(n*fstim-round(n*fstim/Fs)*Fs);
   artifacts = [artifacts temp];
end

end
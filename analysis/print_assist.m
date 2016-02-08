pref = {'dat050815*','dat092815*','dat103015*'};

for p=1:length(pref)
    pre =pref{p};
    
    direc = dir(pre);
    
    for d=1:length(direc)
        
        load(direc(d).name)
        
        disp(strcat(direc(d).name, ' assist: ', num2str(mean(dat.assist_level)), ' time: ', num2str(dat.abs_time(end)/60)))
    end
end

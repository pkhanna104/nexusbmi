function dec = ascii2dec(ascii)
    c = str2num(char(ascii));
    mult = 1;
    dec = 0;
    for i = 1:length(c)
        ci = c(end+1-i);
        dec = dec + (ci*mult);
        mult = mult * 10; 
    end
end
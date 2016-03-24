cmap = {[32 178 170]/255, [70 130 180]/255,[255 215 0]/255, [255 69 0]/255};

%P1: 
x = [7.6, 10.3, 5.7, 5.5];
y = [.48, 0.36, .26, 0.0];
p1 ={x, y};

%P2: 
x = [14.7, 21.7, 8.2];
y = [.54, .45, .35];
p2 = {x, y};
%P3:
x = [12.0, 13.6, 13.1];
y = [.4, .4, .4];
p3={x,y};

all = {'p1', 'p2', 'p3'};
f = figure();
hold on;

for i_p =1:length(all)
    p = eval(all{i_p});
    x1 = [0 cumsum(p{1})];
    y1 = p{2};
    
    for b = 1:length(y1)
        plot([x1(b) x1(b+1)], [y1(b) y1(b)], '.-','color',cmap{i_p},'linewidth',5)
        if b < length(y1)
            plot([x1(b+1) x1(b+1)], [y1(b) y1(b+1)], '.-','color', cmap{i_p},'linewidth',5)
        end
    end
end
    

    
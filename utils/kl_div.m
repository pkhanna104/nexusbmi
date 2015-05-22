function kld = kl_div(x,y)
%X, y are vectors of same length
if length(x)~=length(y)
    error('Inconsistent lengths')
end


%Normalize:
x = (x)/sum(x);
y = (y)/sum(y);

kld_x = 0;
kld_y = 0;


for i=1:length(x)
    if x(i) ~= 0
        if y(i)~=0
            kld_x_i = x(i)*log(x(i)/y(i));
            kld_x = kld_x + kld_x_i;
            kld_y_i = y(i)*log(y(i)/x(i));
            kld_y = kld_y + kld_y_i;
        end
    end
    
end

kld = (kld_x + kld_y) / 2;
end
    
    
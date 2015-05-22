% LP filter your features, then fit mu and std: 
function [FT, RAW, TARG, CURS, REW, idx] = concat_dat(blocks, start_ind, rm_targs)

dir = 'C:\Users\George\Downloads\UCSF_minibmi5\';
dir2 = '/Users/preeyakhanna/Dropbox/Carmena_Lab/UCSF_minibmi5/';

%blocks = 'gh';
%start_ind = [141, 1];

FT = [];
RAW = [];
TARG = [];
CURS = [];
REW = [];
idx = [];
ind_offs = 0;

%Stack data: 
for ai = 1:length(blocks)
    alpha = blocks(ai);
    fname1 = [dir 'data\dat050815' alpha '_.mat'];
    fname2 = [dir2 'data/dat050815' alpha' '_.mat'];
    load(fname1)

    ft = dat.features(:,3);
    ix_zer = find(ft==0);
   
    act_curs = dat.cursor(ix_zer);
    c1 = dat.cursor(ix_zer-1);
    c2 = (2*act_curs) - c1;

    ft_interp = (c2*25)+300;
    ft(ix_zer) = ft_interp;

    FT = [FT; ft(start_ind(ai):end)];
    RAW = [RAW; dat.rawdata_timeseries_stn(start_ind(ai):end,:)];

    [targ_locs, rew_inds] = get_targ_loc(dat);
    TARG = [TARG; targ_locs(start_ind(ai):end)];
    CURS = [CURS; dat.cursor(start_ind(ai):end)];
    
    rews = rew_inds(rew_inds>start_ind(ai));
    blk_rews = rews-start_ind(ai)+1+ind_offs';
    blk_rews = blk_rews(1:end-rm_targs(ai));
    REW = [REW blk_rews];
    
    ind_offs = ind_offs+length(ft(start_ind(ai):end));
    
    idx = [idx length(FT)];
    
end
end


    % before3 = (ft(ix_zer-3)-300)/25;
    % before2 = (ft(ix_zer-2)-300)/25;
    % before = (ft(ix_zer-1)-300)/25;
    % 
    % plot(ft_interp,'.-')
    % hold all;plot(before,'.-')
    % plot(before2,'.-')
    % plot(before3,'.-')
    % legend('interp','before'),'before2','before3')
    % calc_ft = zeros(len(ft_interp));

    % ft(ix_zer) = ft(ix_zer-2);

    
    %Decode Cursor postion: 
%     dec_pos = zeros(length(ft),1);
%     cursor = zeros(length(ft), 1);
% 
%     for i = 1:length(ft)
%         if i==1
%             lp_ft(i) = (ft(i) - dat.decoder.mean)/dat.decoder.std;
%         else
%             dec = (ft(i) - dat.decoder.mean)/dat.decoder.std;
%             lp_ft(i) = .5*(dec+cursor(i-1));
%         end
% 
% 
%         if lp_ft(i) > 10
%             cursor(i) = 10;
%         elseif lp_ft(i) < -10
%             cursor(i) = -10;
%         else
%             cursor(i) = lp_ft(i);
%         end
%     end

    % plot(dat.cursor,'.-')
    % hold all
    % plot(cursor,'.-')
    % %plot((ft-300)/25,'.-')
    % legend('dat.cursor','cursor calc')


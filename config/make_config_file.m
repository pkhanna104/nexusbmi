function make_config_file()

%To be run at the start of putting the repo on a new machine
%Will generate a config text file that git ignores in this config directory

%Need to know if machine is windows or PC
%Need to know root 'nexusbmi' directory

prompt = {'Enter path to nexusbmi: (should have nexusbmi\ or nexusbmi/as final part of path',...
    'Enter 1 for windows, 2 for Mac:'};
dlg_title = 'Configuration Input';
num_lines = 1;
def = {pwd,'1'};
answer = inputdlg(prompt,dlg_title,num_lines,def);

root = answer{1};

if str2double(answer{2})==1 %Windows
    dec_path = [root 'decoder\'];
    dat_path = [root 'data\'];
    med_path = [root 'media\'];
elseif str2double(answer{2}) == 2 %Mac
    dec_path = [root 'decoder/'];
    dat_path = [root 'data/'];
    med_path = [root 'media/'];
else
    disp('Machine Type not recognized...try again!')
end

fid = fopen([root 'config.txt'], 'w');
fprintf(fid, '%s\n','config paths');
fprintf(fid, '%s\n',['root ' root ]);
fprintf(fid, '%s\n',['dec ' dec_path ]);
fprintf(fid, '%s\n',['dat ' dat_path ]);
fprintf(fid, '%s\n',['med ' med_path ]);
fclose(fid);

    
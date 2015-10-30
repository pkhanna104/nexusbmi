%close and clean up

% Nicki - no need to reset the Nexus back to defaults. Nexus resets
% back to defaults when power is cycled
% inst.setNexusConfiguration(10,2) % reset to defaults

status = inst.disconnect;
if (status == 1)
    fprintf('disconnect success\n');
else
    fprintf('disconnect fail\n');
end

inst.dispose % clean up properly

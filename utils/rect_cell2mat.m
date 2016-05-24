function [rect_cell, rect_mat] = rect_cell2mat(cell, cell_shape)
%Fills in incorrect sized cell shapes with -1s of the correct shape
    rect_cell = {};
    for ii = 1:length(cell)
        if size(cell{ii},1) ~= cell_shape(1)
            rect_cell{ii} = zeros(cell_shape)-1;
            disp(strcat('Skipping ix: ', num2str(ii)));            
        else
            rect_cell{ii} = cell{ii};
        end
    end
    rect_mat  = cell2mat(rect_cell);
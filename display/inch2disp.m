function scatter_size = inch2disp(xlim, axpos, target_rad)
    % Calculate Marker width in points
    markerWidth = (2*target_rad)/diff(xlim)*axpos(3); 
    scatter_size = markerWidth^2;
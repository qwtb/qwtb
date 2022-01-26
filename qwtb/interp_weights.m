function w = interp_weights(lut, ipoint)
    % axes in lut and ipoint must be same and already checked! XXX ensure
    % find axes of the LUT:
    tmpQs = fieldnames(lut.ax);
    for j = 1:numel(tmpQs)
        tmpfs = fieldnames(lut.ax.(tmpQs{j}));
        for k = 1:numel(tmpfs);
            ax_Qs{end+1} = tmpQs{j};
            ax_fs{end+1} = tmpfs{k};
            ax_names{end+1} = [tmpQs{j} "." tmpfs{k}];
        end % for k = 1:numel(tmpfs{k});
    end % for j = 1:numel(tmpQs)
    % ZJEDNODUSIT PRES JOB.VARLIST? NE, dat to do lut.names.ax a lut.names.qu
    % count of names:
    A = numel(ax_names);
    
    % get existing quantites:
    % get quantities in qu parameter, i.e. results of the LUT:
    tmpQs = fieldnames(lut.qu);
    for j = 1:numel(tmpQs)
        tmpfs = fieldnames(lut.qu.(tmpQs{j}));
        for k = 1:numel(tmpfs);
            qu_Qs{end+1} = tmpQs{j};
            qu_fs{end+1} = tmpfs{k};
            qu_names{end+1} = [tmpQs{j} "." tmpfs{k}];
        end % for k = 1:numel(tmpfs{k});
    end % for j = 1:numel(tmpQs)
    % ZJEDNODUSIT PRES JOB.VARLIST? NE, dat to do lut.names.ax a lut.names.qu
    % count - Q = 1
    Q = numel(qu_names);

    % load first quantity record:
    % get its axes sizes:
    adims = size(lut.qu.(qu_Qs{1}).(qu_fs{1}).data);
        
    % --- create interpolation weight-matrix ---
    
    % create interpolation weigth matrix:
    %  note: at this point same w. for all elements
    w = ones(adims);
    
    % for each axis of dependence:
    for a = 1:A
    
        % get axis name:
        a_name = ax_names{a};
    
        % get axis setup:
        cax = lut.ax.(ax_Qs{a}).(ax_fs{a});
        % get axis values:
        vax = cax.values(:);
        
        % get interpolation value of the axis from ipoint (interpolation point):
        ai = ipoint.(ax_Qs{a}).(ax_fs{a});
        % get interpolation values:
        ai = ai.val;
        
        % limit interp. value to valid range:
        if ai < cax.min_ovr*min(vax)
            % required axis value too low:
            if strcmpi(cax.min_lim,'error')
                % XXX error generator
                error(sprintf('Uncertainty estimator: Required interpolation value of axis ''%s'' is too low! Range of estimator data is not sufficient to estimate the uncertainty.',a_name));
            elseif strcmpi(cax.min_lim,'const')
                % limit interpolation value 'ai' to the nearest axis spot:
                ai = min(vax);
            else
                % XXX error generator
                error(sprintf('Uncertainty estimator: Required interpolation value of axis ''%s'' is too low and the corrective action ''%s'' is not recognized! Range of estimator data is not sufficient to estimate the uncertainty.',a_name,cax.min_lim));
            end
        elseif ai > cax.max_ovr*max(vax)
            % required axis value too low:
            if strcmpi(cax.max_lim,'error')
                % XXX error generator
                error(sprintf('Uncertainty estimator: Required interpolation value of axis ''%s'' is too high! Range of estimator data is not sufficient to estimate the uncertainty.',a_name));
            elseif strcmpi(cax.max_lim,'const')
                % limit interpolation value 'ai' to the nearest axis spot:
                ai = max(vax);
            else
                % XXX error generator
                error(sprintf('Uncertainty estimator: Required interpolation value of axis ''%s'' is too high and the corrective action ''%s'' is not recognized! Range of estimator data is not sufficient to estimate the uncertainty.',a_name,cax.max_lim));
            end            
        end
        
        % select mode of interpolation:
        if strcmpi(cax.scale,'log')
            % log-scale interpolation:
            vax = log10(vax);
            ai = log10(ai);
        elseif ~strcmpi(cax.scale,'lin')
            % XXX error generator
            error(sprintf('Uncertainty estimator: Interpolation mode of axis ''%s'' is unknown! Possibly incorrect lookup data.',a_name));
        end
        
        % create axis interpolation mask:
        wa = zeros(size(vax));
        % zeros, collumn vector
        
        % descending axis values?
        is_descend = any(diff(vax) < 0);
                
        % if at limit of axis, set weight at limits to 1
        % i.e. if value of axis is at upper max of lut axis, the weight vector is 0;0;...;0;1
        % i.e. if value of axis is at lower min of lut axis, the weight vector is 1;0;...;0;0
        % i.e. if value of axis is somewhere in the middle, the weight vector is 0;0;...;1;...;0;0
        % or                                                                    0;0;...;0.5;0.5;...;0;0
        if ai <= min(vax)
            % left limit:
            if is_descend
                wa(end) = 1;
            else
                wa(1) = 1;
            end                
        elseif ai >= max(vax)
            % right limit:
            if is_descend
                wa(1) = 1;
            else
                wa(end) = 1;
            end
        else
            % interpolate the axis:
            if is_descend
                % descending axis order:
                id = find(vax > ai,1,'last');               
                ws = (vax(id) - ai)/(vax(id) - vax(id+1));                
                wa(id+0) = 1 - ws;
                wa(id+1) = ws;
            else
                % ascending axis order:
                id = find(ai > vax,1,'last');               
                ws = (ai - vax(id))/(vax(id+1) - vax(id));                
                wa(id+0) = 1 - ws;
                wa(id+1) = ws;
            end                
        end
        
        % expand the axis interpolation mask to all dimensions:
        % adims = 11,11,2
        wdim = ones(size(adims));
        % for iteration 1: wdim = 1 1 1
        wdim(a) = adims(a);
        % for iteration 1: wdim = 11 1 1
        % for iteration 2: wdim = 1 11 1
        % for iteration 3: wdim = 1 1 2
        wa = reshape(wa,wdim);                                                 
        rdim = adims;
        rdim(a) = 1;
        % for iteration 1: rdim = 1 11 2
        % for iteration 2: rdim = 11 1 2
        % for iteration 3: rdim = 11 11 1
        wa = repmat(wa,rdim);
        % for iteration 1: wa = zeros, but ones at wa(6,:,1) and wa(6,:,2)
        % for iteration 2: wa = zeros, but ones at wa(:,6,1) and wa(:,6,2)
        % for iteration 3: wa = 0.5 everywhere
        
        % combine the mask with previous axes:
        w = bsxfun(@times,w,wa);            
        % for iteration 3: w = zeros, but w(6,6,1)=w(6,6,2)=0.5
        
    end

end % w = interp_weight(lut, ax)

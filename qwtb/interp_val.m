function val = interp_val(lut, w)
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

    % init result struct:
    val = struct();
        
    % --- interpolate the quantities ---
    for k = 1:Q
    
        % quantity name:
        q_name = qu_names{k};
        
        % load quantity record:
        qu = lut.qu.(qu_Qs{k}).(qu_fs{k});
        
        data = qu.data;
        % XXXXXXXXXXXXX data decoding is not supported in qwtbvar
        % decode data:
        % % if strcmpi(qu.data_mode,'log10u16')
        % %     % decode log()+uint16 format:
        % %     data = 10.^(double(qu.data)*qu.data_scale + qu.data_offset);
        % % elseif strcmpi(qu.data_mode,'real')
        % %     % unscaled data:
        % %     data = double(qu.data);
        % % else
        % %     # XXX error_msg
        % %     error(sprintf('Uncertainty estimator: Precalculated values of quantity ''%s'' stored in unknown format ''%s''! Possibly invalid lookup table content.',q_name,qu.data_mode));
        % % end
        % %
        % % % convert quantity before interpolation:
        % % is_log = 0;
        % % if isfield(qu,'scale') && strcmpi(qu.scale,'log')
        % %     is_log = 1;
        % %     data = log10(data);
        % % elseif isfield(qu,'scale') && ~strcmpi(qu.scale,'lin')
        % %     # XXX error_msg
        % %     error(sprintf('Uncertainty estimator: Precalculated values of quantity ''%s'' cannot be coverted to ''%s'' - unknown operation (only ''lin'' or ''log'')! Possibly invalid lookup table content.',q_name,qu.scale));
        % % end

        % interplate using the weight mask:
        data = data.*w;
        data = sum(data(:))/sum(w(:));
        
        % % XXXXXXXXXXXXX data decoding is not supported in qwtbvar
        % % convert back to state before interp.:
        % if is_log
        %     data = 10^data;
        % end

        % % % XXXXXXXXXXXXX data multiplication is not supported in qwtbvar
        % % multiply the data by mult-factor:
        % if isfield(qu,'mult')
        %     data = data*qu.mult;
        % end
        
        % store interpolated quantity:
        val = setfield(val, q_name, struct('val',data));        
    
    end

end % function val = interp_val(lut, w)

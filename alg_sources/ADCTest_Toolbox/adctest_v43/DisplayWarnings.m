function DisplayWarnings(warnings)
% @fn DisplayWarnings
% @brief Displays the warnings that appeared while loading an XML
%        descriptor
% @param warnings Struct of the warning messages
% @return none
% @author Tamás Virosztek, Budapest University of Technology and Economics,
%         Department of Measurement and Infromation Systems,
%         Virosztek.Tamas@mit.bme.hu



screensize = get(0,'ScreenSize');

display_warnings_window = figure('Visible','on',...
                                 'Position', [screensize(3)*0.3 screensize(4)*0.3 screensize(3)*0.4 screensize(4)*0.4],...
                                 'Name','XML load warnings',...
                                 'NumberTitle','off');
                             
to_display = [];
for k = 1:length(warnings)
    to_display = [to_display ;warnings{k}];
end
                             
hTextWarnings = uicontrol('Style','text',...
                          'Units','normalized',...
                          'Position', [0.1 0.1 0.8 0.8],...
                          'String',to_display);
                      
hPushButtonOk = uicontrol('Style','pushbutton',...
                          'String','OK',...
                          'Units','normalized',...
                          'Position',[0.45 0 0.1 0.1],...
                          'Callback',@OK_callback);
                      
    function OK_callback(source,eventdata)
        close(display_warnings_window);
    end

end
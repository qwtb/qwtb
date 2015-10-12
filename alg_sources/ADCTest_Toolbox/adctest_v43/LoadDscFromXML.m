function [new_dsc,success,error_msg,warnings] = LoadDscFromXML(filename)
% @fn LoadDscFromXML
% @brief Loads measurement descriptor from XML file
% @param filename The name of the XML file
% @return new_dsc The descriptor read from the file on disk
% @return success 1 if load succeeded, 0 otherwise
% @return error_msg Indicates the type of error (if appeared)
% @return warnings Cell array to collect warnings (if appeared)
% @author Tamás Virosztek, Budapest University of Technology and Economics,
%         Department of Measurement and Infromation Systems,
%         Virosztek.Tamas@mit.bme.hu

%Setting default return values:
success = 1;
error_msg = '';
warnings = {'Warnings:'};
new_dsc.name = 'Invalid name';
new_dsc.comment = {'Invalid comment';'in two lines'};
new_dsc.model = 'Invalid model';
new_dsc.serial = 'Invalid serial';
new_dsc.channel = NaN;
new_dsc.NoB = NaN;
new_dsc.data = NaN;


try
    document = xmlread(filename); %Reads Document Object Model Node from XML file
catch
    success = 0;
    error_msg = 'Unable to read XML file';
    return;
end

%Reading field 'Name'
temp = document.getElementsByTagName('Name');
if (temp.getLength > 0)
    new_dsc.name = char(temp.item(0).getFirstChild.getData);
else
    success = 0;
    error_msg = 'Mandatory field "Name" not found';
    return;
end

%Reading comment lines:
%<Comment>
%    <c></c>
%    <c></c>
%</Comment>
temp = document.getElementsByTagName('c');
try
    new_dsc.comment = cell(temp.getLength,1);
    for k = 0:temp.getLength-1
        new_dsc.comment{k+1,1} = char(temp.item(k).getFirstChild.getData);
    end
catch
    warnings = {warnings 'Field "Comment" not found'};
end

%Reading field 'Model'
temp = document.getElementsByTagName('Model');
if (temp.getLength > 0)
    new_dsc.model = char(temp.item(0).getFirstChild.getData);
else
    warnings = {warnings 'Field "Model" not found'};
end

%Reading field 'Serial'
temp = document.getElementsByTagName('Serial');
if (temp.getLength > 0)
    new_dsc.serial = char(temp.item(0).getFirstChild.getData);
else
    warnings = {warnings 'Field "Serial" not found'};
end

%Reading field 'Channel'
temp = document.getElementsByTagName('Channel');
if (temp.getLength > 0)
    new_dsc.channel = str2double(char(temp.item(0).getFirstChild.getData));
else
    warnings = {warnings 'Field "Channel" not found'};
end

%Reading field 'Bit_number'
temp = document.getElementsByTagName('Bit_number');
if (temp.getLength > 0)
    new_dsc.NoB = str2double(char(temp.item(0).getFirstChild.getData));
else
    success = 0;
    error_msg = 'Mandatory field "Bit_number" not found';
    return;
end

%Reading data vector
temp = document.getElementsByTagName('s');
if (temp.getLength > 0)
    new_dsc.data = zeros(temp.getLength,1);
    for k = 0:temp.getLength-1
        new_dsc.data(k+1,1) = str2double(char(temp.item(k).getFirstChild.getData));
    end
else
    success = 0;
    error_msg = 'Mandatory field "Data" not found';
    return;
end

%Reading parameters in case of simulated measurement
temp = document.getElementsByTagName('Simulation');
if (strcmpi('Yes',char(temp.item(0).getFirstChild.getData))) %Parameters are described in the XML
    
    new_dsc.simulation = 1;
    
    temp = document.getElementsByTagName('Parameter_A');
    new_dsc.parameters.A = str2double(char(temp.item(0).getFirstChild.getData));
    
    temp = document.getElementsByTagName('Parameter_B');
    new_dsc.parameters.B = str2double(char(temp.item(0).getFirstChild.getData));
    
    temp = document.getElementsByTagName('Parameter_C');
    new_dsc.parameters.C = str2double(char(temp.item(0).getFirstChild.getData));

    temp = document.getElementsByTagName('Parameter_Theta');
    new_dsc.parameters.theta = str2double(char(temp.item(0).getFirstChild.getData));

    temp = document.getElementsByTagName('Parameter_Sigma');
    new_dsc.parameters.sigma = str2double(char(temp.item(0).getFirstChild.getData));
    
    temp = document.getElementsByTagName('INL');
    new_dsc.parameters.INL = zeros(1,temp.getLength);
    for k = 0:temp.getLength - 1 
        new_dsc.parameters.INL(k+1) = str2double(char(temp.item(k).getFirstChild.getData));
    end
else
    new_dsc.simulation = 0;
end

end
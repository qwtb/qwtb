function [success,error_msg] = SaveDscToXML(dsc,filename)
% @fn SaveDscToXML
% @brief Saves a measurement descriptor to a XML file
% @param dsc The measurement descriptor to save
% @param filename The name of the file, where the descriptor shall be
%                 saved
% @return success 1, if saving succeeded, 0 otherwise
% @return error_msg Indicates the type of error (if appeared)
% @author Tamás Virosztek, Budapest University of Technology and Economics,
%         Department of Measurement and Infromation Systems,
%         Virosztek.Tamas@mit.bme.hu


%Setting default return values
success = 1;
error_msg = '';

try
    %Creating Document Object Model Node
    docNode = com.mathworks.xml.XMLUtils.createDocument('Descriptor');
    docRootNode = docNode.getDocumentElement;

    %Adding field 'Name'
    field_name = docNode.createElement('Name');
    field_name.appendChild(docNode.createTextNode(dsc.name));
    docRootNode.appendChild(field_name);

    %Adding comments
    field_comment = docNode.createElement('Comment');
    docRootNode.appendChild(field_comment);
    for k = 1:length(dsc.comment)
        field_c = docNode.createElement('c');
        field_c.appendChild(docNode.createTextNode(dsc.comment{k,1}));
        field_comment.appendChild(field_c);
    end

    %Adding fileds about the Device Under Test
    field_DUT = docNode.createElement('DUT');
    docRootNode.appendChild(field_DUT);

        %Adding field 'Model'
        field_model = docNode.createElement('Model');
        field_model.appendChild(docNode.createTextNode(dsc.model));
        field_DUT.appendChild(field_model);

        %Adding field 'Serial'
        field_serial = docNode.createElement('Serial');
        field_serial.appendChild(docNode.createTextNode(dsc.serial));
        field_DUT.appendChild(field_serial);

        %Adding field 'Channel'
        field_channel = docNode.createElement('Channel');
        field_channel.appendChild(docNode.createTextNode(sprintf('%d',dsc.channel)));
        field_DUT.appendChild(field_channel);

        %Adding field 'Bit_number'
        field_bit_number = docNode.createElement('Bit_number');
        field_bit_number.appendChild(docNode.createTextNode(sprintf('%d',dsc.NoB)));
        field_DUT.appendChild(field_bit_number);

    %Adding data fields
    field_input_vector = docNode.createElement('Input_vector');
    docRootNode.appendChild(field_input_vector);
    for k = 1:length(dsc.data)
        field_s = docNode.createElement('s');
        field_s.appendChild(docNode.createTextNode(sprintf('%d',dsc.data(k))));
        field_input_vector.appendChild(field_s);
    end
    
    %Setting field 'Simulation' to determine the measurement is real or simulated'    
    field_simulation = docNode.createElement('Simulation');
    if (isfield(dsc,'parameters')) %the descriptor describes a simulated measurement
        field_simulation.appendChild(docNode.createTextNode('Yes'));
    else
        field_simulation.appendChild(docNode.createTextNode('No'));
    end
    docRootNode.appendChild(field_simulation);
    
    %Adding real signal parameters, if the measurement is simulated
    if (isfield(dsc,'parameters')) %in case of simulation, parameters shall be saved
        field_parameters = docNode.createElement('Parameters');
        docRootNode.appendChild(field_parameters);
        
        field_parameter_A = docNode.createElement('Parameter_A');
        field_parameter_A.appendChild(docNode.createTextNode(sprintf('%e',dsc.parameters.A)));
        field_parameters.appendChild(field_parameter_A);
        
        field_parameter_B = docNode.createElement('Parameter_B');
        field_parameter_B.appendChild(docNode.createTextNode(sprintf('%e',dsc.parameters.B)));
        field_parameters.appendChild(field_parameter_B);
        
        field_parameter_C = docNode.createElement('Parameter_C');
        field_parameter_C.appendChild(docNode.createTextNode(sprintf('%e',dsc.parameters.C)));
        field_parameters.appendChild(field_parameter_C);
        
        field_parameter_theta = docNode.createElement('Parameter_Theta');
        field_parameter_theta.appendChild(docNode.createTextNode(sprintf('%e',dsc.parameters.theta)));
        field_parameters.appendChild(field_parameter_theta);
        
        field_parameter_sigma = docNode.createElement('Parameter_Sigma');
        field_parameter_sigma.appendChild(docNode.createTextNode(sprintf('%e',dsc.parameters.sigma)));
        field_parameters.appendChild(field_parameter_sigma);
        
        field_parameter_INL = docNode.createElement('Parameter_INL');
        field_parameters.appendChild(field_parameter_INL);
        for k = 1:length(dsc.parameters.INL)
            field_actual_INL = docNode.createElement('INL');
            field_actual_INL.appendChild(docNode.createTextNode(sprintf('%e',dsc.parameters.INL(k))));
            field_parameter_INL.appendChild(field_actual_INL);
        end
    end

    %Converting from DOM to XML
    xmlwrite(filename,docNode);

catch
    error_msg = 'Unable to save XML';
    success = 0;
    return
end
end
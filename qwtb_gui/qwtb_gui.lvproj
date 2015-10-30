<?xml version='1.0' encoding='UTF-8'?>
<Project Type="Project" LVVersion="13008000">
	<Property Name="CCSymbols" Type="Str"></Property>
	<Property Name="NI.LV.All.SourceOnly" Type="Bool">true</Property>
	<Property Name="NI.Project.Description" Type="Str">Q-Wave Toolbox Graphical User Interface</Property>
	<Item Name="My Computer" Type="My Computer">
		<Property Name="NI.SortType" Type="Int">3</Property>
		<Property Name="server.app.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.control.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.tcp.enabled" Type="Bool">false</Property>
		<Property Name="server.tcp.port" Type="Int">0</Property>
		<Property Name="server.tcp.serviceName" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.tcp.serviceName.default" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.vi.callsEnabled" Type="Bool">true</Property>
		<Property Name="server.vi.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="specify.custom.address" Type="Bool">false</Property>
		<Item Name="qwtb_lvlib" Type="Folder">
			<Item Name="Call Algorithm.vi" Type="VI" URL="../qwtb_lvlib/Call Algorithm.vi"/>
			<Item Name="Clear temporary variables.vi" Type="VI" URL="../qwtb_lvlib/Clear temporary variables.vi"/>
			<Item Name="Get Algorithms.vi" Type="VI" URL="../qwtb_lvlib/Get Algorithms.vi"/>
			<Item Name="Get Quantity.vi" Type="VI" URL="../qwtb_lvlib/Get Quantity.vi"/>
			<Item Name="Set MCM Calculation Settings.vi" Type="VI" URL="../qwtb_lvlib/Set MCM Calculation Settings.vi"/>
			<Item Name="Set Calculation Settings.vi" Type="VI" URL="../qwtb_lvlib/Set Calculation Settings.vi"/>
			<Item Name="Set QWTB Path.vi" Type="VI" URL="../qwtb_lvlib/Set QWTB Path.vi"/>
			<Item Name="Set DOF Settings.vi" Type="VI" URL="../qwtb_lvlib/Set DOF Settings.vi"/>
			<Item Name="Set Cor Settings.vi" Type="VI" URL="../qwtb_lvlib/Set Cor Settings.vi"/>
			<Item Name="Set Data Call Alg Get Data.vi" Type="VI" URL="../qwtb_lvlib/Set Data Call Alg Get Data.vi"/>
			<Item Name="Set Quantity.vi" Type="VI" URL="../qwtb_lvlib/Set Quantity.vi"/>
			<Item Name="VI Tree.vi" Type="VI" URL="../qwtb_lvlib/VI Tree.vi"/>
			<Item Name="TD DOF Calculation Settings.ctl" Type="VI" URL="../qwtb_lvlib/TD DOF Calculation Settings.ctl"/>
			<Item Name="TD Algorithm Information.ctl" Type="VI" URL="../qwtb_lvlib/TD Algorithm Information.ctl"/>
			<Item Name="TD Calculation Settings.ctl" Type="VI" URL="../qwtb_lvlib/TD Calculation Settings.ctl"/>
			<Item Name="TD Correlation Calculation Settings.ctl" Type="VI" URL="../qwtb_lvlib/TD Correlation Calculation Settings.ctl"/>
			<Item Name="TD MCM Calculation Method.ctl" Type="VI" URL="../qwtb_lvlib/TD MCM Calculation Method.ctl"/>
			<Item Name="TD MCM Calculation Settings.ctl" Type="VI" URL="../qwtb_lvlib/TD MCM Calculation Settings.ctl"/>
			<Item Name="TD Backend Engine.ctl" Type="VI" URL="../qwtb_lvlib/TD Backend Engine.ctl"/>
			<Item Name="TD Quantity.ctl" Type="VI" URL="../qwtb_lvlib/TD Quantity.ctl"/>
			<Item Name="TD Uncertainty Calculation Method.ctl" Type="VI" URL="../qwtb_lvlib/TD Uncertainty Calculation Method.ctl"/>
		</Item>
		<Item Name="compare two string arrays.vi" Type="VI" URL="../compare two string arrays.vi"/>
		<Item Name="globals.vi" Type="VI" URL="../globals.vi"/>
		<Item Name="main.vi" Type="VI" URL="../main.vi"/>
		<Item Name="Settings.vi" Type="VI" URL="../Settings.vi"/>
		<Item Name="Algorithms.vi" Type="VI" URL="../Algorithms.vi"/>
		<Item Name="Input Data.vi" Type="VI" URL="../Input Data.vi"/>
		<Item Name="Output Data.vi" Type="VI" URL="../Output Data.vi"/>
		<Item Name="TD GUI Settings.ctl" Type="VI" URL="../qwtb_lvlib/TD GUI Settings.ctl"/>
		<Item Name="Dependencies" Type="Dependencies">
			<Item Name="vi.lib" Type="Folder">
				<Item Name="compatCalcOffset.vi" Type="VI" URL="/&lt;vilib&gt;/_oldvers/_oldvers.llb/compatCalcOffset.vi"/>
				<Item Name="compatFileDialog.vi" Type="VI" URL="/&lt;vilib&gt;/_oldvers/_oldvers.llb/compatFileDialog.vi"/>
				<Item Name="compatOpenFileOperation.vi" Type="VI" URL="/&lt;vilib&gt;/_oldvers/_oldvers.llb/compatOpenFileOperation.vi"/>
				<Item Name="FindCloseTagByName.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/xml.llb/FindCloseTagByName.vi"/>
				<Item Name="FindElement.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/xml.llb/FindElement.vi"/>
				<Item Name="FindElementStartByName.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/xml.llb/FindElementStartByName.vi"/>
				<Item Name="FindEmptyElement.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/xml.llb/FindEmptyElement.vi"/>
				<Item Name="FindFirstTag.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/xml.llb/FindFirstTag.vi"/>
				<Item Name="FindMatchingCloseTag.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/xml.llb/FindMatchingCloseTag.vi"/>
				<Item Name="Open_Create_Replace File.vi" Type="VI" URL="/&lt;vilib&gt;/_oldvers/_oldvers.llb/Open_Create_Replace File.vi"/>
				<Item Name="ParseXMLFragments.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/xml.llb/ParseXMLFragments.vi"/>
				<Item Name="Read From XML File(array).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/xml.llb/Read From XML File(array).vi"/>
				<Item Name="Read From XML File(string).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/xml.llb/Read From XML File(string).vi"/>
				<Item Name="Read From XML File.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/xml.llb/Read From XML File.vi"/>
				<Item Name="Write to XML File(array).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/xml.llb/Write to XML File(array).vi"/>
				<Item Name="Write to XML File(string).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/xml.llb/Write to XML File(string).vi"/>
				<Item Name="Write to XML File.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/xml.llb/Write to XML File.vi"/>
				<Item Name="ex_CorrectErrorChain.vi" Type="VI" URL="/&lt;vilib&gt;/express/express shared/ex_CorrectErrorChain.vi"/>
				<Item Name="subFile Dialog.vi" Type="VI" URL="/&lt;vilib&gt;/express/express input/FileDialogBlock.llb/subFile Dialog.vi"/>
				<Item Name="Clear Errors.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Clear Errors.vi"/>
				<Item Name="Check if File or Folder Exists.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/libraryn.llb/Check if File or Folder Exists.vi"/>
				<Item Name="NI_FileType.lvlib" Type="Library" URL="/&lt;vilib&gt;/Utility/lvfile.llb/NI_FileType.lvlib"/>
				<Item Name="Error Cluster From Error Code.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Error Cluster From Error Code.vi"/>
				<Item Name="NI_PackedLibraryUtility.lvlib" Type="Library" URL="/&lt;vilib&gt;/Utility/LVLibp/NI_PackedLibraryUtility.lvlib"/>
			</Item>
		</Item>
		<Item Name="Build Specifications" Type="Build"/>
	</Item>
</Project>

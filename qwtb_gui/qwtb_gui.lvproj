<?xml version='1.0' encoding='UTF-8'?>
<Project Type="Project" LVVersion="13008000">
	<Property Name="CCSymbols" Type="Str"></Property>
	<Property Name="NI.LV.All.SourceOnly" Type="Bool">true</Property>
	<Property Name="NI.Project.Description" Type="Str">Q-Wave Toolbox Graphical User Interface</Property>
	<Item Name="My Computer" Type="My Computer">
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
			<Item Name="call_alg.vi" Type="VI" URL="../qwtb_lvlib/call_alg.vi"/>
			<Item Name="get_algs.vi" Type="VI" URL="../qwtb_lvlib/get_algs.vi"/>
			<Item Name="get_quantity.vi" Type="VI" URL="../qwtb_lvlib/get_quantity.vi"/>
			<Item Name="set_calcset.vi" Type="VI" URL="../qwtb_lvlib/set_calcset.vi"/>
			<Item Name="set_quantity.vi" Type="VI" URL="../qwtb_lvlib/set_quantity.vi"/>
			<Item Name="TD Algorithm Information.ctl" Type="VI" URL="../qwtb_lvlib/TD Algorithm Information.ctl"/>
			<Item Name="TD Calculation Settings.ctl" Type="VI" URL="../qwtb_lvlib/TD Calculation Settings.ctl"/>
			<Item Name="TD Quantity.ctl" Type="VI" URL="../qwtb_lvlib/TD Quantity.ctl"/>
		</Item>
		<Item Name="main.vi" Type="VI" URL="../main.vi"/>
		<Item Name="Dependencies" Type="Dependencies"/>
		<Item Name="Build Specifications" Type="Build"/>
	</Item>
</Project>

function dep(indir,main,reclim,others,fileout)

% dep(indir,main,reclim,others,fileout)
%
% Matlab/Octave dependency report
% version 1.7 / 06.04.2010
% Thomas Guillod
%
% Find the dependencies of a .m file.
% Show the dependencies for each file.
% Show the dependencies (recursive) from the main file.
% Create a .dot file (graphviz file).
% Draw the graph (only if you have graphviz dot).
%     red arrows - recursion loop
%     green box - item from 'others' argument
%
% Arguments
% =========
% indir   - search directory (string), ex: 'src'
% main    - main file for recursion (string), ex: 'src/main.m'
% reclim  - limit for the number of recursive calls (int), ex: 3 or inf
% others  - add local, extern functions in the search paths (struct), ex: {'fct1','fct3'}
% fileout - name of the output files (string), ex: 'fout'
%
% Examples
% ========
% dep('src','src/main.m',3,{'fct1','fct3'},'fout')
% dep('src','src/main.m',inf,{'fct1','fct2','fct3','fct4'},'fout')
% 
% produces 'fout.txt', 'fout.dot', 'fout.pdf'
%
% Then control the results, modify the dot file and do in yor favorite shell:
% $ dot -Tpdf tout.dot -o fout.pdf
% 
% Limitations
% ===========
%
% The MATLAB/Octave language is not a strong typed language. Static code analysis is very hard (and in many
% case impossible).
%
%    - only one function per file, don't take the local functions (workaround with 'others' arguement)
%    - no support for script (workaround: call the script with brackets myscript();)
%    - nasty comment (ex: some content % foobar(), the program will find a call of foobar())
%    - function declaration in two (or more) lines (the keyword 'function' is not at the same line as foobar())
%    - dependent of Unix: you need find, grep, sed, sort and uniq (workaround: rewrite 'list.sh' and 'dep.sh')
%    - function call with a function handle (@f)
%    - dynamic evaluation (eval())
%    - some others bugs (this is a quick and dirty program)


if ~isunix()
    disp('not a unix system, sorry...')
end

% find the list of the file
[ex,txt] = unix(['./list.sh ',indir]);

% add the function from the arguments (*.m file + others cell array)
fid = fopen ('deptmp/grep_file','a');
for i=[1:length(others)]
    fprintf(fid,'%s\\(\n',others{i});
end
fclose(fid);

% load the list of the files (without path, without ext)
fid = fopen ('deptmp/file_list_short_noext');
txt = fgetl (fid);
i=1;
while txt>0
    name{i}=txt;
    txt = fgetl (fid);
    i=i+1;
end
fclose(fid);

% load the list of the files (with path, with ext)
fid = fopen ('deptmp/file_list_comp');
txt = fgetl (fid);
i=1;
while txt>0
    namelong{i}=txt;
    txt = fgetl (fid);
    i=i+1;
end
fclose(fid);

% diplay the dependence of all the files
fout = fopen ([fileout '.txt'],'w');
displ(fout,'---------------------------');
displ(fout,'-------ALL THE FILE--------');
displ(fout,'---------------------------');

% for all files
for i=[1:length(namelong)]
    displ(fout,namelong{i});
    % find the dependence
    node = depend(namelong{i},name,namelong);
    % for all dependence
    for j=[1:length(node)]
        % if it comes from 'others' cell arrax
        if strcmp(node(j).namelong,'none')==1
            displ(fout,['    ' node(j).name ' : ' num2str(node(j).number)]);
        % if it comes from a *.m file
        else
            displ(fout,['    ' node(j).namelong ' : ' num2str(node(j).number)]);
        end
    end
end

% display the dependence for main (recursion)
displ(fout,'---------------------------');
displ(fout,'-------DEP OF MAIN---------');
displ(fout,'---------------------------');

fdot = fopen ('deptmp/graph.dot','w');
% compute the root
root = depend(main,name,namelong);
displ(fout,main);
father=short(main,name,namelong);
walklist{1}=main;
% recursion
recu(root,name,namelong,1,reclim,walklist,father,fout,fdot);

fclose(fout);
fclose(fdot);

[ex,txt] = unix(['./dot.sh ' fileout]);

% remove temp files
[ex,txt] = unix('rm -rf deptmp');

end


function recu(node,name,namelong,count,reclim,walklist,father,fout,fdot)
% compute the dependence of the file 'node' (recursion)

% break the recursion (if too deep)
if count>=reclim
    return;
end

% indentation
blank=repmat(' ',1,4);
indent = [];
for i=[1:count]
    indent = [indent '¦' blank];
end

% for all childrens
for i=[1:length(node)]
    % if it comes from 'others' cell arrax
    if strcmp(node(i).namelong,'none')==1
        displ(fout,[indent node(i).name ' : ' num2str(node(i).number)]);
	dot(fdot,father,node(i).name,node(i).number,'others');
    % if it comes from a *.m file
    else
        % search for loop in the calls
        flag =0;
        j=1;
        while j<=length(walklist) && flag==0
            % if there is a loop
            if strcmp(walklist{j},node(i).namelong)==1
                displ(fout,[indent node(i).namelong ' : loop : ' num2str(node(i).number)]);
	        dot(fdot,father,node(i).name,node(i).number,'loop');
                flag=1;
            end
            j=j+1;
        end
        % if no loop => continue
        if flag==0
            displ(fout,[indent node(i).namelong ' : ' num2str(node(i).number)]);
	    dot(fdot,father,node(i).name,node(i).number,'normal');

            % blacklist the name
            tmp=node(i).name;

            tmplong=walklist;
            tmplong{end+1}=node(i).namelong;

            % compute the dependence
            node2 = depend(node(i).namelong,name,namelong);
            % recursion
            recu(node2,name,namelong,count+1,reclim,tmplong,tmp,fout,fdot)
        end
    end
end

end


function line=depend(file,name,namelong)
% find the dependence of the file 'file'

% if it comes from 'others' cell arrax => no dependence
if strcmp(file,'none')==1
    line={};
    return;
end

% compute the dependence
[ex,txt] = unix(['./dep.sh ',file]);

% process the dependence name
fid = fopen ('deptmp/dep_list');
txt = fgetl (fid);
i=1;
% for all the dependence
while txt>0
    flag=1;
    k=1;
    % find the number of the dependence (which file it is)
    while k<=length(name) && flag==1
        if (strcmp(txt,name{k}) == 1)
            flag=0;
        end
        k=k+1;
    end
    % if no match => come form 'others' cell array
    if flag==1
        line(i).idx=0;
        line(i).namelong='none';
    % if match => put the name of the file (and the number)
    else
        line(i).idx=k-1;
        line(i).namelong=namelong{k-1};
    end

    % put the short name
    line(i).name=txt;
    
    txt = fgetl (fid);
    i=i+1;
end
fclose(fid);

% process the dependence line number
fid = fopen ('deptmp/dep_number');
txt = fgetl (fid);
i=1;
% for all the depandance	
while txt>0
    % take the line number
    line(i).number=str2num(txt);
    txt = fgetl (fid);
    i=i+1;
end
fclose(fid);

% if there is no dependence
if i==1
    line={};
end

end


function  str=short(file,name,namelong)
% find the short name of a file from the long name
% foo/foobar.m => foobar

for i=[1:length(name)]
    if strcmp(file,namelong{i})==1
        str=name{i};
        return;
    end
end
str={};
end


function displ(fid,str)
% wrapper for disp
    disp(str);
    fprintf(fid,'%s\n',str);
end


function dot(fid,str1,str2,line,type)
% parse the output dor graphviz dot

%fdisp(fid,['    "' str1 '" -> "' str2 '" [label="' num2str(line) '"];']);

if strcmp(type,'normal')
    fprintf(fid,'    "%s" -> "%s";\n',str1,str2);
elseif strcmp(type,'others')
    fprintf(fid,'    "%s" -> "%s";\n',str1,str2);
    fprintf(fid,'    "%s" [color=green];\n',str2);
elseif strcmp(type,'loop')
    fprintf(fid,'    "%s" -> "%s" [color=red];\n',str1,str2);
end

end

%% Betterpublish
% Reformats output of GNU Octave publish command to a better result optimized
% for QWTB documentation. It is called by publish_all_algs2tex.m and
% publish_all_examples2tex.m.
%
% This will not work with Matlab, because Matlab output is quite different. See
% previous versions of this script in git to get Matlab compatible version.
%
% Script is very dependent on actual output of publish command, so when Octave
% version changes, this script probably has to be changed also!
%
% Tested with Octave version 9.1.0

function outstr = betterpublish(instr, imgprefix, change_rank)
% the order of following commands IS important. It uses a set of regular
% expression substitutes.

% Delete whole heading up to \tableofcontents, so it can be included into the
% main document. Add start of local table of contents.
tmp = '\\startcontents[localtoc]\n\\printcontents[localtoc]{}{0}{\\section\*{Contents}\\setcounter{tocdepth}{2}}';
instr = regexprep(instr, '.*\\tableofcontents\n\\vspace\*{4em}', tmp, 'dotall');
% And replace \end{document} by end of local table of contents:
instr = regexprep(instr, '\\end{document}', '\\stopcontents[localtoc]', 'dotexceptnewline');

if change_rank
    % Change rank of sub/sub/sections for better integration into main document.
    % subsection -> subsubsection
    instr = regexprep(instr, '\\subsection(.*)', '\\subsubsection$1', 'dotexceptnewline');
    % section -> subsection
    instr = regexprep(instr, '\\section(.*)', '\\subsection$1', 'dotexceptnewline');
end

    % Matlab leftover:
    % % change texttt{http...} to hyperref package link:
    % %sed -i 's/\\begin{verbatim}http:\(.*\)\\end{verbatim}/\\url{http:\1}/' "$origf"
    % instr = regexprep(instr, '\\begin{verbatim}http:(.*)\\end{verbatim}', '\\url{http:$1}', 'dotexceptnewline');
    % % email adresses etc. are also enclosed by verbatim, but has no new line inside:
    % instr = regexprep(instr, '\\begin{verbatim}([^\n]*)\\end{verbatim}', '\\verb"$1"', 'dotexceptnewline');

    % % change \end{verbatim} to \end{lstlisting}
    % %sed -i 's/\\end{verbatim}/\\end{lstlisting}/' "$origf"
    % instr = regexprep(instr, '\\end{verbatim}', '\\end{lstlisting}', 'dotexceptnewline');
    % % change lightgray-verbatim to lstlisting style output
    % %sed -i 's/\\color{lightgray} \\begin{verbatim}/\\begin{lstlisting}[style=output]\n/' "$origf"
    % instr = regexprep(instr, '\\color{lightgray} \\begin{verbatim}', '\\begin{lstlisting}[style=output]\n', 'dotexceptnewline');
    % % change \begin{verbatim} to \begin{lstlisting}[style=mcode]
    % %sed -i 's/\\begin{verbatim}/\\begin{lstlisting}[style=mcode]/' "$origf"
    % instr = regexprep(instr, '\\begin{verbatim}', '\\begin{lstlisting}[style=mcode]', 'dotexceptnewline');
    % % change \texttt to \lstinline
    % %sed -i 's/\\texttt/\\lstinline/g' "$origf"
    % instr = regexprep(instr, '\\texttt', '\\lstinline', 'dotexceptnewline');

% Change path to images, replace environment {figure} by environment {center},
% set width of images to 0.7 of \textwidth
    % % for algorithms:
    % tmp = [ '\\begin{center}\n\\includegraphics[width=0.7\\textwidth]{' imgprefix '_alg_example$1.pdf}\n\\end{center}' ];
    % instr = regexprep(instr, '\\begin{figure}\[!ht\]\n\\includegraphics.*alg_example(.*).eps}\n\\end{figure}', tmp, 'dotexceptnewline');
    %
    % % for qwtb examples:
    % tmp = [ '\\begin{center}\n\\includegraphics[width=0.7\\textwidth]{' imgprefix 'qwtb_example$1.pdf}\n\\end{center}' ];
    % instr = regexprep(instr, '\\begin{figure}\[!ht\]\n\\includegraphics.*qwtb_example(.*).pdf}\n\\end{figure}', tmp, 'dotexceptnewline');
tmp = [ '\\begin{center}\n\\includegraphics[width=0.7\\textwidth]{' imgprefix '$1.pdf}\n\\end{center}' ];
instr = regexprep(instr, '\\begin{figure}\[!ht\]\n\\includegraphics.*{(.*).pdfcrop}\n\\end{figure}', tmp, 'dotexceptnewline');

outstr = instr;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4

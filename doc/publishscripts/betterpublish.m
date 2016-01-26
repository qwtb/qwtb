%% reformats output of matlab publish command to a better result optimized for
% QWTB documentation. It is called by publish_all_algs.m and
% publish_all_examples.m.

function outstr = betterpublish(instr, imgprefix)
% the order of following commands IS important. It uses a set of regular
% expression substitutes.

% comment headings
%sed -i 's/\(\\documentclass{article}\)$/%%% \1/' "$origf"
instr = regexprep(instr, '(\\documentclass{article})', '%%% $1', 'dotexceptnewline');
% comment usepackages
% sed -i 's/\(\\usepackage.*\)$/%%% \1/' "$origf"
instr = regexprep(instr, '(\\usepackage.*)', '%%% $1', 'dotexceptnewline');

% comment defined light gray (it is too dark)
%sed -i 's/\(\\definecolor.*\)$/%%% \1/' "$origf"
instr = regexprep(instr, '(\\definecolor.*)', '%%% $1', 'dotexceptnewline');
% comment sloppy
% sed -i 's/\(\\sloppy.*\)$/%%% \1/' "$origf"
instr = regexprep(instr, '(\\sloppy.*)', '%%% $1', 'dotexceptnewline');
% comment begin document
%sed -i 's/\(\\begin{document}\)$/%%% \1/' "$origf"
instr = regexprep(instr, '(\\begin{document})', '%%% $1', 'dotexceptnewline');
% comment end document
%sed -i 's/\(\\end{document}\)$/%%% \1/' "$origf"
instr = regexprep(instr, '(\\end{document})', '%%% $1', 'dotexceptnewline');

% change subsections* to subsubsections
%sed -i 's/\\subsection\(.*\)$/\\subsubsection\1/' "$origf"
instr = regexprep(instr, '\\subsection(.*)', '\\subsubsection$1', 'dotexceptnewline');
% change sections* to subsections
%sed -i 's/\\section\(.*\)$/\\subsection\1/' "$origf"
instr = regexprep(instr, '\\section(.*)', '\\subsection$1', 'dotexceptnewline');

% change texttt{http...} to hyperref package link:
%sed -i 's/\\begin{verbatim}http:\(.*\)\\end{verbatim}/\\url{http:\1}/' "$origf"
instr = regexprep(instr, '\\begin{verbatim}http:(.*)\\end{verbatim}', '\\url{http:$1}', 'dotexceptnewline');
% email adresses etc. are also enclosed by verbatim, but has no new line inside:
instr = regexprep(instr, '\\begin{verbatim}([^\n]*)\\end{verbatim}', '\\verb"$1"', 'dotexceptnewline');

% change \end{verbatim} to \end{lstlisting}
%sed -i 's/\\end{verbatim}/\\end{lstlisting}/' "$origf"
instr = regexprep(instr, '\\end{verbatim}', '\\end{lstlisting}', 'dotexceptnewline');
% change lightgray-verbatim to lstlisting style output
%sed -i 's/\\color{lightgray} \\begin{verbatim}/\\begin{lstlisting}[style=output]\n/' "$origf"
instr = regexprep(instr, '\\color{lightgray} \\begin{verbatim}', '\\begin{lstlisting}[style=output]\n', 'dotexceptnewline');
% change \begin{verbatim} to \begin{lstlisting}[style=mcode]
%sed -i 's/\\begin{verbatim}/\\begin{lstlisting}[style=mcode]/' "$origf"
instr = regexprep(instr, '\\begin{verbatim}', '\\begin{lstlisting}[style=mcode]', 'dotexceptnewline');
% change \texttt to \lstinline
%sed -i 's/\\texttt/\\lstinline/g' "$origf"
instr = regexprep(instr, '\\texttt', '\\lstinline', 'dotexceptnewline');

% change path to images
% for algorithms:
tmp = [ '\\begin{center}\n\\includegraphics[width=0.7\\textwidth]{' imgprefix '_alg_example$1.pdf}\n\\end{center}' ];
instr = regexprep(instr, '\\includegraphics.*alg_example(.*).eps}', tmp, 'dotexceptnewline');

% for qwtb examples:
tmp = [ '\\begin{center}\n\\includegraphics[width=0.7\\textwidth]{' imgprefix 'qwtb_example$1.pdf}\n\\end{center}' ];
instr = regexprep(instr, '\\includegraphics.*qwtb_example(.*).eps}', tmp, 'dotexceptnewline');

outstr = instr;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4

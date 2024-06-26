% Function converts string to something compatible to latex

function s = texify(s)
    % replace underscores:
    s = strrep(s, '_', '\_');
end % function texify


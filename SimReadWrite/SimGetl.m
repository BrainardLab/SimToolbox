function [buf] = SimGetl(file)% [buf] = SimGetl(file)%% Reads a string and discards comments (lines starting with "# " or "#!#Sim"),% blank lines, and lines containing only "#". %% 10/29/98  dhb  Add comments.%           dhb  Replace isEqualN by strncmp% 1/19/99   dhb  Change name and let "# " be a comment too.% Copyright (c) 1999 David Brainard and Philippe Longere.   All rights reserved.buf = '';while (isempty(buf) | buf(1) == ' ' | ...	strncmp(buf,'#!#Sim',5) | strncmp(buf,'# ',2) | buf == '#' )	buf = fgetl(file);end
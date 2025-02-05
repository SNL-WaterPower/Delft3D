function varargout=realset(varargin)
%REALSET Manipulate sets of real values.
%
%   [SetStruct,SimplifiedSetString]=REALSET(SetString)
%
%   SetString=REALSET(SetStruct)
%
%   Set2=REALSET('not',Set1)
%
%   Y=REALSET('keep',SetStruct,X)
%   Y=REALSET('clip',SetStruct,X)

%----- LGPL --------------------------------------------------------------------
%                                                                               
%   Copyright (C) 2011-2015 Stichting Deltares.                                     
%                                                                               
%   This library is free software; you can redistribute it and/or                
%   modify it under the terms of the GNU Lesser General Public                   
%   License as published by the Free Software Foundation version 2.1.                         
%                                                                               
%   This library is distributed in the hope that it will be useful,              
%   but WITHOUT ANY WARRANTY; without even the implied warranty of               
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU            
%   Lesser General Public License for more details.                              
%                                                                               
%   You should have received a copy of the GNU Lesser General Public             
%   License along with this library; if not, see <http://www.gnu.org/licenses/>. 
%                                                                               
%   contact: delft3d.support@deltares.nl                                         
%   Stichting Deltares                                                           
%   P.O. Box 177                                                                 
%   2600 MH Delft, The Netherlands                                               
%                                                                               
%   All indications and logos of, and references to, "Delft3D" and "Deltares"    
%   are registered trademarks of Stichting Deltares, and remain the property of  
%   Stichting Deltares. All rights reserved.                                     
%                                                                               
%-------------------------------------------------------------------------------
%   http://www.deltaressystems.com
%   $HeadURL: https://svn.oss.deltares.nl/repos/delft3d/branches/research/Deltares/20160119_tidal_turbines/src/tools_lgpl/matlab/quickplot/progsrc/private/realset.m $
%   $Id: realset.m 4612 2015-01-21 08:48:09Z mourits $

switch nargin
    case 3
        cmd = varargin{1};
        switch lower(cmd)
            case 'keep'
                Set = realsetinverse(varargin{2});
                Y = realsetapply(Set,varargin{3});
                varargout = {Y};
            case 'clip'
                Y = realsetapply(varargin{2:3});
                varargout = {Y};
        end
    case 2
        if ischar(varargin{1})
            cmd = varargin{1};
            switch lower(cmd)
                case 'not'
                    Set = realsetinverse(varargin{2});
                    varargout={Set};
                otherwise
                    %
                    % apply SetStruct as 'clip'
                    %
                    Y = realsetapply(varargin{1:2});
                    varargout = {Y};
            end
        else
            %
            % apply SetStruct as 'clip'
            %
            Y = realsetapply(varargin{1:2});
            varargout = {Y};
        end
    case 1
        if ischar(varargin{1})
            [varargout{1:max(nargout,1)}] = string2realset(varargin{1});
        else
            str=realset2string(varargin{1});
            varargout={str};
        end
end

function X = realsetapply(Set,X)
if ischar(Set)
    c1=realset(Set);
else
    c1=Set;
end
if isfinite(c1.min)
    if c1.minkeep
        X(X<c1.min)=NaN;
    else
        X(X<=c1.min)=NaN;
    end
end
if isfinite(c1.max)
    if c1.maxkeep
        X(X>c1.max)=NaN;
    else
        X(X>=c1.max)=NaN;
    end
end
if ~isempty(c1.val)
    X(ismember(X(:),c1.val(:)))=NaN;
end
for i=1:size(c1.range,1)
    Y=X(:)>c1.range(i,1) | (X(:)==c1.range(i,1) & ~c1.rangeminmaxkeep(i,1));
    Y=Y & (X(:)<c1.range(i,2) | (X(:)==c1.range(i,2) & ~c1.rangeminmaxkeep(i,2)));
    X(Y)=NaN;
end

function c2 = realsetinverse(c1)
c2 = emptyset;
%
v1=c1.min;
v1keep=c1.minkeep;
%
val=c1.val;
range=c1.range;
rangeminmaxkeep=c1.rangeminmaxkeep;
while ~isempty(val) | ~isempty(range)
    if isempty(val)
        K=range(:,1);
    elseif isempty(range)
        K=val;
    else
        K=cat(2,val,range(:,1)');
    end
    [mnk,k]=min(K);
    if k>length(val)
        i = k-length(val);
        if isfinite(v1)
            c2.range = cat(1,c2.range,[v1 range(i,1)]);
            c2.rangeminmaxkeep = cat(1,c2.rangeminmaxkeep,[~v1keep ~rangeminmaxkeep(i,1)]);
        else
            c2.min = range(i,1);
            c2.minkeep = ~rangeminmaxkeep(i,1);
        end
        v1 = range(i,2);
        v1keep = rangeminmaxkeep(i,2);
        %
        range(i,:)=[];
        rangeminmaxkeep(i,:)=[];
    else
        if isfinite(v1)
            c2.range = cat(1,c2.range,[v1 mnk]);
            c2.rangeminmaxkeep = cat(1,c2.rangeminmaxkeep,[~v1keep 1]);
        else
            c2.min = range(i,1);
            c2.minkeep = 1;
        end
        v1 = mnk;
        v1keep = 0;
        %
        val(k)=[];
    end
end
if isfinite(c1.max)
    if isfinite(v1)
        c2.range = cat(1,c2.range,[v1 c1.max]);
        c2.rangeminmaxkeep = cat(1,c2.rangeminmaxkeep,[~v1keep ~c1.maxkeep]);
    else
        c2.min = c1.max;
        c2.minkeep = ~c1.maxkeep;
    end
else
    if isfinite(v1)
        c2.max = v1;
        c2.maxkeep = ~v1keep;
    else
        % c1 set is empty, c2 set should contain all ...
        c2.min=0;
        c2.minkeep=0;
        c2.max=0;
        c2.maxkeep=1;
    end
end
%
equalvals = find(c2.range(:,1)==c2.range(:,2))';
for i=equalvals
    if c2.rangeminmaxkeep(i,1)==0 & ...
            c2.rangeminmaxkeep(i,2)==0
        c2.val=cat(2,c2.val,c2.range(i,1));
    end
end
c2.range(equalvals,:)=[];
c2.rangeminmaxkeep(equalvals,:)=[];

function clipstruct = emptyset
clipstruct.val=[];
clipstruct.range=zeros(0,2);
clipstruct.rangeminmaxkeep=zeros(0,2);
clipstruct.min=-inf;
clipstruct.minkeep=0;
clipstruct.max=inf;
clipstruct.maxkeep=0;

function varargout = string2realset(str)
fullstr=str;
clipstruct = emptyset;
str1='';
while ~isempty(str) | ~isempty(str1)
    if isempty(str)
        str=' ';
    end
    [v,N,err,i] = sscanf(str,' %f',[1 inf]);
    switch str1
        case {'',' '}
            if ~isempty(v)
                clipstruct.val=cat(2,clipstruct.val,v);
            end
        case {'>','>='}
            if isequal(str(1),' ')
                error('%s\n%s',fullstr,'A value should directly follow a > sign.')
            else
                clipstruct.max=cat(1,clipstruct.max,v(1));
                clipstruct.maxkeep=cat(1,clipstruct.maxkeep,length(str1)==1);
                if N>1
                    clipstruct.val=cat(2,clipstruct.val,v(2:end));
                end
            end
        case {'<','<='}
            if isequal(str(1),' ')
                error('%s\n%s',fullstr,'A value should directly follow a < sign.')
            else
                clipstruct.min=cat(1,clipstruct.min,v(1));
                clipstruct.minkeep=cat(1,clipstruct.minkeep,length(str1)==1);
                if N>1
                    clipstruct.val=cat(2,clipstruct.val,v(2:end));
                end
            end
        case {'[','('}
            if isequal(size(v),[1 2])
                if i>length(str) | (~strcmp(str(i),']') & ~strcmp(str(i),')'))
                    error('%s\n%s',fullstr,'Missing closing bracket ] or ) for range')
                end
                clipstruct.range=cat(1,clipstruct.range,sort(v));
                rangeminkeep=strcmp(str1,'(');
                rangemaxkeep=strcmp(str(i),')');
                clipstruct.rangeminmaxkeep=cat(1,clipstruct.rangeminmaxkeep,[rangeminkeep rangemaxkeep]);
                str(i)=' ';
            else
                error('%s\n%s',fullstr,'A range should consist of 2 values.')
            end
        otherwise
            error('Unexpected character: %s.',str1)
    end
    if i>length(str)
        str=cat(2,str,' ');
    end
    str1=str(i);
    str0=' ';
    if i>1
        str0=str(i-1);
    end
    if ~isequal(str0,' ') & (strcmp(str1,'<') | strcmp(str1,'>'))
        error('%s\nThere should be a space before a %s sign.',fullstr,str1)
    end
    str=str(i+1:end);
    if strcmp(str1,'>') | strcmp(str1,'<')
        if ~isempty(str) & strcmp(str(1),'='),
            str1=[str1 '='];
            str=str(2:end);
        end
    end
    if strcmp(str1,' ') & isempty(str)
        break
    end
end
clipstruct.val=unique(clipstruct.val);

newmin=max(clipstruct.min);
i=find(clipstruct.min==newmin);
if length(i)>1
    clipstruct.minkeep=all(clipstruct.minkeep(i));
    clipstruct.min=clipstruct.min(i(1));
else
    clipstruct.minkeep=clipstruct.minkeep(i);
    clipstruct.min=clipstruct.min(i);
end
newmax=min(clipstruct.max);
i=find(clipstruct.max==newmax);
if length(i)>1
    clipstruct.maxkeep=all(clipstruct.maxkeep(i));
    clipstruct.max=clipstruct.max(i(1));
else
    clipstruct.maxkeep=clipstruct.maxkeep(i);
    clipstruct.max=clipstruct.max(i);
end
c1=clipstruct;
c2=[];
while ~isequal(c1,c2)
    c2=c1;
    if c1.maxkeep
        if any(c1.val>c1.max)
            c1.val=c1.val(c1.val<=c1.max);
        end
        if ~isempty(c1.val) & any(c1.val==c1.max)
            c1.val=c1.val(c1.val~=c1.max);
            c1.maxkeep=0;
        end
    else
        if any(c1.val>=c1.max)
            c1.val=c1.val(c1.val<c1.max);
        end
    end
    if c1.maxkeep
        I=c1.range>c1.max | (c1.range==c1.max & ~c1.rangeminmaxkeep);
    else
        I=c1.range>=c1.max;
    end
    II=any(I,2); III=all(I,2); JJ=c1.range(II&~III,1); JJkeep=c1.rangeminmaxkeep(II&~III,1);
    c1.rangeminmaxkeep(II,:)=[];
    c1.range(II,:)=[];
    if ~isempty(JJ)
        [c1.max,jj]=min(JJ(:));
        c1.maxkeep=JJkeep(jj);
    end
    %-------
    if c1.minkeep
        if any(c1.val<c1.min)
            c1.val=c1.val(c1.val>=c1.min);
        end
        if ~isempty(c1.val) & any(c1.val==c1.min)
            c1.val=c1.val(c1.val~=c1.min);
            c1.minkeep=0;
        end
    else
        if any(c1.val<=c1.min)
            c1.val=c1.val(c1.val>c1.min);
        end
    end
    I=c1.range<=c1.min;
    if c1.minkeep
        I=c1.range<c1.min | (c1.range==c1.min & ~c1.rangeminmaxkeep);
    else
        I=c1.range<=c1.min;
    end
    II=any(I,2); III=all(I,2); JJ=c1.range(II&~III,2); JJkeep=c1.rangeminmaxkeep(II&~III,2);
    c1.rangeminmaxkeep(II,:)=[];
    c1.range(II,:)=[];
    if ~isempty(JJ)
        [c1.min,jj]=max(JJ(:));
        c1.minkeep=JJkeep(jj);
    end
    %------- convert ranges with min==max to value
    i=1;
    while i<=size(c1.range,1)
        if c1.range(i,1)==c1.range(i,2)
            c1.val(1,end+1)=c1.range(i,1);
            c1.range(i,:)=[];
        else
            i=i+1;
        end
    end
    %-------
    i=1;
    while i<=size(c1.range,1)
        if ~isempty(c1.val)
            II=(c1.val>c1.range(i,1) | (c1.val==c1.range(i,1) & ~c1.rangeminmaxkeep(i,1))) & ...
                (c1.val<c1.range(i,2) | (c1.val==c1.range(i,2) & ~c1.rangeminmaxkeep(i,2)));
            if any(II), c1.val=c1.val(~II); end
        end
        if ~isempty(c1.val)
            if c1.val==c1.range(i,1)
                c1.rangeminmaxkeep(i,1)=0;
                c1.val(c1.val==c1.range(i,1))=[];
            end
            if ~isempty(c1.val)
                if c1.val==c1.range(i,2)
                    c1.rangeminmaxkeep(i,2)=0;
                    c1.val(c1.val==c1.range(i,2))=[];
                end
            end
        end
        j=i+1;
        while j<=size(c1.range,1)
            if (c1.range(j,1)>c1.range(i,1) | (c1.range(j,1)==c1.range(i,1) & (~c1.rangeminmaxkeep(i,1) | ~c1.rangeminmaxkeep(j,1)) )) & ...
                    (c1.range(j,1)<c1.range(i,2) | (c1.range(j,1)==c1.range(i,2) & (~c1.rangeminmaxkeep(i,2) | ~c1.rangeminmaxkeep(j,1)) )) % j overlaps at max, j inside i
                if c1.range(i,1)==c1.range(j,1)
                    c1.rangeminmaxkeep(i,1)=all(c1.rangeminmaxkeep([i j],1));
                end
                if c1.range(i,2)<c1.range(j,2)
                    c1.range(i,2)=c1.range(j,2);
                    c1.rangeminmaxkeep(i,2)=c1.rangeminmaxkeep(j,2);
                elseif c1.range(i,2)==c1.range(j,2)
                    c1.rangeminmaxkeep(i,2)=all(c1.rangeminmaxkeep([i j],2));
                end
                c1.range(j,:)=[];
                c1.rangeminmaxkeep(j,:)=[];
            elseif (c1.range(j,2)>c1.range(i,1) | (c1.range(j,2)==c1.range(i,1) & (~c1.rangeminmaxkeep(i,1) | ~c1.rangeminmaxkeep(j,2)) )) & ...
                    (c1.range(j,2)<c1.range(i,2) | (c1.range(j,2)==c1.range(i,2) & (~c1.rangeminmaxkeep(i,2) | ~c1.rangeminmaxkeep(j,2)) )) % j overlaps at min
                if c1.range(i,1)>c1.range(j,1)
                    c1.range(i,1)=c1.range(j,1);
                    c1.rangeminmaxkeep(i,1)=c1.rangeminmaxkeep(j,1);
                elseif c1.range(i,1)==c1.range(j,1)
                    c1.rangeminmaxkeep(i,1)=all(c1.rangeminmaxkeep([i j],1));
                end
                c1.range(j,:)=[];
                c1.rangeminmaxkeep(j,:)=[];
            elseif (c1.range(i,1)>c1.range(j,1) | (c1.range(i,1)==c1.range(j,1) & (~c1.rangeminmaxkeep(i,1) | ~c1.rangeminmaxkeep(j,1)) )) & ...
                    (c1.range(i,1)<c1.range(j,2) | (c1.range(i,1)==c1.range(j,2) & (~c1.rangeminmaxkeep(i,1) | ~c1.rangeminmaxkeep(j,2)) )) % i inside j
                c1.range(i,:)=[];
                c1.rangeminmaxkeep(i,:)=[];
                i=i-1;
                break
            else
                j=j+1;
            end
        end
        i=i+1;
    end
end
if c1.min>c1.max
    c1.min=c1.max;
    c1.maxkeep=c1.maxkeep & ~c1.minkeep;
end
%
if nargout>1
    varargout={c1 realset(c1)};
else
    varargout={c1};
end

function str=realset2string(c1)
str='';
eql='=';
if c1.minkeep, eql=''; end
if isfinite(c1.min), str=sprintf('<%s%g ',eql,c1.min); end
val=c1.val;
range=c1.range;
rangeminmaxkeep=c1.rangeminmaxkeep;
while ~isempty(val) | ~isempty(range)
    if isempty(val)
        K=range(:,1);
    elseif isempty(range)
        K=val;
    else
        K=cat(2,val,range(:,1)');
    end
    [mnk,k]=min(K);
    if k>length(val)
        i=k-length(val);
        lrkeep='[';
        if rangeminmaxkeep(i,1), lrkeep='('; end
        urkeep=']';
        if rangeminmaxkeep(i,2), urkeep=')'; end
        str=cat(2,str,sprintf('%s%g %g%s ',lrkeep,range(i,:),urkeep));
        range(i,:)=[];
        rangeminmaxkeep(i,:)=[];
    else
        str=cat(2,str,sprintf('%g ',mnk));
        val(k)=[];
    end
end
eql='=';
if c1.maxkeep, eql=''; end
if isfinite(c1.max), str=cat(2,str,sprintf('>%s%g ',eql,c1.max)); end
if isempty(str)
    str='';
else
    str=str(1:end-1); % remove last space
end

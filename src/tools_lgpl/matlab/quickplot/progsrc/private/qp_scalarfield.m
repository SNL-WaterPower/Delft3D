function hNew = qp_scalarfield(Parent,hNew,presentationtype,datatype,varargin)
%QP_SCALARFIELD Plot scalar data for curvilinear and triangular meshes.
%   H = QP_SCALARFIELD(PARENT,H,PLOTTYPE,'TRI',TRI,XYZ,VAL,OPTIONS)
%   H = QP_SCALARFIELD(PARENT,H,PLOTTYPE,'QUAD',X,Y,Z,VAL,OPTIONS)
%   H = QP_SCALARFIELD(PARENT,H,PLOTTYPE,'UGRID',DATA,OPTIONS)

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
%   $HeadURL: https://svn.oss.deltares.nl/repos/delft3d/branches/research/Deltares/20160119_tidal_turbines/src/tools_lgpl/matlab/quickplot/progsrc/private/qp_scalarfield.m $
%   $Id: qp_scalarfield.m 5507 2015-10-20 09:50:46Z jagers $ 

switch datatype
    case 'TRI'
        hNew = qp_scalarfield_tri(Parent,hNew,presentationtype,varargin{:});
    case 'QUAD'
        hNew = qp_scalarfield_quad(Parent,hNew,presentationtype,varargin{:});
    case 'UGRID'
        hNew = qp_scalarfield_ugrid(Parent,hNew,presentationtype,varargin{:});
end

function hNew = qp_scalarfield_quad(Parent,hNew,presentationtype,X,Y,Z,Val,Ops)
extended=~isequal(size(X),size(Val));
if ~extended
    Val(isnan(X) | isnan(Y))=NaN;
    mx=max(X(:));
    my=max(Y(:));
    X(isnan(X))=mx;
    Y(isnan(Y))=my;
end
%
set(Parent,'NextPlot','add')
switch presentationtype
    case {'patches','patches with lines'}
        if isequal(size(X),size(Z))
            hNew=genfaces(hNew,Ops,Parent,Val,X,Y,Z);
        else
            hNew=genfaces(hNew,Ops,Parent,Val,X,Y);
        end
        
    case 'values'
        I=~isnan(Val);
        if numel(X)==numel(Val)+1
            X = (X(1:end-1)+X(2:end))/2;
            Y = (Y(1:end-1)+Y(2:end))/2;
        end
        hNew=gentextfld(hNew,Ops,Parent,Val(I),X(I),Y(I));
        
    case 'continuous shades'
        if size(X,2)==1
            XY = [X(:) Y(:);NaN NaN];
            SEG = 1:size(XY,1);
            Val = [Val(:);NaN];
            if ishandle(hNew)
                set(hNew,'vertices',XY,'faces',SEG, ...
                    'facevertexcdata',Val)
            else
                edgecolor = 'interp';
                if strcmp(Ops.linestyle,'none')
                    edgecolor = 'flat';
                end
                hNew=patch('vertices',XY, ...
                    'faces',SEG, ...
                    'facevertexcdata',Val, ...
                    'parent',Parent, ...
                    'edgecolor',edgecolor, ...
                    'linewidth',Ops.linewidth, ...
                    'linestyle',Ops.linestyle, ...
                    'marker',Ops.marker, ...
                    'markersize',Ops.markersize, ...
                    'markeredgecolor',Ops.markercolour, ...
                    'markerfacecolor',Ops.markerfillcolour);
            end
        else
            if isequal(size(X),size(Z))
                z=Z;
            else
                z=Val;
            end
            hNew=gensurface(hNew,Ops,Parent,Val,X,Y,z);
        end
        
    case 'markers'
        if numel(X)==numel(Val)+1
            X = (X(1:end-1)+X(2:end))/2;
            Y = (Y(1:end-1)+Y(2:end))/2;
        end
        hNew=genmarkers(hNew,Ops,Parent,Val,X,Y);
        
    case {'contour lines','coloured contour lines','contour patches','contour patches with lines'}
        if isequal(size(X),size(Val)+1)
            [X,Y,Val]=face2surf(X,Y,Val);
            X(isnan(X))=mean(X(~isnan(X)));
            Y(isnan(Y))=mean(Y(~isnan(Y)));
        end
        hNew=gencontour(hNew,Ops,Parent,X,Y,Val,Ops.Thresholds);
        if strcmp(Ops.presentationtype,'contour lines')
            set(hNew,Ops.LineParams{:});
        end
        
    case 'edge'
        XY = [X(:) Y(:)];
        SEG = 1:numel(X);
        Val = cat(1,Val(:),NaN);
        if ishandle(hNew)
            set(hNew,'vertices',XY,'faces',SEG, ...
                'facevertexcdata',Val)
        else
            hNew=patch('vertices',XY, ...
                'faces',SEG, ...
                'facevertexcdata',Val, ...
                'parent',Parent, ...
                'edgecolor','flat', ...
                'linewidth',Ops.linewidth, ...
                'linestyle',Ops.linestyle, ...
                'marker',Ops.marker, ...
                'markersize',Ops.markersize, ...
                'markeredgecolor',Ops.markercolour, ...
                'markerfacecolor',Ops.markerfillcolour);
        end
end

function hNew = qp_scalarfield_tri(Parent,hNew,presentationtype,TRI,XYZ,Val,Ops)
set(Parent,'NextPlot','add')
switch presentationtype
    case {'patches','patches with lines'}
        hNew=genfaces(hNew,Ops,Parent,Val,XYZ,TRI);
        
    case 'values'
        I=~isnan(Val);
        hNew=gentextfld(hNew,Ops,Parent,Val(I),X(I),Y(I));
        
    case 'markers'
        hNew=genmarkers(hNew,Ops,Parent,Val,X,Y);
        
    case 'continuous shades'
        
        if size(XYZ,4)==2
            sz = size(XYZ);
            sz(4) = 1;
            XYZ = cat(4,XYZ,reshape(Val,sz));
        end
        XYZ=squeeze(XYZ);
        if isempty(hNew)
            hNew=patch('vertices',XYZ,'faces',TRI,'facevertexcdata',Val(:), ...
                'facecolor','interp','edgecolor','none', ...
                'parent',Parent);
            
        elseif ishandle(hNew)
            set(hNew,'vertices',XYZ,'facevertexcdata',Val(:));
        else
            return
        end
        
    case {'contour lines','coloured contour lines','contour patches','contour patches with lines'}
        XYZ=squeeze(XYZ);
        delete(hNew);
        switch Ops.presentationtype
            case 'contour lines'
                hNew=tricontour(TRI,XYZ(:,1),XYZ(:,2),Val(:),Ops.Thresholds,'k');
                set(hNew,'color',Ops.colour,'linestyle',Ops.linestyle,'marker',Ops.marker,'markeredgecolor',Ops.markercolour,'markerfacecolor',Ops.markerfillcolour)
            case 'coloured contour lines'
                hNew=tricontour(TRI,XYZ(:,1),XYZ(:,2),Val(:),Ops.Thresholds);
                for i=1:length(hNew)
                    c=get(hNew(i),'FaceVertexCData');
                    set(hNew(i),'FaceVertexCData',0*c+i)
                end
            case 'contour patches'
                hNew=tricontourf(TRI,XYZ(:,1),XYZ(:,2),Val(:),Ops.Thresholds,'clevel','index0','zplane',0);
            case 'contour patches with lines'
                hNew1=tricontourf(TRI,XYZ(:,1),XYZ(:,2),Val(:),Ops.Thresholds,'clevel','index0','zplane',0);
                hNew2=tricontour(TRI,XYZ(:,1),XYZ(:,2),Val(:),Ops.Thresholds,'k');
                set(hNew2,'color',Ops.colour,'linestyle',Ops.linestyle,'marker',Ops.marker,'markeredgecolor',Ops.markercolour,'markerfacecolor',Ops.markerfillcolour)
                hNew = [hNew1 hNew2];
        end
end

function hNew = qp_scalarfield_ugrid(Parent,hNew,presentationtype,data,Ops)
set(Parent,'NextPlot','add')
unknown_ValLocation = 0;
Val = data.Val;

if isfield(data,'TRI')
    FaceNodeConnect = data.TRI;
elseif isfield(data,'FaceNodeConnect')
    FaceNodeConnect = data.FaceNodeConnect;
elseif isfield(data,'Connect')
    FaceNodeConnect = data.Connect;
end

switch data.ValLocation
    case 'NODE'
        switch presentationtype
            case {'patches','patches with lines'}
                hNew=genfaces(hNew,Ops,Parent,Val,XYZ,TRI);
                
            case 'values'
                X = data.X;
                Y = data.Y;
                I=~isnan(Val);
                hNew=gentextfld(hNew,Ops,Parent,Val(I),X(I),Y(I));
                
            case 'markers'
                X = data.X;
                Y = data.Y;
                I=~isnan(Val);
                hNew=genmarkers(hNew,Ops,Parent,Val(I),X(I),Y(I));
                
            case 'continuous shades'
                XY = [data.X data.Y];
                nNodes = sum(~isnan(FaceNodeConnect),2);
                uNodes = unique(nNodes);
                first = isempty(hNew);
                for i = length(uNodes):-1:1
                    I = nNodes == uNodes(i);
                    if first
                        hNew(i) = patch(...
                            'vertices',XY, ...
                            'faces',FaceNodeConnect(I,1:uNodes(i)), ...
                            'facevertexcdata',Val, ...
                            'facecolor','interp', ...
                            'edgecolor','none', ...
                            'parent',Parent);
                    else
                        set(hNew(i), ...
                            'vertices',XY, ...
                            'facevertexcdata',Val);
                    end
                end
                
            case {'contour lines','coloured contour lines','contour patches','contour patches with lines'}
                nNodes = sum(~isnan(FaceNodeConnect),2);
                uNodes = unique(nNodes);
                %
                % approach: split every face into triangles (assuming
                % that each face is convex).
                %
                % count how many triangles we will create
                nTri = 0;
                for i = 1:length(uNodes)
                    nTri = nTri + (uNodes(i)-2)*sum(nNodes==uNodes(i));
                end
                TRI = zeros(nTri,3);
                % split faces into triangles
                nTri = 0;
                for i = 1:length(uNodes)
                    I = nNodes==uNodes(i);
                    nFace = sum(I);
                    for j = 2:uNodes(i)-1
                        TRI(nTri + (1:nFace),:) = FaceNodeConnect(I,[1 j j+1]);
                        nTri = nTri + nFace;
                    end
                end
                %
                delete(hNew);
                switch Ops.presentationtype
                    case 'contour lines'
                        hNew=tricontour(TRI,data.X,data.Y,Val,Ops.Thresholds,'k');
                        set(hNew,'color',Ops.colour,'linestyle',Ops.linestyle,'marker',Ops.marker,'markeredgecolor',Ops.markercolour,'markerfacecolor',Ops.markerfillcolour)
                    case 'coloured contour lines'
                        hNew=tricontour(TRI,data.X,data.Y,Val,Ops.Thresholds);
                        for i=1:length(hNew)
                            c=get(hNew(i),'FaceVertexCData');
                            set(hNew(i),'FaceVertexCData',0*c+i)
                        end
                    case 'contour patches'
                        hNew=tricontourf(TRI,data.X,data.Y,Val,Ops.Thresholds,'clevel','index0','zplane',0);
                    case 'contour patches with lines'
                        hNew1=tricontourf(TRI,data.X,data.Y,Val,Ops.Thresholds,'clevel','index0','zplane',0);
                        hNew2=tricontour(TRI,data.X,data.Y,Val,Ops.Thresholds,'k');
                        set(hNew2,'color',Ops.colour,'linestyle',Ops.linestyle,'marker',Ops.marker,'markeredgecolor',Ops.markercolour,'markerfacecolor',Ops.markerfillcolour)
                        hNew = [hNew1 hNew2];
                end
                
            otherwise
                unknown_ValLocation = 1;
        end
    case 'EDGE'
        iEdge = data.EdgeNodeConnect;
        switch presentationtype
            case 'edge'
                if isempty(hNew)
                    hNew = patch(...
                        'vertices',[data.X(iEdge,:) data.Y(iEdge,:)], ...
                        'faces',reshape(1:2*size(iEdge,1),[size(iEdge,1) 2]), ...
                        'facevertexcdata',[data.Val;data.Val], ...
                        'facecolor','none', ...
                        'edgecolor','interp', ...
                        'linewidth',Ops.linewidth, ...
                        'linestyle',Ops.linestyle, ...
                        'marker',Ops.marker, ...
                        'markersize',Ops.markersize, ...
                        'markeredgecolor',Ops.markercolour, ...
                        'markerfacecolor',Ops.markerfillcolour);
                else
                    set(hNew, ...
                        'vertices',[data.X(iEdge,:) data.Y(iEdge,:)], ...
                        'faces',reshape(1:2*size(iEdge,1),[size(iEdge,1) 2]), ...
                        'facevertexcdata',[data.Val;data.Val])
                end

            case 'values'
                X = mean(data.X(iEdge),2);
                Y = mean(data.Y(iEdge),2);
                I=~isnan(Val);
                hNew=gentextfld(hNew,Ops,Parent,Val(I),X(I),Y(I));
                
            case 'markers'
                X = mean(data.X(iEdge),2);
                Y = mean(data.Y(iEdge),2);
                I=~isnan(Val);
                hNew=genmarkers(hNew,Ops,Parent,Val(I),X(I),Y(I));

            otherwise
                unknown_ValLocation = 1;
        end
    case 'FACE'
        switch presentationtype
            case {'patches','patches with lines'}
                XY = reshape([data.X data.Y],[1 length(data.X) 1 2]);
                nNodes = sum(~isnan(FaceNodeConnect),2);
                uNodes = unique(nNodes);
                delete(hNew)
                hNew = {};
                for i = length(uNodes):-1:1
                    I = nNodes == uNodes(i);
                    hOld = [];
                    hNew{i} = genfaces(hOld,Ops,Parent,data.Val(I),XY,FaceNodeConnect(I,1:uNodes(i)));
                end
                hNew = cat(2,hNew{:});
                
            case {'continuous shades','contour lines','coloured contour lines','contour patches','contour patches with lines'}
                data = dual_ugrid(data);
                hNew = qp_scalarfield_ugrid(Parent,hNew,presentationtype,data,Ops);
                
            case {'values','markers'}
                X = data.X;
                Y = data.Y;
                if isfield(data,'XFace')
                    X = data.XFace;
                    Y = data.YFace;
                else
                    missing = isnan(FaceNodeConnect);
                    FaceNodeConnect(missing) = 1;
                    nc=sum(~missing,2);
                    xFace = X(FaceNodeConnect);
                    xFace(missing)=0;
                    X = sum(xFace,2)./nc;
                    yFace = Y(FaceNodeConnect);
                    yFace(missing)=0;
                    Y=sum(yFace,2)./nc;
                end
                I=~isnan(Val);
                switch presentationtype
                    case 'values'
                        hNew=gentextfld(hNew,Ops,Parent,Val(I),X(I),Y(I));
                    case 'markers'
                        hNew=genmarkers(hNew,Ops,Parent,Val(I),X(I),Y(I));
                end
                
            otherwise
                unknown_ValLocation = 1;
        end
    otherwise
        error('Value location "%s" not supported for plotting UGRID data',data.ValLocation)
end
if unknown_ValLocation
    error('Presentationtype "%s" not supported for UGRID-%s variables',presentationtype,data.ValLocation)
end    
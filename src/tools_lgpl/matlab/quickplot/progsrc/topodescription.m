function Description = topodescription(Topology)
%TOPODESCRIPTION Returns a topology description string for a location.

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
%   $HeadURL: https://svn.oss.deltares.nl/repos/delft3d/branches/research/Deltares/20160119_tidal_turbines/src/tools_lgpl/matlab/quickplot/progsrc/topodescription.m $
%   $Id: topodescription.m 4612 2015-01-21 08:48:09Z mourits $

switch Topology
    case 'Struct3D'
        Description = '3D structured grid';
    case 'Struct2D+'
        Description = '2D structured grid';
    case 'Unstruct3D'
        Description = '3D unstructured mesh';
    case 'Unstruct2D+'
        Description = '2D unstructured mesh';
    case 'Unstruct1D+'
        Description = 'network';
    case 'Unstruct0D+'
        Description = 'point set';
    otherwise
        Description = Topology;
end

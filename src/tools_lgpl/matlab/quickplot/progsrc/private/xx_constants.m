function XX=xx_constants
%XX_CONSTANTS Define several constants.
%   XX=XX_CONSTANTS

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
%   $HeadURL: https://svn.oss.deltares.nl/repos/delft3d/branches/research/Deltares/20160119_tidal_turbines/src/tools_lgpl/matlab/quickplot/progsrc/private/xx_constants.m $
%   $Id: xx_constants.m 4612 2015-01-21 08:48:09Z mourits $

try
    Inactive = qp_settings('UIInActiveColor');
    Active   = qp_settings('UIActiveColor'); 
catch
    Inactive = get(0,'defaultuicontrolbackgroundcolor');
    Active   = [1 1 1];
end 

XX.Clr.LightGray = Inactive;
XX.Inactive      = XX.Clr.LightGray;
XX.Clr.White     = Active;
XX.Active        = XX.Clr.White;

XX.Margin        = 10;
XX.Txt.Height    = 18;
XX.But.Height    = 20;
XX.Slider        = 20;

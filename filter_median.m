%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%     Photobleaching Step Detection
%     Copyright (C) 2014  
%     Venkatramanan Krishnamani, Rahul Chadda & ...
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pc=filter_median(dat,hwidth)
%
% filter_median(dat,hwidth)
%
% perform rolling median calculation on an input 1-D data file using
% the input window size.  The returned variable has the same size as
% the input data file.  The initial and final "hwidth" number of
% points are fillers for matching the data file size - they are the
% average values of the forward (hwidth+1) points or the backward
% (hwidth+1) points, respectively.
%
% inputs:
% dat == 1-D data file
% hwidth ==  half width of the window size for calculating the mean.
%       so that window size = 2*hwidth +1
%

[nrow nframe]=size(dat);
dum=zeros(1,nframe);
nframe=nframe-2*hwidth;

% initial "hwidth" fillers
for indx=1:hwidth
    dum(1,indx)=median(dat(1,indx:indx+hwidth));
end;

for indx=hwidth+1:nframe+hwidth
    dum(1,indx)=median(dat(1,indx-hwidth:indx+hwidth));
end;

% final "hwidth" fillers
for indx=nframe+hwidth+1:nframe+2*hwidth
    dum(1,indx)=median(dat(1,indx-hwidth:indx));
end;

pc=dum;
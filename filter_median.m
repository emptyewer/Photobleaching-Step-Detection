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
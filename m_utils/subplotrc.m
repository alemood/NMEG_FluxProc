function h = subplotrc( varargin ) 
% function h=subplotrc(varargin) - extension of subplot
% subplotrc(m,n,r,c) put suplot in row r, column c of figure; all
% other forms passed through to subplot without alteration
%
% obtained from Matlab file exchange, 3 Oct 2012 -- TWH
% http://www.mathworks.com/matlabcentral/fileexchange/11272-subplotrc
%
if(length(varargin)==4 && all(cellfun(@isnumeric,varargin))) 
    p=sub2ind([varargin{2},varargin{1}],varargin{4},varargin{3}); 
    h=subplot(varargin{1},varargin{2},p); 
else 
    h=subplot(varargin{:}) 
end 
if(nargout == 0) 
    clear h; 
end
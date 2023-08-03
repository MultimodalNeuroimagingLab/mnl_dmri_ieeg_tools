function [X_end] = linreg3(varargin)

%   Jordan Bilderbeek June 30, 2023; updated August 3
%
%   Perform line of best fit (least squares) via SVD in order to find the line of
%   best fit between the different electrode positions. This will give us a
%   smooth line (avoid cubic splines...etc). 
%
%   Implemented as CTMR output can be improved: We can identify
%   the locations based on the CT positions although sometimes the selection
%   is not always precise. For visualization we find the line of best fit 
%   (assume there to be no curve in the DBS probe). 
%
%
%   INPUTS: 
%       a) varargin{1} - matrix of points - must be formatted
%        s.t N=size(X,2)
%       b) varargin{2} - input variable for optional plot tag
%       c) varargin{3} - input variable for optional point projection onto
%       the PC acis
%
%   OUTPUTS: 
%       a) X_end - endpoints of the PC axis line

%% linreg3
X=varargin{1};
N=size(X, 2);

X_ave=mean(X,1);            % mean; line of best fit will pass through this point  
dX=bsxfun(@minus,X,X_ave);  % residuals
C=(dX'*dX)/(N-1);           % variance-covariance matrix of X
[R,D]=svd(C,0);             % singular value decomposition of C; C=R*D*R'

D=diag(D);

%R2=D(1)/sum(D);
%disp(['R-sqared between probe locations: ' num2str(R2) ])

% End-points of a best-fit line (segment)
x=dX*R(:,1);
x_min=min(x);
x_max=max(x);
dx=x_max-x_min;
Xa=(x_min-0.05*dx)*R(:,1)' + X_ave;
Xb=(x_max+0.05*dx)*R(:,1)' + X_ave;
X_end=[Xa;Xb]; %old output


if nargin>1 %plots output onto top subplot, can be re-config
    subplot(2,1,1)
    plot3(X_end(:,1),X_end(:,2),X_end(:,3),'-r','LineWidth',3) % best fit line 
    hold on
    plot3(X(:,1),X(:,2),X(:,3),'.k','MarkerSize',13)           % electrode positions
    title('Electrode line fitting with SDV best-fit')
    xlabel('X (mm)'), ylabel('Y (mm)'), zlabel('Z (mm)');
    legend('Best Fit Line', 'Electrode Positions');
end

if nargin>2 % call to projectPoint2Line
    X_end=zeros(size(X));
    for ii=1:size(X, 1)
        X_end(ii,:)=projectPoint2Line(X(ii,:), Xa, Xb); % takes the original electrode position and projects onto principal axis
    end
end

end


function net=netReTrain(out,in,net)
%   in - input time series.
%   out - feedback time series.

X = tonndata(out,false,false);
T = tonndata(in,false,false);
% Prepare the Data for Training and Simulation
% The function PREPARETS prepares timeseries data for a particular network,
% shifting time by the minimum amount to fill input states and layer
% states. Using PREPARETS allows you to keep your original time series data
% unchanged, while easily customizing it for networks with differing
% numbers of delays, with open loop or closed loop feedback modes.
[x,xi,ai,t] = preparets(net,X,{},T);

% Choose a Performance Function
% For a list of all performance functions type: help nnperformance
net.performFcn = 'mse';  % Mean Squared Error

% Choose Plot Functions
% For a list of all plot functions type: help nnplot
net.plotFcns = {'plotperform','plottrainstate', 'ploterrhist', ...
    'plotregression', 'plotresponse', 'ploterrcorr', 'plotinerrcorr'};

% Train the Network
[net,~] = train(net,x,t,xi,ai);

% Test the Network
% y = net(x,xi,ai);
% e = gsubtract(t,y);
% performance = perform(net,t,y)

% Recalculate Training, Validation and Test Performance
% trainTargets = gmultiply(t,tr.trainMask);
% valTargets = gmultiply(t,tr.valMask);
% testTargets = gmultiply(t,tr.testMask);
% trainPerformance = perform(net,trainTargets,y)
% valPerformance = perform(net,valTargets,y)
% testPerformance = perform(net,testTargets,y)

% View the Network
% view(net)

% Plots
% Uncomment these lines to enable various plots.
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, ploterrhist(e)
%figure, plotregression(t,y)
% figure, plotresponse(t,y)
%figure, ploterrcorr(e)
%figure, plotinerrcorr(x,e)

% Closed Loop Network
% Use this network to do multi-step prediction.
% The function CLOSELOOP replaces the feedback input with a direct
% connection from the outout layer.
% netc = closeloop(net);
% netc.name = [net.name ' - Closed Loop'];
% % view(netc)
% [xc,xic,aic,tc] = preparets(netc,X,{},T);
% yc = netc(xc,xic,aic);
% closedLoopPerformance = perform(net,tc,yc)

% Multi-step Prediction
% Sometimes it is useful to simulate a network in open-loop form for as
% long as there is known output data, and then switch to closed-loop form
% to perform multistep prediction while providing only the external input.
% Here all but 5 timesteps of the input series and target series are used
% to simulate the network in open-loop form, taking advantage of the higher
% accuracy that providing the target series produces:
% numTimesteps = size(x,2);
% knownOutputTimesteps = 1:(numTimesteps-5);
% predictOutputTimesteps = (numTimesteps-4):numTimesteps;
% X1 = X(:,knownOutputTimesteps);
% T1 = T(:,knownOutputTimesteps);
% [x1,xio,aio] = preparets(net,X1,{},T1);
% [y1,xfo,afo] = net(x1,xio,aio);
% Next the the network and its final states will be converted to
% closed-loop form to make five predictions with only the five inputs
% provided.
% x2 = X(1,predictOutputTimesteps);
% [netc,xic,aic] = closeloop(net,xfo,afo);
% [y2,xfc,afc] = netc(x2,xic,aic);
% multiStepPerformance = perform(net,T(1,predictOutputTimesteps),y2)
% Alternate predictions can be made for different values of x2, or further
% predictions can be made by continuing simulation with additional external
% inputs and the last closed-loop states xfc and afc.

% Step-Ahead Prediction Network
% For some applications it helps to get the prediction a timestep early.
% The original network returns predicted y(t+1) at the same time it is
% given y(t+1). For some applications such as decision making, it would
% help to have predicted y(t+1) once y(t) is available, but before the
% actual y(t+1) occurs. The network can be made to return its output a
% timestep early by removing one delay so that its minimal tap delay is now
% 0 instead of 1. The new network returns the same outputs as the original
% network, but outputs are shifted left one timestep.
% nets = removedelay(net);
% nets.name = [net.name ' - Predict One Step Ahead'];
% % view(nets)
% [xs,xis,ais,ts] = preparets(nets,X,{},T);
% ys = nets(xs,xis,ais);
% stepAheadPerformance = perform(nets,ts,ys)

function [testData,testResponseVariables] = ...
    buildTestDataMatrix(events,spikes,pairID,testDataTrials,varargin)
%
%
%

%%
    %Uncomment this line if you want to exlude interneurons. 
    %     nSpikes = cellfun('length',spikes);
    %     interneurons = nSpikes > 20000;
    interneurons = zeros(length(spikes),1); 
    
    p = inputParser;
    p.addRequired('events',@(x) iscell(x)); 
    p.addRequired('spikes',@(x) iscell(x)); 
    p.addRequired('armID',@(x) isnumeric(x)); 
    p.addRequired('testDataTrials',@(x) isnumeric(x)); 
    p.addParameter('neurons',find(~interneurons),@(x) isnumeric(x)); 
    p.addParameter('useDecisionEpoch',false,@(x) islogical(x)); 
    p.addParameter('tMinusEvent',2,@(x) isnumeric(x)); 
    
    p.parse(events,spikes,pairID,testDataTrials,varargin{:});
    neurons = p.Results.neurons; 
        if size(neurons,1) > size(neurons,2), neurons = neurons'; end; 
    useDecisionEpoch = p.Results.useDecisionEpoch;
    tMinusEvent = p.Results.tMinusEvent;

%% 
    start = events{9}; stop = events{10}; 
    
    %If using decision point, instead taking the tMinusEvent seconds before
    %entering the arm instead. 
    if useDecisionEpoch
        stop = start; 
        start = start - tMinusEvent;
    end
    
    nNeurons = length(neurons); 
    nTestDataTrials = length(testDataTrials); 
    
    testData = zeros(nTestDataTrials,nNeurons); 
    t = 1;
    for trial = testDataTrials
        timeSpentOnArm = stop(trial) - start(trial); 
        testData(t,:) = ...
            cellfun(@(x) sum(x > start(trial) & x < stop(trial)),...
            spikes(neurons))./timeSpentOnArm;
    
        t = t+1; 
    end
    
    %Response variable. 
    testResponseVariables = pairID(testDataTrials);
end
function [predictions,accuracy,postProbs] = ...
    armPairDecoderAccuracy(Mdl,testData,testResponses)
%
%
%

%% Predict and get accuracy. 
    [predictions,postProbs] = predict(Mdl,testData); 
    nTrials = length(predictions); 
    accuracy = (sum((testResponses-predictions)==0)/nTrials)*100; 
    
end
function correct_or_incorrect = judgeTrials(trials)
%
%
%

%%
    good = [1 3 6 8 10 11];
    
    correct_or_incorrect = ismember(trials,good); 
end
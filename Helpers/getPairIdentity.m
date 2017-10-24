function pairID = getPairIdentity(armID)
%
%
%

%%
    nTrials = length(armID);
    
    pairs = {[1 2] [3 4] [5 6] [7 8] [9 10] [11 12]};
    nPairs = length(pairs);
    
    pairID = zeros(nTrials,1); 
    for pair = 1:nPairs
        pairID(ismember(armID,pairs{pair})) = pair;
    end
end
function [Entropy,Sorted_Entropy,Sorted_Shift_Index,Detected_Output_Over_Shift,Remove_Index,Sorted_Cnt_0_1]=Find_Entropy_Double_Shift(max_shift,TF_b,T_b,Remove_percent)

Entropy = zeros(max_shift);
%Detected_Output_Over_Shift = zeros(max_shift+1,4);

for shift_Detect_1 = 0:max_shift
    for shift_Detect_2 = 0:max_shift
        %Find the probability of 0 and 1 as the detected output for each input state
        if sum(isnan(TF_b(1).TF_b)) ==0
            [Cnt_0_1,P_0_1] = Detect_Logic_in_TimeSeries(TF_b,T_b,shift_Detect_1,shift_Detect_2,[],0);
        else
            [Cnt_0_1,P_0_1] = Detect_Logic_in_TimeSeries_All(TF_b,T_b,shift_Detect_1,shift_Detect_2);
        end
        
        %Calculate entropy
        [Entropy(shift_Detect_1+1,shift_Detect_2+1),Remove_Index_Struct(shift_Detect_1+1,shift_Detect_2+1).index] = Find_Entropy_01(Cnt_0_1,P_0_1,Remove_percent);
        
        [~,max_indx] =  max(Cnt_0_1');
        %Find the counts that 0 and 1 are equal
        Equal_Index = Cnt_0_1(:,1)==Cnt_0_1(:,2);
        max_indx(Equal_Index) = 0; %This will generate output -1 for the cases that number of xounts for 0 and 1 are equal
        Detected_Output_Over_Shift_struct(shift_Detect_1+1).Logic(shift_Detect_2+1,:)=max_indx-1;
        Cnt_0_1_struct(shift_Detect_1+1,shift_Detect_2+1).Cnt_0_1=Cnt_0_1;
    end
end

%Find the index of the minimum Entropy
Sorted_Entropy_Unique = unique(sort(Entropy(:)));
Detected_Output_Over_Shift=[];
Sorted_Shift_Index = [];
m=0;

Remove_Index = [];
Sorted_Cnt_0_1=[];
Sorted_Entropy=[];

for i=1:length(Sorted_Entropy_Unique)
    [Shift_1,Shift_2]= find(Entropy==Sorted_Entropy_Unique(i));
    
    
    Shift_1 = Shift_1-1;
    Shift_2 = Shift_2-1;
    
    %If we have a value in multiple places, 'find' will return more than one value
    %the followin for loop in for handling this situation.
    for k=1:length(Shift_1)
        %If detected logic is all zero or all one we should ignore it
        Sum_Output_State = sum(abs(Detected_Output_Over_Shift_struct(Shift_1(k)+1).Logic(Shift_2(k)+1,:)));
        if Sum_Output_State~=0 && Sum_Output_State ~=4
            m = m+1;
            Sorted_Entropy(end+1) = Sorted_Entropy_Unique(i);
            Sorted_Shift_Index(m,:) = [Shift_1(k) Shift_2(k)];
            Detected_Output_Over_Shift(end+1,:) = Detected_Output_Over_Shift_struct(Shift_1(k)+1).Logic(Shift_2(k)+1,:);
            Remove_Index(end+1,:).index = Remove_Index_Struct(Shift_1(k)+1,Shift_2(k)+1).index;
            Sorted_Cnt_0_1(end+1,:).Cnt_0_1 = Cnt_0_1_struct(Shift_1(k)+1,Shift_2(k)+1).Cnt_0_1;
        end
    end
    
end

end
function [Detection_Count_in_State,Detection_Probability_in_State] = Detect_Logic_in_TimeSeries_All(TF_b,T_b,shift_1,shift_2)

NaN_Index = [0 find(isnan(TF_b(1).TF_b))];
TF1_bb = [];
TF2_bb = [];
T_bb=[];

%To synchronize the samples of TFs and target, we do as follows;
%1) Find the maximum of shift_1 and shift_2 (Max_Shift)
%2) insert NaN between different data sets with the number of Max_Shift NaNs
%3) At the beginning of TF1 time series inser shift_1 NaNs
%4) At the beginning of TF2 time series inser shift_2 NaNs
%%) Now, all time series are synchronized, i.e., TF1(n) and TF2(n) affect T(n) representing the required shifts 
% 
% TF1 = [<shift_1> NaN ... NaN  SAMPLES OF FIRST DATASET <Max_Shift> NaN ... NaN SAMPLES OF 2nd DATASET <Max_Shift> NaN ... NaN ....]
% TF2 = [<shift_2> NaN ... NaN  SAMPLES OF FIRST DATASET <Max_Shift> NaN ... NaN SAMPLES OF 2nd DATASET <Max_Shift> NaN ... NaN ....]
% TF = [ SAMPLES OF FIRST DATASET <Max_Shift> NaN ... NaN SAMPLES OF 2nd DATASET <Max_Shift> NaN ... NaN ....]
% 

[Max_Shift,Max_Indx] = max([shift_1 shift_2]);

for i=1:length(NaN_Index)-1
   TF1_bb = [TF1_bb  TF_b(1).TF_b(NaN_Index(i)+1:NaN_Index(i+1)-1) NaN(1,Max_Shift)];
   TF2_bb = [TF2_bb  TF_b(2).TF_b(NaN_Index(i)+1:NaN_Index(i+1)-1) NaN(1,Max_Shift)];
   T_bb = [T_bb  T_b(NaN_Index(i)+1:NaN_Index(i+1)-1) NaN(1,Max_Shift)];
end

TF1_bb = [NaN(1,shift_1) TF1_bb];
TF2_bb = [NaN(1,shift_2) TF2_bb];

%Find NaN indexof all vectors to remove the corresponding elements in all vectors

NaN_Vector = [find(isnan(TF1_bb)) find(isnan(TF2_bb)) find(isnan(T_bb))];
NaN_Vector = unique(NaN_Vector);

TF1_bb(NaN_Vector(NaN_Vector<=length(TF1_bb)))=[];
TF2_bb(NaN_Vector(NaN_Vector<=length(TF2_bb)))=[];
T_bb(NaN_Vector(NaN_Vector<=length(T_bb)))=[];


N = length(T_b);
Num_TF = length(TF_b);
Num_State = 2^Num_TF;
Detection_Probability_in_State = zeros(Num_State,2);
Detection_Count_in_State = zeros(Num_State,2);



%% 00
ind = find(~TF1_bb & ~TF2_bb);

count00=hist(T_bb(ind'),[0 1]);
Detection_Probability_in_State(1,:) = count00/sum(count00);
Detection_Count_in_State(1,:) = count00;


%% 01
ind = find(~TF1_bb & TF2_bb);
count01=hist(T_bb(ind'),[0 1]);
Detection_Probability_in_State(2,:) = count01/sum(count01);
Detection_Count_in_State(2,:) = count01;


%% 10
ind = find(TF1_bb & ~TF2_bb);
count10=hist(T_bb(ind'),[0 1]);
Detection_Probability_in_State(3,:) = count10/sum(count10);
Detection_Count_in_State(3,:) = count10;

%11
ind = find(TF1_bb & TF2_bb);
count11=hist(T_bb(ind'),[0 1]);
Detection_Probability_in_State(4,:) = count11/sum(count11);
Detection_Count_in_State(4,:) = count11;


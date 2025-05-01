libname mme "C:\Users\leoma\OneDrive - University of South Florida\1 Grad School\Gobal Health Strat\Micromobility data"; 
proc import out= mme.qualtrics1 /* denotes the name and location of the dataset in SAS*/ 
			datafile=  "C:\Users\leoma\OneDrive - University of South Florida\1 Grad School\Gobal Health Strat\Micromobility data\Micromobility Crash Exposure Final_July 1, 2024_col_trimmed.csv"/*denotes the filename and location on the computer*/ 
			DBMS=CSV
			Replace; /*overwrites and existing file in the sas library*/ 
			Getnames=Yes;
			Datarow=2; /*location of when the values start*/
			Guessingrows=Max; /* denotes the max num of rows to scan for determining type*/
run; 

Proc freq data= mme.qualtrics1; /* N=558 */
run;

/* Removes unfinised surveys and test variables N= 433*/
data mme.clean1;
set mme.qualtrics1;
drop progress Duration__in_seconds_ responseid userlanguage Q_RecaptchaScore;
if finished = 'TRUE';
if Multiple_Crash = 'Test' then delete;
run; 

/*Removes unsatitisfactory inclusion criteria N= 414 */ 
data mme.clean2;
set mme.clean1; 
if _18_years = 'Yes'; /*n= -2*/
if In_Person = 'Yes'; /*n= -17*/
run; 

/*Converts non micromobility crashes N= 414 */ 
data mme.clean3;
set mme.clean2; 
if _1_Parties_Involved = "1" and _1_Other_Mode ^= "No one else was involved, it was just myself" then Crash_Involvement= 'No'; /*n= -1*/
if _1_Parties_Involved = "2" and _1_Personal_Use ^in("E-scooter","E-bicycle", "E-skateboard","Mono-wheel") and _1_Other_Mode in("Walking", "Bicycle", "Car", "Skateboard", "Push scooter", "Bus", "Other") then Crash_Involvement= 'No'; /*n= -9*/ 
drop _4_Parties_Involved _4_Personal_Use _4_Other_Mode _4_Injuries _4_Injuries_6_TEXT _4_Clinic_Visit _4_Police_Report _4_Contact_Info _4_Other_Crash _5_Parties_Involved _5_Personal_Use _5_Other_Mode _5_Injuries _5_Injuries_6_TEXT _5_Clinic_Visit _5_Police_Report _5_Contact_Info _5_Other_Crash _6_Parties_Involved _6_Personal_Use _6_Other_Mode _6_Injuries _6_Injuries_6_TEXT _6_Clinic_Visit _6_Contact_Info _6_Other_Crash _7_Parties_Involved _7_Personal_Use _7_Other_Mode _7_Injuries _7_Injuries_6_TEXT _7_Clinic_Visit _7_Police_Report _7_Contact_Info _7_Other_Crash _8_Parties_Involved _8_Personal_Use _8_Other_Mode _8_Injuries _8_Injuries_6_TEXT _8_Clinic_Visit _8_Police_Report _8_Contact_Info _8_Other_Crash _9_Parties_Involved  
_9_Personal_Use _9_Other_Mode _9_Injuries _9_Injuries_6_TEXT _9_Clinic_Visit _9_Police_Report _9_Contact_Info _9_Other_Crash _10_Parties_Involved _10_Personal_Use 
_10_Other_Mode _10_Injuries _10_Injuries_6_TEXT _10_Clinic_Visit _10_Police_Report _10_Contact_Info _10_Other_Crash;
run;

/*Removes failed attention/bot questions N= 389 */ 
data mme.clean4;
set mme.clean3;
if DBQ_8 ^= "Usually" and DBQ_8 ^= '' then delete; /*n= -3*/
if DBQ2_14 ^= "Rarely" and DBQ2_14 ^= '' then delete; /*n= -2*/
if PBQ_9 ^= "Sometimes" and PBQ_9 ^= '' then delete; /*n= -10*/
if PBQ2_9 ^= "Never" and PBQ2_9 ^= '' then delete; /*n= -5*/
if CBQ_9 ^= "Always" and CBQ_9 ^= '' then delete; /*n= -2*/
if Q52_10 ^= "Rarely" and Q52_10 ^= '' then delete; /*n= -3*/
run; 

/*Creating New Variables*/
data mme.clean5;
set mme.clean4;
length Road_user $30;
if Transportation_Mode='Car' then Road_user= 'Driver';
else if Transportation_Mode in('Walking','Bus')then Road_user= "Ped/Bus";
else if Transportation_Mode in('Bicycle')then Road_user= "Bicyclists";
else if Transportation_Mode in('E-scooter','E-bicycle','E-skateboard','Mono-wheel')then Road_user= "Micromobility";
else if Transportation_Mode in('Skateboard','Push scooter','Other')then Road_user= "Other";
else; 
run;

/*Knowlege Sum Score*/
data mme.clean6;
set mme.clean5; 
if Bicyclist_room = '3 Feet' then Kq1 =1;
else if Bicyclist_room ='' then Kq1=.;
else Kq1 =0;

if E_Scooter_room = '3 Feet' then Kq2= 1;
else if E_Scooter_room ='' then Kq2=.;
else Kq2 =0;

if Speed_limit = '25 MPH' then Kq3= 1;
else if E_Scooter_room ='' then Kq3=.;
else Kq3 =0;

if Crash_Scene = 'Crashing into another motor vehicle,Crashing into a bicyclist or e-scooter rider,Crashing into a pedestrian,Crashing into private property' then Kq4= 1;
else if Crash_Scene ='' then Kq4=.;
else Kq4 =0;

if Bicycle_Signal = 'Signaling that they are slowing down or stopping' then Kq5= 1;
else if Bicycle_Signal ='' then Kq5=.;
else Kq5 =0;

if Lights_Combo = 'White (Front) - Red (Rear)' then Kq6= 1;
else if Lights_Combo ='' then Kq6=.;
else Kq6 =0;

if Helmet_Requirement = '16 years old and younger' then Kq7= 1;
else if Helmet_Requirement ='' then Kq7=.;
else Kq7 =0;

if TF_Bike_Lanes = 'FALSE' then Kq8= 1;
else if TF_Bike_Lanes ='' then Kq8=.;
else Kq8 =0;

if Sidewalks = 'FALSE' then Kq9= 1;
else if Sidewalks ='' then Kq9=.;
else Kq9 =0;

if Push_For_Walk = 'Push the button and wait for the "Walk" signal' then Kq10= 1;
else if Push_For_Walk ='' then Kq10=.;
else Kq10 =0;

if Off_Bus = 'FALSE' then Kq11= 1;
else if Off_Bus ='' then Kq11=.;
else Kq11 =0;

if Micromobility_Lights = 'White (Front) - Red (Rear)' then Kq12 = 1;
else if Micromobility_Lights ='' then Kq12=.;
else Kq12 =0;

if E_scooter_Push_Cross = 'Push the button and wait for the "Cross" signal' then Kq13= 1;
else if E_scooter_Push_Cross ='' then Kq13=.;
else Kq13 =0;

if E_scooter_Bike_Lanes = 'FALSE' then Kq14= 1;
else if E_scooter_Bike_Lanes ='' then Kq14=.;
else Kq14 =0;
`
Driver_Kscore  = Kq1 + Kq2 + Kq3 + Kq4 + Kq5;
PB_Kscore      = Kq1 + Kq2 + Kq9 + Kq10 + Kq11;
Bicycle_Kscore = Kq1 + Kq2 + Kq6 + Kq7 + Kq8;
Micromobility_Kscore = Kq1 + Kq2 + Kq12 + Kq13 + Kq14;
KSS = coalesce(Driver_Kscore, PB_Kscore, Bicycle_Kscore, Micromobility_Kscore); 
run;
/*Risk Sum Score*/ 
data mme.clean7;
set mme.clean6;
array dbq  [20] $Dbq_1-dbq_7 dbq2_1-Dbq2_13;
array dbqr [20] dbqr_1-dbqr_20;
array pbq  [16] $pbq_1-pbq_8 pbq2_1-pbq2_8;
array pbqr [16] pbqr_1-pbqr_16; 
array cbq  [17] $cbq_1-cbq_8 q52_1-Q52_9;
array cbqr [17] cbqr_1-cbqr_17;
array pbqo [10] pbqr_3 pbqr_7-pbqr_15;
array pbqn [10] pbqn_3 pbqn_7-pbqn_15;
array cbqo [3] cbqr_15-cbqr_17;
array cbqn [3] cbqn_15-cbqn_17;

 do i = 1 to 20; 
	     if  dbq [i] = 'Always' then dbqr [i] = 5; 
	else if  dbq [i] = 'Usually' then dbqr [i] = 4; 
	else if  dbq [i] = 'Sometimes' then dbqr [i] = 3; 
	else if  dbq [i] = 'Rarely' then dbqr [i] = 2; 
	else if  dbq [i] = 'Never' then dbqr [i] = 1; 
 end;

 do j = 1 to 16; 
	     if  pbq [j] = 'Always' then pbqr [j] = 5; 
	else if  pbq [j] = 'Usually' then pbqr [j] = 4; 
	else if  pbq [j] = 'Sometimes' then pbqr [j] = 3; 
	else if  pbq [j] = 'Rarely' then pbqr [j] = 2; 
	else if  pbq [j] = 'Never' then pbqr [j] = 1; 
 end;

  do k = 1 to 17; 
	     if  cbq [k] = 'Always' then cbqr [k] = 5; 
	else if  cbq [k] = 'Usually' then cbqr [k] = 4; 
	else if  cbq [k] = 'Sometimes' then cbqr [k] = 3; 
	else if  cbq [k] = 'Rarely' then cbqr [k] = 2; 
	else if  cbq [k] = 'Never' then cbqr [k] = 1; 
 end;

do l = 1 to 10;
pbqn [l] = 6 - pbqo [l]; 
end;

do m = 1 to 3;
cbqn [m] = 6 - cbqo [m]; 
end;

DBQ_Rscore = mean(of dbqr_1-dbqr_20);
PBQ_Rscore = mean(of pbqr_1-pbqr_2,of pbqr_4-pbqr_6,of pbqr_16, pbqn_3,of pbqn_7-pbqn_15);
CBQ_Rscore = mean(of cbqr_1-cbqr_14,of cbqn_15-cbqn_17);
	   RSS = coalesce(DBQ_Rscore, PBQ_Rscore, CBQ_Rscore);
format CBQ_Rscore 3.2 RSS 3.2;
run; 
/*testing for normality - data is non normal*/  
proc univariate data= mme.final normal;
	var RSS KSS; 
	run;
/* the relationship between user risk behaviors and traffic safety knowledge */ 
proc corr data=mme.final spearman;
    var RSS KSS;
    title "Spearman's Rank Correlation Coefficient using PROC CORR";
run;

/* Mann_Whitney U Test: sum risk behavior score and knowledge score with crash exposure */

/* RSS- Crash */
proc NPAR1WAY data=mme.final wilcoxon;
    class Crash_Involvement; /* Specify the grouping variable */
    var RSS;   /* Specify the variable to compare */
    title "Mann-Whitney U Test for Scores by Group - RSS";
run;

/* RSS- International */
proc NPAR1WAY data=mme.final wilcoxon;
    class International; /* Specify the grouping variable */
    var RSS;   /* Specify the variable to compare */
    title "Mann-Whitney U Test for Scores by Group - RSS International";
run;

/* RSS- Micro Owner */
proc NPAR1WAY data=mme.final wilcoxon;
    class Micromobility_Owner; /* Specify the grouping variable */
    var RSS;   /* Specify the variable to compare */
    title "Mann-Whitney U Test for Scores by Group - RSS Micro Owner";
run;

/* KSS- Crash  */
proc NPAR1WAY data=mme.final wilcoxon;
    class Crash_Involvement; /* Specify the grouping variable */
    var KSS;   /* Specify the variable to compare */
    title "Mann-Whitney U Test for Scores by Group- KSS";
run;

/* KSS- International */
proc NPAR1WAY data=mme.final wilcoxon;
    class International; /* Specify the grouping variable */
    var KSS;   /* Specify the variable to compare */
    title "Mann-Whitney U Test for Scores by Group - KSS International";
run;

/* KSS- Micro Owner */
proc NPAR1WAY data=mme.final wilcoxon;
    class Micromobility_Owner; /* Specify the grouping variable */
    var kSS;   /* Specify the variable to compare */
    title "Mann-Whitney U Test for Scores by Group - KSS Micro Owner";
run;

proc freq data= mme.final nlevels; 
title "Crash Frequencies";
table Multiple_Crash _1_Parties_Involved _1_Injuries _1_Clinic_Visit 
	  _1_Police_Report _1_Contact_Info _2_Parties_Involved _2_Injuries _2_Clinic_Visit
	  _2_Clinic_Visit _2_Contact_Info _3_Injuries _3_Clinic_Visit _3_Police_Report _3_Contact_Info / list missing;
run;

proc freq data= mme.final nlevels; 
title "Crash Frequencies";
table  _2_Police_Report/ list missing;
run;

/*Mean scores*/
proc GLM data= mme.final;
class road_user;
MODEL KSS = Road_user;
means road_user / HOVTESt = levene; 
run; 
quit;

/*Risk Score One Way ANOVA and Pairwise */
Title 'Risk Score KW and Pairwise';
proc npar1way data= mme.final wilcoxon dscf;
class Road_user; 
var RSS;
run;
quit; 
/*Knowledge Score One Way ANOVA and Pairwise */
Title 'Knowledge Score KW and Pairwise';
proc npar1way data= mme.final wilcoxon dscf;
class Road_user; 
var KSS;
run;
quit; 

/*mean response scores per road user */
proc means data= mme.final; 
/*class Road_user;*/
var Rss kss;
title "mean response scores";
run; 

/*mean response scores per question bloack */
proc means data= mme.final; 
var Driver_Kscore PB_Kscore Bicycle_Kscore Micromobility_Kscore;
title "mean response scores  per question bloack";
run; 

/*mean response scores per question bloack */
proc corr data= mme.final; 
var Driver_Kscore PB_Kscore Bicycle_Kscore Micromobility_Kscore;
title "mean response scores  per question bloack";
run; 
/* Fisher's Test on Road User v Demographics */
proc freq data=mme.final;
	title "Fisher's Test on Road User v Demographics";
	tables road_user * (international final_RE final_class Micromobility_Owner Live_on_Campus) / norow nocol;
run; 
quit; 

proc freq data=mme.final;
	title "Fisher's Test on Road User v Demographics";
	tables international * Micromobility_Owner / fisher chisq  norow nocol;
run; 
quit; 

proc freq data=mme.final;
    title "Driver vs E-Scooter Room";
    tables road_user * e_scooter_room / norow nocol;
run;

proc freq data=mme.final;
    title "Driver vs Bicyclist Room";
    tables road_user * bicyclist_room / norow nocol;
run;

/*Road User v. Demographics*/
proc freq data=mme.final nlevels;
	title "Road User v. Demographics";
	tables (Gender Final_RE International Final_Class Live_on_campus Micromobility_owner Final_RE)* road_user / list chisq nocum;
run; 
quit; 

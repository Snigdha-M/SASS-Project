Libname mydata "/home/u63822929/sasuser.v94/FinalAssignment";
options validvarname=v7;

proc import datafile='/home/u63822929/sasuser.v94/FinalAssignment/Chicago_Energy_Benchmarking.csv'
    out=mydata.energy_data dbms=csv replace; 
run;

proc print data=mydata.energy_data(obs=10);
run;


/* 1.  Top Natural Gas Consumption by Property Type Based on Reporting status = Submitted Data - Atia */ 

proc sql;
  create table ng_buildingwise_energy_table as
  select Primary_Property_Type, sum(Natural_Gas_Use__kBtu_) as NG_Consumption
  from mydata.energy_data
  where Primary_Property_Type is not null
  and UPPER(reporting_status) = "SUBMITTED DATA"
  group by Primary_Property_Type
  order by NG_Consumption desc;
quit;

proc sgplot data=ng_buildingwise_energy_table(obs=5);
  title 'NG Consumption by Year';
  vbar Primary_Property_Type / response=NG_Consumption;
  xaxis label='Primary_Property_Type';
  yaxis label='Mean Energy Consumption';
run;


/* 2.  Analysis of buildings of different energy ratings compare in terms of electricity and gas usage, and their overall ENERGY STAR scores  - Snigdha */

proc sql;
    create table energy_by_rating as
    select Chicago_Energy_Rating,
           count(*) as Number_of_Properties,
           sum(Electricity_Use__kBtu_) as Total_Electricity_Use,
           sum(Natural_Gas_Use__kBtu_) as Total_Natural_Gas_Use,
           mean(ENERGY_STAR_Score) as Avg_ENERGY_STAR_Score
    from mydata.energy_data
    where Chicago_Energy_Rating is not null
    group by Chicago_Energy_Rating
    order by Chicago_Energy_Rating;
quit;


proc sgplot data=energy_by_rating;
    vbar Chicago_Energy_Rating / response=Total_Electricity_Use datalabel;
    title "Total Electricity Usage by Chicago Energy Rating";
    xaxis label="Chicago Energy Rating";
    yaxis label="Total Electricity Use (kBtu)";
run;

proc sgplot data=energy_by_rating;
    vbar Chicago_Energy_Rating / response=Total_Natural_Gas_Use datalabel;
    title "Total Natural Gas Usage by Chicago Energy Rating";
    xaxis label="Chicago Energy Rating";
    yaxis label="Total Natural Gas Use (kBtu)";
run;

proc sgplot data=energy_by_rating;
    vbar Chicago_Energy_Rating / response=Avg_ENERGY_STAR_Score datalabel;
    title "Average ENERGY STAR Score by Chicago Energy Rating";
    xaxis label="Chicago Energy Rating";
    yaxis label="Average ENERGY STAR Score";
run;


/* 3. Energy Consumption Over Time - Astha / already done */

proc sql;
  create table yearwise_mean_energy_table as
  select Data_Year, mean(Electricity_Use__kBtu_) as Mean_Energy_Consumption
  from mydata.energy_data
  where Data_Year is not null
  group by Data_Year;
quit;

proc sgplot data=yearwise_mean_energy_table;
  title 'Energy Consumption Over Time';
  series x=Data_Year y=Mean_Energy_Consumption / markers;
run;

/* 4. Scatter plot along with regression analysis of Gross Floor area with Electricity usuage - Snigdha*/ 

proc reg data=mydata.energy_data;
    model Gross_Floor_Area___Buildings__sq = Electricity_Use__kBtu_; 
    title "Regression Analysis of Gross Floor area  vs Electricity Usage";
run;

proc sgplot data=mydata.energy_data;
    scatter x=Gross_Floor_Area___Buildings__sq  y=Electricity_Use__kBtu_ / markerattrs=(symbol=CircleFilled);
    reg x=Gross_Floor_Area___Buildings__sq y=Electricity_Use__kBtu_ / lineattrs=(color=red);
    title "Scatter Plot and Regression Line of Gross Floor area vs. Electricity Usage";
    xaxis label="Gross Floor area ";
    yaxis label="Electricity Usage";
run;

/* 5. Analysis of Total_GHG_Emissions__Metric_Tons - Atia*/

proc univariate data=mydata.energy_data;
    var Total_GHG_Emissions__Metric_Tons;
    histogram Total_GHG_Emissions__Metric_Tons/ normal;
    qqplot Total_GHG_Emissions__Metric_Tons / normal(mu=est sigma=est);
    title 'Univariate Analysis of Total_GHG_Emissions__Metric_Tons';
run;

/* 6. How do building characteristics (e.g., Gross Floor Area) affect GHG emissions for the top 5 zip codes - Atia*/

proc sql;
    create table total_ghg_by_prop_floor_area as
    select Zip_Code,
           Total_GHG_Emissions__Metric_Tons,
           Gross_Floor_Area___Buildings__sq
    from mydata.energy_data
    group by Zip_Code
    order by Total_GHG_Emissions__Metric_Tons desc;
quit;

proc sgplot data=total_ghg_by_prop_floor_area;
    scatter x=Gross_Floor_Area___Buildings__sq y=Total_GHG_Emissions__Metric_Tons / group=Zip_Code;
    reg x=Gross_Floor_Area___Buildings__sq y=Total_GHG_Emissions__Metric_Tons;
    xaxis label="Gross Floor Area (sq ft)";
    yaxis label="Total GHG Emissions (Metric Tons CO2e)";
    title "GHG Emissions vs. Gross Floor Area for Top 5 Zip Code";
run;


/* 7 Ttest to check if average energy score is equal to 59 - Astha  */
PROC TTEST data= mydata.energy_data h0= 59;
var ENERGY_STAR_Score;
RUN;


/* 8. Comparative Analysis of Average Site EUI and Source EUI Across Building Age Groups - Rashmi */

proc sql;
  create table energy_data_age_groups as
  select Year_Built,
         (year(today()) - Year_Built) as Building_Age,
         case
           when (year(today()) - Year_Built) <= 10 then '0-10 years'
           when (year(today()) - Year_Built) <= 20 then '11-20 years'
           when (year(today()) - Year_Built) <= 30 then '21-30 years'
           when (year(today()) - Year_Built) <= 40 then '31-40 years'
           else 'Over 40 years'
         end as Age_Group,
         Site_EUI__kBtu_sq_ft_ as Site_EUI,
         Source_EUI__kBtu_sq_ft_ as Source_EUI,
         Chicago_Energy_Rating as Rating
  from mydata.energy_data
  where Site_EUI__kBtu_sq_ft_ is not null
    and Source_EUI__kBtu_sq_ft_ is not null;
quit;


proc print data=energy_data_age_groups(obs=20);
  var Year_Built Building_Age Age_Group Site_EUI Source_EUI;
  title 'Data with Building Age Groups and Calculated Energy Metrics';
run;

proc print data=energy_data_age_groups(obs=20);
  var Year_Built Building_Age Age_Group Site_EUI Source_EUI;
  title 'Data with Building Age Groups and Calculated Energy Metrics';
run;

/* Reshape data for clustered bar chart */
data reshaped_energy_data;
  set energy_data_age_groups;
  Metric = 'Site EUI';
  EUI = Site_EUI;
  output;
  Metric = 'Source EUI';
  EUI = Source_EUI;
  output;
  keep Age_Group Metric EUI;
run;

/* Clustered bar chart for Average Site EUI and Average Source EUI by Building Age Group */
proc sgplot data=reshaped_energy_data;
  title 'Average Site EUI and Source EUI by Building Age Group';
  vbar Age_Group / response=EUI stat=mean group=Metric groupdisplay=cluster;
  xaxis display=(nolabel) label='Building Age Group';
  yaxis label='Average EUI';
  keylegend / title='Metrics' position=topright;
run;

/* 9 Categorical Association test between age_group and Energy rating - Asthma */
proc freq data=energy_data_age_groups;
    tables Rating*Age_Group / chisq;
run;

/* 10 Correlation between Natural Gas and Total GHG Emissions - Rashmi */

proc corr data=mydata.energy_data;
    var Natural_Gas_Use__kBtu_ Total_GHG_Emissions__Metric_tons;
    title "Correlation between Natural Gas and GHG Emissions";
run;

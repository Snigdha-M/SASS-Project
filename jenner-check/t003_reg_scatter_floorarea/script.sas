/* Adapted from "SASS Project.sas" (Chicago Energy Benchmarking analysis).
   Original read mydata.energy_data via PROC IMPORT from a hardcoded lab
   path; here the same columns are loaded from a small inline sample so
   the bundle is self-contained. Analysis logic (block 4: regression of
   Gross Floor Area vs Electricity usage) is unmodified from the source
   script. */

/* Mock sample of the Chicago Energy Benchmarking columns the original
   script reads (PROC IMPORT source: hardcoded lab path, replaced here
   with inline sample rows so the bundle is fully self-contained). */
data mydata.energy_data;
  infile datalines dsd dlm='|' truncover;
  length Primary_Property_Type $20 reporting_status $20;
  input Primary_Property_Type $ reporting_status $ Natural_Gas_Use__kBtu_
        Chicago_Energy_Rating Electricity_Use__kBtu_ ENERGY_STAR_Score
        Data_Year Gross_Floor_Area___Buildings__sq Total_GHG_Emissions__Metric_Tons
        Zip_Code Year_Built Site_EUI__kBtu_sq_ft_ Source_EUI__kBtu_sq_ft_;
  datalines;
Multifamily Housing|Submitted Data|1250000|3|980000|62|2019|185000|410|60601|1978|58.2|102.4
Office|Submitted Data|2100000|4|1650000|74|2019|240000|520|60602|1985|63.1|110.8
Retail Store|Submitted Data|540000|2|410000|45|2019|72000|180|60603|1995|71.4|120.5
K-12 School|Submitted Data|980000|3|720000|55|2019|150000|300|60604|1965|49.8|88.3
Hospital|Submitted Data|3200000|2|4100000|38|2019|310000|1450|60605|1972|140.2|255.6
Multifamily Housing|Submitted Data|1100000|4|890000|70|2020|165000|360|60606|1990|52.6|95.1
Office|Estimated Data|1900000|3|1550000|60|2020|225000|480|60607|1980|60.5|105.9
Retail Store|Submitted Data|610000|3|455000|58|2020|80000|195|60608|2001|68.9|115.2
K-12 School|Submitted Data|1020000|4|760000|66|2020|158000|315|60609|1968|48.1|86.7
Hospital|Submitted Data|3350000|1|4300000|30|2020|325000|1520|60610|1971|145.7|262.3
Multifamily Housing|Submitted Data|1300000|2|1010000|48|2021|190000|430|60611|1975|60.4|106.2
Office|Submitted Data|2200000|4|1720000|78|2021|248000|540|60612|1988|62.0|109.4
Retail Store|Submitted Data|560000|3|420000|52|2021|74000|182|60613|1998|70.1|118.6
K-12 School|Submitted Data|1000000|3|740000|57|2021|152000|305|60614|1966|49.0|87.5
Hospital|Estimated Data|3280000|2|4200000|35|2021|315000|1480|60615|1973|142.8|258.1
Multifamily Housing|Submitted Data|1180000|3|930000|64|2022|178000|395|60616|1982|57.1|100.6
Office|Submitted Data|2050000|4|1610000|72|2022|235000|505|60617|1983|61.4|108.0
Retail Store|Submitted Data|590000|2|435000|47|2022|77000|188|60618|1999|69.5|116.9
K-12 School|Submitted Data|990000|4|730000|68|2022|155000|308|60619|1967|48.6|87.0
Hospital|Submitted Data|3300000|1|4250000|32|2022|318000|1500|60620|1970|143.9|260.0
Multifamily Housing|Submitted Data|1220000|4|950000|69|2023|182000|405|60621|1979|58.6|103.1
Office|Submitted Data|2150000|3|1680000|63|2023|242000|525|60622|1986|62.5|109.9
Retail Store|Submitted Data|570000|3|425000|54|2023|75000|184|60623|1997|69.9|117.5
K-12 School|Submitted Data|1010000|2|745000|50|2023|153000|310|60624|1965|49.3|87.9
Hospital|Submitted Data|3260000|3|4180000|42|2023|312000|1470|60625|1974|141.5|256.4
Multifamily Housing|Submitted Data|1160000|3|915000|61|2024|176000|388|60626|1981|56.8|99.8
Office|Submitted Data|2000000|4|1590000|71|2024|232000|498|60627|1984|60.9|107.2
;
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

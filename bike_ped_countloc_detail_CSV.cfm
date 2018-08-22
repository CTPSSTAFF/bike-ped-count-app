<cfsetting enablecfoutputonly="Yes">
<cfset cr_lf = "#chr(13)#" & "#chr(10)#">
<cfquery name="records_for_detail_report_CSV" datasource="cert_act">
        SELECT  ID, COUNT_ID, BP_LOC_ID, LATITUDE, LONGITUDE,
                MUNICIPALITY, FACILITY_NAME,
                Bpcl.DESCRIPTION AS BPCL_DESCRIPTION,
                STREET_1, STREET_2, STREET_3, STREET_4, STREET_5, STREET_6,
                Bpc.DESCRIPTION AS BPC_DESCRIPTION,
                TEMPERATURE, SKY,
                FACILITY_TYPE, COUNT_TYPE,
                FROM_ST_NAME, FROM_ST_DIR, TO_ST_NAME, TO_ST_DIR, 
                TO_CHAR(COUNT_DATE, 'YYYY-MM-DD') AS TEXT_COUNT_DATE,  COUNT_DOW,
                CNT_0630, CNT_0645,
                CNT_0700, CNT_0715, CNT_0730, CNT_0745,
                CNT_0800, CNT_0815, CNT_0830, CNT_0845,
                CNT_0900, CNT_0915, CNT_0930, CNT_0945,
                CNT_1000, CNT_1015, CNT_1030, CNT_1045,
                CNT_1100, CNT_1115, CNT_1130, CNT_1145,
                CNT_1200, CNT_1215, CNT_1230, CNT_1245,
                CNT_1300, CNT_1315, CNT_1330, CNT_1345,
                CNT_1400, CNT_1415, CNT_1430, CNT_1445,
                CNT_1500, CNT_1515, CNT_1530, CNT_1545, 
                CNT_1600, CNT_1615, CNT_1630, CNT_1645,
                CNT_1700, CNT_1715, CNT_1730, CNT_1745,
                CNT_1800, CNT_1815, CNT_1830, CNT_1845,
                CNT_1900, CNT_1915, CNT_1930, CNT_1945,
                CNT_2000, CNT_2015, CNT_2030, CNT_2045,  
                CNT_TOTAL
        FROM    BP_COUNTS Bpc, BP_COUNT_LOCATIONS Bpcl
        WHERE   Bpc.BP_LOC_ID = Bpcl.LOC_ID 
                <cfif #URL.csv_loc_id# IS NOT ""> 
                   AND Bpc.BP_LOC_ID = #URL.csv_loc_id#
               </cfif>
               <cfif NOT ("+999+998+" CONTAINS URL.csv_municipality)>
                   AND Bpc.Municipality LIKE '%#URL.csv_municipality#%'
               </cfif>
               <cfif NOT ("+999+998+" CONTAINS URL.csv_facility_name)>
                   AND Bpc.Facility_Name LIKE '%#URL.csv_facility_name#%'
               </cfif>
               <cfif NOT ("+01-JAN-1900+02-JAN-1900+" CONTAINS URL.csv_date)>
                   AND TO_CHAR(Bpc.COUNT_DATE, 'YYYY') = '#URL.csv_date#'
               </cfif>              
        <!--- GROUP BY COUNT_ID, FROM_ST_NAME, FROM_ST_DIR, TO_ST_NAME, TO_ST_DIR --->
        ORDER BY ID
</cfquery>
<cfcontent type="text/csv">
<cfheader name="Content-Disposition" value="attachment; filename=bike_ped_counts.csv"> 
<!--- output header records --->
<cfoutput>"BP_LOC_ID","LATITUDE","LONGITUDE","COUNT_ID","MUNICIPALITY","FACILITY_NAME","CNT_LOC_DESCRIPTION","STREET_1","STREET_2","STREET_3","STREET_4","STREET_5","STREET_6","CNT_DESCRIPTION","TEMPERATURE","SKY","FACILITY_TYPE","COUNT_TYPE","FROM_ST_NAME","FROM_ST_DIR","TO_ST_NAME","TO_ST_DIR","COUNT_DATE","COUNT_DOW","CNT_0630","CNT_0645","CNT_0700","CNT_0715","CNT_0730","CNT_0745","CNT_0800","CNT_0815","CNT_0830","CNT_0845","CNT_0900","CNT_0915","CNT_0930","CNT_0945","CNT_1000","CNT_1015","CNT_1030","CNT_1045","CNT_1100","CNT_1115","CNT_1130","CNT_1145","CNT_1200","CNT_1215","CNT_1230","CNT_1245","CNT_1300","CNT_1315","CNT_1330","CNT_1345","CNT_1400","CNT_1415","CNT_1430","CNT_1445","CNT_1500","CNT_1515","CNT_1530","CNT_1545","CNT_1600","CNT_1615","CNT_1630","CNT_1645","CNT_1700","CNT_1715","CNT_1730","CNT_1745","CNT_1800","CNT_1815","CNT_1830","CNT_1845","CNT_1900","CNT_1915","CNT_1930","CNT_1945","CNT_2000","CNT_2015","CNT_2030","CNT_2045","CNT_TOTAL"#cr_lf#</cfoutput>    
<cfoutput query="records_for_detail_report_CSV">#BP_LOC_ID#,#LATITUDE#,#LONGITUDE#,#COUNT_ID#,"#MUNICIPALITY#","#FACILITY_NAME#","#BPCL_DESCRIPTION#","#STREET_1#","#STREET_2#","#STREET_3#","#STREET_4#","#STREET_5#","#STREET_6#","#BPC_DESCRIPTION#",#TEMPERATURE#,#SKY#,"#FACILITY_TYPE#","#COUNT_TYPE#","#FROM_ST_NAME#","#FROM_ST_DIR#","#TO_ST_NAME#","#TO_ST_DIR#",#TEXT_COUNT_DATE#,"#COUNT_DOW#",#CNT_0630#,#CNT_0645#,#CNT_0700#,#CNT_0715#,#CNT_0730#,#CNT_0745#,#CNT_0800#,#CNT_0815#,#CNT_0830#,#CNT_0845#,#CNT_0900#,#CNT_0915#,#CNT_0930#,#CNT_0945#,#CNT_1000#,#CNT_1015#,#CNT_1030#,#CNT_1045#,#CNT_1100#,#CNT_1115#,#CNT_1130#,#CNT_1145#,#CNT_1200#,#CNT_1215#,#CNT_1230#,#CNT_1245#,#CNT_1300#,#CNT_1315#,#CNT_1330#,#CNT_1345#,#CNT_1400#,#CNT_1415#,#CNT_1430#,#CNT_1445#,#CNT_1500#,#CNT_1515#,#CNT_1530#,#CNT_1545#,#CNT_1600#,#CNT_1615#,#CNT_1630#,#CNT_1645#,#CNT_1700#,#CNT_1715#,#CNT_1730#,#CNT_1745#,#CNT_1800#,#CNT_1815#,#CNT_1830#,#CNT_1845#,#CNT_1900#,#CNT_1915#,#CNT_1930#,#CNT_1945#,#CNT_2000#,#CNT_2015#,#CNT_2030#,#CNT_2045#,#CNT_TOTAL##cr_lf#</cfoutput> 
<cfoutput> #cr_lf# </cfoutput>
      


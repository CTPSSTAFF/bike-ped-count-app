<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<style type="text/css">
p.pagebreak {page-break-before: always}
sup {font-size:80%; vertical-align:20%}
table {page-break-inside:avoid}

tr.avoid_pagebreak_after {page-break-after: avoid}

th {border-top-style:none; border-bottom-style:none; padding-bottom:0; border-left-style:none}
th.column_header {empty-cells:show; font-weight:bold; background-color:#dddddd; page-break-after:avoid}
th.row_header    {empty-cells:show; font-weight:bold; background-color:#dddddd; page-break-after:avoid} /* Identical to th.column_header, for now. */
th.time_header   {empty-cells:show; font-weight:normal; background-color:#ebebeb; page-break-after:avoid; border-right-style:solid; border-right-width:thin}
th.time_header_empty   {empty-cells:show; font-weight:normal; page-break-after:avoid; border-right-style:none}
th.time_header_end_of_row  {empty-cells:show; font-weight:normal; background-color:#ebebeb; border-right-style:none; page-break-after:avoid}
th.peak_header   {empty-cells:show; font-weight:bold; background-color:rgb(189,189,189); border-right:solid thin black; padding:0em 0.5em 0em 0.5em}
th.peak_header_end_of_row   {empty-cells:show; font-weight:bold; background-color:rgb(189,189,189); padding:0em 0.5em 0em 0.5em}
th.peak_period_am   {empty-cells:show; font-weight:bold; background-color:rgb(235,235,235); border-right:solid thin black}
th.peak_period_pm   {empty-cells:show; font-weight:bold; background-color:rgb(235,235,235)}
th.peak_row_header  {empty-cells:show; font-weight:bold; background-color:rgb(189,189,189); padding:0em 0.5em 0em 0.5em}

td {border-top-style:none; border-bottom-style:none; padding-bottom:0; border-left-style:none}
td.data_cell {white-space:nowrap; empty-cells:show; font-weight:bold; border-right-style:solid; border-right-width:thin}
td.data_cell_empty {white-space:nowrap; empty-cells:show; border-right-style:none}
td.data_cell_end_of_row {white-space:nowrap; empty-cells:show; font-weight:bold; border-right-style:none}
td.row_description {white-space:normal; max-width:21.5em; text-align:left; empty-cells:show; font-weight:normal; }
td.peak_period_cell {empty-cells:show; font-weight:bold; background-color:#dddddd; page-break-after:avoid}
td.peak_period_title {font-weight:bold; text-align:center; border:solid thin black}
td.peak_period_hour {empty-cells:show; font-weight:normal; border-right:solid thin black; text-align:center; padding:0em 0.5em 0em 0.5em}
td.peak_period_count {empty-cells:show; font-weight:normal; border-right:solid thin black; text-align:right; padding:0em 0.5em 0em 0.5em}
td.peak_period_end_of_row {empty-cells:show; font-weight:normal; text-align:right; padding:0em 0.5em 0em 0.5em}

span.meridian {font-size:80%}
span.note {font-size:80%}
div.countHeader {max-width:9in}
#peakHourCountInfo {float:right}


</style>
<title>Bicycle / Pedestrian Count Location Detail</title>
<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
	<cfquery name="records_for_detail_report" datasource="cert_act">
        SELECT  COUNT_ID, Bpcl.LOC_ID, MUNICIPALITY, LATITUDE, LONGITUDE,
                Bpcl.DESCRIPTION AS THE_DESCRIPTION, FACILITY_NAME,
                STREET_1, STREET_2, STREET_3, STREET_4, STREET_5, STREET_6,
                FACILITY_TYPE, Bpc.DESCRIPTION AS ROW_DESCRIPTION,
                FROM_ST_NAME, FROM_ST_DIR, TO_ST_NAME, TO_ST_DIR, COUNT_TYPE,
                COUNT_DOW, TO_CHAR(COUNT_DATE, 'DD-MON-YYYY') AS TEXT_COUNT_DATE, 
		COUNT_DATE,
                TEMPERATURE, SKY,
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
                <cfif #URL.loc_id# IS NOT ""> 
                   AND Bpc.BP_LOC_ID = #URL.loc_id#
               </cfif>
               <cfif NOT ("+999+998+" CONTAINS URL.html_municipality)>
                   AND Bpc.Municipality LIKE '%#URL.html_municipality#%'
               </cfif>
               <cfif NOT ("+999+998+" CONTAINS URL.html_facility_name)>
                   AND Bpc.Facility_Name LIKE '%#URL.html_facility_name#%'
               </cfif>
               <cfif NOT ("+01-JAN-1900+02-JAN-1900+" CONTAINS URL.html_date)>
                   AND TO_CHAR(Bpc.COUNT_DATE, 'YYYY') = '#URL.html_date#'
               </cfif>              
        <!--- GROUP BY COUNT_ID, FROM_ST_NAME, FROM_ST_DIR, TO_ST_NAME, TO_ST_DIR --->
        ORDER BY Bpcl.LOC_ID, COUNT_DATE DESC, COUNT_ID, FROM_ST_NAME, FROM_ST_DIR, TO_ST_NAME, TO_ST_DIR, COUNT_TYPE
	</cfquery>

	<!--- Query of query to aggregate quarter-hour counts to hour counts and sum by count_ID --->
	<cfquery name="peak_summary" dbtype="query">
	SELECT
		COUNT_ID,
		<cfset startTime = CreateTime(6,30,0)><cfset endTime = CreateTime(20,0,0)><cfset intervalTime = CreateTimeSpan(0,0,15,0)>
		<cfloop index="time_index" from="#startTime#" to="#endTime#" step="#intervalTime#">
			<cfset quarter2 = time_index + intervalTime>
			<cfset quarter3 = quarter2 + intervalTime>
			<cfset quarter4 = quarter3 + intervalTime>
			<cfoutput>
		sum(CNT_#TimeFormat(time_index,"HHmm")# + CNT_#TimeFormat(quarter2,"HHmm")# + CNT_#TimeFormat(quarter3,"HHmm")# + CNT_#TimeFormat(quarter4,"HHmm")#) HOUR_#TimeFormat(time_index,"HHmm")#<cfif time_index LT endTime>,</cfif>
			</cfoutput>
		</cfloop>
	FROM
		records_for_detail_report
	GROUP BY
		COUNT_ID
	</cfquery>

	<!--- Query of query to aggregate quarter-hour counts, for bicycle users only, to hour counts and sum by count_ID --->
	<cfquery name="peak_summary_bike" dbtype="query">
	SELECT
		COUNT_ID,
		<cfset startTime = CreateTime(6,30,0)><cfset endTime = CreateTime(20,0,0)><cfset intervalTime = CreateTimeSpan(0,0,15,0)>
		<cfloop index="time_index" from="#startTime#" to="#endTime#" step="#intervalTime#">
			<cfset quarter2 = time_index + intervalTime>
			<cfset quarter3 = quarter2 + intervalTime>
			<cfset quarter4 = quarter3 + intervalTime>
			<cfoutput>
		sum(CNT_#TimeFormat(time_index,"HHmm")# + CNT_#TimeFormat(quarter2,"HHmm")# + CNT_#TimeFormat(quarter3,"HHmm")# + CNT_#TimeFormat(quarter4,"HHmm")#) HOUR_#TimeFormat(time_index,"HHmm")#<cfif time_index LT endTime>,</cfif>
			</cfoutput>
		</cfloop>
	FROM
		records_for_detail_report
	WHERE
		COUNT_TYPE = 'B'
	GROUP BY
		COUNT_ID
	</cfquery>

	<!--- For each row of summary numbers, find the peak hours and counts within the AM and PM peak periods and overall --->
	<!--- Store results in dynamic CF variables (organized by COUNT_ID) for later use --->
	<cfset timeFormatMain = "h:mm">
	<cfset timeFormatMeridian = "tt">
	<cfset startTimePeak = CreateTime(7,0,0)><cfset endTimePeak = CreateTime(19,0,0)>
	<cfset startTimeAMPeak = CreateTime(6,0,0)><cfset endTimeAMPeak = CreateTime(10,0,0)>
	<cfset startTimePMPeak = CreateTime(15,0,0)><cfset endTimePMPeak = CreateTime(19,0,0)>
	<cfset startTime = CreateTime(6,30,0)><cfset endTime = CreateTime(20,0,0)>
	<cfset quarterHour = CreateTimeSpan(0,0,15,0)><cfset oneHour = CreateTimeSpan(0,1,0,0)>
	<cfoutput query="peak_summary">
		<cfset "peakHourCount#COUNT_ID#" = ""><cfset "peakHour#COUNT_ID#" = ""><cfset "peakHourComplete#COUNT_ID#" = "">
		<cfset "peakHourAMCount#COUNT_ID#" = ""><cfset "peakHourAM#COUNT_ID#" = ""><cfset "peakHourAMComplete#COUNT_ID#" = "">
		<cfset "peakHourPMCount#COUNT_ID#" = ""><cfset "peakHourPM#COUNT_ID#" = ""><cfset "peakHourPMComplete#COUNT_ID#" = "">
		<cfloop index="time_index" from="#startTime#" to="#endTime#" step="#CreateTimeSpan(0, 0, 15, 0)#">
			<cfset countValue = Evaluate('peak_summary.HOUR_#TimeFormat(time_index,"HHmm")#')>
			<cfset hourText = TimeFormat(time_index,timeFormatMain) & ' <span class="meridian">' & 
				TimeFormat(time_index,timeFormatMeridian) & "</span>&ndash;" & 
				TimeFormat((time_index + oneHour),timeFormatMain) & ' <span class="meridian">' &
				TimeFormat((time_index + oneHour),timeFormatMeridian) & "</span>">
			<cfif countValue IS NOT "">
				<cfif ((time_index GREATER THAN OR EQUAL TO startTimeAMPeak) AND (time_index LESS THAN (endTimeAMPeak-oneHour)))
				   OR ((time_index GREATER THAN OR EQUAL TO startTimePMPeak) AND (time_index LESS THAN (endTimePMPeak-oneHour)))>
					<cfif (time_index GREATER THAN OR EQUAL TO startTimeAMPeak) AND (time_index LESS THAN (endTimeAMPeak-oneHour))>
						<cfset peakHourVariable = "peakHourAM#COUNT_ID#">
						<cfset peakCountVariable = "peakHourAMCount#COUNT_ID#">
					<cfelse>
						<cfset peakHourVariable = "peakHourPM#COUNT_ID#">
						<cfset peakCountVariable = "peakHourPMCount#COUNT_ID#">
					</cfif>
					<cfif Evaluate("#peakCountVariable#") IS "">
						<cfset "#peakCountVariable#" = countValue>
						<cfset "#peakHourVariable#" = hourText>
					<cfelseif countValue GREATER THAN Evaluate("#peakCountVariable#")>
						<cfset "#peakCountVariable#" = countValue>
						<cfset "#peakHourVariable#" = hourText>
					</cfif>
				</cfif>
				<cfif (time_index GREATER THAN OR EQUAL TO startTimePeak) AND (time_index LESS THAN (endTimePeak-oneHour))>
					<cfif Evaluate("peakHourCount#COUNT_ID#") IS "">
						<cfset "peakHourCount#COUNT_ID#" = countValue>
						<cfset "peakHour#COUNT_ID#" = hourText>
					<cfelseif countValue GREATER THAN Evaluate("peakHourCount#COUNT_ID#")>
						<cfset "peakHourCount#COUNT_ID#" = countValue>
						<cfset "peakHour#COUNT_ID#" = hourText>
					</cfif>
				</cfif>
			<cfelse>
				<cfif (time_index GREATER THAN OR EQUAL TO startTimeAMPeak) AND (time_index LESS THAN (endTimeAMPeak-oneHour))>
					<cfset "peakHourAMComplete#COUNT_ID#" = '<sup>*</sup>'>
				</cfif>
				<cfif (time_index GREATER THAN OR EQUAL TO startTimePMPeak) AND (time_index LESS THAN (endTimePMPeak-oneHOur))>
					<cfset "peakHourPMComplete#COUNT_ID#" = '<sup>*</sup>'>
				</cfif>
				<cfif (time_index GREATER THAN OR EQUAL TO startTimePeak) AND (time_index LESS THAN (endTimePeak-oneHour))>
					<cfset "peakHourComplete#COUNT_ID#" = '<sup>*</sup>'>
				</cfif>
			</cfif>
		</cfloop>
	</cfoutput>

	<!--- For each row of summary bike numbers, find the peak hours within the AM and PM peak periods and overall ---> 
	<!--- Store results in dynamic CF variables (organized by COUNT_ID) for later use --->
	<cfoutput query="peak_summary_bike">
		<cfset "peakHourCountBike#COUNT_ID#" = ""><cfset "peakHourBike#COUNT_ID#" = ""><cfset "peakHourCompleteBike#COUNT_ID#" = "">
		<cfset "peakHourAMCountBike#COUNT_ID#" = ""><cfset "peakHourAMBike#COUNT_ID#" = ""><cfset "peakHourAMCompleteBike#COUNT_ID#" = "">
		<cfset "peakHourPMCountBike#COUNT_ID#" = ""><cfset "peakHourPMBike#COUNT_ID#" = ""><cfset "peakHourPMCompleteBike#COUNT_ID#" = "">
		<cfloop index="time_index" from="#startTime#" to="#endTime#" step="#CreateTimeSpan(0, 0, 15, 0)#">
			<cfset countValueBike = Evaluate('peak_summary_bike.HOUR_#TimeFormat(time_index,"HHmm")#')>
			<cfset hourText = TimeFormat(time_index,timeFormatMain) & ' <span class="meridian">' & 
				TimeFormat(time_index,timeFormatMeridian) & "</span>&ndash;" & 
				TimeFormat((time_index + CreateTimeSpan(0,1,0,0)),timeFormatMain) & ' <span class="meridian">' &
				TimeFormat((time_index + CreateTimeSpan(0,1,0,0)),timeFormatMeridian) & "</span>">
			<cfif countValueBike IS NOT "">
				<cfif ((time_index GREATER THAN OR EQUAL TO startTimeAMPeak) AND (time_index LESS THAN (endTimeAMPeak-oneHour)))
				   OR ((time_index GREATER THAN OR EQUAL TO startTimePMPeak) AND (time_index LESS THAN (endTimePMPeak-oneHour)))>
					<cfif (time_index GREATER THAN OR EQUAL TO startTimeAMPeak) AND (time_index LESS THAN (endTimeAMPeak-oneHour))>
						<cfset peakHourBikeVariable = "peakHourAMBike#COUNT_ID#">
						<cfset peakCountBikeVariable = "peakHourAMCountBike#COUNT_ID#">
					<cfelse>
						<cfset peakHourBikeVariable = "peakHourPMBike#COUNT_ID#">
						<cfset peakCountBikeVariable = "peakHourPMCountBike#COUNT_ID#">
					</cfif>
					<cfif Evaluate("#peakCountBikeVariable#") IS "">
						<cfset "#peakCountBikeVariable#" = countValueBike>
						<cfset "#peakHourBikeVariable#" = hourText>
					<cfelseif countValueBike GREATER THAN Evaluate("#peakCountBikeVariable#")>
						<cfset "#peakCountBikeVariable#" = countValueBike>
						<cfset "#peakHourBikeVariable#" = hourText>
					</cfif>
				</cfif>
				<cfif (time_index GREATER THAN OR EQUAL TO startTimePeak) AND (time_index LESS THAN (endTimePeak-oneHour))>
					<cfif Evaluate("peakHourCountBike#COUNT_ID#") IS "">
						<cfset "peakHourCountBike#COUNT_ID#" = countValueBike>
						<cfset "peakHourBike#COUNT_ID#" = hourText>
					<cfelseif countValueBike GREATER THAN Evaluate("peakHourCountBike#COUNT_ID#")>
						<cfset "peakHourCountBike#COUNT_ID#" = countValueBike>
						<cfset "peakHourBike#COUNT_ID#" = hourText>
					</cfif>
				</cfif>
			<cfelse>
				<cfif (time_index GREATER THAN OR EQUAL TO startTimeAMPeak) AND (time_index LESS THAN (endTimeAMPeak-oneHour))>
					<cfset "peakHourAMCompleteBike#COUNT_ID#" = '<sup>*</sup>'>
				</cfif>
				<cfif (time_index GREATER THAN OR EQUAL TO startTimePMPeak) AND (time_index LESS THAN (endTimePMPeak-oneHour))>
					<cfset "peakHourPMCompleteBike#COUNT_ID#" = '<sup>*</sup>'>
				</cfif>
				<cfif (time_index GREATER THAN OR EQUAL TO startTimePeak) AND (time_index LESS THAN (endTimePeak-oneHour))>
					<cfset "peakHourCompleteBike#COUNT_ID#" = '<sup>*</sup>'>
				</cfif>
			</cfif>
		</cfloop>
	</cfoutput>

<script language="JavaScript" type="text/javascript">
	// Open a CSV FORMAT bike-ped count loc record detail page using the hidden "csvDetailRequestForm" form. 
function openCountLocDetailCSV(loc_id) {
	document.getElementById("csv_loc_id").value = loc_id;
	// Get the parameters with which this page was opened, in order to open the CSV detail page.	
	document.getElementById("csv_municipality").value = <cfoutput> '#URL.html_municipality#' </cfoutput>;
	document.getElementById("csv_facility_name").value = <cfoutput> '#URL.html_facility_name#' </cfoutput>;
	document.getElementById("csv_date").value = <cfoutput> '#URL.html_date#' </cfoutput>;
	document.getElementById("detailRequestFormCSV").submit();
	return void(0);
}
</script>
</head>
<body style="background-color:white;">
<input type="button" id="get_this_data_CSV" value="Download this data" onClick="openCountLocDetailCSV('')"/>
<input type="button" id="close_this_window" value="Close this window" onClick="self.close()"/>
<div>
<form action="bike_ped_countloc_detail_CSV.cfm" method="get" name="detailRequestFormCSV" id="detailRequestFormCSV" 
		target="_blank">
        <input type="hidden" name="csv_loc_id" id="csv_loc_id" value="">
        <input type="hidden" name="csv_municipality" id="csv_municipality" value="#URL.html_municipality#">
		<input type="hidden" name="csv_facility_name" id="csv_facility_name" value="#URL.html_facility_name#">
		<input type="hidden" name="csv_date" id="csv_date" value="#URL.html_date#">
    </form>
</div>

    <cfset generated_output = false> 
    <cfset cur_count_id = "">
    <cfset saved_count_id = "">
    <cfset saved_loc_id = "">
    <cfset saved_latitude = "">
    <cfset saved_longitude = "">
    <cfset first_count_id = true>
    <cfset full_text_dow = "">
    <cfset am_peak_times = "">
    <cfset pm_peak_times = "">
    
<!---<cfdump var="#peak_summary#">
<cfdump var="#peak_summary_bike#">--->
    <cfoutput><h3>Boston Region MPO Bicycle / Pedestrian Traffic Count Report</h3></cfoutput>
    <cfloop query="records_for_detail_report"> 
    
    	<!--- The body of this loop is executed for each record that satisfies the "records_for_detail_report" query. 
		      This set of records may, and in most cases does, contain records for more than one COUNT_ID.---> 
              
        <cfset generated_output = true>  
    	<cfset cur_count_id = #COUNT_ID#>
        <cfif cur_count_id IS NOT saved_count_id> 
              
        	<!--- We're beginning to process a batch of records with a new count ID.
				  Write out the "preamble" that applies to all records with that count ID.
				  The "preamble" contains:
				      1. count date and day-of-week
					  2. municipality and count-loc description
					  3. streets (up to six)
					  4. facility name and count type
					  5. temperature and sky conditions
				  But before writing the "preamble", unless this is the very first count ID
				  we're processing, write out the "post-amble" that applies to the set of
				  records with the *previous* count ID.
				  The "post-amble" contains:
				      1. count ID and count-loc ID
					  2. latitude and longitude
			 --->
             <cfif first_count_id IS true>
             	<cfset first_count_id = false>
             <cfelse>
                <!--- Generate the post-amble.
                      Output: saved count_id, loc_id, latitude, longitude. 
					  Do this *before* overwriting these values, below.
				--->
                <cfoutput> <b>Count ID:&nbsp;#saved_count_id#&nbsp;Location ID:&nbsp;#saved_loc_id#</b><br /> </cfoutput>
                <cfoutput> <b>Latitude:&nbsp;#saved_latitude#&nbsp;N&nbsp;Longitude:&nbsp;#abs(saved_longitude)#&nbsp;W</b><br /> </cfoutput>
                <cfoutput> <hr /> </cfoutput>
             	<cfoutput> <p class="pagebreak"> </p> </cfoutput>
             </cfif> 
                                         
            <cfset saved_count_id = #cur_count_id#>
            <cfset saved_loc_id = #LOC_ID#>
            <cfset saved_latitude = #LATITUDE#>
            <cfset saved_longitude = #LONGITUDE#>
                        
            <cfswitch expression = #COUNT_DOW#>
            	<cfcase value = "Su">
                	<cfset full_text_dow = "Sunday">
                </cfcase>
                <cfcase value = "M">
                	<cfset full_text_dow = "Monday">
                </cfcase>
                 <cfcase value = "M-Hol">
                	<cfset full_text_dow = "Monday (holiday)">
                </cfcase>               
                <cfcase value = "Tu">
                	<cfset full_text_dow = "Tuesday">
                </cfcase>
                <cfcase value = "Tu-Hol">
                	<cfset full_text_dow = "Tuesday (holiday)">
                </cfcase>                
                <cfcase value = "W">
                	<cfset full_text_dow = "Wednesday">
                </cfcase>
                <cfcase value = "W-Hol">
                	<cfset full_text_dow = "Wednesday (holiday)">
                </cfcase>                              
                <cfcase value = "Th">
                	<cfset full_text_dow = "Thursday">
                </cfcase>
                <cfcase value = "Th-Hol">
                	<cfset full_text_dow = "Thursday (holiday)">
                </cfcase>                                
                <cfcase value = "F">
                	<cfset full_text_dow = "Friday">
                </cfcase>
                <cfcase value = "F-Hol">
                	<cfset full_text_dow = "Friday (holiday)">
                </cfcase>                
                <cfcase value = "Sa">
                	<cfset full_text_dow = "Saturday">
                </cfcase>               
                <cfdefaultcase>
                	<cfset full_text_dow = "">
                </cfdefaultcase>
            </cfswitch> 
            <cfoutput> <br /> </cfoutput>           

	    <!--- A table of peak hour data for each count, floated to the upper right of the count data itself. --->
	<div class="countHeader">
            <div id="peakHourCountInfo">
                <table id="peakHourCountInfoTable" cellspacing="0">
                    <tr>
                        <cfoutput>
                            <cfif DayOfWeek(COUNT_DATE) IS 1 OR DayOfWeek(COUNT_DATE) IS 7>
                                	<td class="peak_period_title">PEAK</td>
					<th class="peak_header">Hour (#TimeFormat(startTimePeak,timeFormatMain)#
						<span class="meridian">#TimeFormat(startTimePeak,timeFormatMeridian)#</span>&ndash;#TimeFormat(endTimePeak,
						timeFormatMain)# <span class="meridian">#TimeFormat(endTimePeak,
						timeFormatMeridian)#</span>)#Evaluate("peakHourComplete" & COUNT_ID)#</th>
					<th class="peak_header_end_of_row">Count</th>
                         	   </tr>
                          	  <tr>
                                        <th class="peak_row_header">Bicycle</th>
					<td class="peak_period_hour">
						<cfif isDefined("peakHourBike" & COUNT_ID)>#Evaluate("peakHourBike" & COUNT_ID)#</cfif>
					</td>
					<td class="peak_period_end_of_row">
						<cfif isDefined("peakHourBike" & COUNT_ID)>#Evaluate("peakHourCountBike" & COUNT_ID)#</cfif></td>
                                    </tr>
                                    <tr>
                                        <th class="peak_row_header">All</th>
					<td class="peak_period_hour">#Evaluate("peakHour" & COUNT_ID)#</td>
					<td class="peak_period_end_of_row">#Evaluate("peakHourCount" & COUNT_ID)#</td>
                                    <cfif Evaluate("peakHourComplete" & COUNT_ID) IS NOT "">
					</tr>
                                        <tr>
						<td colspan="3"><sup>*</sup><span class="note">This count does not cover the entire period.</span></td>
				    </cfif>
                            <cfelse>
	                                <td rowspan="2" class="peak_period_title">PEAK</td>
					<th class="peak_period_am" colspan="2">AM (#TimeFormat(startTimeAMPeak,timeFormatMain)#
						<span class="meridian">#TimeFormat(startTimeAMPeak,timeFormatMeridian)#</span>&ndash;#TimeFormat(endTimeAMPeak,
						timeFormatMain)# <span class="meridian">#TimeFormat(endTimeAMPeak,
						timeFormatMeridian)#</span>)#Evaluate("peakHourAMComplete" & COUNT_ID)#</th>
					<th class="peak_period_pm" colspan="2">PM (#TimeFormat(startTimePMPeak,timeFormatMain)#
						<span class="meridian">#TimeFormat(startTimePMPeak,timeFormatMeridian)#</span>&ndash;#TimeFormat(endTimePMPeak,
						timeFormatMain)# <span class="meridian">#TimeFormat(endTimePMPeak,
						timeFormatMeridian)#</span>)#Evaluate("peakHourPMComplete" & COUNT_ID)#</th>
	                            </tr>
	                            <tr>
					<th class="peak_header">Hour</th><th class="peak_header">Count</th>
					<th class="peak_header">Hour</th><th class="peak_header_end_of_row">Count</th>
	                            </tr>
	                            <tr>
                                        <th class="peak_row_header">Bicycles</th>
                                            <td class="peak_period_hour">
						<cfif isDefined("peakHourAMBike" & COUNT_ID)>#Evaluate("peakHourAMBike" & COUNT_ID)#</cfif>
					    </td>
					    <td class="peak_period_count">
						<cfif isDefined("peakHourAMCountBike" & COUNT_ID)>#Evaluate("peakHourAMCountBike" & COUNT_ID)#</cfif></td>
                                            <td class="peak_period_hour">
						<cfif isDefined("peakHourPMBike" & COUNT_ID)>#Evaluate("peakHourPMBike" & COUNT_ID)#</cfif>
					    </td>
					    <td class="peak_period_end_of_row">
						<cfif isDefined("peakHourPMCountBike" & COUNT_ID)>#Evaluate("peakHourPMCountBike" & COUNT_ID)#</cfif></td>
                                    </tr>
                                    <tr>
                                        <th class="peak_row_header">All</th>
                                            <td class="peak_period_hour">#Evaluate("peakHourAM" & COUNT_ID)#</td>
					    <td class="peak_period_count">#Evaluate("peakHourAMCount" & COUNT_ID)#</td>
                                            <td class="peak_period_hour">#Evaluate("peakHourPM" & COUNT_ID)#</td>
					    <td class="peak_period_end_of_row">#Evaluate("peakHourPMCount" & COUNT_ID)#</td>
                                    <cfif Evaluate("peakHourAMComplete" & COUNT_ID) IS NOT "" OR Evaluate("peakHourPMComplete" & COUNT_ID) IS NOT "">
					</tr>
                                        <tr>
						<td colspan="5"><sup>*</sup><span class="note">This count does not cover the entire period.</span></td>
				    </cfif>
                            </cfif>
                        </cfoutput>
                    </tr>
                </table>
            </div>
	    <!--- End of summary table of peak data for count --->

            <cfoutput><b>Date:&nbsp;#full_text_dow#&nbsp;#TEXT_COUNT_DATE#</b><br /></cfoutput>
            <cfoutput><b>#MUNICIPALITY# : #THE_DESCRIPTION# </b><br /></cfoutput>
            <!--- Although it would appear that STREET_1 is never empty, we handle that case here, just in case. --->
            <cfif #STREET_1# IS NOT "">
            	<cfif #STREET_2# IS "">
                	<cfoutput><b>Street: #STREET_1#</cfoutput>
                <cfelse>
                	<cfoutput><b>Streets: #STREET_1#, #STREET_2#</cfoutput>
                </cfif>    
                <cfif #STREET_3# IS NOT "">
                	<cfoutput>, #STREET_3#</cfoutput>
                </cfif>
                <cfif #STREET_4# IS NOT "">
                	<cfoutput>, #STREET_4#</cfoutput>
                </cfif>              
                <!--- Currently, it appears that STREET_5 and STREET_6 are always empty.
				      Be prepared to handle cases when they are not empty. --->
                 <cfif #STREET_5# IS NOT "">
                	<cfoutput>, #STREET_5#</cfoutput>
                </cfif>
                <cfif #STREET_6# IS NOT "">
                	<cfoutput>, #STREET_6#</cfoutput>
                </cfif>              
            	<cfoutput> </b><br /></cfoutput>               
            </cfif>       
            <cfoutput><b>#FACILITY_NAME# #FACILITY_TYPE# </b><br /></cfoutput>
            <cfoutput><b>#TEMPERATURE#<cfif #TEMPERATURE# IS NOT "">&deg;F,</cfif></cfoutput>
            <cfswitch expression = #SKY#>
            	<cfcase value = 1>
                	<cfoutput>Sunny</cfoutput>
                </cfcase>
                <cfcase value = 2>
                	<cfoutput>Partly cloudy</cfoutput>
                </cfcase>
                <cfcase value = 3>
                	<cfoutput>Overcast</cfoutput>
                </cfcase>
                <cfcase value = 4>
                	<cfoutput>Precipitation</cfoutput>
                </cfcase>
                <cfcase value = -99>
                	<cfoutput><cfif #TEMPERATURE# IS "">Weather<cfelse>Sky condition</cfif> not recorded</cfoutput>
                </cfcase>
                <cfdefaultcase>
                	<cfoutput></cfoutput>
                </cfdefaultcase>
            </cfswitch>           
	</div>
            <cfoutput></b><br /> </cfoutput>  
         </cfif> <!--- END IF we're processing a record with a new count_id, and 
		               thus need to generate a "preamble" that applies to all records with that count_id. --->
        
         <cfoutput> <table cellspacing=0> </cfoutput>
         
         <!--- Output the individual cells of one *logical* row of the table. 
		       This is divided into four *phyisical* rows. --->
         
         <!--- Physical row #1: the "from", "to", and "count type" header information. --->
 		 <cfoutput> <tr class="avoid_pagebreak_after"> </cfoutput>
         <cfoutput> <th>&nbsp;  </th> </cfoutput>
         
 		 <cfoutput> <th colspan=8 align="left" class="column_header"> </cfoutput>
         <cfoutput>From: &nbsp; #FROM_ST_NAME# #FROM_ST_DIR#</cfoutput>
         <cfoutput> </th> </cfoutput>
         
         <cfoutput> <th colspan=8 align="left" class="column_header"> </cfoutput>
         <cfoutput>To: &nbsp; #TO_ST_NAME# #TO_ST_DIR#</cfoutput>
         <cfoutput> </th> </cfoutput>
         
         <cfoutput> <th colspan=8 align="left" class="column_header"> </cfoutput>
         <cfoutput>Traffic count type: &nbsp;</cfoutput>
         <cfswitch expression = #COUNT_TYPE#>
            <cfcase value = "B">
                <cfoutput>Bicycle</cfoutput>
            </cfcase>
            <cfcase value ="P">
                	<cfoutput>Pedestrian</cfoutput>
            </cfcase>
            <cfcase value = "J">
                	<cfoutput>Jogger</cfoutput>
            </cfcase>
            <cfcase value = "S">
                	<cfoutput>Skater, Rollerblader</cfoutput>
            </cfcase>
            <cfcase value = "C">
                	<cfoutput>Baby Carriage</cfoutput>
            </cfcase> 
            <cfcase value = "W">
                	<cfoutput>Wheelchair</cfoutput>
            </cfcase>
            <cfcase value = "O">
                	<cfoutput>Other</cfoutput>
            </cfcase>                         
            <cfdefaultcase>
                	<cfoutput></cfoutput>
            </cfdefaultcase>
         </cfswitch> 
         <cfoutput></th> </tr></cfoutput>        
         
         <!--- Physical row #2: 6:00 AM to 11:45 AM --->
       
         <!--- Yes, we know there is no data collected at 6:00 or 6:15 AM.
               We're just trying to get the columns to line up nicely. Ugh. --->         
         <cfoutput> <tr class="avoid_pagebreak_after"> </cfoutput>
         
         <cfoutput> <th rowspan=2 align="center" class="row_header"> <b>AM</b> </th></cfoutput>
           
         <cfoutput> <th align="right" class="time_header"> &nbsp;6:00 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;6:15 </th></cfoutput>         
         <cfoutput> <th align="right" class="time_header"> &nbsp;6:30 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;6:45 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;7:00 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;7:15 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;7:30 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;7:45 </th></cfoutput>           
         <cfoutput> <th align="right" class="time_header"> &nbsp;8:00 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;8:15 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;8:30 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;8:45 </th></cfoutput>            
         <cfoutput> <th align="right" class="time_header"> &nbsp;9:00 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;9:15 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;9:30 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;9:45 </th></cfoutput>  
         <cfoutput> <th align="right" class="time_header"> 10:00 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> 10:15 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> 10:30 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> 10:45 </th></cfoutput>                                       
         <cfoutput> <th align="right" class="time_header"> 11:00 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> 11:15 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> 11:30 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header_end_of_row"> 11:45 </th></cfoutput>        
         <cfoutput> </tr> </cfoutput>
         <cfoutput> <tr> </cfoutput>  
         <cfoutput> <td align="right" class="data_cell"> &nbsp; </th></cfoutput>
         <cfoutput> <td align="right" class="data_cell"> &nbsp; </th></cfoutput> 
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_0630# GREATER THAN OR EQUAL TO 0> #CNT_0630# <cfelse> &nbsp; </cfif> </td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_0645# GREATER THAN OR EQUAL TO 0> #CNT_0645# <cfelse> &nbsp; </cfif> </td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_0700# GREATER THAN OR EQUAL TO 0> #CNT_0700# <cfelse> &nbsp; </cfif> </td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_0715# GREATER THAN OR EQUAL TO 0> #CNT_0715# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_0730# GREATER THAN OR EQUAL TO 0> #CNT_0730# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_0745# GREATER THAN OR EQUAL TO 0> #CNT_0745# <cfelse> &nbsp; </cfif></td> </cfoutput>         
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_0800# GREATER THAN OR EQUAL TO 0> #CNT_0800# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_0815# GREATER THAN OR EQUAL TO 0> #CNT_0815# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_0830# GREATER THAN OR EQUAL TO 0> #CNT_0830# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_0845# GREATER THAN OR EQUAL TO 0> #CNT_0845# <cfelse> &nbsp; </cfif></td> </cfoutput>                  
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_0900# GREATER THAN OR EQUAL TO 0> #CNT_0900# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_0915# GREATER THAN OR EQUAL TO 0> #CNT_0915# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_0930# GREATER THAN OR EQUAL TO 0> #CNT_0930# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_0945# GREATER THAN OR EQUAL TO 0> #CNT_0945# <cfelse> &nbsp; </cfif></td> </cfoutput>                  
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1000# GREATER THAN OR EQUAL TO 0> #CNT_1000# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1015# GREATER THAN OR EQUAL TO 0> #CNT_1015# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1030# GREATER THAN OR EQUAL TO 0> #CNT_1030# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1045# GREATER THAN OR EQUAL TO 0> #CNT_1045# <cfelse> &nbsp; </cfif></td> </cfoutput>                   
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1100# GREATER THAN OR EQUAL TO 0> #CNT_1100# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1115# GREATER THAN OR EQUAL TO 0> #CNT_1115# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1130# GREATER THAN OR EQUAL TO 0> #CNT_1130# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell_end_of_row"> <cfif #CNT_1145# GREATER THAN OR EQUAL TO 0> #CNT_1145# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> </tr> </cfoutput> 
          
         <!--- Physical row #3: 12:00 PM to 5:45 PM --->   

         <cfoutput> <tr> </cfoutput>
         <cfoutput> <th rowspan=4 align="center" class="row_header"> <b>PM</b></th></cfoutput>
         
         <cfoutput> <th align="right" class="time_header"> 12:00 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> 12:15 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> 12:30 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> 12:45 </th></cfoutput>                        
         <cfoutput> <th align="right" class="time_header"> &nbsp;1:00 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;1:15 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;1:30 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;1:45 </th></cfoutput>  
         <cfoutput> <th align="right" class="time_header"> &nbsp;2:00 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;2:15 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;2:30 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;2:45 </th></cfoutput>                                     
         <cfoutput> <th align="right" class="time_header"> &nbsp;3:00 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;3:15 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;3:30 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;3:45 </th></cfoutput>                
         <cfoutput> <th align="right" class="time_header"> &nbsp;4:00 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;4:15 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;4:30 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;4:45 </th></cfoutput> 
         <cfoutput> <th align="right" class="time_header"> &nbsp;5:00 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;5:15 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;5:30 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header_end_of_row"> &nbsp;5:45 </th></cfoutput>                               
         <cfoutput> </tr> </cfoutput>
         <cfoutput> <tr> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1200# GREATER THAN OR EQUAL TO 0> #CNT_1200# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1215# GREATER THAN OR EQUAL TO 0> #CNT_1215# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1230# GREATER THAN OR EQUAL TO 0> #CNT_1230# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1245# GREATER THAN OR EQUAL TO 0> #CNT_1245# <cfelse> &nbsp; </cfif></td> </cfoutput>                  
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1300# GREATER THAN OR EQUAL TO 0> #CNT_1300# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1315# GREATER THAN OR EQUAL TO 0> #CNT_1315# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1330# GREATER THAN OR EQUAL TO 0> #CNT_1330# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1345# GREATER THAN OR EQUAL TO 0> #CNT_1345# <cfelse> &nbsp; </cfif></td> </cfoutput>                  
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1400# GREATER THAN OR EQUAL TO 0> #CNT_1400# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1415# GREATER THAN OR EQUAL TO 0> #CNT_1415# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1430# GREATER THAN OR EQUAL TO 0> #CNT_1430# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1445# GREATER THAN OR EQUAL TO 0> #CNT_1445# <cfelse> &nbsp; </cfif></td> </cfoutput>           
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1500# GREATER THAN OR EQUAL TO 0> #CNT_1500# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1515# GREATER THAN OR EQUAL TO 0> #CNT_1515# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1530# GREATER THAN OR EQUAL TO 0> #CNT_1530# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1545# GREATER THAN OR EQUAL TO 0> #CNT_1545# <cfelse> &nbsp; </cfif></td> </cfoutput>         
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1600# GREATER THAN OR EQUAL TO 0> #CNT_1600# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1615# GREATER THAN OR EQUAL TO 0> #CNT_1615# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1630# GREATER THAN OR EQUAL TO 0> #CNT_1630# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1645# GREATER THAN OR EQUAL TO 0> #CNT_1645# <cfelse> &nbsp; </cfif></td> </cfoutput>  
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1700# GREATER THAN OR EQUAL TO 0> #CNT_1700# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1715# GREATER THAN OR EQUAL TO 0> #CNT_1715# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1730# GREATER THAN OR EQUAL TO 0> #CNT_1730# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell_end_of_row"> <cfif #CNT_1745# GREATER THAN OR EQUAL TO 0> #CNT_1745# <cfelse> &nbsp; </cfif></td> </cfoutput>                   
         <cfoutput> </tr> </cfoutput>               
            
         <!--- Physical row #4: 6:00 PM to 8:45 PM --->    
      
         <cfoutput> <tr> </cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;6:00 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;6:15 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;6:30 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;6:45 </th></cfoutput>                    
         <cfoutput> <th align="right" class="time_header"> &nbsp;7:00 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;7:15 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;7:30 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;7:45 </th></cfoutput>                       
         <cfoutput> <th align="right" class="time_header"> &nbsp;8:00 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;8:15 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;8:30 </th></cfoutput>
         <cfoutput> <th align="right" class="time_header"> &nbsp;8:45 </th></cfoutput>  
         <cfoutput> <th align="right" class="time_header_empty">&nbsp;  </th></cfoutput> <!--- 11 columns of padding. or row description, if there is one --->
		 <cfif #ROW_DESCRIPTION# IS "">
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput>
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput>
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput>
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput>
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput>
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput>
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput>
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput>
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput>
         <cfelse>
         <cfoutput> <td align="center" class="row_description" colspan="9" rowspan="2"><strong>Note:</strong> #HTMLEditFormat(ROW_DESCRIPTION)# </td></cfoutput>
         </cfif>
         <cfoutput> <th align="right" class="time_header_empty">&nbsp;  </th></cfoutput> <!--- End padding. --->
         <cfoutput> <th align="center" class="time_header_end_of_row"> <b>Total</b> </th></cfoutput>                        
         <cfoutput> </tr> </cfoutput>
         <cfoutput> <tr> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1800# GREATER THAN OR EQUAL TO 0> #CNT_1800# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1815# GREATER THAN OR EQUAL TO 0> #CNT_1815# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1830# GREATER THAN OR EQUAL TO 0> #CNT_1830# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1845# GREATER THAN OR EQUAL TO 0> #CNT_1845# <cfelse> &nbsp; </cfif></td> </cfoutput>           
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1900# GREATER THAN OR EQUAL TO 0> #CNT_1900# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1915# GREATER THAN OR EQUAL TO 0> #CNT_1915# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1930# GREATER THAN OR EQUAL TO 0> #CNT_1930# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_1945# GREATER THAN OR EQUAL TO 0> #CNT_1945# <cfelse> &nbsp; </cfif></td> </cfoutput>         
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_2000# GREATER THAN OR EQUAL TO 0> #CNT_2000# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_2015# GREATER THAN OR EQUAL TO 0> #CNT_2015# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_2030# GREATER THAN OR EQUAL TO 0> #CNT_2030# <cfelse> &nbsp; </cfif></td> </cfoutput>
         <cfoutput> <td align="right" class="data_cell"> <cfif #CNT_2045# GREATER THAN OR EQUAL TO 0> #CNT_2045# <cfelse> &nbsp; </cfif></td> </cfoutput>          
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput> <!--- 11 columns of padding, or row description, if there is one --->
		 <cfif #ROW_DESCRIPTION# IS "">
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput>
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput>
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput>
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput>
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput>
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput>
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput>
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput>
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput>
         </cfif>
         <cfoutput> <td align="right" class="data_cell_empty">&nbsp;  </td></cfoutput> <!--- End padding. --->
         <cfoutput> <td align="right" class="data_cell_end_of_row">#CNT_TOTAL# </td> </cfoutput>                         
         <cfoutput> </tr> </cfoutput>
         
         <cfoutput> </table> </cfoutput>
         <cfoutput> <br  /> </cfoutput>
	</cfloop>
    <cfif generated_output IS true>
        <!--- Output the post-amble for the last count ID. --->
         <cfoutput> <b>Count ID:&nbsp;#saved_count_id#&nbsp;Location ID:&nbsp;#saved_loc_id#</b><br /> </cfoutput>
         <cfoutput> <b>Latitude:&nbsp;#saved_latitude#&nbsp;N&nbsp;Longitude:&nbsp;#abs(saved_longitude)#&nbsp;W</b><br /> </cfoutput>
         <cfoutput> <hr /> <br  /> </cfoutput>
    </cfif> 
    <cfoutput><h4>Report generated on #DateFormat(Now())# at #TimeFormat(Now())#</h4></cfoutput>
</body>
</html>

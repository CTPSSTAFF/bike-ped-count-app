<cfsetting enableCFoutputOnly="yes">
<cfcontent type="text/xml;charset=UTF-8">
<!---<cfcontent type="application/xhtml+xml;charset=UTF-8">--->
<cfheader name="Cache-Control" value="no-cache">
<cfheader name="Expires" value="Thu, 01 Dec 1994 16:00:00 GMT">
<cfoutput><!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
	<title>Bicyle / Pedestrian query results</title>
	</cfoutput>
	<!--- On initial execution of page, there is no form data yet. Initialize the form variables for 
	      an unrestricted, all-records query. --->
	<cfoutput><meta charset="UTF-8" /><meta HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE" />
	</cfoutput>
	<cfif NOT IsDefined("FORM.date")>
		<cfset FORM.municipality = "999">
		<cfset FORM.facility_name = "999">
	        <cfset FORM.date = "01-JAN-1900">
		<cfset FORM.minX = -180>
		<cfset FORM.maxX = 0>
		<cfset FORM.minY = 0>
		<cfset FORM.maxY = 90>
		<cfset FORM.retrieveAllMarkersInExtent = 0>
		<cfset FORM.updateExtent = 1>
	</cfif>
	
	<!--- Set up numCriteria and multipleCriteria variables to help in initializing the query criteria
	      drop-down lists appropriately with the "All" and "All meeting other criteria" choices --->
	<cfset numCriteria = 0>
	<cfif NOT ("+999+998+" CONTAINS FORM.municipality)><cfset numCriteria = numCriteria + 1></cfif>
	<cfif NOT ("+999+998+" CONTAINS FORM.facility_name)><cfset numCriteria = numCriteria + 1></cfif>   
	<cfif NOT ("+01-JAN-1900+02-JAN-1900" CONTAINS FORM.date)><cfset numCriteria = numCriteria + 1></cfif> 	
	<cfif numCriteria GREATER THAN 1><cfset multipleCriteria = TRUE><cfelse><cfset multipleCriteria = FALSE></cfif>
	<cfset otherCriteriaPhrase = "All">
    
    <!--- The NEW principal query, "uberQuery", which includes the factor of "date" in addition to
	      the other factors (either "tabular" or "spatial") that ultimately have to do with location.
		  The "uberQuery" joins the BP_COUNTS table to the BP_COUNT_LOCATIONS table.
		  This query returns the "result set" for tabular purposes.
	--->
    <cfquery name="uberQuery" datasource="cert_act" cachedwithin="#CreateTimeSpan(0,1,0,0)#">
        SELECT  Bpcl.LOC_ID, Bpc.MUNICIPALITY, 
				SUBSTRING(MUNICIPALITY FROM POSITION('/' IN MUNICIPALITY) + 1 FOR CHAR_LENGTH(MUNICIPALITY) - POSITION('/' IN MUNICIPALITY)) AS MUNI_1,
					<!--- SUBSTRING(MUNICIPALITY FROM 1 FOR POSITION('/' IN MUNICIPALITY) - 1) AS MUNI_2, --->
				CASE WHEN POSITION('/' IN MUNICIPALITY) = 0 THEN '' ELSE SUBSTRING(MUNICIPALITY FROM 1 FOR POSITION('/' IN MUNICIPALITY) - 1) END AS MUNI_2,
                Bpc.FACILITY_NAME,   
				SUBSTRING(FACILITY_NAME FROM POSITION('/' IN FACILITY_NAME) + 1 FOR CHAR_LENGTH(FACILITY_NAME) - POSITION('/' IN FACILITY_NAME)) AS FAC_NAME_1,
					<!--- SUBSTRING(FACILITY_NAME FROM 1 FOR POSITION('/' IN FACILITY_NAME) - 1) AS FAC_NAME_2, --->
				CASE WHEN POSITION('/' IN FACILITY_NAME) = 0 THEN '' ELSE SUBSTRING(FACILITY_NAME FROM 1 FOR POSITION('/' IN FACILITY_NAME) - 1) END AS FAC_NAME_2,
				Bpcl.DESCRIPTION, Bpcl.LATITUDE, Bpcl.LONGITUDE, Bpc.COUNT_DATE AS RAW_COUNT_DATE, 
                TO_CHAR(Bpc.COUNT_DATE, 'DD-MON-YYYY') AS COUNT_DATE, TO_CHAR(Bpc.COUNT_DATE, 'YYYY') AS COUNT_YEAR

				
        FROM   BP_COUNT_LOCATIONS Bpcl, BP_COUNTS Bpc
        WHERE  Bpcl.LOC_ID = Bpc.BP_LOC_ID 
               <cfif NOT ("+999+998+" CONTAINS FORM.municipality)>
			   	   AND ( SUBSTRING(MUNICIPALITY FROM POSITION('/' IN MUNICIPALITY) + 1 FOR CHAR_LENGTH(MUNICIPALITY) - POSITION('/' IN MUNICIPALITY))  = '#Form.municipality#' OR 
				   		 <!--- SUBSTRING(MUNICIPALITY FROM 1 FOR POSITION('/' IN MUNICIPALITY) - 1) --->
						 (CASE WHEN POSITION('/' IN MUNICIPALITY) = 0 THEN '' ELSE SUBSTRING(MUNICIPALITY FROM 1 FOR POSITION('/' IN MUNICIPALITY) - 1) END) = '#Form.municipality#' )
                   <!---AND Bpc.Municipality LIKE '%#Form.municipality#%'---><!--- This was pulling in "New Bedford" when "Bedford" was selected--->
               </cfif>
               <cfif NOT ("+999+998+" CONTAINS FORM.facility_name)>
                   AND Bpc.Facility_Name LIKE '%#Form.facility_name#%'
               </cfif>
               <cfif NOT ("+01-JAN-1900+02-JAN-1900+" CONTAINS FORM.date)>
                   AND TO_CHAR(Bpc.COUNT_DATE, 'YYYY') = '#Form.date#'
               </cfif>              
        GROUP BY Bpcl.LOC_ID, Bpc.MUNICIPALITY, 
                 SUBSTRING(MUNICIPALITY FROM POSITION('/' IN MUNICIPALITY) + 1 FOR CHAR_LENGTH(MUNICIPALITY) - POSITION('/' IN MUNICIPALITY)),
					<!--- SUBSTRING(MUNICIPALITY FROM 1 FOR POSITION('/' IN MUNICIPALITY) - 1), --->
				 CASE WHEN POSITION('/' IN MUNICIPALITY) = 0 THEN '' ELSE SUBSTRING(MUNICIPALITY FROM 1 FOR POSITION('/' IN MUNICIPALITY) - 1) END,	
                 Bpc.FACILITY_NAME, 
                 SUBSTRING(FACILITY_NAME FROM POSITION('/' IN FACILITY_NAME) + 1 FOR CHAR_LENGTH(FACILITY_NAME) - POSITION('/' IN FACILITY_NAME)),
					<!--- SUBSTRING(FACILITY_NAME FROM 1 FOR POSITION('/' IN FACILITY_NAME) - 1), --->
				CASE WHEN POSITION('/' IN FACILITY_NAME) = 0 THEN '' ELSE SUBSTRING(FACILITY_NAME FROM 1 FOR POSITION('/' IN FACILITY_NAME) - 1) END,
                 Bpcl.DESCRIPTION, BPcl.LATITUDE, Bpcl.LONGITUDE, Bpc.COUNT_DATE,  
                 TO_CHAR(Bpc.COUNT_DATE, 'YYYY')
	ORDER BY Bpc.MUNICIPALITY, Bpc.FACILITY_NAME
    </cfquery>
    
    <!--- This is the new version of "meetNonSpatialCriteria" query.
	      We try this as a sub-query of the uberQuery that does a "SELECT DISTINCT" on the 
		  tabular attributes that pertain to location (i.e., everything except date).
	--->
    <cfquery name="meetNonSpatialCriteria" dbtype="query">
    SELECT DISTINCT LOC_ID, MUNICIPALITY, FACILITY_NAME, DESCRIPTION, LATITUDE, LONGITUDE FROM uberQuery
    </cfquery>
    
	<!--- The "othersMeetSpatialCriteria" query returns the set of unique BP_LOC's meeting the spatial criteria (i.e., falling within Google Map display)
		  that do NOT meet the non-spatial (tablular) criteria. It is used to add non-result set markers to the Google Map display. --->

	<cfquery name="othersMeetSpatialCriteria" datasource="cert_act">
		<cfif FORM.retrieveAllMarkersInExtent IS NOT 0>
        SELECT  Bpcl.LOC_ID, Bpc.MUNICIPALITY, Bpc.FACILITY_NAME, Bpcl.DESCRIPTION, Bpcl.LATITUDE, Bpcl.LONGITUDE
        FROM    BP_COUNT_LOCATIONS Bpcl, BP_COUNTS Bpc
        WHERE   Bpcl.LOC_ID = Bpc.BP_LOC_ID AND
                CAST ( (CASE WHEN Latitude IS NULL THEN 0 ELSE Latitude END) AS numeric ) BETWEEN #FORM.minY# AND #FORM.maxY# AND
			    CAST ( (CASE WHEN Longitude IS NULL THEN 0 ELSE Longitude END) AS numeric ) BETWEEN #FORM.minX# AND #FORM.maxX# AND (
                   1 < 0
               <cfif NOT ("+999+998+" CONTAINS FORM.municipality)>
                   OR NOT ( SUBSTRING(MUNICIPALITY FROM POSITION('/' IN MUNICIPALITY) + 1 FOR CHAR_LENGTH(MUNICIPALITY) - POSITION('/' IN MUNICIPALITY)) = '#Form.municipality#' OR 
								<!--- ??? change: substring(.....) is null TO substring(.....) = ' ' --->
				   		    (CASE WHEN POSITION('/' IN MUNICIPALITY) = 0 THEN 'Blank' ELSE SUBSTRING(MUNICIPALITY FROM 1 FOR POSITION('/' IN MUNICIPALITY) - 1) END) = '#Form.municipality#' )
               </cfif>
               <cfif NOT ("+999+998+" CONTAINS FORM.facility_name)>
                   OR  NOT ( (CASE WHEN Bpc.Facility_Name IS NULL THEN 'NOT SPECIFIED' ELSE Bpc.Facility_Name END) LIKE '%#Form.facility_name#%')
               </cfif>
               <cfif NOT ("+01-JAN-1900+02-JAN-1900+" CONTAINS FORM.date)>
                   OR TO_CHAR(Bpc.COUNT_DATE, 'YYYY') <> '#Form.date#'
               </cfif>
               )  
        GROUP BY Bpcl.LOC_ID, Bpc.MUNICIPALITY, Bpc.FACILITY_NAME, Bpcl.DESCRIPTION, BPcl.LATITUDE, Bpcl.LONGITUDE
        ORDER BY Bpcl.LOC_ID
		<cfelse>
		<!--- If display is zoomed out too, far, use a query that returns no rows --->
			SELECT  Bpcl.LOC_ID, Bpc.MUNICIPALITY, Bpc.FACILITY_NAME, Bpcl.DESCRIPTION, Bpcl.LATITUDE, Bpcl.LONGITUDE
			FROM    BP_COUNT_LOCATIONS Bpcl, BP_COUNTS Bpc
			WHERE	Bpcl.LOC_ID < 0
		</cfif>
	</cfquery>
          
	<cfquery name="baseOfSubqueries" datasource="cert_act">
        SELECT  Bpcl.LOC_ID, Bpc.MUNICIPALITY, 
                SUBSTRING(MUNICIPALITY FROM POSITION('/' IN MUNICIPALITY) + 1 FOR CHAR_LENGTH(MUNICIPALITY) - POSITION('/' IN MUNICIPALITY)) AS MUNI_1,
					<!--- SUBSTRING(MUNICIPALITY FROM 1 FOR POSITION('/' IN MUNICIPALITY) - 1) AS MUNI_2, --->
				CASE WHEN POSITION('/' IN MUNICIPALITY) = 0 THEN '' ELSE SUBSTRING(MUNICIPALITY FROM 1 FOR POSITION('/' IN MUNICIPALITY) - 1) END AS MUNI_2,
                Bpc.FACILITY_NAME,   
                SUBSTRING(FACILITY_NAME FROM POSITION('/' IN FACILITY_NAME) + 1 FOR CHAR_LENGTH(FACILITY_NAME) - POSITION('/' IN FACILITY_NAME)) AS FAC_NAME_1,
					<!--- SUBSTRING(FACILITY_NAME FROM 1 FOR POSITION('/' IN FACILITY_NAME) - 1) AS FAC_NAME_2,  --->
				CASE WHEN POSITION('/' IN FACILITY_NAME) = 0 THEN '' ELSE SUBSTRING(FACILITY_NAME FROM 1 FOR POSITION('/' IN FACILITY_NAME) - 1) END AS FAC_NAME_2,
                Bpcl.DESCRIPTION, Bpcl.LATITUDE, Bpcl.LONGITUDE, Bpc.COUNT_DATE AS RAW_COUNT_DATE, 
                TO_CHAR(Bpc.COUNT_DATE, 'DD-MON-YYYY') AS COUNT_DATE, TO_CHAR(Bpc.COUNT_DATE, 'YYYY') AS COUNT_YEAR
        FROM   BP_COUNT_LOCATIONS Bpcl, BP_COUNTS Bpc
        WHERE  Bpcl.LOC_ID = Bpc.BP_LOC_ID 
	</cfquery>
              
    <!--- Queries of baseOfSubqueries query, to return unique, sorted values from various fields of the
	      main query (mostly) for populating the query criteria drop-down lists. --->
	
	<!--- The "meetAllCriteria" query returns the subset of the result set (i.e., the meetNonSpatialCriteria query),
	      that lies within the bounds of the Google Map display. --->
	<cfquery name="meetAllCriteria" dbtype="query">
		<!--- Only return rows for the query if some criteria have been specified (never return all rows) --->
		<cfif numCriteria GREATER THAN 0 OR FORM.retrieveAllMarkersInExtent IS NOT 0>
			SELECT  LOC_ID, MUNICIPALITY, FACILITY_NAME, DESCRIPTION, LATITUDE, LONGITUDE
			FROM    meetNonSpatialCriteria
			WHERE   Latitude >= #FORM.minY# AND Latitude <= #FORM.maxY# AND
					Longitude >= ( 0 - #Abs(FORM.minX)# ) AND Longitude <= ( 0 - #Abs(FORM.maxX)# )
			GROUP BY LOC_ID, MUNICIPALITY, FACILITY_NAME, DESCRIPTION, LATITUDE, LONGITUDE 
            ORDER BY LOC_ID
		<cfelse>
			SELECT  LOC_ID, MUNICIPALITY, FACILITY_NAME, DESCRIPTION, LATITUDE, LONGITUDE
			FROM    meetNonSpatialCriteria
			WHERE	LOC_ID < 0
		</cfif>
	</cfquery>

    <cfquery name="preTownList" dbtype="query">
    SELECT MUNI_1 AS MUNICIPALITY  FROM baseOfSubqueries 
           UNION SELECT MUNI_2 AS MUNICIPALITY FROM uberQuery WHERE MUNI_2 IS NOT NULL
           ORDER BY MUNICIPALITY
    </cfquery>
    <!---<cfquery name="townList" datasource="cert_act">--->
    <cfquery name="townList" dbtype="query">
    SELECT DISTINCT MUNICIPALITY  FROM preTownList 
    </cfquery>
    <cfquery name="preFacilityList" dbtype="query">
    SELECT FAC_NAME_1 AS FACILITY_NAME FROM baseOfSubqueries WHERE FAC_NAME_1 IS NOT NULL
           UNION SELECT FAC_NAME_2 AS FACILITY_NAME FROM uberQuery WHERE FAC_NAME_2 IS NOT NULL
           ORDER BY FACILITY_NAME
    </cfquery>
    <cfquery name="facilityList" dbtype="query">
    SELECT DISTINCT FACILITY_NAME FROM preFacilityList 
    </cfquery>
    
	<cfquery name="dateList" dbtype="query">
		<!---SELECT DISTINCT RAW_COUNT_DATE, COUNT_DATE FROM baseOfSubqueries ORDER BY RAW_COUNT_DATE--->
        SELECT DISTINCT COUNT_YEAR FROM baseOfSubqueries ORDER BY COUNT_YEAR
	</cfquery>
    <cfquery name="resultExtents" dbtype="query">
        SELECT min(Longitude) AS minX, max(Longitude) AS maxX, min(Latitude) AS minY, max(Latitude) AS maxY FROM uberQuery
    </cfquery>

	<cfoutput><link rel="stylesheet" type="text/css" href="bike_ped.css" />
</head>

<body>

<table id="appVariables"></cfoutput><cfoutput query="resultExtents">
	<tr><td id="minX" class="float">#minX#</td></tr>
	<tr><td id="maxX" class="float">#maxX#</td></tr>
	<tr><td id="minY" class="float">#minY#</td></tr>
	<tr><td id="maxY" class="float">#maxY#</td></tr></cfoutput><cfoutput>
    <tr><td id="numExtentResults" class="int">#resultExtents.RecordCount#</td></tr>
	<tr><td id="numResults" class="int">#meetNonSpatialCriteria.RecordCount#</td></tr>
	<tr><td id="otherSpatialResults" class="int">#othersMeetSpatialCriteria.RecordCount#</td></tr>
	<tr><td id="numResultsUberQuery" class="int">#uberQuery.RecordCount#</td></tr>
	<tr><td id="numCriteriaSpecified" class="int">#numCriteria#</td></tr>
	<tr><td id="updateExtent" class="int">#FORM.updateExtent#</td></tr>
</table>
<table id="meetAllCriteria"></cfoutput><cfoutput query="meetAllCriteria">
	<tr><td>#LOC_ID#</td><td>#MUNICIPALITY#</td><td>#Facility_Name#</td><td>#XmlFormat(DESCRIPTION)#</td><td>#Latitude#</td><td>#Longitude#</td></tr></cfoutput><cfoutput>
</table>
<table id="othersMeetSpatialCriteria"></cfoutput><cfoutput query="othersMeetSpatialCriteria">
	<tr><td>#LOC_ID#</td><td>#MUNICIPALITY#</td><td>#Facility_Name#</td><td>#XmlFormat(DESCRIPTION)#</td><td>#Latitude#</td><td>#Longitude#</td></tr></cfoutput><cfoutput>
</table>

<div id="tabularQueryDiv">
	<form name="tabularQuery" id="tabularQuery">
		<table id="tabularQueryTbl">
			<tr>
				<td class="tabularQueryTableCell"><b>Search by:</b></td>
				<td style="text-align:right">
					<input type="button" id="reset" value="New search" onClick="CTPS.bikePedApp.doQuery(999,true)" />
				</td>
			</tr>
		</table>
		<div class="queryListGroup" style="width:100%">
			<label for="facility_name">Facility:</label>
			<select name="facility_name" id="facility_name" size="1" style="width:100%" ></cfoutput>
				<cfif multipleCriteria
					OR numCriteria GREATER THAN 0 AND "+999+998+" CONTAINS FORM.facility_name><cfoutput>
				<option value="998"<cfif "+999+998+" CONTAINS FORM.facility_name> selected="selected"</cfif></cfoutput>
						<cfoutput>>#otherCriteriaPhrase#</option></cfoutput>
				<cfelse><cfoutput>
				<option value="999"<cfif "+999+998+" CONTAINS FORM.facility_name> selected="selected"</cfif></cfoutput>
						<cfoutput>>All</option></cfoutput>
				</cfif>
				<cfoutput query="facilityList">
				<option value="#Facility_Name#"<cfif IsDefined("FORM.facility_name")><cfif FORM.facility_name 
					IS #Facility_Name#> selected="selected"</cfif></cfif>>#Facility_Name#</option></cfoutput><cfoutput>
	      		</select>
		</div>
		<div class="queryListGroup">
			<label for="municipality">Municipality:</label>
			<select name="municipality" id="municipality" size="1" style="width:100%" ></cfoutput>
				<cfif multipleCriteria
					OR numCriteria GREATER THAN 0 AND "+999+998+" CONTAINS FORM.municipality><cfoutput>
				<option value="998"<cfif "+999+998+" CONTAINS FORM.municipality> selected="selected"</cfif></cfoutput>
						<cfoutput>>#otherCriteriaPhrase#</option></cfoutput>
				<cfelse><cfoutput>
				<option value="999"<cfif "+999+998+" CONTAINS FORM.municipality> selected="selected"</cfif></cfoutput>
						<cfoutput>>All</option></cfoutput>
				</cfif>
				<cfoutput query="townList">
				<option value="#Municipality#"<cfif IsDefined("FORM.municipality")><cfif FORM.municipality 
					IS #Municipality#> selected="selected"</cfif></cfif>>#Municipality#</option></cfoutput><cfoutput>
			</select>
		</div>
		<div class="queryListGroup">
			<label for="date">Year:</label>
			<select name="date" id="date" size="1" style="width:100%" ></cfoutput>
				<cfif multipleCriteria
					OR numCriteria GREATER THAN 0 AND "+01-JAN-1900+02-JAN-1900+" CONTAINS FORM.date><cfoutput>
				<option value="02-JAN-1900"<cfif "+01-JAN-1900+02-JAN-1900+" CONTAINS FORM.date> selected="selected"</cfif></cfoutput>
						<cfoutput>>#otherCriteriaPhrase#</option></cfoutput>
				<cfelse><cfoutput>
				<option value="01-JAN-1900"<cfif "+01-JAN-1900+02-JAN-1900+" CONTAINS FORM.date> selected="selected"</cfif></cfoutput>
						<cfoutput>>All</option></cfoutput>
				</cfif>
				<cfoutput query="dateList">
				<option value="#COUNT_YEAR#"<cfif IsDefined("FORM.date")><cfif FORM.date 
					IS #COUNT_YEAR#> selected="selected"</cfif></cfif>>#Count_Year#</option></cfoutput><cfoutput>
			</select>
		</div>
	</form>
</div></cfoutput>

<!--- Hidden table of result set to be copied to visible area of parent page --->
<cfoutput>
<div id="results"></cfoutput><cfif numCriteria IS NOT 0><cfoutput>
	<b>Count locations meeting criteria: #meetNonSpatialCriteria.RecordCount#</b><br />
	<table class="resultTable">
		<tr>
			<th class="resultTableLocCell">Location Description</th>
			<th class="resultTableTownCell">Town</th>
		</tr></cfoutput><cfoutput query="meetNonSpatialCriteria">
		<tr><td class="resultTableLocCell"><a id="list#LOC_ID#" href="javascript:CTPS.bikePedApp.openCountLocDetail(#LOC_ID#);" onMouseOver="CTPS.bikePedApp.markerHilite" onMouseOut="CTPS.bikePedApp.markerUnHilite">#XmlFormat(DESCRIPTION)#</a></td><td class="resultTableTownCell"><b>#MUNICIPALITY#</b></td></tr></cfoutput><cfoutput>
	</table></cfoutput></cfif><cfoutput>
</div>
</body>
</html>
</cfoutput>

CTPS = {};
CTPS.bikePedApp = {};

CTPS.bikePedApp.queryPageDebug = 0;  // Set to 1 to enable debug messages on this page.
CTPS.bikePedApp.cLegendTxtHilite = "Count locations matching search criteria";
CTPS.bikePedApp.cLegendTxtRegular = "Other count locations";

// All the arrays below have a primary index based on bike-ped count location's LOC_ID value
CTPS.bikePedApp.arrDispResultSet = [];    // 2-D array to hold count location information for records in result set and display bounds
CTPS.bikePedApp.arrDispNotResultSet = []; // 2-D array to hold count location infomation for records NOT in result set but in display bounds

// Index constants for easy access to 2nd dimension of array data.
// The elements of the 2nd dimension of the array are:
CTPS.bikePedApp.cIDIdx = 0; //ID (i.e., count location ID)
CTPS.bikePedApp.cMunIdx = 1; //Municipality
CTPS.bikePedApp.cFacIdx = 2; //Facility
CTPS.bikePedApp.cDescIdx = 3; //Description
CTPS.bikePedApp.cLatIdx = 4; //Latitude
CTPS.bikePedApp.cLngIdx = 5; //Longitude

CTPS.bikePedApp.arrMarkersResultSet = [];    // array to hold Google Map markers for count locations in result set and display bounds
CTPS.bikePedApp.arrMarkersNotResultSet = []; // array to hold markers for count location not in result set but in display bounds
CTPS.bikePedApp.arrMapped = [];	             // array of Booleans indicating which Google Map overlay markers have been added to map
CTPS.bikePedApp.arrToMap = [];	             // array of Booleans indicating which Google Map overlay markers should be added to map next
CTPS.bikePedApp.arrResultSet = [];	         // array of Booleans indicating count locations that are part of current result set
CTPS.bikePedApp.numCriteriaSpecified = 0;	 // details how many criteria drop-down lists have a specific option selected

// variables characterizing the current result set
CTPS.bikePedApp.minX;
CTPS.bikePedApp.maxX;
CTPS.bikePedApp.minY;
CTPS.bikePedApp.maxY;
CTPS.bikePedApp.newMinX;
CTPS.bikePedApp.newMaxX;
CTPS.bikePedApp.newMinY;
CTPS.bikePedApp.newMaxY;
CTPS.bikePedApp.numResults;
CTPS.bikePedApp.cDisplayLimit = 200;	// to help maintain performance, no more than this number of overlay markers are added to Google Map
CTPS.bikePedApp.cZoomThreshold = 10;	// intersections outside the result set are only shown at this zoom level or higher
CTPS.bikePedApp.cMapAreaMarginFactor = 1.3;	// linear scale factor for area slightly larger than Google Map area (pre-add markers just outside currently visible area)
CTPS.bikePedApp.retrieveAllMarkersInExtent = 0;
CTPS.bikePedApp.cSrcMarkerHilite = "images/marker_link_blue.png"
CTPS.bikePedApp.cSrcMarkerHilitePr = "images/marker_link_blue.gif";
CTPS.bikePedApp.cSrcMarkerRegular = "images/marker_dark_blue.png"
CTPS.bikePedApp.cSrcMarkerRegularPr = "images/marker_dark_blue.gif";
CTPS.bikePedApp.cSrcMarkerHover = "images/marker_link_hover.png";

CTPS.bikePedApp.boolNewResultSetToMap = true;
CTPS.bikePedApp.boolNewExtent = true;


/*******
  LOAD
*******/
// Executes once, when this page has loaded. Initializes the Google Map and sets a few variables
// pointing to HTML nodes in the legend for later use. Then kicks off the first xmlHttpRequest
// for point data from the ColdFusion server.
CTPS.bikePedApp.load = function() {

	var myOptions = {
		center: new google.maps.LatLng(42.1, -71.7),
		zoom: 8,
		mapTypeId: google.maps.MapTypeId.ROADMAP
	};
	CTPS.bikePedApp.map = new google.maps.Map(document.getElementById("map"), myOptions);

	CTPS.bikePedApp.infoWindow = new google.maps.InfoWindow({'maxWidth': 210});	// create the re-usable info window for all the markers
	CTPS.bikePedApp.legendTxtHilite = document.getElementById("legendTxtHiliteMarker");
	CTPS.bikePedApp.legendTxtRegular = document.getElementById("legendTxtRegularMarker");
	// Listen for the 'idle' event and respond by requesting new data via XHR. The idle event fires once
	// after the end of any panning or zooming. The bounds_changed and center_changed events by contrast
	// fire multiple times during dragging and panning, and would generate too much XHR traffic.
	google.maps.event.addListener(CTPS.bikePedApp.map, "idle", CTPS.bikePedApp.mapExtentChangeHandler);

	CTPS.bikePedApp.doQuery(999,false);
}

/**********************
  CREATEXMLHTTPREQUEST
***********************/
CTPS.bikePedApp.createXMLHttpRequest = function() {
	var request = false;

	// Does this browser support the XMLHttpRequest object?
	if (window.XMLHttpRequest) {
		if (typeof XMLHttpRequest != 'undefined') {
			try {
				request = new XMLHttpRequest();
			} catch (e) {
				request = false;
			}
		} else if (window.ActiveXObject) {
			// Try to create a new ActiveX XMLHTTP object
			try {
				request = new ActiveXObject('Microsoft.XMLHTTP');
			} catch (e) {
				request = false;
			}
		}
	}
	return request;
}

/***********************
  PARSEEXMLHTTPRESPONSE
************************/
CTPS.bikePedApp.parseXMLHttpResponse = function() {
	// Is the readyState 4?
	if (CTPS.bikePedApp.xmlHttpRequest.readyState === 4) {
		// Is the status 200?
		if (CTPS.bikePedApp.xmlHttpRequest.status === 200) {
			// Mark the live-update areas of the page busy, so that assistive technology
			// doesn't begin to announce changes until all updates are finished
			document.getElementById('tabularQuery').setAttribute('aria-busy','true');
			document.getElementById('resultsContainer').setAttribute('aria-busy','true');

			// Proceed to process the response XML
			// Start with the updating the select list controls
			selectNodes = CTPS.bikePedApp.xmlHttpRequest.responseXML.getElementsByTagName('select');
			i = 0;
			while (selectNodes.length && i < selectNodes.length) {
				oNodeToUpdate = document.getElementById(selectNodes[i].getAttribute('id'));
				//IE only allows replacement or appending of nodes that have been created using DOM methods
				//so this kludge allows for transfer of responseXML structure via the outerHTML property
				//(also nonstandard with IE)
				if (oNodeToUpdate.outerHTML && selectNodes[i].xml) {
					oNodeToUpdate.outerHTML = selectNodes[i].xml;
					i = i + 1;
				} else {
					oParentNode = oNodeToUpdate.parentNode;
					oParentNode.replaceChild(selectNodes[0],oNodeToUpdate);
				}
			}
			// Proceed to update the list of results
			divNodes = CTPS.bikePedApp.xmlHttpRequest.responseXML.getElementsByTagName('div');
			for (i = divNodes.length - 1; i >= 0; i--) {
				if (divNodes[i].getAttribute('id') === 'results') {
					responseList = divNodes[i];
					break;
				}
			}
			oNodeToUpdate = document.getElementById('results');
			if (oNodeToUpdate.outerHTML && responseList.xml) {
				oNodeToUpdate.outerHTML = responseList.xml;
			} else {
				oParentNode = oNodeToUpdate.parentNode;
				oParentNode.replaceChild(responseList,oNodeToUpdate);
			}
			// Now set mouse event handlers for each link
			arrLinks = document.getElementById('results').getElementsByTagName("a")
			for (i = 0; i < arrLinks.length; i++) {
				arrLinks[i].onmouseover = CTPS.bikePedApp.markerHilite;
				arrLinks[i].onmouseout = CTPS.bikePedApp.markerUnHilite;
			}
			
			// Then process the variables and arrays
			tableNodes = CTPS.bikePedApp.xmlHttpRequest.responseXML.getElementsByTagName('table');
			for (i = 0; i < tableNodes.length; i++) {
				if (tableNodes[i].getAttribute('id') === 'appVariables') {
					rowNodes = tableNodes[i].getElementsByTagName('tr');
					for (rw = 0; rw < rowNodes.length; rw++) {
						switch (rowNodes[rw].firstChild.getAttribute('class')) {
							case 'float':
								CTPS.bikePedApp[rowNodes[rw].firstChild.getAttribute('id')] =
									parseFloat(rowNodes[rw].firstChild.firstChild.nodeValue);
								break;
							case 'int':
								CTPS.bikePedApp[rowNodes[rw].firstChild.getAttribute('id')] =
									parseInt(rowNodes[rw].firstChild.firstChild.nodeValue,10);
								break;
							default:
								CTPS.bikePedApp[rowNodes[rw].firstChild.getAttribute('id')] =
									rowNodes[rw].firstChild.firstChild.nodeValue;
						}
					}
				} else if (tableNodes[i].getAttribute('id') === 'meetAllCriteria') {
					CTPS.bikePedApp.arrDispResultSet = [];
					rowNodes = tableNodes[i].getElementsByTagName('tr');
					for (rw = 0; rw < rowNodes.length; rw++) {
						cellNodes = rowNodes[rw].getElementsByTagName('td');
						if (cellNodes.length === 6) {
							CTPS.bikePedApp.arrDispResultSet.push (
									[(cellNodes[0].firstChild ? parseInt(cellNodes[0].firstChild.nodeValue,10) : 0),
									(cellNodes[1].firstChild ? cellNodes[1].firstChild.nodeValue : ''), 
									(cellNodes[2].firstChild ? cellNodes[2].firstChild.nodeValue : ''),
									(cellNodes[3].firstChild ? cellNodes[3].firstChild.nodeValue : ''),
									(cellNodes[4].firstChild ? parseFloat(cellNodes[4].firstChild.nodeValue) : 0),
									(cellNodes[5].firstChild ? parseFloat(cellNodes[5].firstChild.nodeValue) : 0)]);
						}
					}
				} else if (tableNodes[i].getAttribute('id') === 'othersMeetSpatialCriteria') {
					arrDispNotResultSetRaw = [];
					rowNodes = tableNodes[i].getElementsByTagName('tr');
					for (rw = 0; rw < rowNodes.length; rw++) {
						cellNodes = rowNodes[rw].getElementsByTagName('td');
						if (cellNodes.length === 6) {
							arrDispNotResultSetRaw.push (
									[(cellNodes[0].firstChild ? parseInt(cellNodes[0].firstChild.nodeValue,10) : 0),
									(cellNodes[1].firstChild ? cellNodes[1].firstChild.nodeValue : ''), 
									(cellNodes[2].firstChild ? cellNodes[2].firstChild.nodeValue : ''),
									(cellNodes[3].firstChild ? cellNodes[3].firstChild.nodeValue : ''),
									(cellNodes[4].firstChild ? parseFloat(cellNodes[4].firstChild.nodeValue) : 0),
									(cellNodes[5].firstChild ? parseFloat(cellNodes[5].firstChild.nodeValue) : 0)]);
						}
					}
				}
			}
			lenDispResultSet = CTPS.bikePedApp.arrDispResultSet.length;
			lenDispNotResultSetRaw = arrDispNotResultSetRaw.length;	
//			if (CTPS.bikePedApp.numExtentResults == 0) {
//				CTPS.bikePedApp.boolNewExtent = false;
//			} else {
//				if (CTPS.bikePedApp.newMinX == CTPS.bikePedApp.minX && CTPS.bikePedApp.newMaxX == CTPS.bikePedApp.maxX && 
//					CTPS.bikePedApp.newMinY == CTPS.bikePedApp.minY && CTPS.bikePedApp.newMaxY == CTPS.bikePedApp.maxY) {
//					CTPS.bikePedApp.boolNewExtent = false;
//				} else {
//					CTPS.bikePedApp.boolNewExtent = true;
//				}
//				CTPS.bikePedApp.minX = CTPS.bikePedApp.newMinX;
//				CTPS.bikePedApp.maxX = CTPS.bikePedApp.newMaxX;
//				CTPS.bikePedApp.minY = CTPS.bikePedApp.newMinY;
//				CTPS.bikePedApp.maxY = CTPS.bikePedApp.newMaxY;
//			}

			var i; // Iterates over NON-result set
			var j; // Iterates over result set
			var found = false; // Is element in the (raw) "non-result set" ALSO in "result set"?
			
			CTPS.bikePedApp.arrDispNotResultSet = [];
			for (i = 0; i < lenDispNotResultSetRaw; i++ ) { 
				found = false;
				for (j = 0; j < lenDispResultSet; j++ ) {
					if (arrDispNotResultSetRaw[i][CTPS.bikePedApp.cIDIdx] == 
							CTPS.bikePedApp.arrDispResultSet[j][CTPS.bikePedApp.cIDIdx]) {
						found = true;
						break;
					}
				}
				if (found == false) {
					CTPS.bikePedApp.arrDispNotResultSet.push(arrDispNotResultSetRaw[i]);
				}
			}
			
			// if the query did not specify a geographic extent (was not submitted due
			// to user moving around in map window), then update the extent to fit
			// the result set (which action will cause a new query to be submitted
			// specifying geographic extent and causing execution of other branch of this
			// if statement)
			if (CTPS.bikePedApp.updateExtent === 1) {
				if (!CTPS.bikePedApp.adjustMapToResultSet()) {
					// if there is not a new extent, there's no need to adjust the map to the result set;
					// however a query for results in the current map extent does need to be kicked off
					// (normally handled by the handler for a change in the map extent) so kick it off directly
					CTPS.bikePedApp.mapExtentChangeHandler();
				}
			} else {
			// otherwise, query was submitted for current map window extent, so don't
			// update the map extents--just use response data to update what markers
			// are added to the map display
				CTPS.bikePedApp.manageMarkersForExtent();	// update the markers shown on the map
			}
			// Announce to adaptive technology that the update to the live regions of the page is finished
			document.getElementById('tabularQuery').setAttribute('aria-busy','false');
			document.getElementById('resultsContainer').setAttribute('aria-busy','false');
		} else {
			alert('There was a problem retrieving the data: \n' + 
				CTPS.bikePedApp.xmlHttpRequest.statusText);
		}
		//CTPS.bikePedApp.xmlHttpRequest = null;
	}
}

/************************
  MAPEXTENTCHANGEHANDLER
*************************/
// this event handler executes every time the area shown in the Google Map changes
CTPS.bikePedApp.mapExtentChangeHandler = function() {
	// determine the maximum and minimum latitude and longitude of the Google Map area
	var mapBounds = CTPS.bikePedApp.map.getBounds();
	var mapSW = mapBounds.getSouthWest(), mapNE = mapBounds.getNorthEast();
	var mapLatMin = mapSW.lat(), mapLatMax = mapNE.lat(), mapLngMin = mapSW.lng(), mapLngMax = mapNE.lng();
	// and find out the zoom level
	var zoomLevel = CTPS.bikePedApp.map.getZoom();

	// determine the maximum and minimum latitude and longitude of an area slightly larger than the Google Map area
	var centerLat = (mapLatMax + mapLatMin) / 2, centerLng = (mapLngMax + mapLngMin) / 2;
	var newHalfSpanLat = (mapLatMax - mapLatMin) * CTPS.bikePedApp.cMapAreaMarginFactor / 2;
	var newHalfSpanLng = (mapLngMax - mapLngMin) * CTPS.bikePedApp.cMapAreaMarginFactor / 2;
	var mapLatMarginMin = centerLat - newHalfSpanLat, mapLatMarginMax = centerLat + newHalfSpanLat;
	var mapLngMarginMin = centerLng - newHalfSpanLng, mapLngMarginMax = centerLng + newHalfSpanLng;

	// do a new query for intersections in the map window
	if (zoomLevel >= CTPS.bikePedApp.cZoomThreshold) CTPS.bikePedApp.retrieveAllMarkersInExtent = 1
	else CTPS.bikePedApp.retrieveAllMarkersInExtent = 0;
	// save current extent variables to restore after initiating the query for the expanded extent
	var minXSaved = CTPS.bikePedApp.minX;
	var maxXSaved = CTPS.bikePedApp.maxX;
	var minYSaved = CTPS.bikePedApp.minY;
	var maxYSaved = CTPS.bikePedApp.maxY;
	CTPS.bikePedApp.minX = mapLngMarginMin;
	CTPS.bikePedApp.maxX = mapLngMarginMax;
	CTPS.bikePedApp.minY = mapLatMarginMin;
	CTPS.bikePedApp.maxY = mapLatMarginMax;
	
	CTPS.bikePedApp.doQuery(0,false);
	
	// restore saved extent variables
	CTPS.bikePedApp.minX = minXSaved;
	CTPS.bikePedApp.maxX = maxXSaved;
	CTPS.bikePedApp.minY = minYSaved;
	CTPS.bikePedApp.maxY = maxYSaved;
	
}

/*************************
  MANAGEMARKERSFOREXTENT
*************************/
// This routine manages arrays that keep track of the markers currently added to the map display,
// updating them to reflect the result sets from the query response, and doing the corresponding 
// adding and removing of markers
CTPS.bikePedApp.manageMarkersForExtent = function() {
	
	var i = 0;	// index to arrays of result set intersection info
	var intMarkerIdx	// index to most recently added element of marker array
	var intMarkersDisplayed = 0;	// running count of markers added to display
	var marker;
	
	// first, move the marker display arrays into temporary array variables so the
	// original arrays can be rebuilt
	var arrMarkersResultSetTemp = [];
	var arrMarkersNotResultSetTemp = [];
	
	while (CTPS.bikePedApp.arrMarkersResultSet.length > 0) {
		arrMarkersResultSetTemp.push(CTPS.bikePedApp.arrMarkersResultSet.pop());
	}
	while (CTPS.bikePedApp.arrMarkersNotResultSet.length > 0) {
		arrMarkersNotResultSetTemp.push(CTPS.bikePedApp.arrMarkersNotResultSet.pop());
	}
	
	// Both the result set arrays and the displayed marker arrays are sorted count location id (loc_id), 
	// so we can walk through them in parallel, removing markers that are not in the result set
	// array, and addding markers that are not in the displayed marker arrays. Start with markers
	// that meet search criteria, being careful not to exceed the limit on total markers displayed.
	marker = arrMarkersResultSetTemp.pop();
	while (i < CTPS.bikePedApp.arrDispResultSet.length && i < CTPS.bikePedApp.cDisplayLimit) {
		// if displayed markers have lower ID than current result set element, remove them from display
		if (marker) {
			if (parseInt(marker.getTitle()) < CTPS.bikePedApp.arrDispResultSet[i][CTPS.bikePedApp.cIDIdx]) {
				google.maps.event.clearListeners(marker,"mouseover");	// clean up event listeners
				google.maps.event.clearListeners(marker,"mouseout");
				google.maps.event.clearListeners(marker,"click");
				marker.setMap(null);					// remove the overlay
				marker = arrMarkersResultSetTemp.pop();
			// if displayed marker has same ID as current result set element, push marker variable
			// back into the displayed marker array [from temp array]
			} else if (parseInt(marker.getTitle(),10) === CTPS.bikePedApp.arrDispResultSet[i][CTPS.bikePedApp.cIDIdx]) {
				CTPS.bikePedApp.arrMarkersResultSet.push(marker);
				marker = arrMarkersResultSetTemp.pop();
				i = i + 1;
			// otherwise current result set element describes marker not yet displayed or part of 
			// displayed marker array, so create the marker from the info, add it to the display, and
			// push its variable into the array
			} else {
				CTPS.bikePedApp.arrMarkersResultSet.push(CTPS.bikePedApp.MMSMarker(i, true));
				intMarkerIdx = CTPS.bikePedApp.arrMarkersResultSet.length - 1;
				// CTPS.bikePedApp.arrMarkersResultSet[intMarkerIdx].setMap(CTPS.bikePedApp.map);	// add the overlay
				// add mouseout event listener for overlay
				CTPS.bikePedApp.addMarkerMouseoutListener(CTPS.bikePedApp.arrMarkersResultSet[intMarkerIdx], true);
						// (CTPS.bikePedApp.numCriteriaSpecified > 0));
				// add mouseover event listener for overlay
				CTPS.bikePedApp.addMarkerMouseoverListener(CTPS.bikePedApp.arrMarkersResultSet[intMarkerIdx], true);
						// (CTPS.bikePedApp.numCriteriaSpecified > 0));
				// add click event listener for overlay
				CTPS.bikePedApp.addMarkerClickListener(CTPS.bikePedApp.arrMarkersResultSet[intMarkerIdx]);
				i = i + 1;
			}
		} else {
			CTPS.bikePedApp.arrMarkersResultSet.push(CTPS.bikePedApp.MMSMarker(i, true));
			intMarkerIdx = CTPS.bikePedApp.arrMarkersResultSet.length - 1;
			// CTPS.bikePedApp.arrMarkersResultSet[intMarkerIdx].setMap(CTPS.bikePedApp.map);		// add the overlay
			// add mouseout event listener for overlay
			CTPS.bikePedApp.addMarkerMouseoutListener(CTPS.bikePedApp.arrMarkersResultSet[intMarkerIdx], true);
					// (CTPS.bikePedApp.numCriteriaSpecified > 0));
			// add mouseover event listener for overlay
			CTPS.bikePedApp.addMarkerMouseoverListener(CTPS.bikePedApp.arrMarkersResultSet[intMarkerIdx], true);
					// (CTPS.bikePedApp.numCriteriaSpecified > 0));
			// add click event listener for overlay
			CTPS.bikePedApp.addMarkerClickListener(CTPS.bikePedApp.arrMarkersResultSet[intMarkerIdx]);
			i = i + 1;
		}
	}
	while (marker) {
		google.maps.event.clearListeners(marker,"mouseover");	// clean up event listeners
		google.maps.event.clearListeners(marker,"mouseout");
		google.maps.event.clearListeners(marker,"click");
		marker.setMap(null);					// remove the overlay
		marker = arrMarkersResultSetTemp.pop();
	}
	intMarkersDisplayed = i;
	i = 0;
	// repeat the loop above for intersections falling within the display extent that are not in the
	// result set, assuming the number of markers added to the map has not yet exceeded the display limit
	marker = arrMarkersNotResultSetTemp.pop();
	while (i < CTPS.bikePedApp.arrDispNotResultSet.length && (i+intMarkersDisplayed) < CTPS.bikePedApp.cDisplayLimit) {
		// if displayed markers have lower ID than current result set element, remove them from display
		if (marker) {
			if (parseInt(marker.getTitle()) < CTPS.bikePedApp.arrDispNotResultSet[i][CTPS.bikePedApp.cIDIdx]) {
				google.maps.event.clearListeners(marker,"mouseover");	// clean up event listeners
				google.maps.event.clearListeners(marker,"mouseout");
				google.maps.event.clearListeners(marker,"click");
				marker.setMap(null);					// remove the overlay
				marker = arrMarkersNotResultSetTemp.pop();
			// if displayed marker has same ID as current result set element, push marker variable
			// back into the displayed marker array [from temp array]
			} else if (parseInt(marker.getTitle(),10) === CTPS.bikePedApp.arrDispNotResultSet[i][CTPS.bikePedApp.cIDIdx]) {
				CTPS.bikePedApp.arrMarkersNotResultSet.push(marker);
				marker = arrMarkersNotResultSetTemp.pop();
				i = i + 1;
			// otherwise current result set element describes marker not yet displayed or part of 
			// displayed marker array, so create the marker from the info, add it to the display, and
			// push its variable into the array
			} else {
				CTPS.bikePedApp.arrMarkersNotResultSet.push(CTPS.bikePedApp.MMSMarker(i, false));
				intMarkerIdx = CTPS.bikePedApp.arrMarkersNotResultSet.length - 1;
				// CTPS.bikePedApp.arrMarkersNotResultSet[intMarkerIdx].setMap(CTPS.bikePedApp.map);	// add the overlay
				// add mouseout event listener for overlay
				CTPS.bikePedApp.addMarkerMouseoutListener(CTPS.bikePedApp.arrMarkersNotResultSet[intMarkerIdx], false);
				// add mouseover event listener for overlay
				CTPS.bikePedApp.addMarkerMouseoverListener(CTPS.bikePedApp.arrMarkersNotResultSet[intMarkerIdx], false);
				// add click event listener for overlay
				CTPS.bikePedApp.addMarkerClickListener(CTPS.bikePedApp.arrMarkersNotResultSet[intMarkerIdx]);
				i = i + 1;
			}
		} else {
			CTPS.bikePedApp.arrMarkersNotResultSet.push(CTPS.bikePedApp.MMSMarker(i, false));
			intMarkerIdx = CTPS.bikePedApp.arrMarkersNotResultSet.length - 1;
			// CTPS.bikePedApp.arrMarkersNotResultSet[intMarkerIdx].setMap(CTPS.bikePedApp.map);	// add the overlay
			// add mouseout event listener for overlay
			CTPS.bikePedApp.addMarkerMouseoutListener(CTPS.bikePedApp.arrMarkersNotResultSet[intMarkerIdx], false);
			// add mouseover event listener for overlay
			CTPS.bikePedApp.addMarkerMouseoverListener(CTPS.bikePedApp.arrMarkersNotResultSet[intMarkerIdx], false);
			// add click event listener for overlay
			CTPS.bikePedApp.addMarkerClickListener(CTPS.bikePedApp.arrMarkersNotResultSet[intMarkerIdx]);
			i = i + 1;
		}
	}
	while (marker) {
		google.maps.event.clearListeners(marker,"mouseover");	// clean up event listeners
		google.maps.event.clearListeners(marker,"mouseout");
		google.maps.event.clearListeners(marker,"click");
		marker.setMap(null);					// remove the overlay
		marker = arrMarkersNotResultSetTemp.pop();
	}
	var zoomLevel = CTPS.bikePedApp.map.getZoom();
	// if overlay limit was reached, adjust visual warning in legend for result set intersections
	if (intMarkersDisplayed >= CTPS.bikePedApp.cDisplayLimit) 
		CTPS.bikePedApp.legendTxtHilite.innerHTML = CTPS.bikePedApp.cLegendTxtHilite + 
			".<br><b>Some within the current map bounds are not shown. Zoom in to see them.</b>"
	else CTPS.bikePedApp.legendTxtHilite.innerHTML = CTPS.bikePedApp.cLegendTxtHilite;
	// adjust visual warning in legend for non-result-set intersections
	if (zoomLevel < CTPS.bikePedApp.cZoomThreshold) {
		CTPS.bikePedApp.legendTxtRegular.innerHTML = CTPS.bikePedApp.cLegendTxtRegular +
			" <b>shown only at higher zoom levels</b>"
	} else if ((intMarkersDisplayed+i) >= CTPS.bikePedApp.cDisplayLimit) {
		CTPS.bikePedApp.legendTxtRegular.innerHTML = CTPS.bikePedApp.cLegendTxtRegular +
			".<br><b>Some in the current map are not shown. Zoom in further to see them.</b>"
	} else CTPS.bikePedApp.legendTxtRegular.innerHTML = CTPS.bikePedApp.cLegendTxtRegular;
}

/*****************************
  ADDMARKERMOUSEOVERLISTENER
*****************************/
// This event handler executes every time the mouse moves over a marker overlay in the Google Map.
// It uses so-called "closures," which can cause memory leak problems if not cleaned up properly.
CTPS.bikePedApp.addMarkerMouseoverListener = function(objMarker, isInResultSet) {
	if (isInResultSet) {
		google.maps.event.addListener(objMarker, "mouseover", function() {
			objMarker.setIcon(CTPS.bikePedApp.cSrcMarkerHover);	// change color of marker to highlight color
			var DOMElement = document.getElementById("list" + objMarker.getTitle());
			if (DOMElement)				// add highlight color to text in corresponding item of result set list
				DOMElement.innerHTML = '<span class="blueHilite" style="text-decoration:underline">' + DOMElement.innerHTML + "</span>";
		});
	} else {
		google.maps.event.addListener(objMarker, "mouseover", function() {
			objMarker.setIcon(CTPS.bikePedApp.cSrcMarkerHover);	// change color of marker to highlight color
		});
	}
}

/****************************
  ADDMARKERMOUSEOUTLISTENER
****************************/
// This event handler executes every time the mouse moves off a marker overlay in the Google Map.
// It uses so-called "closures," which can cause memory leak problems if not cleaned up properly.
CTPS.bikePedApp.addMarkerMouseoutListener = function(objMarker, isInResultSet) {
	if (isInResultSet) {
		google.maps.event.addListener(objMarker, "mouseout", function() {
			objMarker.setIcon(CTPS.bikePedApp.cSrcMarkerHilite);	// 1) highlight color (marker belongs to result set)
			var DOMElement = document.getElementById("list" + objMarker.getTitle());
			if (DOMElement)	// remove highlight color from text in corresponding item of result set list
				DOMElement.innerHTML = DOMElement.innerHTML.substring(DOMElement.innerHTML.indexOf(">")+1,
					DOMElement.innerHTML.lastIndexOf("<"));
		});
	} else {
		google.maps.event.addListener(objMarker, "mouseout", function() {
			objMarker.setIcon(CTPS.bikePedApp.cSrcMarkerRegular);	// 2) regular color (marker does NOT belong to result set)
		});
	}
}
	
/*************************
  ADDMARKERCLICKLISTENER
*************************/
// This event handler executes when a marker overlay in the Google Map is clicked.
// It uses so-called "closures," which can cause memory leak problems if not cleaned up properly.
CTPS.bikePedApp.addMarkerClickListener = function(objMarker) {
	google.maps.event.addListener(objMarker, 'click', function() {
		CTPS.bikePedApp.infoWindow.setContent(objMarker.infoWindowHtml);
		CTPS.bikePedApp.infoWindow.open(CTPS.bikePedApp.map, objMarker);
	});
}

/***************
  MARKERHILITE
***************/
// Invoked by moving the mouse over an item in the result set list. Highlights the corresponding overlay
// marker in the Google Map, if it has been added to the map
CTPS.bikePedApp.markerHilite = function() {
	var i = 0;
	var strInt = this.id.substr(4);
	while (i < CTPS.bikePedApp.arrMarkersResultSet.length && 
			CTPS.bikePedApp.arrMarkersResultSet[i].getTitle() != strInt) i = i + 1;
	if (i < CTPS.bikePedApp.arrMarkersResultSet.length) 
		CTPS.bikePedApp.arrMarkersResultSet[i].setIcon(CTPS.bikePedApp.cSrcMarkerHover);
}

/*****************
  MARKERUNHILITE
*****************/
// Invoked by moving the mouse off an item in the result set list. Unhighlights the corresponding overlay
// marker in the Google Map, if it has been added to the map
CTPS.bikePedApp.markerUnHilite = function() {
	var i = 0;
	var strInt = this.id.substr(4);
	while (i < CTPS.bikePedApp.arrMarkersResultSet.length && 
			CTPS.bikePedApp.arrMarkersResultSet[i].getTitle() != strInt) i = i + 1;
	if (i < CTPS.bikePedApp.arrMarkersResultSet.length)
		CTPS.bikePedApp.arrMarkersResultSet[i].setIcon(CTPS.bikePedApp.cSrcMarkerHilite);
}

/************
  MMSMARKER
************/
// Creates and returns a Google Maps overlay marker for the specified intersection, using either the highlight
// color (for intersections in the result set) or the regular color
CTPS.bikePedApp.MMSMarker = function(intArrIdx,isInResultSet) {
	
	var strHTML = "";
	var arrRow;
	if (isInResultSet) arrRow = CTPS.bikePedApp.arrDispResultSet[intArrIdx]
	else arrRow = CTPS.bikePedApp.arrDispNotResultSet[intArrIdx];
	
	// First, set up the HTML string to be shown in the "InfoWindow" bubble of the Google Map
	// when the overlay marker is clicked. 
	// It is an HTML table of location description for the count location that can be clicked
	// to open a page of detailed information for the count location.
	// N.B. For our purposes, at least for the time being, this table will consist of two rows:
	//      Row 1 = Description
	//      Row 2 = Town
	// Both of these *should* never be null.
	// Surround the HTML table with link so contents highlight as one item when mouse rolls over
	strHTML = '<a href="javascript:CTPS.bikePedApp.openCountLocDetail(' + arrRow[CTPS.bikePedApp.cIDIdx] + ');">' +
		      // however, Internet Explorer does not correctly activate the table as a link, so add event handler
		      // to the table that accomplishes the same thing (opening the intersection detail window on click)
		      '<table class="iWinGTbl" onclick="CTPS.bikePedApp.openCountLocDetail(' + arrRow[CTPS.bikePedApp.cIDIdx] + ');">' +
		      '<tr><td colspan="2">' + arrRow[CTPS.bikePedApp.cDescIdx] + '</td></tr>' +
		      '<tr><td colspan="2">' + arrRow[CTPS.bikePedApp.cMunIdx]  + '</td></tr>' +
		      '</table></a>';
	var markerNew, markerOpts;
	markerOpts = {
		'map': CTPS.bikePedApp.map,
		'title': String(arrRow[CTPS.bikePedApp.cIDIdx]),
		'visible': true,
		'position': new google.maps.LatLng(arrRow[CTPS.bikePedApp.cLatIdx], arrRow[CTPS.bikePedApp.cLngIdx]),
		'shadow': new google.maps.MarkerImage('images/shadow50.png',
				new google.maps.Size(37,34), new google.maps.Point(0,0),new google.maps.Point(9,33))
	};
	if (isInResultSet) markerOpts.icon = CTPS.bikePedApp.cSrcMarkerHilite;
	else markerOpts.icon = CTPS.bikePedApp.cSrcMarkerRegular;
	markerNew = new google.maps.Marker(markerOpts);	// create the new marker and add it to the map
	markerNew.infoWindowHtml = strHTML;	// and associate the HTML string with it (not part of Google API)
	return markerNew;
}

/***********************
  ADJUSTMAPTORESULTSET
***********************/
// This function should be triggered by the XmlHttpRequest object response handler for response data from ColdFusion.
// It adjusts the area shown in the Google Map to comfortably contain the intersections in the response data.
// In adjusting the area, it will in turn cause the moveend event handler of the Google Map to execute.
CTPS.bikePedApp.adjustMapToResultSet = function()  {
	
	// create a bounds object using the minimum and maximum latitude and longitude indicated in the response data
	var bounds = new google.maps.LatLngBounds(new google.maps.LatLng(CTPS.bikePedApp.minY, CTPS.bikePedApp.minX), 
			new google.maps.LatLng(CTPS.bikePedApp.maxY, CTPS.bikePedApp.maxX));

	// remember the starting bounds of the map
	var oldBounds = CTPS.bikePedApp.map.getBounds();
	
	// first, temporarily set the minimum zoom level of the map so that a bounds based on a single point doesn't
	// zoom in too far
	CTPS.bikePedApp.map.setOptions({'maxZoom': 17});
	// set the viewport to contain the bounds
	CTPS.bikePedApp.map.fitBounds(bounds);
	// set the minimum zoom level back to the default for the map type
	CTPS.bikePedApp.map.setOptions({'maxZoom': null});
	
	if (CTPS.bikePedApp.map.getBounds().equals(oldBounds)) {
		return false;
	} else {
		return true;
	}
}

/**************
  WRITECOOKIE
**************/
// Cookie helper functions from http://www.headfirstlabs.com/books/hfjs/ch03/irock/cookie.js
CTPS.bikePedApp.writeCookie = function(name, value, days) {
	// By default, there is no expiration so the cookie is temporary
	var expires = "";

	// Specifying a number of days makes the cookie persistent
	if (days) {
		var date = new Date();
		date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
		expires = "; expires=" + date.toGMTString();
	}

	// Set the cookie to the name, value, and expiration date
	document.cookie = name + "=" + value + expires + "; path=/";
}

/*************
  READCOOKIE
*************/
CTPS.bikePedApp.readCookie = function(name) {
	// Find the specified cookie and return its value
	var searchName = name + "=";
	var cookies = document.cookie.split(';');
	for(var i=0; i < cookies.length; i++) {
		var c = cookies[i];
		while (c.charAt(0) == ' ')
			c = c.substring(1, c.length);
		if (c.indexOf(searchName) == 0)
			return c.substring(searchName.length, c.length);
	}
	return null;
}

/**************
  ERASECOOKIE
**************/
CTPS.bikePedApp.eraseCookie = function(name) {
	// Erase the specified cookie
	CTPS.bikePedApp.writeCookie(name, "", -1);
}
// End cookie helper functions
    

/*********************
  SAVESELECTEDFORMAT
*********************/
// Saves selected output format in "outputFormat" cookie.
CTPS.bikePedApp.saveSelectedFormat = function(form) {
	CTPS.bikePedApp.writeCookie("outputFormat", document.forms["tabularQuery"].format.value, 0);
	return true;
}

/*********************
  OPENCOUNTLOCDETAIL
*********************/
// Opens an bike-ped count loc record detail page using a hidden form. 
// It is invoked from the following places:
//     1. A click on a row in the main query result list
//     2. A click on a single Google Maps Infowindow balloon 
//     3. A click on the "Get all selected data" button.
// In cases (1) and (2), the detail page is called to generate a report 
// for a single bike-ped loc_id.
// In case (3), the detail page is called to generate a report for
// all loc_id's selected by the other FORM parameters: municipality,
// facility_name, and date. The latter case is indicated by passing
// the NULL string as the loc_id parameter.
CTPS.bikePedApp.openCountLocDetail = function(loc_id) {
	var outputFormat;
	outputFormat = document.forms["tabularQuery"].format.value;
	switch (outputFormat) {
	case "csv":
		document.getElementById("csv_loc_id").value = loc_id;
		document.getElementById("detailRequestFormCSV").submit();
		break;
	case "html":
		// Fall-through is deliberate.
	default: 
		// Assume HTML format as the only alternative to CSV format for now.
		document.getElementById("loc_id").value = loc_id;
		document.getElementById("detailRequestForm").submit();
		break;
	}
	return void(0);
}	

/**********
  DOQUERY
**********/
// Each of the visible query criteria form elements have onchange handlers. Submitting the query request
// from a hidden, shadow form allows the values of the form to be changed programatically (when multiple
// values must be set simultaneously--as when clearing multiple criteria) without triggering a cascade
// of redundant events. This function is triggered by events on the elements of the visible form 
// ("change" for the criteria drop-down lists, and "click" for the reset button).
CTPS.bikePedApp.doQuery = function(elementValue,updateExtent) {
	CTPS.bikePedApp.xmlHttpRequest = CTPS.bikePedApp.createXMLHttpRequest();
	CTPS.bikePedApp.xmlHttpRequest.open('POST', 'bike_ped_response.cfm', true);
	CTPS.bikePedApp.xmlHttpRequest.setRequestHeader('Content-Type','application/x-www-form-urlencoded; charset=utf-8');
	CTPS.bikePedApp.xmlHttpRequest.onreadystatechange = CTPS.bikePedApp.parseXMLHttpResponse;
	//CTPS.bikePedApp.xmlHttpRequest.overrideMimeType('text/xml');
	if (String(elementValue) === '999') {
		szParams = 'municipality=999&facility_name=999&date=01-JAN-1900';
		szParams += '&minX=-180&maxX=0&minY=0&maxY=90&retrieveAllMarkersInExtent=0';
	} else {
		szParams = 'municipality=' + document.getElementById('municipality').value;
		szParams += '&facility_name=' + document.getElementById('facility_name').value;
		szParams += '&date=' + document.getElementById('date').value;
		szParams += '&minX=' + CTPS.bikePedApp.minX;
		szParams += '&maxX=' + CTPS.bikePedApp.maxX;
		szParams += '&minY=' + CTPS.bikePedApp.minY;
		szParams += '&maxY=' + CTPS.bikePedApp.maxY;
		szParams += '&retrieveAllMarkersInExtent=' + CTPS.bikePedApp.retrieveAllMarkersInExtent;
	}
	if (updateExtent) {
		szParams += '&updateExtent=1';
	} else {
		szParams += '&updateExtent=0';
	}
	CTPS.bikePedApp.xmlHttpRequest.send(szParams);

	// prepare the hidden forms for opening the detail page
	document.getElementById("html_municipality").value = document.getElementById('municipality').value;
	document.getElementById("html_facility_name").value = document.getElementById('facility_name').value;
	document.getElementById("html_date").value = document.getElementById('date').value;
	document.getElementById("csv_municipality").value = document.getElementById('municipality').value;
	document.getElementById("csv_facility_name").value = document.getElementById('facility_name').value;
	document.getElementById("csv_date").value = document.getElementById('date').value;
}


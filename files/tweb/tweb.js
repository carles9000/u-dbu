//	---------------------------------------------------------------------------- //
var _TWebIdDlg = 0

function MsgInfo( cMsg, fCallback, cTitle, cIcon ) {

	cTitle 	= (typeof cTitle ) == 'string' ? cTitle : 'Information' ;
	cIcon 	= (typeof cIcon ) == 'string' ? cIcon : '<i class="fas fa-info-circle"></i>' ;
	
	if ( typeof cMsg !== 'string' ||( typeof cMsg == 'string' && cMsg.length == 0 ))
		cMsg = String(cMsg)
	
	//	Check animations -> https://codepen.io/ghimawan/pen/vXYYOz?editors=0010#0
	//						https://codepen.io/ghimawan/pen/vXYYOz	
	
	var dialog = bootbox.dialog({
		title: cIcon + '&nbsp;' + cTitle,
		message: cMsg,
		size: 'medium',
		backdrop: false,
		onEscape: true, 
		className: 'bounce fadeOut',
		buttons: {
			confirm: {
				label: '<i class="fa fa-check"></i> Accept',
				className: 'btn-outline-success',
				callback: function(result) {									
					if ( typeof fCallback === "function") {					
						fCallback.apply(null, [result] );
					}
				}
			}
		}
	});
	
	dialog.on("shown.bs.modal", function() {
		_TWebIdDlg++
		dialog.attr("id", "TWebIdDlg" +  _TWebIdDlg );
	});
	
	dialog.init(function(){
		dialog.bind('shown.bs.modal', function(){
			//$('.modal-content').draggable()														
		});								
	})			
}

//----------------------------------------------------------------------------//

function MsgError( cMsg, fCallback, cTitle, cIcon ) {

	cTitle 	= (typeof cTitle ) == 'string' ? cTitle : 'System Error' ;
	cIcon 	= (typeof cIcon ) == 'string' ? cIcon : '<i class="fas fa-bug"></i>' ;

	
	if ( typeof cMsg !== 'string' ||( typeof cMsg == 'string' && cMsg.length == 0 ))
		cMsg = '&nbsp;'
	
	var dialog = bootbox.dialog({
		title: cIcon + '&nbsp;' + cTitle,
		message: cMsg,
		size: 'large',
		backdrop: false,
		onEscape: true, 		
		className: 'rubberBand animated',
		buttons: {
			cancel: {
				label: '<i class="fa fa-check"></i> Accept',
				className: 'btn-danger',
				callback: function( result ){
				
					if ( typeof fCallback === "function") {					
						fCallback.apply(null, [result] );
					}				
				}
			}
		}
	});
}

//	---------------------------------------------------------------------------- //

function MsgGet( cInput, fCallback, cTitle, cIcon ) {


	if ( typeof fCallback !== "function") {	
		MsgError( 'MsgGet need fCallback' )
		
		console.trace( 'Error MsgGet(). I need fcallback' )
		return null
	}

	cTitle 	= (typeof cTitle ) == 'string' ? cTitle : 'Information' ;
	cIcon 	= (typeof cIcon ) == 'string' ? cIcon : '<i class="fas fa-info-circle"></i>' ;
	
	if ( typeof cInput !== 'string' ||( typeof cInput == 'string' && cInput.length == 0 ))
		cInput = String(cInput)
	
	//	Check animations -> https://codepen.io/ghimawan/pen/vXYYOz?editors=0010#0
	//						https://codepen.io/ghimawan/pen/vXYYOz	
	
	var dialog = bootbox.prompt({
		title: cIcon + '&nbsp;' + cTitle,
		value: cInput,
		size: 'medium',
		backdrop: false,
		onEscape: true, 
		className: 'bounce fadeOut',
		callback: function(result) {
	
			if ( typeof result == 'string' )
				fCallback.apply(null, [result] );			
		}					
	});
}

//	---------------------------------------------------------------------------- //

function MsgYesNo( cMsg, fCallback, cTitle, cIcon ){

	if ( typeof fCallback !== "function") {	
		MsgError( 'MsgYesNo need fCallback' )
		
		console.trace( 'Error MsgYesNo(). I need fcallback' )
		return null
	}

	cTitle 	= (typeof cTitle ) == 'string' ? cTitle : 'Information' ;
	cIcon 	= (typeof cIcon ) == 'string' ? cIcon : '<i class="fas fa-info-circle"></i>' ;
	
	if ( typeof cMsg !== 'string' ||( typeof cMsg == 'string' && cMsg.length == 0 ))
		cMsg = '&nbsp;'


	bootbox.confirm({
		title: cIcon + ' ' + cTitle,
		message: cMsg,
		buttons: {
			cancel: {
				label: '<i class="fa fa-times"></i> Cancel'
			},
			confirm: {
				label: '<i class="fa fa-check"></i> Confirm'
			}
		},
		callback: function (result) {		
			
			if ( result ) {					
				fCallback.apply(null, [result] );
			}
		}
	});	

}

//	---------------------------------------------------------------------------- //

function MsgServer( cUrl, fCallback, oValues) {	
	
	var oPar = TValuesToParam( oValues )		
		/*
			//	If don't exist fcalback, then we send oValues via Submit Post, not AJAX 

			if ( typeof fCallback !== "function") {	
			
				TWeb_Redirect( cUrl, oValues )
			
				return null
			}
		*/
	
	$.post( cUrl, oPar )		
	
		.done( function( data ) { 	
	
			if ( typeof fCallback == "function") {	
				fCallback.apply(null, [data] );							
			}
			 
		})
		.fail( function(data){ 
			console.log( 'FAIL', data )
			MsgError( data.responseText ) 
		})
}

//	---------------------------------------------------------------------------- //

function TValuesToParam( oValues ) {
	
	var cType 	= $.type( oValues )
	var oPar 	= new Object()
		
	switch ( cType ) {
	
		case 'object':
			oPar[ 'type' ] = 'H'
			oPar[ 'value' ] = JSON.stringify( oValues ) 	
			break;
			
		case 'string':
				
			oPar[ 'type' ] = 'C'
			oPar[ 'value' ] = oValues	
			break;	
			
		case 'boolean':
				
			oPar[ 'type' ] = 'L'
			oPar[ 'value' ] = oValues	
			break;	

		case 'number':
				
			oPar[ 'type' ] = 'N'
			oPar[ 'value' ] = oValues	
			break;			
			
		default:
		
			oPar[ 'type' ] = 'U'
			oPar[ 'value' ] = oValues;				
	}

	return oPar 
}

//	---------------------------------------------------------------------------- //

/*	Icons Animated
  "fas fa-spinner fa-spin"
  "fas fa-circle-notch fa-spin"
  "fas fa-sync fa-spin"
  "fas fa-cog fa-spin"
  "fas fa-spinner fa-pulse"
  "fas fa-stroopwafel fa-spin"
*/

var _TWebMsgLoading = null

function MsgLoading( cMessage, cTitle, cIcon, lHeader ) {



	//	If cMessage == false , close MsgLoading is it was opened
	
		if ( cMessage == false || ( $.type( cMessage ) == 'array' && cMessage.length == 1 && cMessage[0] == false )) {
			if ( $.type( _TWebMsgLoading ) == 'object' ) {

				//	No funciona bien. De momento cerraremos todas...
				//_TWebMsgLoading.modal( 'hide' );
				//_TWebMsgLoading = null
				bootbox.hideAll();
		
			}
			return false		
		}
		
	//	--------------------------------------------------------


	cMessage 	= (typeof cMessage ) == 'string' ? cMessage : 'Loading...' ;
	cTitle 		= (typeof cTitle ) == 'string' ? cTitle : 'System' ;
	cIcon 		= (typeof cIcon ) == 'string' ? '<i class="' + cIcon + '"></i>': '<i class="fas fa-sync fa-spin"></i>' ;
	lHeader		= (typeof lHeader ) == 'boolean' ? lHeader : false ;

	_TWebMsgLoading = bootbox.dialog({
			title: cTitle,
			message: '<p>' + cIcon + '&nbsp;&nbsp;'  + cMessage + '</p>',
			animate: false,							
			//closeButton: false
		}); 

	_TWebMsgLoading.addClass("loading_center");
	_TWebMsgLoading.find("div.modal-content").addClass("loading_content");
	_TWebMsgLoading.find("div.modal-body").addClass("loading_body");																

	if ( ! lHeader )
		_TWebMsgLoading.find("div.modal-header").addClass("loading_header");																
		
	return _TWebMsgLoading
}


//	MsgNotify ------------------------------------------------------------------	
//	cType = 	success, info, danger, warning
//	Examples -> http://bootstrap-growl.remabledesigns.com/

function MsgNotify( cMsg, cType, cIcon, lSound ) {

	cType  = ( $.type(cType) == 'string' ) ? cType : 'info';
	cIcon  = ( $.type( cIcon )== 'string' ) ? cIcon : '';
	lSound = ( $.type( lSound )== 'boolean' ) ? lSound : false;	

	$.notify( { icon: cIcon, message: cMsg }, { type: cType, icon_type: 'image' } );

}

//	---------------------------------------------------------------------------- //

function TDoClick( cId ){ $('#' + cId).click() }

//	---------------------------------------------------------------------------- //

function TWebIntro( cId, fFunction ) {

	$("#" + cId ).on('keyup', function (e) {
		if (e.key === 'Enter' || e.keyCode === 13) {
			if ( typeof fFunction === "function") {					
				fFunction.apply(null);
			}		
		}
	});
}

//	---------------------------------------------------------------------------- //
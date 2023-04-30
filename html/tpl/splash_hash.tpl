<!-- Template Splash -------------------------------

	Hash parameter:
	'file'	- Logo file
	'route' - Route when click logo
	'color' - Background color
-->

<body style="background-color:{{ if( hb_HHasKey( pvalue(1), 'color' ), pvalue(1)[ 'color' ], 'white;' ) }}">

<div class="container-fluid">
	
	<div style="margin-top:15%" align="center">
		<img id="logo" class="logo" src="{{ pvalue(1)[ 'file' ] }}" >							
	</div>

	<?prg 
		local cHtml  := ''
		local cRoute := pvalue(1)[ 'route' ]
		
		if valtype( cRoute ) == 'C'
		
			cHtml := "<script>"
			cHtml += "  $( '#logo' ).on( 'click', function(){"
			cHtml += "     window.location.assign( '" + cRoute + "' );"
			cHtml += "	})"
			cHtml += "</script>"
			
		endif
		
		retu cHtml
	?>
	
</div>	
</body>
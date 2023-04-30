/*
	Esto es solo un ejemplo de como se pueden manejar los datos
	y enviarlos a la vista para que los "pinte"
	
	This is just an example of how the data can be handled
	and send them to the view for you to "paint" them		
*/

function Dashboard()

	local cHtml 
	local hHistorial := {=>}
	local aTxt, aQty, aData

	//	Acceso a API Security
		if ! USessionReady()
			URedirect( 'login' )
			retu nil
		endif	
		
		
	hHistorial[ '2020' ] := GenerateSerie()
	hHistorial[ '2021' ] := GenerateSerie()
	hHistorial[ '2022' ] := GenerateSerie()
	hHistorial[ '2023' ] := GenerateSerie()
	
	aTxt 	:= {	'AA', 'BB', 'CC', 'DD', 'EE' }
	aQty 	:= {	10  ,  80 ,  60 ,  30 ,  21  }	

	aData 	:= {{ 'mes' => 'Gener'		, 'value' => HB_RandomInt( 1, 100 ) },;
	            { 'mes' => 'Febre'		, 'value' => HB_RandomInt( 1, 100 ) },;
	            { 'mes' => 'Març'		, 'value' => HB_RandomInt( 1, 100 ) },;
	            { 'mes' => 'Abril'		, 'value' => HB_RandomInt( 1, 100 ) },;
	            { 'mes' => 'Maig'		, 'value' => HB_RandomInt( 1, 100 ) },;
	            { 'mes' => 'Juny'		, 'value' => HB_RandomInt( 1, 100 ) },;
	            { 'mes' => 'Juliol'		, 'value' => HB_RandomInt( 1, 100 ) },;
	            { 'mes' => 'Agost'		, 'value' => HB_RandomInt( 1, 100 ) },;
	            { 'mes' => 'Septembre'	, 'value' => HB_RandomInt( 1, 100 ) },;
	            { 'mes' => 'Octubre'	, 'value' => HB_RandomInt( 1, 100 ) },;
	            { 'mes' => 'Novembre'	, 'value' => HB_RandomInt( 1, 100 ) },;
	            { 'mes' => 'Desembre'	, 'value' => HB_RandomInt( 1, 100 ) } ;
			}
		
	cHtml 	:= ULoadHtml( 'dbu\dashboard.html', hHistorial, aTxt, aQty, aData  )			
	
	UWrite( cHtml, hHistorial  )
		
retu nil 

// -------------------------------------------------- //

function GenerateSerie( nLen )

	local aSerie := {}
	local n
	
	hb_default( @nLen, 12 )
	
	for n := 1 to nLen 
		Aadd( aSerie, HB_RandomInt( 1, 100 ) )
	next

retu aSerie 

// -------------------------------------------------- //

function Api_Dashboard( oDom )
	do case	
		
		//case oDom:GetProc() == ''

		otherwise 				
			oDom:SetError( "Proc don't defined => " + oDom:GetProc())
	endcase
	
retu oDom:Send()	

// -------------------------------------------------- //
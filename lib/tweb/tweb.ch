#xcommand ? [<explist,...>] => UWrite( '<br>' [,<explist>] )
#xcommand ?? <cText> => UWrite( <cText> )

#xcommand DEFINE WEB <oWeb> [ TITLE <cTitle>] [ ICON <cIcon>] [<lTables: TABLES>] [ CHARSET <cCharSet>]  ;
	=> ;
		<oWeb> := TWeb():New( [<cTitle>], [<cIcon>], [<.lTables.>], [<cCharSet>] )
		
#xcommand INIT WEB <oWeb>  => <oWeb>:Activate()
#xcommand INIT WEB <oWeb> RETURN =>  return <oWeb>:Activate()

#xcommand DEFINE DIALOG <oDlg> => <oDlg> := TWebDialog():New()
#xcommand INIT DIALOG <oDlg> => <oDlg>:Activate()
#xcommand INIT DIALOG <oDlg> RETURN => return <oDlg>:Activate()


#xcommand CSS <oForm> => #pragma __cstream| <oForm>:Html( '<style>' + %s + '</style>' )

#xcommand TEXT TO <var> => #pragma __stream|<var> += %s
#xcommand CODE TO <var> => #pragma __stream|<var> += %s

#xcommand HTML <o> => #pragma __cstream| <o>:Html( %s )
#xcommand HTML <o> INLINE <cHtml> => <o>:Html( <cHtml> )
#xcommand HTML <o> [ PARAMS [<v1>] [,<vn>] ] ;
=> ;
	#pragma __cstream |<o>:Html( UInlinePrg( UReplaceBlocks( %s, '<$', "$>" [,<(v1)>][+","+<(vn)>] [, @<v1>][, @<vn>] ) ) )

#xcommand HTML <oForm> FILE <cFile> [ <prm: PARAMS, VARS> <cValues,...> ]  => <oForm>:Html( TWebHtmlInline( <cFile>, [<cValues>]  ) )
#xcommand TEMPLATE <oForm> FILE <cFile> [ <prm: PARAMS, VARS> <cValues,...> ]  => <oForm>:Html( TWebHtmlInline( <cFile>, [<cValues>]  ) )


#xcommand DEFINE FORM <oForm> [ID <cId> ] [ACTION <cAction>] [METHOD <cMethod>] ;
	[API <cApi>] [<chg: ONINIT,ON INIT> <cProc>] OF <oWeb> ;
=> <oForm> := TWebForm():New( <oWeb>, [<cId>], [<cAction>], [<cMethod>], [<cApi>], [<cProc>] )

#xcommand INIT FORM <oForm> [ CLASS <cClass>] => <oForm>:InitForm( [<cClass> ] )
#xcommand ENDFORM <oForm>  => <oForm>:End()



#xcommand COL <oForm> [ ID <cId> ] [GRID <nGrid>] [TYPE <cType>]  [ CLASS <cClass> ] [ STYLE <cStyle> ] [ <hi: HIDE, HIDDEN> ];
=> ;
	<oForm>:Col( [<cId>], [<nGrid>], [<cType>], [<cClass>], [<cStyle>], [<.hi.>] )
	
#xcommand ROW <oForm> [ ID <cId> ] [ VALIGN <cVAlign> ] [ HALIGN <cHAlign> ] [ CLASS <cClass> ] [ TOP <cTop> ] [ BOTTOM <cBottom>] [ <hi: HIDE, HIDDEN> ] ;
=> ;
	<oForm>:Row( [<cId>], [<cVAlign>], [<cHAlign>], [<cClass>], [<cTop>], [<cBottom>], [<.hi.>] )
	
#xcommand ROWGROUP <oForm> [ ID <cId> ] [ VALIGN <cVAlign> ] [ HALIGN <cHAlign> ] [ CLASS <cClass> ] [ STYLE <cStyle> ] [ <hi: HIDE, HIDDEN> ] ;
=> ;
	<oForm>:RowGroup( [<cId>], <cVAlign>, <cHAlign>, <cClass>, [<cStyle>], [<.hi.>] )
	
#xcommand DIV <oForm> [ ID <cId> ] [ CLASS <cClass> ] [ <hi: HIDE, HIDDEN> ];
	[ STYLE <cStyle> ] [ PROP <cProp> ];
=> ;
	<oForm>:Div( [<cId>], [<cClass>], [<cStyle>], [<cProp>], [<.hi.>])
	
#xcommand DIV [<oDiv>] [ ID <cId> ] [ CLASS <cClass> ] ;
	[ STYLE <cStyle> ] [ PROP <cProp> ] OF <oForm> ;
=> ;
	[<oDiv> := ] <oForm>:Div( [<cId>], [<cClass>], [<cStyle>], [<cProp>])

#xcommand ENDROW <oForm> => <oForm>:End()
#xcommand ENDCOL <oForm> => <oForm>:End()
#xcommand ENDDIV <oForm> => <oForm>:End()	

	
#xcommand CAPTION <oForm> LABEL <cLabel> [ GRID <nGrid> ]  [ CLASS <cClass> ] => <oForm>:Caption( <cLabel>, <nGrid>, [<cClass>] )
#xcommand SEPARATOR <oForm>  [ ID <cId> ] LABEL <cLabel> [ CLASS <cClass> ] => <oForm>:Separator( [<cId>], <cLabel>, [<cClass>] )
#xcommand SMALL <oForm> [ ID <cId> ] [ LABEL <cLabel> ] [ GRID <nGrid> ] [ CLASS <cClass> ] => <oForm>:Small( <cId>, <cLabel>, <nGrid>, [<cClass>] )



#xcommand SAY [<oSay>] [ ID <cId> ] [ <prm: VALUE,PROMPT,LABEL> <uValue> ] [ ALIGN <cAlign> ] ;
	[GRID <nGrid>] [ CLASS <cClass> ] [ FONT <cFont> ] [ LINK <cLink> ] [ STYLE <cStyle>] OF <oForm> ;
=> ;
	[<oSay> := ] TWebSay():New( <oForm>, [<cId>], [<uValue>], [<nGrid>], [<cAlign>], [<cClass>], [<cFont>], [<cLink>], [<cStyle>] )
	
#xcommand DEFINE FONT [<oFont>] NAME <cId> ;
	[ COLOR <cColor> ] [ BACKGROUND <cBackGround> ] [ SIZE <nSize> ] ;
	[ <bold: BOLD> ] [ <italic: ITALIC> ] [ FAMILY <cFamily> ] ;
	OF <oForm> ;
=> ;
	[<oFont> := ] TWebFont():New( <oForm>, <cId>, <cColor>, <cBackGround>, <nSize>, [<.bold.>], [<.italic.>], [<cFamily>] )

#xcommand GET [<oGet>] [ ID <cId> ] [ VALUE <uValue> ] [ <prm: PROMPT,LABEL> <cLabel> ] [ ALIGN <cAlign> ] [ <col:GRID, COL> <nGrid>] ;
	[ <ro: READONLY, DISABLED> ] [TYPE <cType>] [ PLACEHOLDER <cPlaceHolder>] ;
	[ <btn: BUTTON, BUTTONS> <cButton,...> ] [ <act: ACTION, ACTIONS> <cAction,...> ] [ <bid: BTNID, BTNIDS> <cBtnId,...> ] ;
	[ <rq: REQUIRED> ] [ AUTOCOMPLETE <uSource> [ SELECT <cSelect>] ] ;
	[ <chg: ONCHANGE,VALID> <cChange> ];
	[ CLASS <cClass> ] [ FONT <cFont> ] [ FONTLABEL <cFontLabel> ] ;
	[ LINK <cLink> ] [ GROUP <cGroup> ] [ DEFAULT <cDefault>] ;
	[ <spn: SPAN> <cSpan,...> ] [ <spnid: SPANID> <cSpanId,...> ] ;
	[ STYLE <cStyle> ] [ PROP <cProp> ] [ <hi: HIDE, HIDDEN> ];
	OF <oForm> ;
=> ;
	[<oGet> := ] TWebGet():New( <oForm>, [<cId>], [<uValue>], [<nGrid>], [<cLabel>], [<cAlign>], [<.ro.>], [<cType>], [<cPlaceHolder>], [\{<cButton>\}], [\{<cAction>\}], [\{<cBtnId>\}], [<.rq.>], [<uSource>], [<cSelect>], [<cChange>], [<cClass>], [<cFont>], [<cFontLabel>],[<cLink>], [<cGroup>], [<cDefault>], [\{<cSpan>\}], [\{<cSpanId>\}], [<cStyle>], [<cProp>], [<.hi.>] )
	
#xcommand GET [<oGetMemo>] MEMO [ ID <cId> ] [ VALUE <uValue> ] [ LABEL <cLabel> ] [ ALIGN <cAlign> ] [GRID <nGrid>] [ STYLE <cStyle>] ;
	[ <ro: READONLY, DISABLED> ] [ ROWS <nRows> ] ;	
	[ CLASS <cClass> ] [ FONT <cFont> ] ;
	[ <chg: ONCHANGE,VALID> <cChange> ];
	[ STYLE <cStyle> ] [ PROP <hProp> ];
	[ <hi: HIDE, HIDDEN> ];	
	OF <oForm> ;
=> ;
	[<oGetMemo> := ] TWebGetMemo():New( <oForm>, [<cId>], [<uValue>], [<nGrid>], [<cLabel>], [<cAlign>], [<.ro.>], [<nRows>], [<cClass>], [<cFont>], [<cChange>], [<cStyle>], [<hProp>], [<.hi.>] )
	
#xcommand GETNUMBER [<oGet>] [ ID <cId> ] [ VALUE <uValue> ] [ LABEL <cLabel> ] [ ALIGN <cAlign> ] [ <col:GRID, COL> <nGrid>] ;
	[ <ro: READONLY, DISABLED> ] [ PLACEHOLDER <cPlaceHolder>] ;	
	[ <rq: REQUIRED> ]  ;
	[ <chg: ONCHANGE,VALID> <cChange> ];
	[ CLASS <cClass> ] [ FONT <cFont> ] [ STYLE <cStyle> ] ;	
	OF <oForm> ;
=> ;
	[<oGet> := ] TWebGetNumber():New( <oForm>, [<cId>], [<uValue>], [<nGrid>], [<cLabel>], [<cAlign>], [<.ro.>], [<cPlaceHolder>], [<.rq.>], [<cChange>], [<cClass>], [<cFont>], [<cStyle>] )



	
#xcommand BUTTON [<oBtn>] [ ID <cId> ] [ LABEL <cLabel> ] [ ACTION <cAction> ] [ NAME <cName> ] [ VALUE <cValue> ] ;
    [ GRID <nGrid> ] [ ALIGN <cAlign> ]  ;
	[ ICON <cIcon> ] [ <ds: DISABLED> ] [ <sb: SUBMIT> ] [ LINK <cLink> ] ;
	[ CLASS <cClass> ] [ FONT <cFont> ] ;
	[ UPLOAD <cId_Btn_Files> ] ;
	[ WIDTH <cWidth> ] ;
	[ CONFIRM <cConfirm> ] ;
	[ STYLE <cStyle> ] [ PROP <hProp> ];
	[ <hi: HIDE, HIDDEN> ];
	[ PBS <cPBS> ];
	OF <oForm> ;
=> ;
	[ <oBtn> := ] TWebButton():New( <oForm>, [<cId>], <cLabel>, <cAction>, <cName>, <cValue>, <nGrid>, <cAlign>, <cIcon>, [<.ds.>], [<.sb.>], [<cLink>], [<cClass>], [<cFont>], [<cId_Btn_Files>], [<cWidth>], [<cConfirm>], [<cStyle>], [<hProp>], [<.hi.>], [<cPBS>] )	
	
#xcommand BUTTON FILE [<oBtn>] [ ID <cId> ] [ LABEL <cLabel> ] [ ACTION <cAction> ] [ NAME <cName> ] [ VALUE <cValue> ] ;
    [ GRID <nGrid> ] [ ALIGN <cAlign> ]  ;
	[ ICON <cIcon> ] [ <sb: SUBMIT> ] ;
	[ CLASS <cClass> ] [ FONT <cFont> ] ;	
	[ WIDTH <cWidth> ] ;
	[ CONFIRM <cConfirm> ] ;
	[ <ro: READONLY, DISABLED> ];
	[ STYLE <cStyle> ] [ PROP <hProp> ] [ <mu: MULTIPLE> ];	
	OF <oForm> ;
=> ;
	[ <oBtn> := ] TWebButtonFile():New( <oForm>, [<cId>], <cLabel>, <cName>, <cAction>, <cValue>, <nGrid>, <cAlign>, <cIcon>, [<.ro.>], [<.sb.>], [<cClass>], [<cFont>], [<cWidth>], [<cConfirm>], [<cStyle>], [<hProp>], [<.mu.>] )	
	
	
#xcommand IMAGE [<oImg>] [ ID <cId> ] [ FILE <cFile> ] [ BIGFILE <cBigFile> ] [ ALIGN <cAlign> ] ;
	[GRID <nGrid>] [ CLASS <cClass> ] [ WIDTH <nWidth>] [ GALLERY <cGallery> ] ;
	[ <nozoom: NOZOOM> ] [ STYLE <cStyle> ] [ PROP <cProp> ] OF <oForm> ;
=> ;
	[<oImg> := ] TWebImage():New( <oForm>, [<cId>], [<cFile>], [<cBigFile>], [<nGrid>], [<cAlign>], [<cClass>], [<nWidth>], [<cGallery>], [<.nozoom.>], [<cStyle>], [<cProp>] )
	
	
#xcommand SWITCH [<oSwitch>] [ ID <cId> ] [ <lValue: ON> ] [ VALUE <lValue> ] [ LABEL <cLabel> ] ;
	[GRID <nGrid>] [ <act:ACTION,ONCHANGE> <cAction> ];
	[ <ro: READONLY, DISABLED> ] [ <hi: HIDE, HIDDEN> ] OF <oForm> ;
=> ;
	[ <oSwitch> := ] TWebSwitch():New( <oForm>, [<cId>], [<lValue>], [<cLabel>], [<nGrid>], [<cAction>], [<.ro.>], [<.hi.>] ) 	

#xcommand RADIO [<oRadio>] [ ID <cId> ] [ LABEL <cLabel> ] [ <chk: VALUE, CHECKED> <uValue> ] ;
		[ <prm: PROMPT, PROMPTS, ITEMS> <cPrompt,...> ] ;
		[ <tabs: VALUES, KEYS> <cValue,...> ] ;	
		[ <ro: READONLY, DISABLED> ] ;
		[ GRID <nGrid> ] ;
		[ ONCHANGE  <cAction> ] ;
		[ <inline: INLINE> ] ;
		[ CLASS <cClass> ] [ FONT <cFont> ] [ STYLE <cStyle>] [ PROP <hProp> ] [ <hi: HIDE, HIDDEN> ];		
		OF <oForm> ;
=> ;
	[ <oRadio> := ] TWebRadio():New( <oForm>, [<cId>], [<cLabel>], [<uValue>], [\{<cPrompt>\}], [\{<cValue>\}], [<.ro.>], [<nGrid>], [<cAction>], [<.inline.>], [<cClass>], [<cFont>], [<cStyle>], [<hProp>], [<.hi.>] )
		 

#xcommand CHECKBOX [<oCheckbox>] [ ID <cId> ] [ <lValue: ON> ] [ LABEL <cLabel> ] [GRID <nGrid>] [ ACTION  <cAction> ] ;
	[ CLASS <cClass> ] [ FONT <cFont> ] [ STYLE <cStyle> ] [ PROP <hProp> ] [ <ro: READONLY, DISABLED> ] [ <hi: HIDE, HIDDEN> ];
	OF <oForm> ;
=> ;
	[ <oCheckbox> := ] TWebCheckbox():New( <oForm>, [<cId>], [<.lValue.>], [<cLabel>], [<nGrid>], [<cAction>], [<cClass>], [<cFont>], [<cStyle>], [<hProp>], [<.ro.>], [<.hi.>] ) 	
	

	
#xcommand BOX [<oBox>] [ ID <cId> ]  ;
	[GRID <nGrid>] [ HEIGHT <nHeight> ] [ CLASS <cClass> ] OF <oContainer> ;
=> ;
	[<oBox> := ] TWebBox():New( <oContainer>, [<cId>], [<nGrid>], [<nHeight>], [<cClass>] )
	
#xcommand ENDBOX <oBox> => <oBox>:End()	

	 
#xcommand SELECT [<oSelect>] [ ID <cId> ] [ VALUE <uValue> ] [ LABEL <cLabel> ] [ KEYVALUE <aKeyValue> ] ;
		[ <prm: PROMPT, PROMPTS, ITEMS> <cPrompt,...> ] ;
		[ <tabs: VALUES> <cValue,...> ] ;		
		[ GRID <nGrid> ] ;
		[ ONCHANGE  <cAction> ] ;
		[ CLASS <cClass> ] [ FONT <cFont> ]  [ GROUP <cGroup> ] [ STYLE <cStyle>] [ PROP <cProp> ] ;
		[ <ro: READONLY, DISABLED> ] [ <hi: HIDE, HIDDEN> ];	
		OF <oForm> ;
=> ;
	[ <oSelect> := ] TWebSelect():New( <oForm>, [<cId>], [<uValue>], [\{<cPrompt>\}], [\{<cValue>\}], [<aKeyValue>], [<nGrid>], [<cAction>], [<cLabel>], [<cClass>], [<cFont>], [<cGroup>], [<cStyle>], [<cProp>], [<.ro.>], [<.hi.>] )

#xcommand ICON [<oIcon>] [ ID <cId> ] [ <prm: IMAGE,SRC> <cSrc> ] [ ALIGN <cAlign> ] ;
	[GRID <nGrid>] [ CLASS <cClass> ] [ FONT <cFont> ] [ LINK <cLink> ] [ STYLE <cStyle>] OF <oForm> ;
=> ;
	[<oIcon> := ] TWebIcon():New( <oForm>, [<cId>], [<cSrc>], [<nGrid>], [<cAlign>], [<cClass>], [<cFont>], [<cLink>], [<cStyle>] )

#xcommand NAV [<oNav>] [ ID <cId> ] [ TITLE <cTitle> ] [ LOGO <cLogo> [ WIDTH <nWidth>] ;
	[ ROUTE <cRoute>] [HEIGHT <nHeight> ] ] [ <bl: BURGUERLEFT> ] [ <sd: SIDEBAR> [ SIDE <cSide> ] ] OF <oWeb> ;	
=> ;
	[<oNav> := ] TWebNav():New( <oWeb>, [<cId>], [<cTitle>], [<cLogo>], [<nWidth>], [<nHeight>], [<cRoute>], [<.bl.>], [<.sd.>], [<cSide>] )

#xcommand MENU GROUP <cItem> OF <oNav>  => <oNav>:AddMenuItem( <cItem>, nil, nil, nil,  .f., .f., .t. )
#xcommand MENU <cItem> [ ICON <cIcon> ] OF <oNav>  => <oNav>:AddMenuItem( <cItem>, nil, [<cIcon>], nil, .t., .f., .f. )
#xcommand ENDMENU OF <oNav>  => <oNav>:AddMenuItem( nil, nil, nil, nil, .f., .t., .f. )

#xcommand MENUITEM <cItem> [ ICON <cIcon> ] [ ROUTE <cRoute> ] [ <ac: ACTIVE>  ]     OF <oNav>  => <oNav>:AddMenuItem( <cItem>, [<cRoute>], [<cIcon>], nil, .f., .f., .f.,.f.,[<.ac.>]  )
#xcommand MENUITEM <cItem> [ ICON <cIcon> ] [ ROUTE <cRoute> ] [ ACTIVE <lActive>  ] OF <oNav>  => <oNav>:AddMenuItem( <cItem>, [<cRoute>], [<cIcon>], nil, .f., .f., .f.,.f.,[<lActive>]  )
#xcommand MENUITEM SEPARATOR OF <oNav>  => <oNav>:AddMenuItemSeparator()

#xcommand HTML SIDEBAR OF <oNav> => #pragma __cstream| <oNav>:SideBar( %s )

#xcommand HTML SIDEBAR OF <oNav> PARAMS [<v1>] [,<vn>] ;
=> ;
	#pragma __cstream |<oNav>:Sidebar( UInlinePrg( UReplaceBlocks( %s, '<$', "$>" [,<(v1)>][+","+<(vn)>] [, @<v1>][, @<vn>] ) ) )



		 
#xcommand FOLDER [<oFolder>] [ ID <cId> ] ;
		[ <tabs: TABS> <cTab,...> ] ;		
		[ <prm: PROMPT, PROMPTS, ITEMS> <cPrompt,...> ] ;		
		[ GRID <nGrid> ] ;
		[ OPTION <cOption> ] ;
		[ <lAdjust: ADJUST> ] ;
		[ CLASS <cClass> ] [ FONT <cFont> ] ;	
		OF <oForm> ;
=> ;
	[ <oFolder> := ] TWebFolder():New( <oForm>, [<cId>], [\{<cTab>\}], [\{<cPrompt>\}], [<nGrid>], [<cOption>], [<.lAdjust.>] , [<cClass>], [<cFont>]) 

#xcommand DEFINE TAB <cId> [ <lFocus: FOCUS> ] [ CLASS <cClass> ] OF <oFld> => <oFld>:AddTab( <cId>, [<.lFocus.>], [<cClass>] )
#xcommand ENDTAB <oFld> => <oFld>:End()
#xcommand ENDFOLDER <oFld> => <oFld>:End()	

//	--------------------------------------------------------


#xcommand DEFINE BROWSE [<oBrw>] [ ID <cId> ] [OPTIONS <hOptions>] [ EVENTS <aEvents>]  ;
	[ FILTER <aFilter> ] [ FILTER_ID <cFilter_id> ] [ TITLE <cTitle> ] [ <lAll: ALL> ] ; 
	[ CLASS <cClass> ] [ STYLE <cStyle> ] [ <hi: HIDE, HIDDEN> ] ;	
	OF <oForm> ;
=> ;
	[ <oBrw> := ] TWebBrowse():New( <oForm>, [<cId>], <hOptions>, [<aEvents>], [<aFilter>], [<cFilter_id>], [<cTitle>], [<.lAll.>], [<cClass>], [<cStyle>], [<.hi.>] )
	

#xcommand COL <oCol> TO <oBrw> CONFIG <hConfig> ;
=> ;						
	<oCol> := <oBrw>:AddCol( <hConfig> )
	

#xcommand INIT BROWSE <oBrw> [ DATA <aRows> ] ;
=> ;
	<oBrw>:Init( [<aRows>] )	

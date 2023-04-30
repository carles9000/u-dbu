<!-- Bootstrap files... -->

	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">	
	
	<script src="https://code.jquery.com/jquery-3.6.0.js"></script>
	<script src="https://cdn.jsdelivr.net/npm/popper.js@1.12.9/dist/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>
	<link href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" rel="stylesheet">
	<script src="https://code.jquery.com/ui/1.13.1/jquery-ui.js"></script>
	
	<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.8.2/css/all.css">

<!-- TWeb environment -->

	<!--<script src="notify/bootstrap-notify.js"></script>-->
	<script src="https://cdnjs.cloudflare.com/ajax/libs/bootbox.js/5.5.3/bootbox.min.js"></script>
	<link href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/3.7.2/animate.min.css" rel="stylesheet">
	
	
	<script src="{{ hb_GetEnv( "ROOTRELATIVE") }}files/tweb/notify/bootstrap-notify.js"></script>
	<script src="{{ hb_GetEnv( "ROOTRELATIVE") }}files/tweb/bootbox/bootbox.all.min.js"></script>
	
			
	<!-- LIGTHBOX -->
		<script src="{{ hb_GetEnv( "ROOTRELATIVE") }}files/tweb/lightbox/lightbox.js"></script>
		<link href="{{ hb_GetEnv( "ROOTRELATIVE") }}files/tweb/lightbox/css/lightbox.css" rel="stylesheet" >		
		
	<!-- SIDEBAR -->
	
		<script src="{{ hb_GetEnv( "ROOTRELATIVE") }}files/tweb/sidebar/js/jquery.sidebar.js"></script>
		<script src="{{ hb_GetEnv( "ROOTRELATIVE") }}files/tweb/sidebar/js/handlers.js"></script>
		<link href="{{ hb_GetEnv( "ROOTRELATIVE") }}files/tweb/sidebar/css/styles.css" rel="stylesheet" >		

	
	<!-- TWEB -->
	
		<script src="{{ hb_GetEnv( "ROOTRELATIVE") }}files/tweb/tweb.js"></script>
		<link href="{{ hb_GetEnv( "ROOTRELATIVE") }}files/tweb/tweb.css" rel="stylesheet" >		
	

	<!-- Httpd2 environment -->
			
		<!-- Only this files because, jquery was loaded with bootstrap... -->
		<!-- TABULATOR, System Grid -->
		
			<!--<link href="https://unpkg.com/tabulator-tables@5.4.3/dist/css/tabulator.min.css" rel="stylesheet">-->
			<!--<link href="https://unpkg.com/tabulator-tables@5.4.3/dist/css/tabulator_bootstrap5.min.css" rel="stylesheet">-->
			<!--<link href="https://unpkg.com/tabulator-tables@5.4.3/dist/css/tabulator_midnight.min.css" rel="stylesheet">-->
			<link href="https://unpkg.com/tabulator-tables@5.4.3/dist/css/tabulator_bootstrap4.min.css" rel="stylesheet">
			
			<script type="text/javascript" src="https://unpkg.com/tabulator-tables@5.4.3/dist/js/tabulator.min.js"></script>
			<script type="text/javascript" src="{{ hb_GetEnv( "ROOTRELATIVE") }}files/uhttpd2/moment/moment.js"></script> 
		
		<!-- -->

		<script src="{{ hb_GetEnv( "ROOTRELATIVE") }}files/uhttpd2/uhttpd2.min.js"></script>
		<script src="{{ hb_GetEnv( "ROOTRELATIVE") }}files/uhttpd2/uhttpd2.tabulator.js"></script>
		<link href="{{ hb_GetEnv( "ROOTRELATIVE") }}files/uhttpd2/uhttpd2.css" rel="stylesheet" >		

	<!-- ------------------ -->		
	
		
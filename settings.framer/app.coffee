#author Sergiy Voronov twitter.com/mamezito
# This imports all the layers for "1" into 1Layers
sketch = Framer.Importer.load "imported/1"


bg = new BackgroundLayer
	image: "images/bg.png"
	
# i am creating status header which will host wifi, cell, battery,account icons and placing in top with transparent background
statusHeader=new Layer
	width: 1040
	height: 178
	x:20
	y:0
	backgroundColor: null

#creating layer for header with grey background, which will host or date time information
header= new Layer
	width: 1040
	height: 355
	backgroundColor: "#384248"
	y:-177
header.style.boxShadow = "10px 0px 15px 10px rgba(0,0,0,0.2)"

#moving statusbar object from sketch to statusbar layer in framer
sketch.status_bar.superLayer=statusHeader
sketch.status_bar.x=55
sketch.status_bar.y=40

header.centerX()

#creating layer which will host android settings icons and moving it to top
drawer= new Layer
	width:1040
	height:1522
	y:-1320
	backgroundColor:"#263238"

#creating two states for drawer, which we wil animate in future, one state will be with layer moved to very top position, second one - it will be maximum expanded to bottom
drawer.states.add
		collapsed:
			 y:-1320
		expanded:
			y:0


drawer.animationOptions=
	curve: "spring(300, 20, 0)"
		
			
			
drawer.style.boxShadow = "10px 0px 15px 10px rgba(0,0,0,0.2)"
drawer.centerX()


#moving imported from sketch object with settings to "drawer" layer in framer
sketch.drawer.superLayer=drawer

#better positioning of objects on the screen according to layout
sketch.drawer.x=85
sketch.drawer.y=450
sketch.time.originX=0
sketch.time.originY=1
sketch.rightstatus.x=650
sketch.settings.opacity=0
sketch.settings.x=770

#on default battery percentage will be hidden with opacity 0, and we will show it when drawer will be moving
sketch.percent.opacity=0

#assigning datetime object from sketch to "header layer in framer"
sketch.datetime.superLayer=header
sketch.datetime.x=40
sketch.datetime.y=210

#moving header to front so it will overlap drawer
header.bringToFront()

#moving statusheader on top of all framer layers
statusHeader.bringToFront()

#making drawer layer  vertical draggable within constraints
drawer.draggable.enabled=true
drawer.draggable.horizontal=false
drawer.draggable.constraints=
	 x:0
	 y:-1320
	 width: 1055
	 height:2842
	 
#we are using event check on drawer, so when it starts move we are firing some more functions
drawer.on "change:point",->
	#depending on bottom line Y coordinate of "drawer" we are moving header with date time also
	header.y=Utils.modulate(drawer.maxY,[180,1522],[-177,0], true)
	
	#depending on bottom line of "drawer" we are moving all status icons from left to right
	sketch.rightstatus.x=Utils.modulate(drawer.maxY,[180,1522],[650,355], true)
	
	#when drawer will be dragged to bottom, we are hiding reception and wifi icons
	sketch.reception.opacity=Utils.modulate(drawer.maxY,[180,1322],[1,0], true)
	sketch.wifi.opacity=Utils.modulate(drawer.maxY,[180,1322],[1,0], true)
	
	# at same time we are starting to show percentage of battery usage and settings icon
	sketch.percent.opacity=Utils.modulate(drawer.maxY,[480,1522],[0,1], true)
	sketch.settings.opacity=Utils.modulate(drawer.maxY,[680,1522],[0,1], true)
	
	#we are moving settings icon with rotation from right to left, while we drag "drawer" to bottom
	sketch.settings.x=Utils.modulate(drawer.maxY,[680,1522],[770,680], true)
	sketch.settings.rotation=Utils.modulate(drawer.maxY,[680,1522],[0,180], true)
	
	#when "drawer" is dragged to bottom, we are enlarging size of the time object
	sketch.time.scale=Utils.modulate(drawer.maxY,[180,1522],[1,2], true)
	
	
#when we dragging of the "drawer" stops, we are firing some condition checks
drawer.on Events.DragEnd, ->
	
	#if we were dragging to top, even a little, drawer jumps to collapsed state with spring animation we defined above
	if this.draggable.direction is "up"
		this.states.switch("collapsed")
	
	
	else
		#when we are dragging to bottom and we dragged drawer bottom line more then 500px from top of the screen, drawer automaticly jumps to expanded state
		if drawer.maxY > 500 
			this.states.switch("expanded")
			
		#if less then 500px then jumping back to top
		else
			this.states.switch("collapsed")

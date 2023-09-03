#define rank (stat(2350)+1)
#define knifes "mp/knifetable.csv"

#ifndef BUTTON_ALIGN
	#define BUTTON_ALIGN 0 0
#endif

#define DR_BUTTON( id, x, y, w, h, itemName, itemAction, visArg ) \
		DR_BUTTON_EXT( id, x, y, w, h, itemName, itemAction, ;, ;, visArg )

#define DR_BUTTON_EXT( id, x, y, w, h, itemName, itemAction, onItemEnter, onItemExit, visArg ) \
itemDef \
{ \
	visible			visArg \
	name			"button_default"id \
	rect			x y h w BUTTON_ALIGN \
	style			WINDOW_STYLE_FILLED \
	forecolor		1 1 1 0.7 \ 
	border			1 \
	bordercolor		.2 .2 .2 .55 \
	backcolor		0 0 0 0.6 \
} \
itemDef \
{ \
	visible			visArg \
	name			"button_over"id \
	rect			x y w h BUTTON_ALIGN \
	style			WINDOW_STYLE_FILLED \
	forecolor		1 1 1 1 \ 
	border			1 \
	bordercolor		.2 .2 .2 .55 \
	backcolor		0 0 0 0.8 \
} \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		x y w h BUTTON_ALIGN \
	exp			text( itemName ) \
	type		ITEM_TYPE_BUTTON \
	textfont	UI_FONT_NORMAL \
	textstyle	ITEM_TEXTSTYLE_SHADOWED \
	textalign	ITEM_ALIGN_CENTER \
	textscale	0.4 \
	textalignx	0 \
	textaligny	(h-1) \
	visible		visArg \
	mouseEnter \
	{ \
		play "mouse_over"; \
		show "button_over"id; \
		hide "button_default"id; \
		onItemEnter \
	} \
	mouseExit \
	{ \
		hide "button_over"id; \
		show "button_default"id; \
		onItemExit \
	} \
	action \
	{ \
		play "mouse_click"; \
		itemAction \
	} \
}

#define MENU_BUTTON( id, x, y, w, h, itemName, itemAction, visArg ) \
		MENU_BUTTON_EXT( id, x, y, w, h, itemName, itemAction, ;, ;, visArg )

#define MENU_BUTTON_EXT( id, x, y, w, h, itemName, itemAction, onItemEnter, onItemExit, visArg ) \
itemDef \
{ \
	visible			visArg \
	name			"button_over"id \
	rect			x y w h BUTTON_ALIGN \
	style			WINDOW_STYLE_FILLED \
	forecolor		1 1 1 0.7 \ 
	border			1 \
	bordercolor		.2 .2 .2 .55 \
	backcolor		0 0 0 0.8 \
} \
itemDef \
{ \
	visible			visArg \
	name			"button_default"id \
	rect			x y w h BUTTON_ALIGN \
	style			WINDOW_STYLE_FILLED \
	forecolor		1 1 1 0.7 \ 
	border			1 \
	bordercolor		.2 .2 .2 .55 \
	backcolor		0 0 0 0.6 \
} \
itemDef \
{ \
	rect		x y w h BUTTON_ALIGN \
	exp			text( itemName ) \
	type		ITEM_TYPE_BUTTON \
	textfont	UI_FONT_DEFAULT \
	textstyle	ITEM_TEXTSTYLE_NORMAL \
	textalign	ITEM_ALIGN_CENTER \
	textscale	0.3 \
	textalignx	0 \
	textaligny	(h-2) \
	visible		visArg \
	style		WINDOW_STYLE_FILLED \
	mouseEnter \
	{ \
		play "mouse_over"; \
		show "button_over"id; \
		hide "button_default"id; \
		onItemEnter \
	} \
	mouseExit \
	{ \
		hide "button_over"id; \
		show "button_default"id; \
		onItemExit \
	} \
	action \
	{ \
		play "mouse_click"; \
		itemAction \
	} \
}

#define KNIFE_BUTTON( id, x, y, itemID ) \
itemDef \
{ \
	visible			1 \
	name			"button_over"id \
	rect			x y 280 20 BUTTON_ALIGN \
	style			WINDOW_STYLE_FILLED \
	forecolor		1 1 1 0.7 \ 
	border			1 \
	bordercolor		.2 .2 .2 .55 \
	backcolor		0 0 0 0.8 \
} \
itemDef \
{ \
	visible			1 \
	name			"button_default"id \
	rect			x y 280 20 BUTTON_ALIGN \
	style			WINDOW_STYLE_FILLED \
	forecolor		1 1 1 0.7 \ 
	border			1 \
	bordercolor		.2 .2 .2 .55 \
	backcolor		0 0 0 0.6 \
} \
itemDef \
{ \
	rect		x y 280 20 BUTTON_ALIGN \
	exp			text(tableLookup(knifes,0,itemID,4)) \
	type		ITEM_TYPE_BUTTON \
	textfont	UI_FONT_DEFAULT \
	textstyle	ITEM_TEXTSTYLE_NORMAL \
	textalign	ITEM_ALIGN_CENTER \
	textscale	0.3 \
	textalignx	0 \
	textaligny	18 \
	visible		when( rank >= tableLookup(knifes,0,itemID,2) ) \
	style		WINDOW_STYLE_FILLED \
	mouseEnter \
	{ \
		play "mouse_over"; \
		show "button_over"id; \
		hide "button_default"id; \
	} \
	mouseExit \
	{ \
		hide "button_over"id; \
		show "button_default"id; \
	} \
	action \
	{ \
		play "mouse_click"; \
		scriptMenuResponse itemID; \
	} \
} \
itemDef \
{ \
	rect		x y 280 20 BUTTON_ALIGN \
	exp			text("^1"+tableLookup(knifes,0,itemID,4)) \
	type		ITEM_TYPE_BUTTON \
	textfont	UI_FONT_DEFAULT \
	textstyle	ITEM_TEXTSTYLE_NORMAL \
	textalign	ITEM_ALIGN_CENTER \
	textscale	0.3 \
	textalignx	0 \
	textaligny	18 \
	visible		when( rank < tableLookup(knifes,0,itemID,2) ) \
	style		WINDOW_STYLE_FILLED \
	mouseEnter \
	{ \
		play "mouse_over"; \
		show "button_over"id; \
		hide "button_default"id; \
	} \
	mouseExit \
	{ \
		hide "button_over"id; \
		show "button_default"id; \
	} \
} \
itemDef \
{ \
	rect		(x+70) y 280 20 BUTTON_ALIGN \
	exp			text("^1("+tableLookup(knifes,0,itemID,2)+")") \
	type		ITEM_TYPE_BUTTON \
	textfont	UI_FONT_DEFAULT \
	textstyle	ITEM_TEXTSTYLE_NORMAL \
	textalign	ITEM_ALIGN_CENTER \
	textscale	0.3 \
	textalignx	0 \
	textaligny	18 \
	visible		when( rank < tableLookup(knifes,0,itemID,2) ) \
	style		WINDOW_STYLE_FILLED \
} 

#define ADM_PLAYER_CHOICE(x, y, w, h, itemName, itemAction ) \
itemDef \
{ \
	style		WINDOW_STYLE_FILLED \
	rect		x y w h BUTTON_ALIGN \
	forecolor	1 1 1 0.85 \
	exp			text( itemName ) \
	type		ITEM_TYPE_BUTTON \
	textfont	UI_FONT_NORMAL \
	textstyle	ITEM_TEXTSTYLE_SHADOWED \
	textalign	ITEM_ALIGN_LEFT \
	textscale	0.3 \
	textalignx	0 \
	textaligny	(h-1) \
	visible		1 \
	mouseEnter \
	{ \
		play "mouse_over"; \
	} \
	action \
	{ \
		scriptMenuResponse itemAction; \
	} \
} 
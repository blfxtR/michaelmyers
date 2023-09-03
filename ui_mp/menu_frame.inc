		// background
		itemDef 
		{
			rect			175 40 300 400
			style			WINDOW_STYLE_FILLED
			border			1
			bordercolor		.2 .2 .2 .55
			forecolor		1 1 1 1
			backcolor		0 0 0 0.6
			visible 		1
			decoration
		}	

		itemDef
		{
			rect			177 42 298 25
			style			WINDOW_STYLE_FILLED
			forecolor		1 1 1 1
			backcolor		0 0 0 0.8
			visible			1 
			decoration
		}

		itemDef
		{
			rect			250 75 150 120
			forecolor		1 1 1 1
			style			WINDOW_STYLE_SHADER
			background		"$levelBriefing"
			visible 		1
			border			1
			borderColor		.2 .2 .2 .55
			decoration
		}
		itemDef
		{
			rect			250 193 150 20
			style			WINDOW_STYLE_FILLED
			border			1
			bordercolor		.2 .2 .2 .55
			forecolor		1 1 1 1
			backcolor		0 0 0 0.6
			visible 		1
			decoration
		}

		itemDef
		{
			rect			325 211 1 1
			forecolor		1 1 1 1
			visible 		1
			exp				text(dvarstring("mapname"))
			textfont		UI_FONT_NORMAL
			textalign		ITEM_ALIGN_CENTER
			textscale		0.35
			decoration
		}

		itemDef 
		{
			rect			177 220 298 1
			style			WINDOW_STYLE_SHADER
			background		"white"
			forecolor		.2 .2 .2 .55
			visible			1
			decoration
		}
		
		itemDef 
		{
			rect			177 350 298 1
			style			WINDOW_STYLE_SHADER
			background		"white"
			forecolor		.2 .2 .2 .55
			visible			1
			decoration
		}
			
		itemDef
		{
			visible			1
			rect 			325 64 1 1
			forecolor		1 1 1 1
			exp				text("Michael Myers Mod ^10.3")
			textfont		UI_FONT_NORMAL
			textalign		ITEM_ALIGN_CENTER
			textscale		0.4
			decoration
		}

		itemDef
		{
			visible			1
			rect			170 355 300 150
			forecolor		1 1 1 1
			autowrapped
			exp				text("Michael Myers ^10.3a^7 is currently under Development and can look diffrent in near Future! If you notice any Mistakes or Bugs report them at ^1forum.vistic-clan.net")
			textfont		UI_FONT_DEFAULT
			textscale		.3
			textalignx		8
			textaligny		16
			textalign		ITEM_ALIGN_CENTER
			decoration
		}

		itemDef
		{
			visible			1
			origin			330 435
			forecolor		1 1 1 1
			text            "Mod by ^1Blade"
			textfont		UI_FONT_NORMAL
			textalign		ITEM_ALIGN_CENTER
			textscale		0.25
			decoration
		}


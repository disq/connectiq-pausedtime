using Toybox.WatchUi;
using Toybox.Graphics;

class pausedtimeView extends WatchUi.DataField {

	hidden var hasBackgroundColorOption = false;
	hidden var mValue;

	hidden var labelText, labelFont, labelPos;

	// Use the first element if we're going to show "MM:(ss)", second one for "HH:MM:(ss)"
	hidden var valuePos = [ [ 0, 0 ], [ 0, 0 ] ]; // Position for values (without seconds)
	hidden var secondsPos = [ [ 0, 0 ], [ 0, 0 ] ]; // Position for seconds part

	hidden var fontIndex = 0;
	hidden var canShowSeconds = false;

	hidden var labelFonts = [ Graphics.FONT_SYSTEM_SMALL, Graphics.FONT_SYSTEM_SMALL, Graphics.FONT_SYSTEM_TINY ];
	hidden var valueFonts = [ Graphics.FONT_SYSTEM_NUMBER_MEDIUM, Graphics.FONT_SYSTEM_NUMBER_MILD, Graphics.FONT_SYSTEM_SMALL ];
	hidden var secondsFonts = [ Graphics.FONT_SYSTEM_NUMBER_MILD, Graphics.FONT_SYSTEM_SMALL, Graphics.FONT_SYSTEM_TINY ];
	hidden var paddings = [ 6, 4, 2 ];

	const VALUE_DISABLED = -1.0f;

	function initialize() {
		DataField.initialize();

		hasBackgroundColorOption = (self has :getBackgroundColor);
		mValue = VALUE_DISABLED;
	}

	// Set your layout here. Anytime the size of obscurity of
	// the draw context is changed this will be called.
	function onLayout(dc) {
		var width = dc.getWidth();
		var height = dc.getHeight();
		var halfWidth = Math.floor(width / 2);

		// Label things (except labelFont which is set below)
		labelText = WatchUi.loadResource(Rez.Strings.label);
		labelPos = [ halfWidth, 3 ];

		for (var i = 0; i < valueFonts.size(); i++) {
			var textWidth = dc.getTextWidthInPixels("88:88", valueFonts[i]);
			var spaceLeft = width - textWidth - paddings[i];
			if (spaceLeft <= 0) {
				continue;
			}

			// Found our font, calculate positions
			fontIndex = i;
			var secondsWidth = dc.getTextWidthInPixels(":88", secondsFonts[i]);
			var textHeight = dc.getFontHeight(valueFonts[i]);

			// Positions for MM:(ss) first. Y pos doesn't change.
			var halfWidth = dc.getTextWidthInPixels("88", valueFonts[i]);
			valuePos[0] = [ Math.floor((width - halfWidth - secondsWidth) / 2), Math.floor((height - textHeight) / 2) + 14 ];

			var secondsPosY = valuePos[0][1] - 7 + textHeight - dc.getFontHeight(secondsFonts[i]); // align seconds vertically to bottom of line
			secondsPos[0] = [ valuePos[0][0] + halfWidth, secondsPosY ];

			// Do HH:MM(:ss) this time
			canShowSeconds = (spaceLeft >= secondsWidth * 2); // spaceLeft includes space on both sides
			if (!canShowSeconds) {
				secondsWidth = 0;
			}

			valuePos[1] = [ Math.floor((width - textWidth - secondsWidth) / 2), valuePos[0][1] ];
			secondsPos[1] = [ valuePos[1][0] + textWidth, secondsPosY ];
			break;
		}

		return true;
	}

	// The given info object contains all the current workout information.
	// Calculate a value and save it locally in this method.
	// Note that compute() and onUpdate() are asynchronous, and there is no
	// guarantee that compute() will be called before onUpdate().
	function compute(info) {
		// See Activity.Info in the documentation for available information.

		if (info == null || info.timerTime == null || info.elapsedTime == null) {
			mValue = VALUE_DISABLED;
		} else {
			mValue = info.elapsedTime - info.timerTime;
		}

	}

	// Display the value you computed here. This will be called
	// once a second when the data field is visible.
	function onUpdate(dc) {
		var backgroundColor, textColor;

		if (hasBackgroundColorOption) {
			backgroundColor = getBackgroundColor();
			if (backgroundColor == Graphics.COLOR_BLACK) {
				// night
				textColor = Graphics.COLOR_WHITE;
			} else {
				// daylight
				textColor = Graphics.COLOR_BLACK;
			}
		} else {
			backgroundColor = Graphics.COLOR_WHITE;
			textColor = Graphics.COLOR_BLACK;
		}

		var text, secondsText;
		var ignoreHours = true;

		if (mValue == VALUE_DISABLED || mValue < 0.0f) {
			text = "__:__"; // A good placeholder to keep it centered
			secondsText = "";
			ignoreHours = false;
		} else {
			var secs = mValue / 1000.0f;
			var mins = Math.floor(secs / 60.0f);
			secs -= mins * 60;
			var hrs = Math.floor(mins / 60.0f);
			mins -= hrs * 60;
			// var days = Math.floor(hrs / 24.0f);
			// hrs -= days * 24;

			ignoreHours = hrs == 0 && !canShowSeconds;
			hrs = hrs.toLong() % 100; // Modulus 100 so we look good even after being paused for 100 hours

			secondsText = ":" + secs.format("%02u");

			if (ignoreHours) {
				text = mins.format("%02u");
			} else {
				text = Lang.format("$1$:$2$", [hrs.format("%02u"), mins.format("%02u")]);
			}
		}

		dc.setColor(textColor, backgroundColor);
		dc.clear();
		dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);

		// Label
		dc.drawText(labelPos[0], labelPos[1], labelFonts[fontIndex], labelText, Graphics.TEXT_JUSTIFY_CENTER);

		// Value
		var posIdx = ignoreHours ? 0 : 1;

		dc.drawText(valuePos[posIdx][0], valuePos[posIdx][1], valueFonts[fontIndex], text, Graphics.TEXT_JUSTIFY_LEFT);

		if (canShowSeconds || ignoreHours) {
			dc.drawText(secondsPos[posIdx][0], secondsPos[posIdx][1], secondsFonts[fontIndex], secondsText, Graphics.TEXT_JUSTIFY_LEFT);
		}
	}

}

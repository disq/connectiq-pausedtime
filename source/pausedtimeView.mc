using Toybox.WatchUi;
using Toybox.Graphics;

class pausedtimeView extends WatchUi.DataField {

    hidden var hasBackgroundColorOption = false;
    hidden var mValue;
    hidden var width;

	hidden var labelFonts = [ Graphics.FONT_SYSTEM_SMALL, Graphics.FONT_SYSTEM_SMALL, Graphics.FONT_SYSTEM_TINY ];
	hidden var valueFonts = [ Graphics.FONT_SYSTEM_NUMBER_MEDIUM, Graphics.FONT_SYSTEM_NUMBER_MILD, Graphics.FONT_SYSTEM_SMALL ];
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
        View.setLayout(Rez.Layouts.MainLayout(dc));

        // "Centered" manual layout
        var labelView = View.findDrawableById("label");

        var valueView = View.findDrawableById("value");
        valueView.locY = valueView.locY + 14;

        labelView.setText(Rez.Strings.label);
        width = dc.getWidth();
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

		// Set the background color
		View.findDrawableById("Background").setColor(backgroundColor);

		// Set label color
		var label = View.findDrawableById("label");
		label.setColor(textColor);

		// Set the foreground color and value
		var value = View.findDrawableById("value");
		value.setColor(textColor);

		var text;
		var zeroHours = true;

		if (mValue == VALUE_DISABLED || mValue < 0.0f) {
			text = "-";
			zeroHours = false;
		} else {
	        var secs = mValue / 1000.0f;
	        var mins = Math.floor(secs / 60.0f);
	        secs -= mins * 60;
	        var hrs = Math.floor(mins / 60.0f);
	        mins -= hrs * 60;
	        var days = Math.floor(hrs / 24.0f);
	        hrs -= days * 24;

			// Only show days if we've paused more than a day
			// Show hours, but strip them if there isn't enough space and we've paused less than an hour

			if (days > 0) {
				text = Lang.format("$1$:$2$:$3$:$4$", [days.format("%u"), hrs.format("%02u"), mins.format("%02u"), secs.format("%02u")]);
				zeroHours = false;
			} else if (hrs > 0) {
				text = Lang.format("$1$:$2$:$3$", [hrs.format("%02u"), mins.format("%02u"), secs.format("%02u")]);
				zeroHours = false;
			} else {
				text = Lang.format("$1$:$2$", [mins.format("%02u"), secs.format("%02u")]);
			}
		}

		// Iterate font options from biggest to smallest
		for (var i = 0; i < valueFonts.size(); i++) {
			var dimensions = dc.getTextDimensions(text, valueFonts[i]);
			var spaceLeft = width - dimensions[0] - paddings[i];
			if (spaceLeft <= 0) {
				continue;
			}

			if (zeroHours) { // Prepend "00:" if we have enough space
				var zeroDims = dc.getTextDimensions("00:", valueFonts[i]);
				if (spaceLeft > zeroDims[0]) {
					text = "00:" + text;
				}
			}

			value.setFont(valueFonts[i]);
			label.setFont(labelFonts[i]);
			break;
		}

		value.setText(text);        

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}

using Toybox.WatchUi;
using Toybox.Graphics;

class pausedtimeView extends WatchUi.DataField {

    hidden var mValue;

    function initialize() {
        DataField.initialize();
        mValue = -1.0f;
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
        var obscurityFlags = DataField.getObscurityFlags();

        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            var labelView = View.findDrawableById("label");
            labelView.locY = labelView.locY - 16;
            var valueView = View.findDrawableById("value");
            valueView.locY = valueView.locY + 7;
        }

        View.findDrawableById("label").setText(Rez.Strings.label);
        return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.

       if (info == null || info.timerTime == null || info.elapsedTime == null) {
        	mValue = -1.0f;
        } else {
        	mValue = info.elapsedTime - info.timerTime;
    	}

    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        // Set the background color
        View.findDrawableById("Background").setColor(getBackgroundColor());

        // Set the foreground color and value
        var value = View.findDrawableById("value");
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            value.setColor(Graphics.COLOR_WHITE);
        } else {
            value.setColor(Graphics.COLOR_BLACK);
        }
        
        if (mValue < 0) {
        	value.setText("N/A");
	        View.onUpdate(dc);
	        return;
        }
        
        var secs = mValue / 1000.0f;
        var mins = Math.floor(secs / 60.0f);
        secs -= mins * 60;
        var hrs = Math.floor(mins / 60.0f);
        mins -= hrs * 60;
        var days = Math.floor(hrs / 24.0f);
        hrs -= days * 24;

		var text;
		if (days > 0) {
		 	text = Lang.format("$1$:$2$:$3$:$4$", [days.format("%u"), hrs.format("%02u"), mins.format("%02u"), secs.format("%02u")]);
	 	} else if (hrs > 0) {
		 	text = Lang.format("$1$:$2$:$3$", [hrs.format("%02u"), mins.format("%02u"), secs.format("%02u")]);
		} else {
		 	text = Lang.format("$1$:$2$", [mins.format("%02u"), secs.format("%02u")]);
		}

		value.setText(text);        

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}

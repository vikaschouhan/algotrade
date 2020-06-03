//@version=4
study("ROC MTF", "ROC MTF", overlay=false)
time_frame = input(defval='1D', type=input.resolution, title='Time Frame')
period     = input(defval=14,   type=input.integer,    title='Loopback Period')

// Calculate roc for time frame
roc_t      = security(syminfo.tickerid, time_frame, roc(close, period))

// Plot
plot(roc_t, color=color.blue, title='ROC MTF')

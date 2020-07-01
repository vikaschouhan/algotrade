//@version=4
study(title="ROC trend strength", overlay=false)

////////////////////////////////////////////////////////////////////////////////
// Inputs
roc_source      = input(defval=close,     title='ROC Source', type=input.source)
roc_length      = input(defval=2,         title='ROC Loopback Length', type=input.integer, minval=1)
roc_pct_change  = input(defval=10,        title='ROC Percentage change threshold', type=input.integer, minval=1)
roc_tf          = input(defval='1D',      title='ROC Time Frame', type=input.resolution)

/////////////////////////////////////////////////////////////////////////////////
// Calculate indicators
roc_org_t       = 100 * (roc_source - roc_source[roc_length])/roc_source[roc_length]
roc_ema_t       = ema(roc_org_t, roc_length/2)
ind_eroc_t      = security(syminfo.tickerid, roc_tf, roc_ema_t)

//////////////////////////////////////////////////////////////////////////////////
// Plots
plot(ind_eroc_t,          color=color.blue,  title='EROC')
plot(roc_pct_change/2,    color=color.black, title='UThr')
plot(-roc_pct_change/2,   color=color.black, title='LThr')

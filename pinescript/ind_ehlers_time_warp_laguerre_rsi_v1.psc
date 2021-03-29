//@version=4
study("Ehlers Laguerre RSI v1", overlay=false)

///////////////////////////////////////////////////
// Inputs
filt_gamma  = input(defval=0.8,      title="Gamma", type=input.float, step=0.1)
time_frame  = input(defval='1D',     title="Time Frame", type=input.resolution)
src         = input(defval=close,    title="Sourc", type=input.source)
ema_len     = input(defval=0,        title="RSI Smooth EMA Length", type=input.integer)

///////////////////////////////////////////////////
// Calculate Signals
LaguerreRSI_v1(gamma, src) =>
    L0  = src
    L1  = src
    L2  = src
    L3  = src
    L0  := (1-gamma)*src + gamma*nz(L0[1])
    L1  := -gamma*L0 + L0[1] + gamma*nz(L1[1])
    L2  := -gamma*L1 + L1[1] + gamma*nz(L2[1])
    L3  := -gamma*L2 + L2[1] + gamma*nz(L3[1])
    CU  = 0.0
    CD  = 0.0
    if (L0>=L1)
        CU := (L0-L1)
    else
        CD := (L1-L0)
    //
    if (L1>=L2)
        CU := CU + (L1-L2)
    else
        CD := CD + (L2-L1)
    //
    if (L2>=L3)
        CU := CU + (L2-L3)
    else
        CD := CD + (L3-L2)
    //
    CU_new = CU
    CD_new = CD
    if ema_len > 0
        CU_new := ema(CU, ema_len)
        CD_new := ema(CD, ema_len)
    //
    RSI = CU_new/(CU_new+CD_new)
//

filt_ind_t = LaguerreRSI_v1(filt_gamma, src)
filt_ind   = security(syminfo.tickerid, time_frame, filt_ind_t)

////////////////////////////////////////////////////////////
// Plots
plot(filt_ind, title='Laguerre RSI')

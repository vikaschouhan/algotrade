//@version=4
study("Ehlers Laguerre Filter v1", overlay=true)

///////////////////////////////////////////////////
// Inputs
filt_gamma  = input(defval=0.8,      title="Gamma", type=input.float, step=0.1)
time_frame  = input(defval='1D',     title="Time Frame", type=input.resolution)
src         = input(defval=close,    title="Sourc", type=input.source)

///////////////////////////////////////////////////
// Calculate Signals
Average_v1(L0, L1, L2, L3) =>
    (L0 + 2*L1 + 2*L2 + L3)/6
    
Average_v2(L0, L1, L2, L3) =>
    (L0 + L1 + L2 + L3)/4

Laguerre_v1(gamma, src) =>
    L0  = src
    L1  = src
    L2  = src
    L3  = src
    L0  := (1-gamma)*src + gamma*nz(L0[1])
    L1  := -gamma*L0 + L0[1] + gamma*nz(L1[1])
    L2  := -gamma*L1 + L1[1] + gamma*nz(L2[1])
    L3  := -gamma*L2 + L2[1] + gamma*nz(L3[1])
    Average_v1(L0, L1, L2, L3)
//

filt_ind_t = Laguerre_v1(filt_gamma, src)
filt_ind   = security(syminfo.tickerid, time_frame, filt_ind_t)

////////////////////////////////////////////////////////////
// Plots
plot(filt_ind, title='Laguerre Filter')

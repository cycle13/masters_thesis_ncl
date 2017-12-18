
;Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
;  a = addfile("/glade/scratch/acaruth/NSF_CLM/presettle/BL_data/wrfout_d02_all.nc","r")

  a1920s = addfile("/glade/scratch/acaruth/NSF_CLM/1920s/1920s.nc","r")

  apre = addfile("/glade/scratch/acaruth/NSF_CLM/presettle/presettle.nc","r")

  adust = addfile("/glade/scratch/acaruth/NSF_CLM/dust1930s/dustbowl.nc","r")

  amodern = addfile("/glade/scratch/acaruth/NSF_CLM/modernday/modern.nc","r")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; What times and how many time steps are in the data set?
  times = wrf_user_getvar(amodern,"times", -1)  ; get all times in the file
  ntimes = dimsizes(times)         ; number of times in the file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First get the variables we will need        
;temperature in K
;convert to C
;smooth a bit

   alb_1920s_raw = wrf_user_getvar(a1920s, "ALBEDO", -1) ;
        wrf_smooth_2d(alb_1920s_raw, 5)

   alb_pre_raw = wrf_user_getvar(apre, "ALBEDO", -1) ;
        wrf_smooth_2d(alb_pre_raw, 5)

   alb_dust_raw = wrf_user_getvar(adust, "ALBEDO", -1) ;
        wrf_smooth_2d(alb_dust_raw, 5)

   alb_modern_raw = wrf_user_getvar(amodern, "ALBEDO", -1) ;
        wrf_smooth_2d(alb_modern_raw, 5)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; differences modern - presettlement
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; We generate plots, but what kind do we prefer?
;  type = "x11"
;  type = "pdf"
  type = "png"
; type = "ncgm"
  wks = gsn_open_wks(type,"../../plots/modern_avg_albedo")

 gsn_define_colormap(wks,"NCV_banded")

 setvalues NhlGetWorkspaceObjectId()
    "wsMaximumSize" : 300000000
  end setvalues



; Set some basic resources
  res = True
  res@MainTitle                   = "REAL-TIME WRF"

  pltres = True
  mpres = True

mpGridAndLimbOn= True


mpres@mpGeophysicalLineColor = "Black"
  mpres@mpNationalLineColor    = "Black"
  mpres@mpUSStateLineColor     = "Black"
   mpres@mpGridLineColor        = "transparent"
   mpres@mpLimbLineColor        = "transparent"
   mpres@mpPerimLineColor       = "transparent"
  mpres@mpGeophysicalLineThicknessF = 2
  mpres@mpUSStateLineThicknessF = 2
  mpres@mpNationalLineThicknessF    = 2


pltres@PanelPlot = True      ; Indicate these plots are to be paneled.
res@NoHeaderFooter = True
pltres@NoTitles = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;loop thru each month (May-Aug)

m = (/0,1,2,3/)

letters  = (/"May", "June", "July", "August"/)

month_string = stringtochar(letters)

plots = new (4, graphic)

do ii = 0,0
   istart = 0 + ii*3
    iend = istart+3
    iplot = 0
do i = istart, iend

mon = m(i)
month = month_string(i,:)


 alb_modern = dim_avg_n(alb_modern_raw(mon::4,:,:), 0) ;average over month

 alb_pre = dim_avg_n(alb_pre_raw(mon::4,:,:), 0) ;average over month


   ; Plotting options for albedo
        opts = res
        opts@cnFillOn = True
	opts@lbLabelBarOn = False
	opts@gsnSpreadColorEnd = -3  ; End third from the last color in color map
        opts@ContourParameters = (/.24,.6, .02/)
        contour_alb= wrf_contour(amodern,wks,alb_modern,opts)
        delete(opts)
     
     mpres@tmXBLabelFontHeightF = 0.03
     mpres@tmYLLabelFontHeightF = 0.03
     plots(iplot) = wrf_map_overlays(amodern,wks,(/contour_alb/),pltres,mpres)


         delete(contour_alb)
      iplot = iplot + 1

    end do




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;panel time ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    pnlres                            = True
    pnlres@txString                   = "Mean Surface Albedo ~C~~Z75~Modern Day ~C~~Z25~ "
    pnlres@txFontHeightF               = 0.025
    pnlres@gsnPanelYWhiteSpacePercent = 5       ; Add white space b/w plots.
    pnlres@gsnPanelLabelBar           = True    ; Turn on common labelbar
    pnlres@lbLabelAutoStride          = True    ; Spacing of lbar labels.
    pnlres@lbBoxMinorExtentF          = 0.5
     pnlres@lbLabelFontHeightF         = 0.015
    pnlres@gsnPanelFigureStrings= (/"a)","b)","c)","d)"/) ; add strings to panel
  pnlres@amJust   = "TopLeft"
    gsn_panel(wks,(/plots/),(/2,2/),pnlres)

end do



end
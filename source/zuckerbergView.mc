using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.Application as App;
using Toybox.Time.Gregorian as Gregorian;

var ilast = 0; // letzter his wert
var iscreen = 1;
var breite, hoehe;
var i;
var fenix = false;
var live_km, live_kcal, live_stepsLive, live_stepsGoal, activity, acthis, returnVal; 

class CD extends Ui.ConfirmationDelegate {
    function onResponse(value) {
        if( value == 0 ) {
            returnVal = "Cancel/No";
            Ui.requestUpdate();            
        }
        else {
            returnVal = "Confirm/Yes";
            var app = App.getApp();
            App.getApp().clearProperties();
            kcal_his = 0;
            // jetzt noch letztes Update auf jetzt speichern
	        last_update =  Gregorian.now();
	        last_update = last_update.value();
	        app.setProperty(LASTUPDATE, last_update.toNumber());
	        seit_lastupdate = null;
            Ui.requestUpdate();
            
        }
    }
}


class zuckerbergView extends Ui.View {

    //! Load your resources here
    function onLayout(dc) {
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
    // aktivitäten global merken
       acthis    = ActivityMonitor.getHistory();
       activity  = ActivityMonitor.getInfo();
       live_stepsGoal = activity.stepGoal;
       live_stepsLive = activity.steps; 
       live_kcal      = activity.calories;
       live_km        = activity.distance.toFloat() / 100 / 1000; // distance is saved as cm --> / 100 / 1000 --> km
       breite = dc.getWidth();
       hoehe = dc.getHeight();
       
       if (hoehe > 200) {fenix = true;} 
       //Sys.println(breite);
       // history seit letztem aufruf starten
       //Sys.println(seit_lastupdate); 
       if (seit_lastupdate == null) {seit_lastupdate = 7;} 
       for (i = 0; i < seit_lastupdate; i++){
                if (acthis.size()> i){ // out of bounds
                    if (acthis[i] != null){ // nur wenn es den historysatz auch gibt
                         kcal_his  = kcal_his + acthis[i].calories; // history der kcal speichern
                        //Sys.println("loop1" + i);
                    }else{i = seit_lastupdate;} // Ende
                }     
       }
       seit_lastupdate = 0;


        // erstmal Bidschirm schwarz einfärben
        dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
        dc.fillRectangle(0, 0, 220, 220);
        dc.clear();
        
         if (iscreen == 1){      // heute
	        //kcal Zuckerberg
	         if (fenix){ // fenix
                           // dc,x,  y,  kcal     
	            zdraw_suggar(dc,29,160,0, "today"); // passt auf Fenix watch!
	         }else{ // Forerunner
	            zdraw_suggar(dc,22,120,0,"today"); // passt auf Square watch!
	         }
        }
        if (iscreen == 2){     
            //kcal Zuckerberg total
             if (fenix){ // fenix
                           // dc,x,  y,  kcal     
                zdraw_suggar(dc,29,160,kcal_his, "total"); // passt auf Fenix watch!
             }else{ // Forerunner
                zdraw_suggar(dc,22,120,kcal_his, "total"); // passt auf Square watch!
             }
        }
        else if (iscreen == 3) {
           var rand = Math.rand();         
               rand = rand % 4;
               //Sys.println(rand);
	          if (rand == 2){  
			          dc.setPenWidth(4);
			          for (var i = 0 ; i <= breite; i ++){
			            dc.setColor(COLORS[i%12], COLORS[i%12]);
			            dc.fillCircle(breite/2, hoehe, (breite+hoehe)-i*4);   
			          }  
			          dc.setPenWidth(1);
			          dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
			          dc.drawText(breite/2, hoehe/2 -35  ,Gfx.FONT_XTINY, "You have used this widget" , Gfx.TEXT_JUSTIFY_CENTER);
			          dc.drawText(breite/2, hoehe/2-18  ,Gfx.FONT_MEDIUM, ncount.toString() + " times" , Gfx.TEXT_JUSTIFY_CENTER);
			          dc.drawText(breite/2, hoehe/2 +10  ,Gfx.FONT_XTINY, "Please think about" , Gfx.TEXT_JUSTIFY_CENTER);
			          dc.drawText(breite/2, hoehe/2 +25  ,Gfx.FONT_XTINY, "a tiny PAYPAL donation" , Gfx.TEXT_JUSTIFY_CENTER);
			          dc.drawText(breite/2, hoehe/2 +40 , Gfx.FONT_TINY, "bit.ly/1J0K35Y" , Gfx.TEXT_JUSTIFY_CENTER);
			          if (fenix){ dc.drawText(breite/2, hoehe/2 +60 , Gfx.FONT_TINY, "Thank you!" , Gfx.TEXT_JUSTIFY_CENTER);}
			   } else {
			          dc.setPenWidth(1);
			          dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
			          dc.drawText(breite/2, hoehe/2 -45  ,Gfx.FONT_XTINY, "kcal History since:" , Gfx.TEXT_JUSTIFY_CENTER);
                      if (fenix){
                        dc.setColor(Gfx.COLOR_WHITE, fenix_purble);
                      }else{
                        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_PINK);
                      }  
                      dc.drawText(breite/2, hoehe/2-18  ,Gfx.FONT_LARGE, firstday.toString()  , Gfx.TEXT_JUSTIFY_CENTER);
                      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
                     // dc.drawText(breite/2, hoehe/2 +25  ,Gfx.FONT_XTINY, "plus max 7 days" , Gfx.TEXT_JUSTIFY_CENTER);
                     // dc.drawText(breite/2, hoehe/2 +45  ,Gfx.FONT_XTINY, "history" , Gfx.TEXT_JUSTIFY_CENTER);
               
			   }
}			            
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
        // Das hier einbauen? --> vivo active speichert anscheinend nicht ordentlich 

        //Sys.println("tttest");
         //var app = App.getApp();
        // app.setProperty(KCAL_HIS, kcal_his);
        // app.setProperty(COUNT_KEY, ncount);
    }

function zdraw_suggar(dc,x,y,kcal_his, subtitle){
    // gesamt kalorien ermitteln
    var kcal = 0;
    if (kcal_his == null) {kcal_his=0;}
    kcal = kcal_his.toNumber() + live_kcal.toNumber(); // + heutige kca
    var pieces = kcal / 18; // würfelzucker 4g = 18kcal
    var total = pieces;
    var xpos, ypos,col,row;    
    xpos = x;
    ypos = y;
    var suggarx = 10;
    var suggary = 6;
    var p100 = 0; 
    var p1k= 0;
    var p10k = 0;
    var delta_pieces = 0;
    var j=0;
    var rows_max = 0;
    
    
    if (fenix){
        rows_max = (y-60) / suggary; // max rows & cols
    }else{
        rows_max = (y-20) / suggary; // max rows & cols
    }
    var cols_max = (breite -x-20) /suggarx;
    
    //Sys.println("cmax=" + cols_max + "rowmax=" +rows_max);
    if (cols_max > rows_max) {cols_max = rows_max;} else{rows_max = cols_max;}
    //Sys.println(rows_max);
    row = 1;
    col = cols_max;
    // anzahl zucker in pyramide ermitteln
    var max_pieces = (cols_max+1)*(cols_max/2f);
    
    // jetzt die bunten Stückchen ermitteln.
    // wenn pyramide voll ist, dann erst 10er füllen, wenn wieder voll, 100er , wenn wieder voll tausender
    
    //Sys.println("pieces=" + pieces);
    
    while( pieces > max_pieces) {
     pieces = pieces - 100; 
     p100 = p100 +  1;
    }
    
    while( pieces+p100 > max_pieces) {
     p100 = p100 - 10;
     p1k = p1k +  1;
    }
    while( pieces+p100+p1k > max_pieces) {
     p1k = p1k - 10;
     p10k = p10k +  1;
    }    
    // jetzt wieder eins zurück bei bedarf
    while (pieces+p100+p1k+p10k > max_pieces){
      if (pieces >= 100) {pieces = pieces -100; p100++;}
      else if (p100 >= 10) {p100 = p100 -10; p1k++;}
      else if (p1k > 10) {p1k = p1k -10; p10k++;}
    } 
    
    //Sys.println("würfel anzahl=" + (p10k+p1k+p100+pieces));
    //Sys.println("max_pieces= " + max_pieces);
    //Sys.println("max_cols= " + cols_max);
    //Sys.println(" 5k=" + p10k + " 1k=" + p1k + " 100er=" + p100 + " 1er=" + pieces); 
    
    while (col >=1){ 
    for (var i = 0; i < col; i++){ // eine reihe zeichnen
        j ++;
        xpos = xpos + suggarx; 
        if (j<= p10k && p10k > 0) {dc.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_DK_BLUE);}
        else if (j<= (p10k + p1k) && p1k > 0) {dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_DK_GREEN);}
        else if (j<= (p10k + p1k + p100) && p100 > 0) {dc.setColor(Gfx.COLOR_PINK, Gfx.COLOR_PINK);}
        else if (j<= p10k + p1k + p100 + pieces) {dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);}
        if (j<=p10k+p1k+p100+pieces){
            dc.fillRectangle(xpos+1, ypos+1, suggarx-1, suggary-1);
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_LT_GRAY);
            dc.drawRectangle(xpos, ypos, suggarx, suggary);    
        }   
    }
    col = col - 1; // jetzt einen Zucker weniger
    xpos = x + (cols_max-col) * (suggarx/2);
    ypos = ypos- suggary;
    }
    
    // LEGENDE und WERTE schreiben ##################################################################
    //Sys.println(fenix);
    if (fenix){
            
            // Total
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(breite/2 , 38, Gfx.FONT_LARGE, "Zuckerberg", Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
            dc.drawText(breite/2 , 14, Gfx.FONT_XTINY, subtitle.toString() , Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
            // kcal
            dc.drawText(13 , 65, Gfx.FONT_XTINY, "kcal" , Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);
            dc.drawText(breite -13 , 65, Gfx.FONT_XTINY, kcal.toString() , Gfx.TEXT_JUSTIFY_RIGHT|Gfx.TEXT_JUSTIFY_VCENTER);
            // pieces
            dc.drawText(5 , 80, Gfx.FONT_XTINY, "pieces" , Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);     
            dc.drawText(breite-5, 80, Gfx.FONT_XTINY, total.toString() , Gfx.TEXT_JUSTIFY_RIGHT|Gfx.TEXT_JUSTIFY_VCENTER);
            //kg
            total = total / 250; // kg    
            dc.drawText(5 , 118, Gfx.FONT_XTINY, "kg" , Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);
            dc.drawText(breite -5 , 118, Gfx.FONT_XTINY, total.toString() , Gfx.TEXT_JUSTIFY_RIGHT|Gfx.TEXT_JUSTIFY_VCENTER);  
            // Liter Coke
            total = total / 0.068f; // Liter Coke
            total = total.toNumber();
            dc.drawText(3 , 103, Gfx.FONT_XTINY, "Liter Coke" , Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);
            dc.drawText(breite - 3 , 103, Gfx.FONT_XTINY, total.toString(), Gfx.TEXT_JUSTIFY_RIGHT|Gfx.TEXT_JUSTIFY_VCENTER);  
            
            // Legende
            dc.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_DK_BLUE);
            dc.fillRectangle(35, hoehe-34, suggarx-1, suggary-1);
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawRectangle(34, hoehe-35, suggarx, suggary);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(36+suggarx, hoehe-35, Gfx.FONT_XTINY, "10k", Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);  
            
            dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_DK_GREEN);
            dc.fillRectangle(breite/2- 11, hoehe-34, suggarx-1, suggary-1);
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawRectangle(breite/2-12, hoehe-35, suggarx, suggary);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(breite/2 -12 +suggarx, hoehe-35, Gfx.FONT_XTINY, "1k", Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);  
            
            dc.setColor(Gfx.COLOR_PINK, Gfx.COLOR_PINK);
            dc.fillRectangle(150, hoehe-34, suggarx-1, suggary-1);
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawRectangle(149, hoehe-35, suggarx, suggary);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(150+suggarx, hoehe-35, Gfx.FONT_XTINY, "100", Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);      
            
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
            dc.fillRectangle(65, hoehe-15, suggarx-1, suggary-1);
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawRectangle(64, hoehe-16, suggarx, suggary);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(65+suggarx, hoehe-16, Gfx.FONT_XTINY, "1pc(18kcal)", Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);
    
    }else{ // no fenix
            // Total
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(breite/2 , 10, Gfx.FONT_LARGE, "Zuckerberg", Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
            dc.drawText(breite/2 , 24, Gfx.FONT_XTINY, subtitle.toString() , Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
            // kcal
            dc.drawText(1 , 35, Gfx.FONT_XTINY, "kcal" , Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);
            dc.drawText(breite -5 , 35, Gfx.FONT_XTINY, kcal.toString() , Gfx.TEXT_JUSTIFY_RIGHT|Gfx.TEXT_JUSTIFY_VCENTER);
            // pieces
            dc.drawText(1 , 50, Gfx.FONT_XTINY, "pieces" , Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);     
            dc.drawText(breite-5, 50, Gfx.FONT_XTINY, total.toString() , Gfx.TEXT_JUSTIFY_RIGHT|Gfx.TEXT_JUSTIFY_VCENTER);
            //kg
            total = total / 250; // kg    
            dc.drawText(1 , 80, Gfx.FONT_XTINY, "kg" , Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);
            dc.drawText(breite -5 , 80, Gfx.FONT_XTINY, total.toString() , Gfx.TEXT_JUSTIFY_RIGHT|Gfx.TEXT_JUSTIFY_VCENTER);  
            // Liter Coke
            total = total / 0.068f; // Liter Coke
            total = total.toNumber();
            dc.drawText(1 , 65, Gfx.FONT_XTINY, "Liter Coke" , Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);
            dc.drawText(breite -5 , 65, Gfx.FONT_XTINY, total.toString(), Gfx.TEXT_JUSTIFY_RIGHT|Gfx.TEXT_JUSTIFY_VCENTER);  
            
            // Legende
            dc.setColor(Gfx.COLOR_DK_BLUE, Gfx.COLOR_DK_BLUE);
            dc.fillRectangle(15, hoehe-7, suggarx-1, suggary-1);
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawRectangle(14, hoehe-8, suggarx, suggary);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(16+suggarx, hoehe-8, Gfx.FONT_XTINY, "10k", Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);  
            
            dc.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_DK_GREEN);
            dc.fillRectangle(48, hoehe-7, suggarx-1, suggary-1);
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawRectangle(47, hoehe-8, suggarx, suggary);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(49+suggarx, hoehe-8, Gfx.FONT_XTINY, "1k", Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);  

            dc.setColor(Gfx.COLOR_PINK, Gfx.COLOR_PINK);
            dc.fillRectangle(74, hoehe-7, suggarx-1, suggary-1);
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawRectangle(73, hoehe-8, suggarx, suggary);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(75+suggarx, hoehe-8, Gfx.FONT_XTINY, "100", Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);      
            
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
            dc.fillRectangle(110, hoehe-7, suggarx-1, suggary-1);
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
            dc.drawRectangle(109, hoehe-8, suggarx, suggary);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(111+suggarx, hoehe-8, Gfx.FONT_XTINY, "1pcs(18kcal)", Gfx.TEXT_JUSTIFY_LEFT|Gfx.TEXT_JUSTIFY_VCENTER);      
    } // Ende Legende
} // Ende Zuckerberg    

} // ende hauptclasse

class zuckerbergViewDelegate extends Ui.BehaviorDelegate {
    function onKey(key) {
      // Sys.println("on key " + key.getKey());

        if(key.getKey() == Ui.KEY_MENU) { // key 13 lange gedrückt
          //Sys.println("menu gedrueckt");
             var conf_text = "Reset kcal?";
             var cd;
             cd = new Ui.Confirmation( conf_text );
             Ui.pushView( cd, new CD(), Ui.SLIDE_IMMEDIATE );
          //Sys.println("HISTORY und alles gelöscht!");
          return true;
          
        }       
       if(key.getKey() == Ui.KEY_ENTER) {
        //Ui.pushView(new Ui.TextPicker(lastText), new KeyboardListener_d(), Ui.SLIDE_DOWN );
        iscreen = iscreen + 1;
        if ( iscreen > 3 ) {iscreen = 1;}
        Ui.requestUpdate();
       }  
       return false;
    }
}

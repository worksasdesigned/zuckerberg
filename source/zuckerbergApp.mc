using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.Application as App;
using Toybox.Time.Gregorian as Gregorian;

var  seit_lastupdate; // history!
var last_update; // sekunden des letzten updates
var kcal_his; // history of kcal
var fenix_purble = 0x5500AA ;
var ncount, firstday;
enum
{
    LASTUPDATE,
    KCAL_HIS,
    COUNT_KEY,
    FIRSTDAY
}

hidden var COLORS = [
        Gfx.COLOR_WHITE,
        Gfx.COLOR_DK_GRAY,
        Gfx.COLOR_RED,
        Gfx.COLOR_GREEN,
        Gfx.COLOR_YELLOW,
        Gfx.COLOR_PINK,
        Gfx.COLOR_BLUE,
        Gfx.COLOR_LT_GRAY,        
        Gfx.COLOR_BLACK,
        Gfx.COLOR_DK_RED,
        Gfx.COLOR_DK_GREEN,
        Gfx.COLOR_ORANGE,
        fenix_purble,
        Gfx.COLOR_DK_BLUE
        ];

class zuckerbergApp extends App.AppBase {

    function onStart() {
        var last_update;
        var dateStrings = Time.Gregorian.info( Time.now(), Time.FORMAT_SHORT);
        var day,month,year;
        day    = dateStrings.day;
        month  = dateStrings.month;
        year   = dateStrings.year; 
        
        var app = App.getApp();
         ncount = app.getProperty(COUNT_KEY);
         
         // erster Tag der Auswertung speichern            
         firstday = app.getProperty(FIRSTDAY);
         //Sys.println(firstday);
         if (firstday == null) {
            var m_dateStrings = Time.Gregorian.info( Time.now(), Time.FORMAT_MEDIUM);
            var m_month =  m_dateStrings.month; 
            firstday = day.toString() + "." + m_month.toString() + "." + year.toString();
            app.setProperty(FIRSTDAY, firstday.toString());
         }
         if (ncount == null) {ncount = 1;} else{ ncount = ncount.toNumber() + 1;}
         
        //Sys.println("test" + nhis);
        // Last update auslesen
        last_update = app.getProperty(LASTUPDATE); // datum letztes Update
        // noch kein Update gemacht --> heute setzen
        if (last_update == null){
          last_update =  sec_calc({ 
                :year   => year.toNumber(),
                :month  => month.toNumber(),
                :day    => day.toNumber(),
                :hour   => 01,
                :minute => 01,
                :second => 01
                });
          //Sys.println("Last_update zum speichern=" + last_update);      
          app.setProperty(LASTUPDATE, last_update.toNumber());
        } 
        kcal_his = app.getProperty(KCAL_HIS);
        if (kcal_his == null) {kcal_his = 0;}
            
        var heute_sec   = Gregorian.now();
        heute_sec = heute_sec.value();
        seit_lastupdate  =  heute_sec - last_update.toNumber();
        seit_lastupdate = seit_lastupdate.toFloat() / 60 / 60 / 24; 
        seit_lastupdate = seit_lastupdate.toNumber();
        
        // jetzt noch letztes Update auf jetzt speichern
        last_update =  Gregorian.now();
        last_update = last_update.value();
        app.setProperty(LASTUPDATE, last_update.toNumber());
        //
        //Sys.println("seit lastupdate / 60...=" + seit_lastupdate);
        //seit_lastupdate = 5;
    }
    
    // in sekunden umrechnen
    function sec_calc(params){
        var secs = Gregorian.moment(params);
        secs = secs.value();
        return secs;
    }

    //! onStop() is called when your application is exiting
    function onStop() {
         var app = App.getApp();
         app.setProperty(KCAL_HIS, kcal_his);
         app.setProperty(COUNT_KEY, ncount);
    }
    

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new zuckerbergView(), new zuckerbergViewDelegate() ];
    }

}
#!/usr/bin/env python

import xmltodict, urllib2, argparse

class yweather:
    def __init__(self):
        # GLOBAL CONTANTS
        self.UNITS = ['F', 'c'] #c: all units Metric, f: all units US customary
        self.URL = 'http://xml.weather.yahoo.com/forecastrss?p='
        # User settings
        self.LOCID='28054' #Postal Code or Weather Location Code

    def args(self):
        parser = argparse.ArgumentParser(description='Weather Query from Yahoo!')
        parser.add_argument('-L', action="store", dest="locid", default=self.LOCID,
        help="Postal Code or Weather Location Code")
        return parser

    def main(self):
        results = self.args().parse_args()
        doc = xmltodict.parse(urllib2.urlopen(self.URL+results.locid+'&u=F').read())
        root = doc['rss']['channel']
        weatherinst = self.weather(root)
        print weatherinst.getCity()
    
    """Object form of the weather results from Yahoo"""
    class weather:
        
        """Object form of single day of forecast from Yahoo"""
        class forecast:
            
            def __init__(self,root):
                self.day = root["@day"]
                self.date = root["@date"]
                self.low = root["@low"]
                self.high = root["@high"]
                self.condition = root["@text"]
                self.conditioncode = root["@code"]
            
            def getDay(self):
                return self.day
            
            def getDate(self):
                return self.date
            
            def getLow(self):
                return self.low
            
            def getHigh(self):
                return self.high
            
            def getCondition(self):
                return self.condition
            
            def getCoditionCode(self):
                return self.conditioncode
    
        def __init__(self, root):
            self.city = root["yweather:location"]["@city"]
            self.region = root["yweather:location"]["@region"]
            self.country = root["yweather:location"]["@country"]
            self.unitstemp = root["yweather:units"]["@temperature"]
            self.unitsdist = root["yweather:units"]["@distance"]
            self.unitspres = root["yweather:units"]["@pressure"]
            self.unitsspeed = root["yweather:units"]["@speed"]
            self.windchill = root["yweather:wind"]["@chill"]
            self.winddir = root["yweather:wind"]["@direction"]
            self.windspeed = root["yweather:wind"]["@speed"]
            self.humidity = root["yweather:atmosphere"]["@humidity"]
            self.visibility = root["yweather:atmosphere"]["@visibility"]
            self.atmopres = root["yweather:atmosphere"]["@pressure"]
            self.atmorising = root["yweather:atmosphere"]["@rising"]
            self.sunrise = root["yweather:astronomy"]["@sunrise"]
            self.sunset = root["yweather:astronomy"]["@sunset"]
            self.currcond = root["item"]["yweather:condition"]["@text"]
            self.currcondcode = root["item"]["yweather:condition"]["@code"]
            self.currtemp = root["item"]["yweather:condition"]["@temp"]
            self.geolat = root["item"]["geo:lat"]
            self.geolong = root["item"]["geo:long"]
            self.today = self.forecast(root["item"][0])
            self.forecastday1 = self.forecast(root["item"][1])
            self.forecastday2 = self.forecast(root["item"][2])
            self.forecastday3 = self.forecast(root["item"][3])
            self.forecastday4 = self.forecast(root["item"][4])
        
        def getCountry(self):
            return self.country
        
        def getRegion(self):
            return self.region
        
        def getCity(self):
            return self.city
        
        def getUnitsTemperature(self):
            return self.unitstemp
        
        def getUnitsDistance(self):
            return self.unitsdist
        
        def getUnitsPressure(self):
            return self.unitspres
            
        def getUnitsSpeed(self):
            return self.unitsspeed

def main():
    yweatherinst = yweather()
    yweatherinst.main()

if __name__ == "__main__": main() 

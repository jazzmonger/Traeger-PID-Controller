This project is for an ESP32 Based Traeger Pellet Smoker/Grill controller.

The inspiration for much of this project came from the excellent work done be @Nebhead and the PiSmoker project (https://github.com/nebhead/PiFire) based on the Raspberry Pi.  While I respect the platform for what it is, I'm not a huge Raspberry Pi fan and I wanted something based on an ESP32 and ESPHome that would integrate seamlessly into Home Assistant. So,this project was born.

I started this project by writing a very complex and proprietary controller for a gigantic commercial Traeger COM200 3 burn pot pellet smoker.  It can smoke/cook up go 40 full size briskets. That project has a life of its own and had been very successful.  So I decided to take the literally hundreds of hours of work I put into that project and scale it down so it can be used on a single burn pot, generic Traeger style backyard pellet smoker/grill.  Some key attributes of this scaled down version:

- its written in ESPHome, so its easy to understand and modify
- it integrates seamlessly with Home Assistant and all functions are controllable via a LoveLace dashboard both on a PC and in the Home Assistant app.
- it emulates the existing new Trager controllers in all functions and adds several new functions
- it controls 1 auger, 1 hotrod & 1 fan found on the vast majority of pellet smokers
- it uses the existing PT1000 temperature sensor (can be adapted to a PT100)
- it adds a Smith-Predicting, PID temperature compensating control
- it controls the chamber temperature within approximately +/- 5F vs the +/- 25F for existing controllers 
- rotary encoder support so you can control your grill temp with a spinny knob
- it has an interactive, touch screen ili9341 display 
- it adds 3 optional configurable wired meat probes
- it allows dynamic configuration of ALL paramaters so it is infinitly tuneable to any pellet smoker
- it also allows for both touch screen control of all functions as well as optional individual buttons for control. 
- it adds an optional VL53L0X Time of Flight (TOF) Sensor sensor to measure hopper pellet levels

This is a work in progress. I'm not affilaiated with Traeger or any other BBQ or smoker company.  The design may or may not work with your gril, so, your mileage may vary.  The chip Im using in this design is an ESP32 D1 Mini.  Its small size,wide availability, and versatility makes it ideal for this use. You can probably use any ESP32 based drv board, but I cannot guarantee it will work.  My larger project uses an ESP32-S3 as I needed every single available GPIO on that chip, and then some. Plus I needed to use the ESP-IDF framework for that project and also needed PSRAM, hence the S3 based biard choice.

I will publish both schematics and circuit board designs as time permits. I may offer them for sale in the future as well.  




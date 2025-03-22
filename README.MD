This project is for an ESP32 Based Traeger Pellet Smoker/Grill controller.

I started the project writing a complex and proprietary controller for a gigsntic commercial COM200 3 burner Traeger smoker. It can smoke/cook up go 40 full size briskets. That project had a life of its own and had been very successful.  So I decided to take the literally hundreds of hours of work I put into that project and apply it to ising it on a generic Traeger backyard pellet smoker/grill.  Some key attributes:

- it emulates the existing new Trager controllers in all functions and adds several new functions
- it adds a Smith-Predicting, PID temperature compensating control
- it controls the chamber temperature within approximately +/- 5F vs the +/- 25F for existing controllers 
- it has an interactive touch screen ili9341 display 
- it adds 3 optional configurable wired meat probes
- it allows dynamic configuration of ALL paramaters so it is infinitly tuneable to any pellet smoket
- it integrates seamlessly with Home Assistant

This is a work in progress. I'm not affilaiated with Traeger or any other company.  The design may or may not work with your gril, so, your mileage may vary.  
the chip Im using in this design is an ESP32 D1 Mini.  Its small size makes it ideal for this use. 


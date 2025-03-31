This project is for a generic ESP32 Based Traeger Pellet Smoker/Grill controller that can be used on any smoker/grill that has an auger, hotrod and fan used for control. Full Home Assistant control completes it and the sky is the limit on what can be done with it using automations.  See my ESPHome Forums post for discussions https://community.home-assistant.io/t/generic-traeger-smoker-grill-controller/867494

![Image](https://github.com/user-attachments/assets/70b09003-f8f5-4c89-b655-66b821db657c)

The inspiration for much of this project came from the excellent work done be @Nebhead and the PiSmoker project (https://github.com/nebhead/PiFire) based on the Raspberry Pi. Their Discord channel is here https://discord.com/channels/1027346882156052550/1027348991135985796

While I respect the platform for what it is, I'm not a huge Raspberry Pi fan and I wanted something based on an ESP32 and ESPHome that would integrate seamlessly into Home Assistant. So, this project was born.
![Image](https://github.com/user-attachments/assets/69c675f4-6093-4a4e-b6c3-11c539b2dabf)

![Image](https://github.com/user-attachments/assets/15380ceb-184d-453d-b789-48c1be9da0f8)

Some key attributes of this scaled down version:

* its written in ESPHome, so its easy to understand and modify
* can be used standalone or with Home Assistant
* it integrates seamlessly with Home Assistant and all functions are controllable via a LoveLace dashboard both on a PC and in the Home Assistant app.
* it emulates the existing new Trager controllers in all functions and adds several new functions
* it controls 1 auger, 1 hotrod & 1 fan found on the vast majority of pellet smokers
* it uses solid state relays for control
* it uses the existing PT1000 temperature sensor (can be adapted to a PT100)
* it adds a Smith-Predicting, PID temperature compensating control
* it controls the chamber temperature within approximately +/- 5F vs the +/- 25F for existing controllers
* rotary encoder support so you can control your grill temp with a spinny knob
* it has an interactive, touch screen ili9341 display
* it adds 3 optional configurable wired meat probes
* it allows dynamic configuration of ALL paramaters so it is infinitly tuneable to any pellet smoker
* it also allows for both touch screen control of all functions as well as optional individual buttons for control.
* it adds an optional VL53L0X Time of Flight (TOF) Sensor sensor to measure hopper pellet levels
* Circuit board for scaled down versiinshould be approximately the same size as the Traeger controller allowing easy retrofit installation.

Outstanding temperature control even when opening the lid of the smoker.  Very little overshoot when adjusting temperatures (Smith Predictor).
Fully adjustable PID Params (advanced)
Lovelace Dashboards with animated icons for fans, auger & hotrod

This is a work in progress. I'm not affilaiated with Traeger or any other BBQ or smoker company. The design may or may not work with your gril, so, your mileage may vary. The chip Im using in this design is an ESP32 D1 Mini. Its small size,wide availability, and versatility makes it ideal for this use. You can probably use any ESP32 based dev board, but I cannot guarantee it will work. My larger project uses an ESP32-S3 as I needed every single available GPIO on that chip, and then some. Plus I needed to use the ESP-IDF framework for that project and also needed PSRAM, hence the S3 based board choice.

This project has been a ton of fun.  It's a couple thousand lines of ESPHome code so it's not a "beginner" project by any definition.  But if you study the code long enough, you'll begin to make sense of it all - that's what I love about ESPHome. It's easily approachable by novice users. 

Also, because this controller offers the ability to completely customize literally everything, it will take time for you to realize its full potential.  The PID tuning is especially complex, but after many days of testing, I've settled on PID value parameters that do a reasonable job of keeping the chamber temps within +/- 5F or so,  a far cry from the +/-25F of the current controllers. Adding the Smith Predictor to the PID controller eliminates overshoots from wide temperature changes. Many kudos must go to @dogtreatfairy for many hours spent helping me tune the PID controller.


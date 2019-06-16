# Writing your own extension

## Basic Coding Rules
Right now it's BASH only, unless you're figuring it out on your own.  

Simply take the following example and expand on it

```BASH
#!/usr/bin/env bash
# your script
function sfp-your-script(){
    echo hey
    return 0
}
```

The items of note here are the following:
* The she-bang at the first line is pretty much required
* A comment helps anyone know what file they are in. You can throw copyright+license here too
* Your script should have a function of the same name as the script (must be identical), which will be considered your main function
* Your script should be sourceable and *must do nothing* when it is sourced. Otherwise things are gonna get weird.
* Do *not* exit from your function, as it may quit all of sfp (or bash) -- instead use `return`

The script is supposed to do nothing when sourced to enable more effective debugging (for as much as you can debug BASH...)

## Basic Execution Rules
In order to get your executable showing to sfp's front-end, do the following:
* Make your file executable
* Name it like "sfp-letters-and-hyphens" (matches `^sfp-[-a-Z]*$`, no trailing '.sh' or other file extension)
* Add your executable to your path
* Run sfp to see it magically show up or ask for help / file a bug

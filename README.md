This is Apple's Custom HTTP Protocol with a few key differences. 

* The project has been converted to use ARC
* AppDelegate has been cleaned up a lot (Removed logging code, nested ifs, unnecessary comments ect). 


How to build:

    Prerequisists Programs:
        Git (used: version 2.0.1, other versions should be compatible)
        XCode 5 IDE

    Retrieving source in terminal:
        git clone <REPO URL> <FOLDER NAME>
        cd <FOLDER NAME>
        git submodule update --init --recursive

    Running the project
        Open and run .xcodeproject with the simulator or device as the target platform